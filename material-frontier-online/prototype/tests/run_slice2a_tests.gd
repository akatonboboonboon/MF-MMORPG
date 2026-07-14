extends SceneTree

const FIXED_DELTA := 1.0 / 60.0
const POSITION_TOLERANCE_PX := 0.1
const TIME_TOLERANCE_SECONDS := 0.00001
const PLAYER_ID := &"actor.player.local.1"

var _failures: Array[String] = []
var _assertion_count := 0
var _captured_events: Array[Phase1DomainEvent] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	await _test_input_request_mapping()
	await _test_authority_behavior()
	if _failures.is_empty():
		print("[MFO-P2-2A-TEST] PASS: %d assertions" % _assertion_count)
		quit(0)
	else:
		for failure in _failures:
			push_error("[MFO-P2-2A-TEST] %s" % failure)
		print("[MFO-P2-2A-TEST] FAIL: %d / %d assertions failed" % [
			_failures.size(),
			_assertion_count,
		])
		quit(1)


func _test_input_request_mapping() -> void:
	var adapter := Phase1InputAdapter.new()
	root.add_child(adapter)
	adapter.ensure_input_map()
	var evade_event_count := InputMap.action_get_events(Phase1InputAdapter.ACTION_EVADE).size()
	adapter.ensure_input_map()
	_check(
		InputMap.action_get_events(Phase1InputAdapter.ACTION_EVADE).size() == evade_event_count,
		"evade input mapping setup remains idempotent"
	)
	_check(_has_key(Phase1InputAdapter.ACTION_EVADE, KEY_SPACE), "evade maps keyboard Space")
	_check(_has_joy_button(Phase1InputAdapter.ACTION_EVADE, JOY_BUTTON_A), "evade maps gamepad A")
	_check(_has_key(Phase1InputAdapter.ACTION_LOCK_ON, KEY_Q), "reserved lock-on keeps keyboard Q")
	_check(
		_has_joy_button(Phase1InputAdapter.ACTION_LOCK_ON, JOY_BUTTON_LEFT_SHOULDER),
		"reserved lock-on keeps gamepad LB"
	)

	Input.action_release(Phase1InputAdapter.ACTION_EVADE)
	await process_frame
	Input.action_press(Phase1InputAdapter.ACTION_EVADE)
	var fresh_command := adapter.capture_command(Vector2.ZERO, Vector2.RIGHT * 100.0, Vector2.RIGHT)
	_check(fresh_command.evade_requested, "fresh abstract evade press is captured as a request")
	_check(fresh_command.actor_entity_id == PLAYER_ID, "captured evade request keeps the stable local actor ID")
	await process_frame
	await process_frame
	var held_command := adapter.capture_command(Vector2.ZERO, Vector2.RIGHT * 100.0, Vector2.RIGHT)
	_check(not held_command.evade_requested, "held evade input does not repeat the fresh-press request")
	Input.action_release(Phase1InputAdapter.ACTION_EVADE)
	await process_frame
	Input.action_release(Phase1InputAdapter.ACTION_MOVE_RIGHT)
	await process_frame
	var move_deadzone := InputMap.action_get_deadzone(Phase1InputAdapter.ACTION_MOVE_RIGHT)
	var deadzone_edge_strength := move_deadzone + (1.0 - move_deadzone) * 0.005
	Input.action_press(Phase1InputAdapter.ACTION_MOVE_RIGHT, deadzone_edge_strength)
	var deadzone_edge_command := adapter.capture_command(
		Vector2.ZERO,
		Vector2.UP * 100.0,
		Vector2.UP
	)
	_check(
		deadzone_edge_command.move_vector.length_squared() > 0.0
			and deadzone_edge_command.move_vector.length() <= 0.01,
		"input adapter can emit a small nonzero move vector just above its deadzone"
	)
	Input.action_release(Phase1InputAdapter.ACTION_MOVE_RIGHT)
	await process_frame
	adapter.queue_free()
	await process_frame


func _test_authority_behavior() -> void:
	var packed := load("res://scenes/phase1/phase1_arena.tscn") as PackedScene
	_check(packed != null, "Slice 2-A test arena loads")
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
	_check(simulation != null and simulation.definitions_are_valid(), "authority simulation is configured")
	_check(player != null, "configured player actor is available")
	_check(target != null, "Phase 1 target remains available")
	if simulation == null or player == null or target == null:
		arena.queue_free()
		await process_frame
		return

	_captured_events.clear()
	simulation.domain_event_emitted.connect(_capture_domain_event)
	var configured_start := player.global_position
	var configured_aim := player.aim_direction

	_test_eight_direction_movement_and_aim(simulation, player)
	_test_small_nonzero_move_priority(simulation, player)
	_test_move_direction_step(simulation, player, configured_start)
	_test_diagonal_step(simulation, player, configured_start)
	_test_aim_fallback_step(simulation, player, configured_start)
	_test_rejection_and_reuse_boundary(simulation, player, configured_start)
	await _test_collision_limit(simulation, player, arena, configured_start)
	_test_bounds_limit(simulation, player)
	_test_reset_seam(simulation, player, target, configured_start, configured_aim)
	_test_invalid_actor_audit(simulation, player)

	arena.queue_free()
	await process_frame
	_captured_events.clear()


func _test_eight_direction_movement_and_aim(
	simulation: Phase1LocalAuthoritySimulation,
	player: Phase1PlayerActor
) -> void:
	_check(simulation.reset_actor_to_start(PLAYER_ID), "8-direction movement case resets to configured start")
	var directions: Array[Vector2] = [
		Vector2.RIGHT,
		Vector2(1.0, 1.0),
		Vector2.DOWN,
		Vector2(-1.0, 1.0),
		Vector2.LEFT,
		Vector2(-1.0, -1.0),
		Vector2.UP,
		Vector2(1.0, -1.0),
	]
	var expected_distance := player.move_speed * FIXED_DELTA
	for index in range(directions.size()):
		simulation.reset_actor_to_start(PLAYER_ID)
		var start := player.global_position
		var move := directions[index]
		var expected_direction := move.normalized()
		var independent_aim := expected_direction.rotated(PI / 2.0)
		simulation.step(
			_command(1800 + index, 51800 + index, move, independent_aim, false),
			FIXED_DELTA
		)
		var displacement := player.global_position - start
		_check(
			absf(displacement.length() - expected_distance) <= POSITION_TOLERANCE_PX,
			"8-direction sample %d preserves normalized movement speed" % index
		)
		_check(
			displacement.normalized().is_equal_approx(expected_direction),
			"8-direction sample %d preserves movement direction" % index
		)
		_check(
			player.aim_direction.is_equal_approx(independent_aim),
			"8-direction sample %d preserves independent aim" % index
		)


func _test_small_nonzero_move_priority(
	simulation: Phase1LocalAuthoritySimulation,
	player: Phase1PlayerActor
) -> void:
	_check(simulation.reset_actor_to_start(PLAYER_ID), "small-nonzero case resets full evade state")
	var small_nonzero_move := Vector2(0.005, 0.0)
	var command := _command(1900, 51900, small_nonzero_move, Vector2.UP, true)
	_check(
		command.move_vector.is_equal_approx(small_nonzero_move),
		"InputCommand preserves a small nonzero movement request"
	)
	simulation.step(command, FIXED_DELTA)
	_check(
		(player.debug_evade_state().direction as Vector2).is_equal_approx(Vector2.RIGHT),
		"accepted evade prioritizes every nonzero movement input over aim fallback"
	)


func _test_move_direction_step(
	simulation: Phase1LocalAuthoritySimulation,
	player: Phase1PlayerActor,
	configured_start: Vector2
) -> void:
	_check(simulation.reset_actor_to_start(PLAYER_ID), "move-direction case resets to configured start")
	var start := player.global_position
	var first := _command(2000, 52000, Vector2.RIGHT, Vector2.UP, true)
	_check(first.move_vector.is_equal_approx(Vector2.RIGHT), "evade command preserves normalized move direction")
	simulation.step(first, FIXED_DELTA)
	var state_after_start := player.debug_evade_state()
	_check(state_after_start.active, "fresh valid evade request is accepted by authority")
	_check(
		(state_after_start.direction as Vector2).is_equal_approx(Vector2.RIGHT),
		"accepted evade latches movement direction before aim fallback"
	)
	_check(
		is_equal_approx(float(state_after_start.elapsed_seconds), FIXED_DELTA),
		"accepted evade advances exactly one fixed tick on its start command"
	)

	for offset in range(1, 11):
		simulation.step(
			_command(2000 + offset, 52000 + offset, Vector2.LEFT, Vector2.UP, false),
			FIXED_DELTA
		)
	_check(player.debug_evade_state().active, "evade remains active through nominal tick 11 of 12")
	_check(
		(player.debug_evade_state().direction as Vector2).is_equal_approx(Vector2.RIGHT),
		"aim changes during an active step do not redirect its latched movement direction"
	)
	simulation.step(_command(2011, 52011, Vector2.LEFT, Vector2.UP, false), FIXED_DELTA)
	var final_state := player.debug_evade_state()
	var displacement := player.global_position - start
	_check(not final_state.active, "evade ends on nominal active tick 12")
	_check(
		absf(displacement.length() - 140.0) <= POSITION_TOLERANCE_PX,
		"collision-free evade travels 140 px within QA tolerance"
	)
	_check(
		absf(displacement.y) <= POSITION_TOLERANCE_PX and displacement.x > 0.0,
		"ordinary opposite movement does not alter active step direction"
	)
	_check(
		absf(float(final_state.elapsed_seconds) - 0.20) <= TIME_TOLERANCE_SECONDS,
		"evade active duration records 0.20 seconds"
	)
	_check(player.aim_direction.is_equal_approx(Vector2.UP), "aim remains independently updateable during evade")
	var completed_position := player.global_position
	simulation.step(_command(2012, 52012, Vector2.LEFT, Vector2.UP, false), FIXED_DELTA)
	_check(player.global_position.x < completed_position.x, "ordinary movement resumes after evade completion")
	_check(
		configured_start.is_equal_approx(start),
		"move-direction test uses the captured same-arena start"
	)


func _test_diagonal_step(
	simulation: Phase1LocalAuthoritySimulation,
	player: Phase1PlayerActor,
	_configured_start: Vector2
) -> void:
	_check(simulation.reset_actor_to_start(PLAYER_ID), "diagonal case resets full evade state")
	var start := player.global_position
	for offset in range(12):
		simulation.step(
			_command(2100 + offset, 52100 + offset, Vector2(1.0, 1.0), Vector2.RIGHT, offset == 0),
			FIXED_DELTA
		)
	var displacement := player.global_position - start
	_check(
		absf(displacement.length() - 140.0) <= POSITION_TOLERANCE_PX,
		"normalized diagonal evade has the same 140 px travel"
	)
	_check(
		absf(displacement.x - displacement.y) <= POSITION_TOLERANCE_PX,
		"diagonal evade components remain normalized and symmetric"
	)


func _test_aim_fallback_step(
	simulation: Phase1LocalAuthoritySimulation,
	player: Phase1PlayerActor,
	_configured_start: Vector2
) -> void:
	_check(simulation.reset_actor_to_start(PLAYER_ID), "aim-fallback case resets full evade state")
	var start := player.global_position
	for offset in range(12):
		simulation.step(
			_command(2200 + offset, 52200 + offset, Vector2.ZERO, Vector2.UP, offset == 0),
			FIXED_DELTA
		)
	var displacement := player.global_position - start
	_check(
		absf(displacement.length() - 140.0) <= POSITION_TOLERANCE_PX,
		"neutral-move aim-fallback evade travels 140 px"
	)
	_check(
		absf(displacement.x) <= POSITION_TOLERANCE_PX and displacement.y < 0.0,
		"neutral move latches the command aim as evade direction"
	)


func _test_rejection_and_reuse_boundary(
	simulation: Phase1LocalAuthoritySimulation,
	player: Phase1PlayerActor,
	_configured_start: Vector2
) -> void:
	_check(simulation.reset_actor_to_start(PLAYER_ID), "rejection case resets full evade state")
	var start := player.global_position
	simulation.step(_command(2300, 52300, Vector2.RIGHT, Vector2.RIGHT, true), FIXED_DELTA)
	var elapsed_after_first := float(player.debug_evade_state().elapsed_seconds)
	simulation.step(_command(2301, 52301, Vector2.LEFT, Vector2.LEFT, true), FIXED_DELTA)
	var active_reject_state := player.debug_evade_state()
	_check(
		(active_reject_state.direction as Vector2).is_equal_approx(Vector2.RIGHT),
		"request during active interval does not restart or redirect evade"
	)
	_check(
		float(active_reject_state.elapsed_seconds) > elapsed_after_first,
		"active rejection does not reset evade progress"
	)

	for offset in range(2, 27):
		simulation.step(
			_command(2300 + offset, 52300 + offset, Vector2.ZERO, Vector2.LEFT, true),
			FIXED_DELTA
		)
	var tick_26_state := player.debug_evade_state()
	_check(not tick_26_state.active, "requests through start offset tick 26 remain rejected")
	_check(
		player.global_position.distance_to(start + Vector2.RIGHT * 140.0) <= POSITION_TOLERANCE_PX,
		"rejected active and reuse requests do not add travel"
	)
	simulation.step(_command(2327, 52327, Vector2.ZERO, Vector2.LEFT, false), FIXED_DELTA)
	_check(not player.debug_evade_state().active, "rejected request is not buffered into the ready tick")

	_check(simulation.reset_actor_to_start(PLAYER_ID), "reuse-boundary case resets full evade state")
	simulation.step(_command(2400, 52400, Vector2.RIGHT, Vector2.RIGHT, true), FIXED_DELTA)
	for offset in range(1, 27):
		simulation.step(
			_command(2400 + offset, 52400 + offset, Vector2.ZERO, Vector2.RIGHT, false),
			FIXED_DELTA
		)
	_check(not player.debug_evade_state().active, "reuse is idle immediately before a new tick-27 request")
	simulation.step(_command(2427, 52427, Vector2.LEFT, Vector2.LEFT, true), FIXED_DELTA)
	var tick_27_state := player.debug_evade_state()
	_check(tick_27_state.active, "fresh request at start-to-start tick 27 is accepted")
	_check(
		(tick_27_state.direction as Vector2).is_equal_approx(Vector2.LEFT),
		"tick-27 accepted request latches its own fresh direction"
	)


func _test_collision_limit(
	simulation: Phase1LocalAuthoritySimulation,
	player: Phase1PlayerActor,
	arena: Phase1Arena,
	_configured_start: Vector2
) -> void:
	_check(simulation.reset_actor_to_start(PLAYER_ID), "collision case resets full evade state")
	var original_mask := player.collision_mask
	player.collision_mask = 4
	var obstacle := StaticBody2D.new()
	obstacle.collision_layer = 4
	obstacle.collision_mask = 0
	var shape_node := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(20.0, 160.0)
	shape_node.shape = rectangle
	obstacle.add_child(shape_node)
	arena.add_child(obstacle)
	var start := player.global_position
	obstacle.global_position = start + Vector2(80.0, 0.0)
	await physics_frame
	for offset in range(12):
		simulation.step(
			_command(2500 + offset, 52500 + offset, Vector2.RIGHT, Vector2.RIGHT, offset == 0),
			FIXED_DELTA
		)
	var travel := player.global_position.distance_to(start)
	var player_circle := (player.get_node("CollisionShape2D") as CollisionShape2D).shape as CircleShape2D
	var expected_contact_travel := (
		obstacle.global_position.x
		- start.x
		- player_circle.radius
		- rectangle.size.x / 2.0
	)
	_check(travel < 140.0 - POSITION_TOLERANCE_PX, "runtime gameplay collision shortens evade travel")
	_check(
		absf(travel - expected_contact_travel) <= POSITION_TOLERANCE_PX,
		"collision-limited evade reaches the expected swept-shape contact point"
	)
	_check(
		player.global_position.x <= obstacle.global_position.x - 35.0,
		"evade does not penetrate the QA collision fixture"
	)
	_check(not player.debug_evade_state().active, "collision-limited evade still ends after 12 active ticks")
	_check(
		absf(float(player.debug_evade_state().elapsed_seconds) - 0.20) <= TIME_TOLERANCE_SECONDS,
		"collision-limited evade preserves the approved 0.20 s active duration"
	)
	player.collision_mask = original_mask
	obstacle.queue_free()
	await physics_frame


func _test_bounds_limit(
	simulation: Phase1LocalAuthoritySimulation,
	player: Phase1PlayerActor
) -> void:
	_check(simulation.reset_actor_to_start(PLAYER_ID), "bounds case resets full evade state")
	var bound_end_x := player.movement_bounds.end.x
	player.global_position = Vector2(bound_end_x - 20.0, player.global_position.y)
	var start := player.global_position
	for offset in range(12):
		simulation.step(
			_command(2600 + offset, 52600 + offset, Vector2.RIGHT, Vector2.RIGHT, offset == 0),
			FIXED_DELTA
		)
	_check(
		player.global_position.x <= bound_end_x + POSITION_TOLERANCE_PX,
		"evade does not cross the configured gameplay bound"
	)
	_check(
		player.global_position.distance_to(start) < 140.0 - POSITION_TOLERANCE_PX,
		"configured gameplay bound shortens outward evade travel"
	)
	_check(
		absf(player.global_position.x - bound_end_x) <= POSITION_TOLERANCE_PX
			and absf(player.global_position.y - start.y) <= POSITION_TOLERANCE_PX,
		"bounds-limited evade reaches but does not cross the configured edge"
	)
	_check(not player.debug_evade_state().active, "bounds-limited evade still ends after 12 active ticks")


func _test_reset_seam(
	simulation: Phase1LocalAuthoritySimulation,
	player: Phase1PlayerActor,
	target: Phase1TargetDummy,
	configured_start: Vector2,
	configured_aim: Vector2
) -> void:
	_check(simulation.reset_actor_to_start(PLAYER_ID), "reset case begins from configured state")
	var target_hits_before := target.hit_count
	simulation.step(_command(2700, 52700, Vector2.DOWN, Vector2.DOWN, true), FIXED_DELTA)
	_check(player.debug_evade_state().active, "reset case enters an active evade")
	_check(player.global_position != configured_start, "active evade mutates position before reset")
	_check(simulation.reset_actor_to_start(PLAYER_ID), "explicit authority reset succeeds for configured actor")
	var reset_state := player.debug_evade_state()
	_check(player.global_position.is_equal_approx(configured_start), "reset restores configured start position")
	_check(player.aim_direction.is_equal_approx(configured_aim), "reset restores configured initial aim")
	_check(player.velocity.is_zero_approx(), "reset restores zero velocity")
	_check(not reset_state.active, "reset clears active evade state")
	_check((reset_state.direction as Vector2).is_zero_approx(), "reset clears latched evade direction")
	_check(
		absf(float(reset_state.elapsed_seconds)) <= TIME_TOLERANCE_SECONDS,
		"reset clears evade elapsed progress"
	)
	_check(
		absf(float(reset_state.reuse_remaining_seconds)) <= TIME_TOLERANCE_SECONDS,
		"reset clears evade reuse timing"
	)
	_check(target.hit_count == target_hits_before, "reset does not execute the provisional attack")
	_check(simulation.reset_actor_to_start(PLAYER_ID), "repeated explicit authority reset succeeds")
	_check(player.global_position.is_equal_approx(configured_start), "repeated reset remains position-idempotent")
	_check(player.aim_direction.is_equal_approx(configured_aim), "repeated reset remains aim-idempotent")

	for offset in range(12):
		simulation.step(
			_command(2710 + offset, 52710 + offset, Vector2.DOWN, Vector2.LEFT, offset == 0),
			FIXED_DELTA
		)
	var cooldown_state := player.debug_evade_state()
	_check(not cooldown_state.active, "mid-cooldown reset case first completes its active step")
	_check(
		float(cooldown_state.reuse_remaining_seconds) > TIME_TOLERANCE_SECONDS,
		"mid-cooldown reset case retains a nonzero reuse lock before reset"
	)
	_check(simulation.reset_actor_to_start(PLAYER_ID), "explicit authority reset succeeds during cooldown")
	var cooldown_reset_state := player.debug_evade_state()
	_check(player.global_position.is_equal_approx(configured_start), "mid-cooldown reset restores start position")
	_check(player.aim_direction.is_equal_approx(configured_aim), "mid-cooldown reset restores initial aim")
	_check(player.velocity.is_zero_approx(), "mid-cooldown reset restores zero velocity")
	_check(not cooldown_reset_state.active, "mid-cooldown reset leaves evade inactive")
	_check(
		absf(float(cooldown_reset_state.reuse_remaining_seconds)) <= TIME_TOLERANCE_SECONDS,
		"mid-cooldown reset clears the residual reuse lock"
	)

	simulation.step(_command(2701, 52701, Vector2.LEFT, Vector2.LEFT, true), FIXED_DELTA)
	_check(player.debug_evade_state().active, "fresh valid evade is immediately accepted after reset")
	_check(simulation.reset_actor_to_start(PLAYER_ID), "post-reset acceptance case returns to start")
	simulation.step(_command(2702, 52702, Vector2.RIGHT, Vector2.UP, false), FIXED_DELTA)
	var ordinary_position := player.global_position
	_check(ordinary_position != configured_start, "ordinary simulation step moves away from configured start")
	for offset in range(3):
		simulation.step(
			_command(2703 + offset, 52703 + offset, Vector2.ZERO, Vector2.UP, false),
			FIXED_DELTA
		)
	_check(
		player.global_position.is_equal_approx(ordinary_position),
		"neutral ticks and cached aim never trigger authority reset automatically"
	)
	_check(player.aim_direction.is_equal_approx(Vector2.UP), "cached aim remains independent of reset activation")


func _test_invalid_actor_audit(
	simulation: Phase1LocalAuthoritySimulation,
	player: Phase1PlayerActor
) -> void:
	_check(simulation.reset_actor_to_start(PLAYER_ID), "invalid-actor case resets configured actor")
	_captured_events.clear()
	var before_position := player.global_position
	var before_aim := player.aim_direction
	var before_evade := player.debug_evade_state().duplicate(true)
	var bad_sequence := 2800
	var bad_tick := 52800
	simulation.step(
		_command(
			bad_sequence,
			bad_tick,
			Vector2.RIGHT,
			Vector2.DOWN,
			true,
			&"actor.missing.slice2a"
		),
		FIXED_DELTA
	)
	_check(player.global_position.is_equal_approx(before_position), "unknown actor command cannot mutate position")
	_check(player.aim_direction.is_equal_approx(before_aim), "unknown actor command cannot mutate aim")
	_check(player.debug_evade_state() == before_evade, "unknown actor command cannot mutate evade runtime state")
	var rejected := _latest_event(&"CommandRejected")
	_check(rejected != null, "unknown actor command remains auditable")
	_check(rejected != null and rejected.command_sequence == bad_sequence, "rejection preserves command sequence")
	_check(rejected != null and rejected.physics_tick == bad_tick, "rejection preserves command physics tick")
	_check(
		rejected != null and rejected.payload.get("actor_entity_id") == &"actor.missing.slice2a",
		"rejection preserves the unknown stable actor ID"
	)
	_check(not simulation.reset_actor_to_start(&"actor.missing.slice2a"), "unknown actor reset is rejected")
	_check(player.global_position.is_equal_approx(before_position), "unknown actor reset cannot mutate configured actor")


func _command(
	sequence: int,
	tick: int,
	move: Vector2,
	aim: Vector2,
	request_evade: bool,
	actor_id: StringName = PLAYER_ID
) -> Phase1InputCommand:
	return Phase1InputCommand.create(
		sequence,
		tick,
		move,
		aim,
		false,
		actor_id,
		&"",
		request_evade
	)


func _capture_domain_event(event: Phase1DomainEvent) -> void:
	_captured_events.append(event)


func _latest_event(name: StringName) -> Phase1DomainEvent:
	for index in range(_captured_events.size() - 1, -1, -1):
		if _captured_events[index].event_name == name:
			return _captured_events[index]
	return null


func _has_key(action: StringName, physical_keycode: int) -> bool:
	for event in InputMap.action_get_events(action):
		var key := event as InputEventKey
		if key != null and key.physical_keycode == physical_keycode:
			return true
	return false


func _has_joy_button(action: StringName, button_index: int) -> bool:
	for event in InputMap.action_get_events(action):
		var button := event as InputEventJoypadButton
		if button != null and button.button_index == button_index:
			return true
	return false


func _check(condition: bool, description: String) -> void:
	_assertion_count += 1
	if condition:
		print("[MFO-P2-2A-TEST] PASS: %s" % description)
	else:
		_failures.append(description)
