extends SceneTree

const TUNING_PATH := "res://data/fast_slice/fs_a_provisional_tuning.tres"

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var tuning := load(TUNING_PATH) as FsATuning
	_check(tuning != null, "fs_provisional tuning loads")
	if tuning != null:
		_check(tuning.authority_label == FsATuning.AUTHORITY_FS_PROVISIONAL, "tuning remains fs_provisional")
		_check(tuning.validate().is_empty(), "tuning validates")
		_test_action_state(tuning)
		_test_core_combat_loop(tuning)
		_test_post_combat_and_rematch(tuning)
		await _test_gameplay_scene(tuning)
	_test_existing_input_map()
	if _failures.is_empty():
		print("[MFO-FS-A-SELF-CHECK] PASS: full gameplay loop")
		quit(0)
	else:
		for failure in _failures:
			push_error("[MFO-FS-A-SELF-CHECK] %s" % failure)
		quit(1)


func _test_action_state(tuning: FsATuning) -> void:
	var action := FsAPlayerAction.new()
	_check(action.configure(tuning), "player action configures")
	_check(action.try_accept(FsAPlayerAction.ACTION_LIGHT, Vector2.RIGHT), "light attack is accepted")
	_check(action.state() == FsAPlayerAction.STATE_WINDUP, "light starts in windup")
	_check(not action.try_accept(FsAPlayerAction.ACTION_HEAVY, Vector2.RIGHT), "busy action rejects overlap")
	action.advance(tuning.light_windup_seconds - 0.01)
	_check(action.pending_hit_query().is_empty(), "light cannot hit before active")
	action.advance(0.01)
	var light_query := action.pending_hit_query()
	_check(light_query.get("action_id") == FsAPlayerAction.ACTION_LIGHT, "light opens its hit query at active")
	var light_result := action.commit_pending_hit(&"part.core_plate")
	_check(light_result.get("hit", false), "light hit is committed")
	_check(action.commit_pending_hit(&"part.core_plate").is_empty(), "one action cannot commit twice")
	action.advance(tuning.light_active_seconds + tuning.light_recovery_seconds)
	_check(action.state() == FsAPlayerAction.STATE_IDLE, "light returns to idle")
	_check(action.try_accept(FsAPlayerAction.ACTION_HEAVY, Vector2.UP), "heavy attack is accepted separately")
	_check(tuning.heavy_windup_seconds > tuning.light_windup_seconds, "heavy timing differs from light")
	action.advance(tuning.heavy_windup_seconds)
	var heavy_query := action.pending_hit_query()
	_check(heavy_query.get("action_id") == FsAPlayerAction.ACTION_HEAVY, "heavy opens its own hit query")
	_check(heavy_query.get("body_damage", 0) > light_query.get("body_damage", 0), "heavy uses distinct damage")
	_check(action.commit_pending_hit(&"").get("hit", true) == false, "miss is committed exactly once")


func _test_core_combat_loop(tuning: FsATuning) -> void:
	var loop := FsAGameplayLoop.new()
	_check(loop.configure(tuning), "gameplay loop configures")
	var initial := loop.get_snapshot()
	_check(initial.is_read_only(), "snapshot root is read-only")
	var initial_parts: Array = initial.get("parts", [])
	_check(initial_parts.size() == 1 and initial_parts.is_read_only(), "one required part is exposed read-only")
	var initial_part: Dictionary = initial_parts[0]
	_check(initial_part.is_read_only(), "part snapshot is read-only")
	var initial_harvest: Array = initial.get("harvest_points", [])
	_check(initial_harvest.size() == 3, "snapshot always defines exact three harvest points")
	_check(initial.get("loop_phase") == FsAGameplayLoop.LOOP_COMBAT, "loop starts in combat")

	var line_player := tuning.boss_position + Vector2(-360.0, 0.0)
	loop.advance_enemy(tuning.enemy_initial_cooldown_seconds, line_player)
	var line_telegraph: Dictionary = loop.get_snapshot().get("telegraph", {})
	_check(line_telegraph.get("shape") == FsAGameplayLoop.TELEGRAPH_LINE, "first enemy warning is line")
	_check(line_telegraph.get("active", false), "line warning is active before strike")
	loop.advance_enemy(tuning.line_telegraph_seconds, line_player)
	var integrity_before_line := int(loop.get_snapshot().get("player_integrity", 0))
	var line_safe_position := line_player + Vector2(0.0, tuning.line_half_width * 3.0)
	var line_result := loop.resolve_pending_enemy_hit(line_safe_position)
	_check(not bool(line_result.get("hit", true)), "movement out of line warning avoids damage")
	_check(loop.get_snapshot().get("player_integrity") == integrity_before_line, "avoided line preserves Integrity")
	_check(loop.resolve_pending_enemy_hit(line_safe_position).is_empty(), "enemy strike resolves only once")

	var sector_player := tuning.boss_position + Vector2(-280.0, 0.0)
	loop.advance_enemy(
		tuning.line_active_seconds + tuning.line_recovery_seconds + tuning.line_cooldown_seconds,
		sector_player
	)
	var sector_telegraph: Dictionary = loop.get_snapshot().get("telegraph", {})
	_check(sector_telegraph.get("shape") == FsAGameplayLoop.TELEGRAPH_SECTOR, "second enemy warning is sector")
	_check(sector_telegraph.get("active", false), "sector warning is active before strike")
	loop.advance_enemy(tuning.sector_telegraph_seconds, sector_player)
	var sector_result := loop.resolve_pending_enemy_hit(sector_player)
	_check(bool(sector_result.get("hit", false)), "sector strike can hit after its warning")
	_check(loop.get_snapshot().get("player_integrity") == tuning.player_integrity_max - tuning.sector_integrity_damage, "enemy hit reduces Integrity")
	_check(is_equal_approx(float(loop.get_snapshot().get("player_deformation", 0.0)), tuning.sector_deformation), "enemy hit increases Deformation")

	var attack_position := loop.part_position() - Vector2(tuning.heavy_reach * 0.55, 0.0)
	var first_part_hp := int(loop.get_snapshot().get("parts")[0].get("hp", 0))
	_perform_heavy_hit(loop, tuning, attack_position)
	var after_first_part_hp := int(loop.get_snapshot().get("parts")[0].get("hp", 0))
	_check(after_first_part_hp == maxi(0, first_part_hp - tuning.heavy_part_damage), "part takes one heavy hit once")
	_perform_heavy_hit(loop, tuning, attack_position)
	_check(bool(loop.get_snapshot().get("parts")[0].get("broken", false)), "required part can break")
	while int(loop.get_snapshot().get("boss_hp", 0)) > 0:
		_perform_heavy_hit(loop, tuning, attack_position)
	var defeated := loop.get_snapshot()
	_check(defeated.get("boss_hp") == 0, "boss reaches HP zero")
	_check(not bool(defeated.get("boss_functional", true)), "boss becomes non-functional at HP zero")
	_check(defeated.get("loop_phase") == FsAGameplayLoop.LOOP_WRECK, "HP zero transitions to wreck phase")
	_check(bool(defeated.get("wreck_active", false)), "wreck is active after defeat")
	_check(not loop.request_player_action(FsAPlayerAction.ACTION_LIGHT, Vector2.RIGHT), "attacks stop after defeat")
	_check(loop.pending_player_hit_query().is_empty(), "player hit query stops after defeat")
	_check(loop.resolve_pending_enemy_hit(attack_position).is_empty(), "enemy hit stops after defeat")
	var counters := loop.debug_counters()
	_check(counters.get("part_breaks") == 1, "part break transition is exact once")
	_check(counters.get("boss_defeat_transitions") == 1, "boss defeat transition is exact once")
	_check(counters.get("wreck_spawns") == 1, "wreck spawn is exact once")


func _perform_heavy_hit(loop: FsAGameplayLoop, tuning: FsATuning, player_position: Vector2) -> void:
	loop.set_player_spatial_state(player_position, Vector2.RIGHT)
	_check(loop.request_player_action(FsAPlayerAction.ACTION_HEAVY, Vector2.RIGHT), "heavy action accepted in combat")
	loop.advance_player_action(tuning.heavy_windup_seconds)
	var before_boss_hp := int(loop.get_snapshot().get("boss_hp", 0))
	var resolution := loop.resolve_pending_player_hit()
	_check(not resolution.is_empty() and bool(resolution.get("hit", false)), "heavy resolves one authoritative hit")
	var after_first_resolution := int(loop.get_snapshot().get("boss_hp", 0))
	_check(loop.resolve_pending_player_hit().is_empty(), "heavy cannot resolve a duplicate hit")
	_check(loop.get_snapshot().get("boss_hp") == after_first_resolution, "duplicate resolution cannot change boss HP")
	_check(after_first_resolution <= before_boss_hp, "authoritative hit never increases boss HP")
	loop.advance_player_action(tuning.heavy_active_seconds + tuning.heavy_recovery_seconds)


func _test_post_combat_and_rematch(tuning: FsATuning) -> void:
	var loop := FsAGameplayLoop.new()
	_check(loop.configure(tuning), "post-combat loop configures")
	var initial := loop.get_snapshot()
	_drive_loop_to_wreck(loop, tuning)
	var wreck_snapshot := loop.get_snapshot()
	var points: Array = wreck_snapshot.get("harvest_points", [])
	_check(points.size() == 3, "wreck exposes exact three harvest points")
	var first: Dictionary = points[0]
	var second: Dictionary = points[1]
	var third: Dictionary = points[2]
	_check(loop.collect_harvest_point(first.get("id"), first.get("position")), "first harvest point collects")
	_check(not loop.collect_harvest_point(first.get("id"), first.get("position")), "first harvest point rejects duplicate collection")
	_check(not loop.collect_harvest_point(second.get("id"), Vector2.ZERO), "harvest enforces interaction range")
	_check(loop.collect_harvest_point(second.get("id"), second.get("position")), "second harvest point collects")
	_check(not bool(loop.get_snapshot().get("result_visible", true)), "result waits for all three points")
	_check(loop.collect_harvest_point(third.get("id"), third.get("position")), "third harvest point collects")
	var reward := loop.get_reward_data()
	_check(reward.get("amount") == tuning.reward_per_harvest_point * 3, "three unique points produce provisional reward data")
	_check(reward.get("persistent") == false, "reward remains non-persistent")
	_check(not bool(loop.get_snapshot().get("result_visible", true)), "result honors provisional delay")
	loop.advance_post_combat(tuning.result_delay_seconds)
	var result := loop.get_snapshot()
	_check(result.get("loop_phase") == FsAGameplayLoop.LOOP_RESULT, "all harvest transitions to result")
	_check(bool(result.get("result_visible", false)), "result becomes visible")
	_check(bool(result.get("rematch_available", false)), "result enables rematch")
	var result_counters := loop.debug_counters()
	_check(result_counters.get("harvest_collections") == 3, "harvest collection count is exact three")
	_check(result_counters.get("result_transitions") == 1, "result transition is exact once")

	_check(loop.request_rematch(), "rematch request resets the round")
	_check(not loop.request_rematch(), "rematch cannot repeat during combat")
	var reset := loop.get_snapshot()
	_check(reset.get("loop_phase") == initial.get("loop_phase"), "rematch returns to combat")
	_check(reset.get("player_integrity") == initial.get("player_integrity"), "rematch restores Integrity")
	_check(is_equal_approx(float(reset.get("player_deformation")), 0.0), "rematch clears Deformation")
	_check(reset.get("boss_hp") == initial.get("boss_hp"), "rematch restores boss HP")
	_check(bool(reset.get("boss_functional", false)), "rematch restores boss function")
	_check(not bool(reset.get("parts")[0].get("broken", true)), "rematch restores the part")
	_check(not bool(reset.get("wreck_active", true)), "rematch removes wreck state")
	_check(not bool(reset.get("result_visible", true)), "rematch clears result")
	var reset_points: Array = reset.get("harvest_points", [])
	_check(_all_harvest_uncollected(reset_points), "rematch clears all harvest collection flags")
	var reset_counters := loop.debug_counters()
	_check(reset_counters.get("round_index") == 2, "rematch enters round two")
	_check(reset_counters.get("rematch_resets") == 1, "rematch reset count is exact once")

	var second_round_position := loop.part_position() - Vector2(tuning.light_reach * 0.55, 0.0)
	loop.set_player_spatial_state(second_round_position, Vector2.RIGHT)
	_check(loop.request_player_action(FsAPlayerAction.ACTION_LIGHT, Vector2.RIGHT), "round two accepts light attack")
	loop.advance_player_action(tuning.light_windup_seconds)
	_check(bool(loop.resolve_pending_player_hit().get("hit", false)), "round two can resolve a player hit")
	loop.advance_enemy(tuning.enemy_initial_cooldown_seconds, tuning.player_start_position)
	var round_two_telegraph: Dictionary = loop.get_snapshot().get("telegraph", {})
	_check(bool(round_two_telegraph.get("active", false)), "round two restarts enemy AI")


func _drive_loop_to_wreck(loop: FsAGameplayLoop, tuning: FsATuning) -> void:
	var attack_position := loop.part_position() - Vector2(tuning.heavy_reach * 0.55, 0.0)
	var safety := 0
	while int(loop.get_snapshot().get("boss_hp", 0)) > 0 and safety < 12:
		_perform_heavy_hit(loop, tuning, attack_position)
		safety += 1
	_check(loop.get_snapshot().get("loop_phase") == FsAGameplayLoop.LOOP_WRECK, "deterministic drive reaches wreck")


func _all_harvest_uncollected(points: Array) -> bool:
	if points.size() != 3:
		return false
	for point_variant in points:
		var point: Dictionary = point_variant
		if bool(point.get("collected", true)):
			return false
	return true


func _test_gameplay_scene(tuning: FsATuning) -> void:
	var packed := load("res://scenes/fast_slice/gameplay/fs_a_gameplay_arena.tscn") as PackedScene
	_check(packed != null, "gameplay child scene loads")
	if packed == null:
		return
	var arena := packed.instantiate() as FsAGameplayArena
	arena.live_input_enabled = false
	root.add_child(arena)
	await process_frame
	await physics_frame
	_check(arena.is_ready_for_gameplay(), "gameplay child scene configures headless")
	var player := arena.get_player_actor()
	var start := player.global_position
	var move_command := Phase1InputCommand.create(9001, 9001, Vector2.RIGHT, Vector2.UP, false, player.entity_id)
	arena.step_authority_command(move_command, &"", false, 1.0 / 60.0)
	_check(player.global_position.x > start.x, "scene composes existing movement")
	_check(player.aim_direction.is_equal_approx(Vector2.UP), "scene preserves independent existing aim")

	var before_evade := player.global_position
	var evade_command := Phase1InputCommand.create(9002, 9002, Vector2.RIGHT, Vector2.UP, false, player.entity_id, &"", true)
	arena.step_authority_command(evade_command, &"", false, 1.0 / 60.0)
	_check(bool(player.debug_evade_state().get("active", false)), "scene composes existing evade start")
	for tick in range(11):
		var neutral := Phase1InputCommand.create(9010 + tick, 9010 + tick, Vector2.ZERO, Vector2.UP, false, player.entity_id)
		arena.step_authority_command(neutral, &"", false, 1.0 / 60.0)
	_check(not bool(player.debug_evade_state().get("active", true)), "existing evade completes after twelve ticks")
	_check(player.global_position.x > before_evade.x, "existing evade moves the player")

	_drive_arena_to_wreck(arena, tuning)
	var runtime_after_defeat := arena.runtime_counts()
	_check(runtime_after_defeat.get("boss_nodes") == 1, "scene owns one large enemy authority node")
	_check(runtime_after_defeat.get("part_nodes") == 1, "scene owns one breakable part authority node")
	_check(runtime_after_defeat.get("wreck_nodes") == 1, "scene creates wreck exact once")
	_check(runtime_after_defeat.get("harvest_nodes") == 3, "scene creates exact three harvest authority nodes")

	var harvest_points: Array = arena.get_snapshot().get("harvest_points", [])
	for index in range(harvest_points.size()):
		var point: Dictionary = harvest_points[index]
		player.reset_authority_state(point.get("position"), Vector2.RIGHT)
		var interact := Phase1InputCommand.create(9200 + index, 9200 + index, Vector2.ZERO, Vector2.RIGHT, false, player.entity_id)
		var collect_result := arena.step_authority_command(interact, &"", true, 0.0)
		_check(bool(collect_result.get("harvest_collected", false)), "scene collects harvest point %d once" % (index + 1))
	var result_tick := Phase1InputCommand.create(9300, 9300, Vector2.ZERO, Vector2.RIGHT, false, player.entity_id)
	arena.step_authority_command(result_tick, &"", false, tuning.result_delay_seconds)
	_check(bool(arena.get_snapshot().get("result_visible", false)), "scene reaches result after all harvest")
	var reward: Dictionary = arena.get_snapshot().get("result_rewards", {})
	_check(reward.get("amount") == tuning.reward_per_harvest_point * 3, "scene exposes provisional reward data")

	var rematch_command := Phase1InputCommand.create(9301, 9301, Vector2.ZERO, Vector2.RIGHT, false, player.entity_id)
	var rematch_result := arena.step_authority_command(rematch_command, &"", true, 0.0)
	_check(bool(rematch_result.get("rematch_reset", false)), "scene accepts rematch from result")
	var runtime_after_reset := arena.runtime_counts()
	_check(runtime_after_reset.get("wreck_nodes") == 0, "rematch removes wreck authority node")
	_check(runtime_after_reset.get("harvest_nodes") == 0, "rematch removes harvest authority nodes")
	_check(player.global_position.is_equal_approx(tuning.player_start_position), "rematch restores existing player position")
	_check(player.can_accept_authority_evade(), "rematch resets existing evade cooldown")

	var second_round_attack_position: Vector2 = arena.get_snapshot().get("parts")[0].get("position") - Vector2(tuning.light_reach * 0.55, 0.0)
	player.reset_authority_state(second_round_attack_position, Vector2.RIGHT)
	var round_two_command := Phase1InputCommand.create(9400, 9400, Vector2.ZERO, Vector2.RIGHT, false, player.entity_id)
	var round_two_accept := arena.step_authority_command(round_two_command, FsAPlayerAction.ACTION_LIGHT, false, 0.0)
	_check(bool(round_two_accept.get("action_accepted", false)), "scene round two accepts light attack")
	var round_two_active := Phase1InputCommand.create(9401, 9401, Vector2.ZERO, Vector2.RIGHT, false, player.entity_id)
	var round_two_hit := arena.step_authority_command(round_two_active, &"", false, tuning.light_windup_seconds)
	_check(bool((round_two_hit.get("player_hit") as Dictionary).get("hit", false)), "scene round two resolves a hit")
	arena.queue_free()
	await process_frame


func _drive_arena_to_wreck(arena: FsAGameplayArena, tuning: FsATuning) -> void:
	var player := arena.get_player_actor()
	var attack_position: Vector2 = arena.get_snapshot().get("parts")[0].get("position") - Vector2(tuning.heavy_reach * 0.55, 0.0)
	player.reset_authority_state(attack_position, Vector2.RIGHT)
	var sequence := 9100
	while int(arena.get_snapshot().get("boss_hp", 0)) > 0 and sequence < 9120:
		var request := Phase1InputCommand.create(sequence, sequence, Vector2.ZERO, Vector2.RIGHT, false, player.entity_id)
		arena.step_authority_command(request, FsAPlayerAction.ACTION_HEAVY, false, 0.0)
		sequence += 1
		var active := Phase1InputCommand.create(sequence, sequence, Vector2.ZERO, Vector2.RIGHT, false, player.entity_id)
		arena.step_authority_command(active, &"", false, tuning.heavy_windup_seconds)
		sequence += 1
		var recover := Phase1InputCommand.create(sequence, sequence, Vector2.ZERO, Vector2.RIGHT, false, player.entity_id)
		arena.step_authority_command(recover, &"", false, tuning.heavy_active_seconds + tuning.heavy_recovery_seconds)
		sequence += 1
	_check(arena.get_snapshot().get("loop_phase") == FsAGameplayLoop.LOOP_WRECK, "scene deterministic drive reaches wreck")


func _test_existing_input_map() -> void:
	var legacy := Phase1InputAdapter.new()
	var adapter := FsAInputAdapter.new()
	_check(adapter.bind_legacy_adapter(legacy), "FS adapter composes legacy input")
	_check(adapter.ensure_input_map(), "legacy input map remains usable")
	var heavy_event_count := InputMap.action_get_events(Phase1InputAdapter.ACTION_HEAVY).size()
	adapter.ensure_input_map()
	_check(InputMap.action_get_events(Phase1InputAdapter.ACTION_HEAVY).size() == heavy_event_count, "input setup stays idempotent")
	_check(_has_mouse_button(Phase1InputAdapter.ACTION_HEAVY, MOUSE_BUTTON_RIGHT), "heavy keeps existing right mouse binding")
	_check(_has_key(Phase1InputAdapter.ACTION_INTERACT, KEY_E), "interact keeps existing E binding")
	adapter.free()
	legacy.free()


func _has_mouse_button(action: StringName, button_index: int) -> bool:
	for event in InputMap.action_get_events(action):
		var mouse := event as InputEventMouseButton
		if mouse != null and mouse.button_index == button_index:
			return true
	return false


func _has_key(action: StringName, keycode: Key) -> bool:
	for event in InputMap.action_get_events(action):
		var key := event as InputEventKey
		if key != null and key.physical_keycode == keycode:
			return true
	return false


func _check(condition: bool, description: String) -> void:
	if condition:
		print("[MFO-FS-A-SELF-CHECK] PASS: %s" % description)
	else:
		_failures.append(description)
