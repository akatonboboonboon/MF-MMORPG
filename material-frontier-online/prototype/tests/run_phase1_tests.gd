extends SceneTree

var _failures: Array[String] = []
var _captured_events: Array[Phase1DomainEvent] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_test_action_definition()
	_test_hit_query_pool()
	_test_input_adapter()
	await _test_vertical_path()
	if _failures.is_empty():
		print("[MFO-P1-TEST] PASS: all Phase 1 tests")
		quit(0)
	else:
		for failure in _failures:
			push_error("[MFO-P1-TEST] %s" % failure)
		quit(1)


func _test_action_definition() -> void:
	var definition := load("res://data/phase1/actions/attack_a.tres") as Phase1ActionDefinition
	_check(definition != null, "attack A definition loads")
	if definition == null:
		return
	_check(definition.validate().is_empty(), "attack A definition validates")
	_check(definition.max_concurrent_hit_queries == 1, "attack A declares its own query limit")


func _test_hit_query_pool() -> void:
	var pool := Phase1HitQueryPool.new()
	pool.configure(1)
	var first := pool.try_reserve(&"test.attack")
	var saturated := pool.try_reserve(&"test.attack")
	_check(first != Phase1HitQueryPool.INVALID_TOKEN, "player-critical query can be reserved")
	_check(saturated == Phase1HitQueryPool.INVALID_TOKEN, "per-action concurrency is enforced")
	_check(pool.active_count() == 1, "active query count is authoritative")
	_check(pool.release(first), "reserved query is returned")
	_check(pool.active_count() == 0, "active query count returns to zero")


func _test_input_adapter() -> void:
	var adapter := Phase1InputAdapter.new()
	adapter.ensure_input_map()
	var attack_event_count := InputMap.action_get_events(Phase1InputAdapter.ACTION_ATTACK_A).size()
	adapter.ensure_input_map()
	_check(
		InputMap.action_get_events(Phase1InputAdapter.ACTION_ATTACK_A).size() == attack_event_count,
		"input map setup is idempotent"
	)
	_check(_has_mouse_button(Phase1InputAdapter.ACTION_ATTACK_A, MOUSE_BUTTON_LEFT), "attack A maps left mouse")
	_check(_has_joy_button(Phase1InputAdapter.ACTION_ATTACK_A, JOY_BUTTON_X), "attack A maps gamepad X")
	_check(_has_joy_motion(Phase1InputAdapter.ACTION_MOVE_LEFT, JOY_AXIS_LEFT_X, -1.0), "movement maps left stick")
	_check(_has_joy_motion(Phase1InputAdapter.ACTION_AIM_RIGHT, JOY_AXIS_RIGHT_X, 1.0), "aim maps right stick")
	_check(_has_joy_motion(Phase1InputAdapter.ACTION_MAGIC_MODIFIER, JOY_AXIS_TRIGGER_LEFT, 1.0), "magic modifier maps LT")
	_check(_has_joy_button(Phase1InputAdapter.ACTION_MAGIC_1, JOY_BUTTON_X), "magic 1 reserves LT+X chord button")

	Input.action_press(Phase1InputAdapter.ACTION_AIM_RIGHT, 1.0)
	var stick_command := adapter.capture_command(Vector2.ZERO, Vector2(0.0, 100.0), Vector2.UP)
	Input.action_release(Phase1InputAdapter.ACTION_AIM_RIGHT)
	var neutral_command := adapter.capture_command(Vector2.ZERO, Vector2(0.0, 100.0), stick_command.aim_vector)
	_check(stick_command.aim_vector.is_equal_approx(Vector2.RIGHT), "right stick controls aim")
	_check(neutral_command.aim_vector.is_equal_approx(Vector2.RIGHT), "neutral stick retains gamepad aim")
	var mouse_motion := InputEventMouseMotion.new()
	mouse_motion.relative = Vector2(4.0, 0.0)
	adapter._input(mouse_motion)
	var mouse_command := adapter.capture_command(Vector2.ZERO, Vector2(0.0, 100.0), neutral_command.aim_vector)
	_check(mouse_command.aim_vector.is_equal_approx(Vector2.DOWN), "actual mouse motion takes aim ownership")
	adapter.free()


func _test_vertical_path() -> void:
	var packed := load("res://scenes/phase1/phase1_arena.tscn") as PackedScene
	_check(packed != null, "phase1 arena loads")
	if packed == null:
		return
	var arena := packed.instantiate() as Phase1Arena
	arena.live_input_enabled = false
	root.add_child(arena)
	await process_frame
	await physics_frame
	var simulation := arena.get_node("LocalAuthoritySimulation") as Phase1LocalAuthoritySimulation
	var player := arena.get_node("PlayerActor") as Phase1PlayerActor
	var target := arena.get_node("TargetDummy") as Phase1TargetDummy
	var guardrails := arena.get_node("RuntimeGuardrails") as Phase1RuntimeGuardrailValidator
	_check(simulation.definitions_are_valid(), "startup definition validation passes")
	_check(simulation.metrics().visible_players == 1, "authority owns a one-entry actor collection")
	_check(not guardrails.has_violations(), "active Phase 1 scope has no RuntimeHardLimit violations")
	_check(guardrails.summary().results.size() == 3, "all three RuntimeHardLimit records are emitted")
	_captured_events.clear()
	simulation.domain_event_emitted.connect(_capture_domain_event)

	var start := player.global_position
	var move_tick := 41001
	var move_command := Phase1InputCommand.create(1001, move_tick, Vector2.RIGHT, Vector2.RIGHT, false, player.entity_id)
	simulation.step(move_command, 1.0 / 60.0)
	_check(player.global_position.x > start.x, "injected command moves the player")
	_check(player.aim_direction.is_equal_approx(Vector2.RIGHT), "aim remains independent and normalized")
	_check(move_command.move_vector.length() <= 1.0, "command movement is normalized")
	var movement_event := _latest_event(&"MovementApplied")
	_check(movement_event != null and movement_event.physics_tick == move_tick, "domain event preserves command tick")

	var position_before_rejection := player.global_position
	var rejected_command := Phase1InputCommand.create(
		1002,
		41002,
		Vector2.LEFT,
		Vector2.RIGHT,
		false,
		&"actor.missing"
	)
	simulation.step(rejected_command, 1.0 / 60.0)
	_check(player.global_position.is_equal_approx(position_before_rejection), "unknown actor command cannot move the player")
	_check(_latest_event(&"CommandRejected") != null, "unknown actor command is auditable")

	player.global_position = Vector2(1160.0, 540.0)
	await physics_frame
	var attack_tick := 41003
	var attack_command := Phase1InputCommand.create(
		1003,
		attack_tick,
		Vector2.ZERO,
		Vector2.RIGHT,
		true,
		player.entity_id,
		target.entity_id
	)
	simulation.step(attack_command, 1.0 / 60.0)
	_check(target.hit_count == 1, "attack A hits the target exactly once")
	_check(simulation.metrics().active_hit_queries == 0, "hit query is returned after resolution")
	var hit_event := _latest_event(&"HitConfirmed")
	_check(hit_event != null and hit_event.physics_tick == attack_tick, "hit event uses the authoritative command tick")
	_check(
		hit_event != null and hit_event.payload.get("target_entity_id") == target.entity_id,
		"hit result carries stable target entity id"
	)

	var wrong_target_command := Phase1InputCommand.create(
		1004,
		41004,
		Vector2.ZERO,
		Vector2.RIGHT,
		true,
		player.entity_id,
		&"target.other"
	)
	simulation.step(wrong_target_command, 1.0 / 60.0)
	_check(target.hit_count == 1, "explicitly mismatched target id cannot be hit")
	var away_command := Phase1InputCommand.create(
		1005,
		41005,
		Vector2.ZERO,
		Vector2.LEFT,
		true,
		player.entity_id
	)
	simulation.step(away_command, 1.0 / 60.0)
	_check(target.hit_count == 1, "attack aimed away from target cannot hit")
	arena.queue_free()
	await process_frame
	_captured_events.clear()


func _capture_domain_event(event: Phase1DomainEvent) -> void:
	_captured_events.append(event)


func _latest_event(name: StringName) -> Phase1DomainEvent:
	for index in range(_captured_events.size() - 1, -1, -1):
		if _captured_events[index].event_name == name:
			return _captured_events[index]
	return null


func _has_mouse_button(action: StringName, button_index: int) -> bool:
	for event in InputMap.action_get_events(action):
		var mouse := event as InputEventMouseButton
		if mouse != null and mouse.button_index == button_index:
			return true
	return false


func _has_joy_button(action: StringName, button_index: int) -> bool:
	for event in InputMap.action_get_events(action):
		var button := event as InputEventJoypadButton
		if button != null and button.button_index == button_index:
			return true
	return false


func _has_joy_motion(action: StringName, axis: int, axis_value: float) -> bool:
	for event in InputMap.action_get_events(action):
		var motion := event as InputEventJoypadMotion
		if motion != null and motion.axis == axis and is_equal_approx(motion.axis_value, axis_value):
			return true
	return false


func _check(condition: bool, description: String) -> void:
	if condition:
		print("[MFO-P1-TEST] PASS: %s" % description)
	else:
		_failures.append(description)
