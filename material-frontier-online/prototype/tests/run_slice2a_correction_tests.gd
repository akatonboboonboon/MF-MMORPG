extends SceneTree

const FIXED_DELTA := 1.0 / 60.0
const SMALL_NONZERO := 0.005
const PLAYER_ID := &"actor.player.local.1"

var _failures: Array[String] = []
var _assertion_count := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	await _test_authority_direction_selection()
	_test_actor_direction_guard()
	if _failures.is_empty():
		print("[MFO-P2-2A-CORRECTION-TEST] PASS: %d assertions" % _assertion_count)
		quit(0)
	else:
		for failure in _failures:
			push_error("[MFO-P2-2A-CORRECTION-TEST] %s" % failure)
		print("[MFO-P2-2A-CORRECTION-TEST] FAIL: %d / %d assertions failed" % [
			_failures.size(),
			_assertion_count,
		])
		quit(1)


func _test_authority_direction_selection() -> void:
	var packed := load("res://scenes/phase1/phase1_arena.tscn") as PackedScene
	_check(packed != null, "correction test arena loads")
	if packed == null:
		return
	var arena := packed.instantiate() as Phase1Arena
	arena.live_input_enabled = false
	root.add_child(arena)
	await process_frame
	await physics_frame

	var simulation := arena.get_node("LocalAuthoritySimulation") as Phase1LocalAuthoritySimulation
	var player := arena.get_node("PlayerActor") as Phase1PlayerActor
	_check(simulation != null and simulation.definitions_are_valid(), "authority simulation is configured")
	_check(player != null, "configured player actor is available")
	if simulation == null or player == null:
		arena.queue_free()
		await process_frame
		return

	_check(simulation.reset_actor_to_start(PLAYER_ID), "exact-zero fallback case resets authority state")
	var fallback_start := player.global_position
	simulation.step(
		_command(3100, 53100, Vector2.ZERO, Vector2.DOWN, true),
		FIXED_DELTA
	)
	var fallback_state := player.debug_evade_state()
	_check(fallback_state.active, "exact-zero movement accepts aim-fallback evade")
	_check(
		(fallback_state.direction as Vector2).is_equal_approx(Vector2.DOWN),
		"exact-zero movement latches aim as evade direction"
	)
	_check(
		(player.global_position - fallback_start).normalized().is_equal_approx(Vector2.DOWN),
		"exact-zero fallback applies motion in the aim direction"
	)
	simulation.step(
		_command(3101, 53101, Vector2.ZERO, Vector2.LEFT, false),
		FIXED_DELTA
	)
	_check(
		(player.debug_evade_state().direction as Vector2).is_equal_approx(Vector2.DOWN),
		"aim change during active step does not redirect the latched evade"
	)
	_check(player.aim_direction.is_equal_approx(Vector2.LEFT), "aim remains independently updateable")

	var cases: Array[Dictionary] = [
		{"label": "+X", "move": Vector2(SMALL_NONZERO, 0.0)},
		{"label": "-X", "move": Vector2(-SMALL_NONZERO, 0.0)},
		{"label": "+Y", "move": Vector2(0.0, SMALL_NONZERO)},
		{"label": "-Y", "move": Vector2(0.0, -SMALL_NONZERO)},
		{"label": "diagonal", "move": Vector2(SMALL_NONZERO, -SMALL_NONZERO)},
	]
	for index in range(cases.size()):
		var test_case: Dictionary = cases[index]
		var label: String = test_case.label
		var move: Vector2 = test_case.move
		var expected := move.normalized()
		_check(
			simulation.reset_actor_to_start(PLAYER_ID),
			"small %s case resets authority state" % label
		)
		var start := player.global_position
		var command := _command(3110 + index, 53110 + index, move, -expected, true)
		_check(
			command.move_vector.is_equal_approx(move),
			"small %s InputCommand preserves the nonzero vector" % label
		)
		simulation.step(command, FIXED_DELTA)
		var state := player.debug_evade_state()
		_check(state.active, "small %s nonzero movement starts evade" % label)
		_check(
			(state.direction as Vector2).is_equal_approx(expected),
			"small %s nonzero movement wins over opposite aim" % label
		)
		_check(
			(player.global_position - start).normalized().is_equal_approx(expected),
			"small %s evade motion uses normalized movement direction" % label
		)

	arena.queue_free()
	await process_frame


func _test_actor_direction_guard() -> void:
	var zero_actor := Phase1PlayerActor.new()
	_check(
		not zero_actor.begin_authority_evade(Vector2.ZERO),
		"actor guard rejects exact-zero direction"
	)
	_check(not zero_actor.debug_evade_state().active, "exact-zero rejection leaves actor inactive")
	zero_actor.free()

	var small_actor := Phase1PlayerActor.new()
	var small_direction := Vector2(-SMALL_NONZERO, SMALL_NONZERO)
	_check(
		small_actor.begin_authority_evade(small_direction),
		"actor guard accepts small nonzero direction"
	)
	var small_state := small_actor.debug_evade_state()
	_check(small_state.active, "small nonzero acceptance activates actor evade")
	_check(
		(small_state.direction as Vector2).is_equal_approx(small_direction.normalized()),
		"actor normalizes accepted small nonzero direction"
	)
	small_actor.free()


func _command(
	sequence: int,
	tick: int,
	move: Vector2,
	aim: Vector2,
	request_evade: bool
) -> Phase1InputCommand:
	return Phase1InputCommand.create(
		sequence,
		tick,
		move,
		aim,
		false,
		PLAYER_ID,
		&"",
		request_evade
	)


func _check(condition: bool, description: String) -> void:
	_assertion_count += 1
	if condition:
		print("[MFO-P2-2A-CORRECTION-TEST] PASS: %s" % description)
	else:
		_failures.append(description)
