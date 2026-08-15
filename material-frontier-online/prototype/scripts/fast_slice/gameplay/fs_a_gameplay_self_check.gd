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
		_test_both_telegraphs_are_avoidable(tuning)
		_test_player_defeat_loop(tuning)
		_test_post_combat_and_rematch(tuning)
		await _test_no_teleport_traversal(tuning)
		await _test_player_defeat_arena(tuning)
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

	var coarse_action := FsAPlayerAction.new()
	_check(coarse_action.configure(tuning), "coarse-delta action configures")
	_check(coarse_action.try_accept(FsAPlayerAction.ACTION_HEAVY, Vector2.UP), "coarse-delta heavy is accepted")
	coarse_action.advance(
		tuning.heavy_windup_seconds + tuning.heavy_active_seconds + tuning.heavy_recovery_seconds
	)
	_check(coarse_action.state() == FsAPlayerAction.STATE_IDLE, "coarse delta may cross the full action")
	var coarse_query := coarse_action.pending_hit_query()
	_check(coarse_query.get("action_id") == FsAPlayerAction.ACTION_HEAVY, "pending hit retains heavy identity after recovery")
	_check(coarse_query.get("body_damage") == tuning.heavy_body_damage, "pending hit retains heavy damage after recovery")
	_check(coarse_query.get("aim") == Vector2.UP, "pending hit retains locked aim after recovery")
	_check(coarse_action.commit_pending_hit(&"boss.large.1").get("action_id") == FsAPlayerAction.ACTION_HEAVY, "coarse-delta hit commits the latched descriptor")
	_check(coarse_action.commit_pending_hit(&"boss.large.1").is_empty(), "coarse-delta hit still commits exact once")


func _test_core_combat_loop(tuning: FsATuning) -> void:
	var loop := FsAGameplayLoop.new()
	_check(loop.configure(tuning), "gameplay loop configures")
	var initial := loop.get_snapshot()
	_check(initial.is_read_only(), "snapshot root is read-only")
	var player_build: Dictionary = initial.get("player_build", {})
	_check(player_build.get("combat_form") == FsAGameplayLoop.PLAYER_COMBAT_FORM, "single player build is Knight")
	_check(player_build.get("material_job") == FsAGameplayLoop.PLAYER_MATERIAL_JOB, "single player build is Iron")
	_check(player_build.size() == 2, "FS-A exposes no alternate player build")
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


func _test_both_telegraphs_are_avoidable(tuning: FsATuning) -> void:
	var loop := FsAGameplayLoop.new()
	_check(loop.configure(tuning), "telegraph avoidance loop configures")
	var line_lock_position := tuning.boss_position + Vector2(-360.0, 0.0)
	loop.advance_enemy(tuning.enemy_initial_cooldown_seconds, line_lock_position)
	loop.advance_enemy(tuning.line_telegraph_seconds, line_lock_position)
	var line_safe_position := line_lock_position + Vector2(0.0, tuning.line_half_width * 3.0)
	_check(not bool(loop.resolve_pending_enemy_hit(line_safe_position).get("hit", true)), "line attack is avoidable after warning")

	var sector_lock_position := tuning.boss_position + Vector2(-280.0, 0.0)
	loop.advance_enemy(
		tuning.line_active_seconds + tuning.line_recovery_seconds + tuning.line_cooldown_seconds,
		sector_lock_position
	)
	var sector_telegraph: Dictionary = loop.get_snapshot().get("telegraph", {})
	_check(sector_telegraph.get("shape") == FsAGameplayLoop.TELEGRAPH_SECTOR, "avoidance loop reaches sector warning")
	loop.advance_enemy(tuning.sector_telegraph_seconds, sector_lock_position)
	var sector_safe_position := tuning.boss_position + Vector2(0.0, -280.0)
	_check(not bool(loop.resolve_pending_enemy_hit(sector_safe_position).get("hit", true)), "sector attack is avoidable after warning")


func _test_player_defeat_loop(tuning: FsATuning) -> void:
	var loop := FsAGameplayLoop.new()
	_check(loop.configure(tuning), "player defeat loop configures")
	var events: Array[Dictionary] = []
	loop.gameplay_event.connect(func(event_name: StringName, payload: Dictionary) -> void:
		events.append({
			"name": event_name,
			"payload": payload.duplicate(true),
		})
	)
	var hit_position := tuning.boss_position + Vector2(-280.0, 0.0)
	loop.advance_enemy(tuning.enemy_initial_cooldown_seconds, hit_position)
	var expected_shapes: Array[StringName] = [
		FsAGameplayLoop.TELEGRAPH_LINE,
		FsAGameplayLoop.TELEGRAPH_SECTOR,
		FsAGameplayLoop.TELEGRAPH_LINE,
		FsAGameplayLoop.TELEGRAPH_SECTOR,
	]
	for index in range(expected_shapes.size()):
		var expected_shape := expected_shapes[index]
		var telegraph: Dictionary = loop.get_snapshot().get("telegraph", {})
		_check(telegraph.get("shape") == expected_shape, "pre-fatal enemy hit %d uses expected telegraph" % (index + 1))
		var telegraph_seconds := (
			tuning.line_telegraph_seconds
			if expected_shape == FsAGameplayLoop.TELEGRAPH_LINE
			else tuning.sector_telegraph_seconds
		)
		loop.advance_enemy(telegraph_seconds, hit_position)
		var hit_result := loop.resolve_pending_enemy_hit(hit_position)
		_check(bool(hit_result.get("hit", false)), "pre-fatal enemy hit %d resolves" % (index + 1))
		if index + 1 < expected_shapes.size():
			_advance_loop_to_next_telegraph(loop, tuning, hit_position, expected_shape)
	var pre_fatal_snapshot := loop.get_snapshot()
	var expected_pre_fatal_integrity := (
		tuning.player_integrity_max
		- (tuning.line_integrity_damage * 2)
		- (tuning.sector_integrity_damage * 2)
	)
	var expected_pre_fatal_deformation := (
		(tuning.line_deformation * 2.0)
		+ (tuning.sector_deformation * 2.0)
	)
	_check(pre_fatal_snapshot.get("player_integrity") == expected_pre_fatal_integrity, "four enemy hits preserve provisional Integrity arithmetic")
	_check(expected_pre_fatal_integrity > 0 and expected_pre_fatal_integrity <= tuning.line_integrity_damage, "four enemy hits leave a positive line-fatal edge")
	_check(is_equal_approx(float(pre_fatal_snapshot.get("player_deformation", 0.0)), expected_pre_fatal_deformation), "pre-fatal Deformation preserves provisional hit arithmetic")

	_advance_loop_to_next_telegraph(
		loop,
		tuning,
		hit_position,
		FsAGameplayLoop.TELEGRAPH_SECTOR
	)
	var fatal_warning: Dictionary = loop.get_snapshot().get("telegraph", {})
	_check(bool(fatal_warning.get("active", false)), "fatal hit has an active warning")
	_check(fatal_warning.get("shape") == FsAGameplayLoop.TELEGRAPH_LINE, "fatal hit is the next line attack")
	loop.set_player_spatial_state(hit_position, Vector2.RIGHT)
	_check(loop.request_player_action(FsAPlayerAction.ACTION_HEAVY, Vector2.RIGHT), "pending player action exists before fatal hit")
	loop.advance_player_action(tuning.heavy_windup_seconds)
	_check(not loop.pending_player_hit_query().is_empty(), "pending player hit query exists before fatal hit")
	var boss_before := int(loop.get_snapshot().get("boss_hp", 0))
	var part_before := int(loop.get_snapshot().get("parts")[0].get("hp", 0))
	var event_count_before_fatal := events.size()
	var enemy_event_count_before_fatal := _event_count(events, &"enemy_hit_resolved")
	loop.advance_enemy(tuning.line_telegraph_seconds, hit_position)
	var fatal_active: Dictionary = loop.get_snapshot().get("telegraph", {})
	var fatal_result := loop.resolve_pending_enemy_hit(hit_position)
	var defeated := loop.get_snapshot()
	_check(bool(fatal_result.get("hit", false)), "fatal enemy hit resolves")
	_check(fatal_result.get("attack_id") == fatal_active.get("id"), "fatal result preserves stopped attack id")
	_check(fatal_result.get("shape") == FsAGameplayLoop.TELEGRAPH_LINE, "fatal result preserves stopped telegraph shape")
	_check(defeated.get("player_integrity") == maxi(0, expected_pre_fatal_integrity - tuning.line_integrity_damage), "fatal hit clamps Integrity to exact zero")
	_check(is_equal_approx(float(defeated.get("player_deformation", 0.0)), expected_pre_fatal_deformation + tuning.line_deformation), "fatal hit preserves provisional final Deformation")
	_check(loop.debug_counters().get("player_defeat_latches") == 1, "player defeat latches exact once")
	_check(events.size() == event_count_before_fatal + 1, "fatal hit emits only its existing resolution event")
	_check(_event_count(events, &"enemy_hit_resolved") == enemy_event_count_before_fatal + 1, "fatal hit emits exact one enemy resolution")
	var fatal_event := _last_event_payload(events, &"enemy_hit_resolved")
	_check(
		bool(fatal_event.get("hit", false))
		and fatal_event.get("attack_id") == fatal_result.get("attack_id")
		and fatal_event.get("shape") == fatal_result.get("shape"),
		"fatal enemy event matches authoritative result"
	)
	var defeated_action: Dictionary = defeated.get("player_action", {})
	_check(defeated_action.get("state") == FsAPlayerAction.STATE_IDLE, "fatal hit cancels pending player action")
	_check(StringName(defeated_action.get("action_id", &"")).is_empty(), "fatal hit clears pending action identity")
	_check(loop.pending_player_hit_query().is_empty(), "fatal hit cancels pending player query")
	_check(loop.resolve_pending_player_hit().is_empty(), "fatal hit cannot resolve cancelled player query")
	var stopped_telegraph: Dictionary = defeated.get("telegraph", {})
	_check(not bool(stopped_telegraph.get("active", true)), "fatal hit stops active telegraph")
	_check(StringName(stopped_telegraph.get("id", &"")).is_empty(), "fatal hit clears enemy attack id")
	_check(StringName(stopped_telegraph.get("shape", &"")).is_empty(), "fatal hit clears enemy telegraph shape")
	_check(defeated.get("loop_phase") == FsAGameplayLoop.LOOP_COMBAT, "player defeat preserves combat phase")
	_check(bool(defeated.get("boss_functional", false)), "player defeat preserves boss function")
	_check(defeated.get("boss_hp") == boss_before, "player defeat preserves boss HP")
	_check(defeated.get("parts")[0].get("hp") == part_before, "player defeat preserves part HP")
	_check(not bool(defeated.get("wreck_active", true)), "player defeat does not create wreck")
	_check(not bool(defeated.get("result_visible", true)), "player defeat does not create result")
	_check(not bool(defeated.get("rematch_available", true)), "player defeat does not create retry or rematch")
	_check(_all_harvest_uncollected(defeated.get("harvest_points", [])), "player defeat preserves uncollected harvest state")

	var frozen_snapshot: Dictionary = defeated
	var frozen_counters: Dictionary = loop.debug_counters()
	var frozen_event_count := events.size()
	loop.set_player_spatial_state(hit_position + Vector2(100.0, 100.0), Vector2.UP)
	_check(not loop.request_player_action(FsAPlayerAction.ACTION_LIGHT, Vector2.UP), "defeat rejects player action")
	loop.advance_authority(20.0, hit_position + Vector2(200.0, 200.0), Vector2.DOWN)
	loop.advance_player_action(20.0)
	loop.advance_enemy(20.0, hit_position + Vector2(300.0, 300.0))
	_check(loop.pending_player_hit_query().is_empty(), "defeat keeps player query stopped")
	_check(loop.resolve_pending_enemy_hit(hit_position).is_empty(), "defeat keeps pending enemy hit discarded")
	_check(loop.get_snapshot() == frozen_snapshot, "defeat freezes player enemy and post-combat snapshot state")
	_check(loop.debug_counters() == frozen_counters, "defeat freezes all gameplay counters")
	_check(events.size() == frozen_event_count, "defeat emits no additional gameplay event")

	_check(not loop.configure(null), "invalid configure fails closed after player defeat")
	loop.set_player_spatial_state(hit_position + Vector2(400.0, 400.0), Vector2.LEFT)
	loop.advance_authority(20.0, hit_position + Vector2(500.0, 500.0), Vector2.LEFT)
	_check(loop.get_snapshot() == frozen_snapshot, "invalid configure preserves defeated authority state")
	_check(loop.debug_counters() == frozen_counters, "invalid configure preserves defeat latch count")
	_check(events.size() == frozen_event_count, "invalid configure emits no gameplay event")
	_check(loop.configure(tuning), "configure clears player defeat latch")
	_check(loop.debug_counters().get("player_defeat_latches") == 0, "configure resets defeat latch count")
	_check(loop.get_snapshot().get("player_integrity") == tuning.player_integrity_max, "configure restores player Integrity")
	_check(loop.request_player_action(FsAPlayerAction.ACTION_LIGHT, Vector2.RIGHT), "configure restores player action acceptance")
	loop.advance_enemy(tuning.enemy_initial_cooldown_seconds, hit_position)
	_check(bool(loop.get_snapshot().get("telegraph", {}).get("active", false)), "configure restarts enemy scheduling")


func _advance_loop_to_next_telegraph(
	loop: FsAGameplayLoop,
	tuning: FsATuning,
	player_position: Vector2,
	completed_shape: StringName
) -> void:
	loop.advance_enemy(
		_enemy_cycle_seconds(tuning, completed_shape),
		player_position
	)


func _enemy_cycle_seconds(tuning: FsATuning, completed_shape: StringName) -> float:
	return (
		tuning.line_active_seconds + tuning.line_recovery_seconds + tuning.line_cooldown_seconds
		if completed_shape == FsAGameplayLoop.TELEGRAPH_LINE
		else tuning.sector_active_seconds + tuning.sector_recovery_seconds + tuning.sector_cooldown_seconds
	)


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


func _test_no_teleport_traversal(tuning: FsATuning) -> void:
	var packed := load("res://scenes/fast_slice/gameplay/fs_a_gameplay_arena.tscn") as PackedScene
	_check(packed != null, "no-teleport gameplay scene loads")
	if packed == null:
		return
	var arena := packed.instantiate() as FsAGameplayArena
	arena.live_input_enabled = false
	var events: Array[Dictionary] = []
	arena.gameplay_event.connect(func(event_name: StringName, payload: Dictionary) -> void:
		events.append({
			"name": event_name,
			"payload": payload.duplicate(true),
		})
	)
	root.add_child(arena)
	await process_frame
	await physics_frame
	_check(arena.is_ready_for_gameplay(), "no-teleport gameplay scene configures")
	if not arena.is_ready_for_gameplay():
		arena.queue_free()
		await process_frame
		return
	var player := arena.get_player_actor()
	var initial := arena.get_snapshot()
	var initial_boss_hp := int(initial.get("boss_hp", 0))
	var initial_part_hp := int(initial.get("parts")[0].get("hp", 0))
	var initial_position := player.global_position
	_check(initial_position.is_equal_approx(tuning.player_start_position), "no-teleport fixture starts at configured spawn")
	var sequence := 10000
	var parity_ok: bool = initial.get("player_position", Vector2.INF).is_equal_approx(player.global_position)

	var light_request := Phase1InputCommand.create(
		sequence,
		sequence,
		Vector2.ZERO,
		Vector2.RIGHT,
		false,
		player.entity_id
	)
	var light_accept := arena.step_authority_command(
		light_request,
		FsAPlayerAction.ACTION_LIGHT,
		false,
		0.0
	)
	sequence += 1
	parity_ok = parity_ok and arena.get_snapshot().get("player_position", Vector2.INF).is_equal_approx(player.global_position)
	_check(bool(light_accept.get("action_accepted", false)), "spawn light action is accepted without teleport")
	var light_active_command := Phase1InputCommand.create(
		sequence,
		sequence,
		Vector2.ZERO,
		Vector2.RIGHT,
		false,
		player.entity_id
	)
	var light_active := arena.step_authority_command(
		light_active_command,
		&"",
		false,
		tuning.light_windup_seconds
	)
	sequence += 1
	parity_ok = parity_ok and arena.get_snapshot().get("player_position", Vector2.INF).is_equal_approx(player.global_position)
	var light_miss: Dictionary = light_active.get("player_hit", {})
	_check(
		light_miss.get("action_id") == FsAPlayerAction.ACTION_LIGHT
		and not bool(light_miss.get("hit", true))
		and StringName(light_miss.get("target_id", &"")).is_empty(),
		"spawn light resolves an out-of-range miss"
	)
	var light_recovery_command := Phase1InputCommand.create(
		sequence,
		sequence,
		Vector2.ZERO,
		Vector2.RIGHT,
		false,
		player.entity_id
	)
	var light_recovery := arena.step_authority_command(
		light_recovery_command,
		&"",
		false,
		tuning.light_active_seconds + tuning.light_recovery_seconds
	)
	sequence += 1
	parity_ok = parity_ok and arena.get_snapshot().get("player_position", Vector2.INF).is_equal_approx(player.global_position)
	_check((light_recovery.get("player_hit", {}) as Dictionary).is_empty(), "spawn light miss cannot resolve twice")

	var heavy_request := Phase1InputCommand.create(
		sequence,
		sequence,
		Vector2.ZERO,
		Vector2.RIGHT,
		false,
		player.entity_id
	)
	var heavy_accept := arena.step_authority_command(
		heavy_request,
		FsAPlayerAction.ACTION_HEAVY,
		false,
		0.0
	)
	sequence += 1
	parity_ok = parity_ok and arena.get_snapshot().get("player_position", Vector2.INF).is_equal_approx(player.global_position)
	_check(bool(heavy_accept.get("action_accepted", false)), "spawn heavy action is accepted without teleport")
	var heavy_active_command := Phase1InputCommand.create(
		sequence,
		sequence,
		Vector2.ZERO,
		Vector2.RIGHT,
		false,
		player.entity_id
	)
	var heavy_active := arena.step_authority_command(
		heavy_active_command,
		&"",
		false,
		tuning.heavy_windup_seconds
	)
	sequence += 1
	parity_ok = parity_ok and arena.get_snapshot().get("player_position", Vector2.INF).is_equal_approx(player.global_position)
	var heavy_miss: Dictionary = heavy_active.get("player_hit", {})
	_check(
		heavy_miss.get("action_id") == FsAPlayerAction.ACTION_HEAVY
		and not bool(heavy_miss.get("hit", true))
		and StringName(heavy_miss.get("target_id", &"")).is_empty(),
		"spawn heavy resolves an out-of-range miss"
	)
	var heavy_recovery_command := Phase1InputCommand.create(
		sequence,
		sequence,
		Vector2.ZERO,
		Vector2.RIGHT,
		false,
		player.entity_id
	)
	var heavy_recovery := arena.step_authority_command(
		heavy_recovery_command,
		&"",
		false,
		tuning.heavy_active_seconds + tuning.heavy_recovery_seconds
	)
	sequence += 1
	parity_ok = parity_ok and arena.get_snapshot().get("player_position", Vector2.INF).is_equal_approx(player.global_position)
	_check((heavy_recovery.get("player_hit", {}) as Dictionary).is_empty(), "spawn heavy miss cannot resolve twice")
	var after_spawn_misses := arena.get_snapshot()
	_check(after_spawn_misses.get("boss_hp") == initial_boss_hp, "spawn misses preserve boss HP")
	_check(after_spawn_misses.get("parts")[0].get("hp") == initial_part_hp, "spawn misses preserve part HP")

	var part_position: Vector2 = after_spawn_misses.get("parts")[0].get("position", Vector2.INF)
	var initial_distance := player.global_position.distance_to(part_position)
	var move_steps := 0
	var saw_existing_evade := false
	while (
		player.global_position.distance_to(part_position)
		> tuning.light_reach + tuning.part_target_radius - 10.0
		and move_steps < 180
	):
		var move_command := Phase1InputCommand.create(
			sequence,
			sequence,
			Vector2.RIGHT,
			Vector2.RIGHT,
			false,
			player.entity_id,
			&"",
			move_steps == 0
		)
		arena.step_authority_command(move_command, &"", false, 1.0 / 60.0)
		sequence += 1
		move_steps += 1
		saw_existing_evade = saw_existing_evade or bool(player.debug_evade_state().get("active", false))
		parity_ok = parity_ok and arena.get_snapshot().get("player_position", Vector2.INF).is_equal_approx(player.global_position)
		if int(arena.get_snapshot().get("player_integrity", 0)) == 0:
			break
	_check(saw_existing_evade, "no-teleport traversal uses existing evade")
	_check(move_steps < 180, "no-teleport traversal reaches attack range")
	_check(player.global_position.distance_to(part_position) < initial_distance, "no-teleport traversal reduces target distance")
	_check(not player.global_position.is_equal_approx(initial_position), "no-teleport traversal moves from initial spawn")
	_check(parity_ok, "movement snapshot parity holds through no-teleport traversal")
	_check(int(arena.get_snapshot().get("player_integrity", 0)) > 0, "no-teleport traversal remains playable")
	if int(arena.get_snapshot().get("player_integrity", 0)) == 0:
		arena.queue_free()
		await process_frame
		return

	var before_light := arena.get_snapshot()
	var light_event_count := _event_count(events, &"player_hit_resolved")
	var in_range_light_request := Phase1InputCommand.create(
		sequence,
		sequence,
		Vector2.ZERO,
		Vector2.RIGHT,
		false,
		player.entity_id
	)
	var in_range_light_accept := arena.step_authority_command(
		in_range_light_request,
		FsAPlayerAction.ACTION_LIGHT,
		false,
		0.0
	)
	sequence += 1
	parity_ok = parity_ok and arena.get_snapshot().get("player_position", Vector2.INF).is_equal_approx(player.global_position)
	_check(bool(in_range_light_accept.get("action_accepted", false)), "in-range light action is accepted")
	var in_range_light_active := Phase1InputCommand.create(
		sequence,
		sequence,
		Vector2.ZERO,
		Vector2.RIGHT,
		false,
		player.entity_id
	)
	var light_hit_step := arena.step_authority_command(
		in_range_light_active,
		&"",
		false,
		tuning.light_windup_seconds
	)
	sequence += 1
	var light_hit: Dictionary = light_hit_step.get("player_hit", {})
	var after_light := arena.get_snapshot()
	parity_ok = parity_ok and after_light.get("player_position", Vector2.INF).is_equal_approx(player.global_position)
	_check(
		bool(light_hit.get("hit", false))
		and light_hit.get("target_id") == FsAGameplayLoop.PART_ID,
		"in-range light uses existing part-first target rule"
	)
	_check(
		after_light.get("parts")[0].get("hp")
		== maxi(0, int(before_light.get("parts")[0].get("hp", 0)) - tuning.light_part_damage),
		"in-range light applies existing part damage"
	)
	_check(
		after_light.get("boss_hp")
		== int(before_light.get("boss_hp", 0)) - roundi(float(tuning.light_body_damage) * tuning.part_hit_body_damage_ratio),
		"in-range light applies existing linked body damage"
	)
	_check(_event_count(events, &"player_hit_resolved") == light_event_count + 1, "in-range light emits one hit event")
	var light_event := _last_event_payload(events, &"player_hit_resolved")
	_check(
		bool(light_event.get("hit", false))
		and light_event.get("action_id") == FsAPlayerAction.ACTION_LIGHT
		and light_event.get("target_id") == FsAGameplayLoop.PART_ID,
		"in-range light event preserves action and target"
	)
	var light_finish := Phase1InputCommand.create(
		sequence,
		sequence,
		Vector2.ZERO,
		Vector2.RIGHT,
		false,
		player.entity_id
	)
	var light_finish_step := arena.step_authority_command(
		light_finish,
		&"",
		false,
		tuning.light_active_seconds + tuning.light_recovery_seconds
	)
	sequence += 1
	var after_light_finish := arena.get_snapshot()
	parity_ok = parity_ok and after_light_finish.get("player_position", Vector2.INF).is_equal_approx(player.global_position)
	_check((light_finish_step.get("player_hit", {}) as Dictionary).is_empty(), "in-range light cannot resolve twice")
	_check(after_light_finish.get("boss_hp") == after_light.get("boss_hp"), "light recovery preserves boss HP")
	_check(after_light_finish.get("parts")[0].get("hp") == after_light.get("parts")[0].get("hp"), "light recovery preserves part HP")
	_check(_event_count(events, &"player_hit_resolved") == light_event_count + 1, "light recovery emits no duplicate hit event")
	_check(after_light_finish.get("player_action", {}).get("state") == FsAPlayerAction.STATE_IDLE, "in-range light completes recovery")

	var before_heavy := arena.get_snapshot()
	var heavy_event_count := _event_count(events, &"player_hit_resolved")
	var part_break_event_count := _event_count(events, &"part_broken")
	var in_range_heavy_request := Phase1InputCommand.create(
		sequence,
		sequence,
		Vector2.ZERO,
		Vector2.RIGHT,
		false,
		player.entity_id
	)
	var in_range_heavy_accept := arena.step_authority_command(
		in_range_heavy_request,
		FsAPlayerAction.ACTION_HEAVY,
		false,
		0.0
	)
	sequence += 1
	parity_ok = parity_ok and arena.get_snapshot().get("player_position", Vector2.INF).is_equal_approx(player.global_position)
	_check(bool(in_range_heavy_accept.get("action_accepted", false)), "in-range heavy action is accepted")
	var in_range_heavy_active := Phase1InputCommand.create(
		sequence,
		sequence,
		Vector2.ZERO,
		Vector2.RIGHT,
		false,
		player.entity_id
	)
	var heavy_hit_step := arena.step_authority_command(
		in_range_heavy_active,
		&"",
		false,
		tuning.heavy_windup_seconds
	)
	sequence += 1
	var heavy_hit: Dictionary = heavy_hit_step.get("player_hit", {})
	var after_heavy := arena.get_snapshot()
	parity_ok = parity_ok and after_heavy.get("player_position", Vector2.INF).is_equal_approx(player.global_position)
	_check(
		bool(heavy_hit.get("hit", false))
		and heavy_hit.get("target_id") == FsAGameplayLoop.PART_ID,
		"in-range heavy uses existing part-first target rule"
	)
	_check(
		after_heavy.get("parts")[0].get("hp")
		== maxi(0, int(before_heavy.get("parts")[0].get("hp", 0)) - tuning.heavy_part_damage),
		"in-range heavy applies existing part damage"
	)
	_check(
		after_heavy.get("boss_hp")
		== int(before_heavy.get("boss_hp", 0)) - roundi(float(tuning.heavy_body_damage) * tuning.part_hit_body_damage_ratio),
		"in-range heavy applies existing linked body damage"
	)
	_check(bool(after_heavy.get("parts")[0].get("broken", false)), "in-range heavy completes existing part break")
	_check(_event_count(events, &"player_hit_resolved") == heavy_event_count + 1, "in-range heavy emits one hit event")
	_check(_event_count(events, &"part_broken") == part_break_event_count + 1, "in-range heavy emits one part break event")
	var heavy_event := _last_event_payload(events, &"player_hit_resolved")
	_check(
		bool(heavy_event.get("hit", false))
		and heavy_event.get("action_id") == FsAPlayerAction.ACTION_HEAVY
		and heavy_event.get("target_id") == FsAGameplayLoop.PART_ID,
		"in-range heavy event preserves action and target"
	)
	var heavy_finish := Phase1InputCommand.create(
		sequence,
		sequence,
		Vector2.ZERO,
		Vector2.RIGHT,
		false,
		player.entity_id
	)
	var heavy_finish_step := arena.step_authority_command(
		heavy_finish,
		&"",
		false,
		tuning.heavy_active_seconds + tuning.heavy_recovery_seconds
	)
	var after_heavy_finish := arena.get_snapshot()
	parity_ok = parity_ok and after_heavy_finish.get("player_position", Vector2.INF).is_equal_approx(player.global_position)
	_check((heavy_finish_step.get("player_hit", {}) as Dictionary).is_empty(), "in-range heavy cannot resolve twice")
	_check(after_heavy_finish.get("boss_hp") == after_heavy.get("boss_hp"), "heavy recovery preserves boss HP")
	_check(after_heavy_finish.get("parts")[0].get("hp") == after_heavy.get("parts")[0].get("hp"), "heavy recovery preserves part HP")
	_check(_event_count(events, &"player_hit_resolved") == heavy_event_count + 1, "heavy recovery emits no duplicate hit event")
	_check(after_heavy_finish.get("player_action", {}).get("state") == FsAPlayerAction.STATE_IDLE, "in-range heavy completes recovery")
	_check(parity_ok, "actor and snapshot positions match for every no-teleport command")
	arena.queue_free()
	await process_frame


func _test_player_defeat_arena(tuning: FsATuning) -> void:
	var packed := load("res://scenes/fast_slice/gameplay/fs_a_gameplay_arena.tscn") as PackedScene
	_check(packed != null, "player defeat arena scene loads")
	if packed == null:
		return
	var arena := packed.instantiate() as FsAGameplayArena
	arena.live_input_enabled = false
	var events: Array[Dictionary] = []
	arena.gameplay_event.connect(func(event_name: StringName, payload: Dictionary) -> void:
		events.append({
			"name": event_name,
			"payload": payload.duplicate(true),
		})
	)
	root.add_child(arena)
	await process_frame
	await physics_frame
	_check(arena.is_ready_for_gameplay(), "player defeat arena configures")
	if not arena.is_ready_for_gameplay():
		arena.queue_free()
		await process_frame
		return
	var player := arena.get_player_actor()
	var hit_position := tuning.boss_position + Vector2(-280.0, 0.0)
	player.reset_authority_state(hit_position, Vector2.RIGHT)
	var sequence := 12000
	var setup_command := Phase1InputCommand.create(
		sequence,
		sequence,
		Vector2.ZERO,
		Vector2.RIGHT,
		false,
		player.entity_id
	)
	arena.step_authority_command(setup_command, &"", false, 0.0)
	sequence += 1
	var initial_warning_command := Phase1InputCommand.create(
		sequence,
		sequence,
		Vector2.ZERO,
		Vector2.RIGHT,
		false,
		player.entity_id
	)
	arena.step_authority_command(
		initial_warning_command,
		&"",
		false,
		tuning.enemy_initial_cooldown_seconds
	)
	sequence += 1
	var expected_shapes: Array[StringName] = [
		FsAGameplayLoop.TELEGRAPH_LINE,
		FsAGameplayLoop.TELEGRAPH_SECTOR,
		FsAGameplayLoop.TELEGRAPH_LINE,
		FsAGameplayLoop.TELEGRAPH_SECTOR,
	]
	for index in range(expected_shapes.size()):
		var expected_shape := expected_shapes[index]
		var warning: Dictionary = arena.get_snapshot().get("telegraph", {})
		_check(warning.get("shape") == expected_shape, "arena pre-fatal hit %d uses expected telegraph" % (index + 1))
		var warning_seconds := (
			tuning.line_telegraph_seconds
			if expected_shape == FsAGameplayLoop.TELEGRAPH_LINE
			else tuning.sector_telegraph_seconds
		)
		var hit_command := Phase1InputCommand.create(
			sequence,
			sequence,
			Vector2.ZERO,
			Vector2.RIGHT,
			false,
			player.entity_id
		)
		var hit_step := arena.step_authority_command(
			hit_command,
			&"",
			false,
			warning_seconds
		)
		sequence += 1
		_check(bool((hit_step.get("enemy_hit", {}) as Dictionary).get("hit", false)), "arena pre-fatal hit %d resolves" % (index + 1))
		if index + 1 < expected_shapes.size():
			var cycle_command := Phase1InputCommand.create(
				sequence,
				sequence,
				Vector2.ZERO,
				Vector2.RIGHT,
				false,
				player.entity_id
			)
			arena.step_authority_command(
				cycle_command,
				&"",
				false,
				_enemy_cycle_seconds(tuning, expected_shape)
			)
			sequence += 1
	var expected_pre_fatal_integrity := (
		tuning.player_integrity_max
		- (tuning.line_integrity_damage * 2)
		- (tuning.sector_integrity_damage * 2)
	)
	_check(arena.get_snapshot().get("player_integrity") == expected_pre_fatal_integrity, "arena preserves provisional pre-fatal Integrity arithmetic")
	_check(expected_pre_fatal_integrity > 0 and expected_pre_fatal_integrity <= tuning.line_integrity_damage, "arena reaches a positive line-fatal edge")

	var final_cycle_command := Phase1InputCommand.create(
		sequence,
		sequence,
		Vector2.ZERO,
		Vector2.RIGHT,
		false,
		player.entity_id
	)
	arena.step_authority_command(
		final_cycle_command,
		&"",
		false,
		_enemy_cycle_seconds(tuning, FsAGameplayLoop.TELEGRAPH_SECTOR)
	)
	sequence += 1
	var final_warning: Dictionary = arena.get_snapshot().get("telegraph", {})
	_check(
		bool(final_warning.get("active", false))
		and final_warning.get("shape") == FsAGameplayLoop.TELEGRAPH_LINE,
		"arena fatal line warning starts"
	)
	var tick_seconds := 1.0 / 60.0
	var warning_lead_seconds := tuning.line_telegraph_seconds - (tick_seconds * 2.0)
	var warning_lead_command := Phase1InputCommand.create(
		sequence,
		sequence,
		Vector2.ZERO,
		Vector2.RIGHT,
		false,
		player.entity_id
	)
	arena.step_authority_command(
		warning_lead_command,
		&"",
		false,
		warning_lead_seconds
	)
	sequence += 1
	var evade_action_command := Phase1InputCommand.create(
		sequence,
		sequence,
		Vector2.RIGHT,
		Vector2.RIGHT,
		false,
		player.entity_id,
		&"",
		true
	)
	var evade_action_step := arena.step_authority_command(
		evade_action_command,
		FsAPlayerAction.ACTION_LIGHT,
		false,
		tick_seconds
	)
	sequence += 1
	var before_fatal := arena.get_snapshot()
	_check(bool(evade_action_step.get("action_accepted", false)), "fatal setup accepts pending player action")
	_check(before_fatal.get("player_integrity") == expected_pre_fatal_integrity, "fatal setup keeps provisional Integrity positive")
	_check(bool(player.debug_evade_state().get("active", false)), "fatal setup has active evade")
	_check(player.velocity.length_squared() > 0.0, "fatal setup has non-zero velocity")
	_check(
		before_fatal.get("player_action", {}).get("state") == FsAPlayerAction.STATE_WINDUP,
		"fatal setup has pending action windup"
	)
	var position_before_fatal_tick := player.global_position
	var event_count_before_fatal := events.size()
	var enemy_event_count_before_fatal := _event_count(events, &"enemy_hit_resolved")
	var fatal_command := Phase1InputCommand.create(
		sequence,
		sequence,
		Vector2.ZERO,
		Vector2.RIGHT,
		false,
		player.entity_id
	)
	var fatal_step := arena.step_authority_command(
		fatal_command,
		&"",
		false,
		tick_seconds
	)
	sequence += 1
	var fatal_enemy_hit: Dictionary = fatal_step.get("enemy_hit", {})
	var defeated := arena.get_snapshot()
	var defeat_position := player.global_position
	_check(bool(fatal_enemy_hit.get("hit", false)), "arena fatal hit resolves")
	_check(defeated.get("player_integrity") == 0, "arena fatal hit reaches exact zero Integrity")
	_check(arena.get_debug_counters().get("player_defeat_latches") == 1, "arena player defeat latches exact once")
	_check(events.size() == event_count_before_fatal + 1, "arena fatal hit emits only existing enemy resolution")
	_check(_event_count(events, &"enemy_hit_resolved") == enemy_event_count_before_fatal + 1, "arena fatal hit forwards exact one enemy resolution")
	var fatal_event := _last_event_payload(events, &"enemy_hit_resolved")
	_check(
		bool(fatal_event.get("hit", false))
		and fatal_event.get("attack_id") == fatal_enemy_hit.get("attack_id")
		and fatal_event.get("shape") == fatal_enemy_hit.get("shape"),
		"arena fatal event matches authoritative result"
	)
	_check(defeat_position.x > position_before_fatal_tick.x, "fatal tick preserves legal evade motion before latch")
	_check(not defeat_position.is_equal_approx(tuning.player_start_position), "fatal latch does not teleport to spawn")
	_check(defeated.get("player_position", Vector2.INF).is_equal_approx(defeat_position), "fatal latch snapshot matches actor position")
	_check(not bool(player.debug_evade_state().get("active", true)), "fatal latch cancels active evade")
	_check(player.velocity.is_equal_approx(Vector2.ZERO), "fatal latch zeros player velocity")
	var defeated_action: Dictionary = defeated.get("player_action", {})
	_check(defeated_action.get("state") == FsAPlayerAction.STATE_IDLE, "fatal latch cancels pending action")
	_check(not bool(defeated_action.get("hit_query_pending", true)), "fatal latch clears pending player query")

	var frozen_snapshot: Dictionary = defeated
	var frozen_counters: Dictionary = arena.get_debug_counters()
	var frozen_event_count := events.size()
	var post_commands: Array[Dictionary] = [
		{
			"move": Vector2.RIGHT,
			"evade": false,
			"action": FsAPlayerAction.ACTION_LIGHT,
			"interact": false,
			"delta": tick_seconds,
		},
		{
			"move": Vector2.LEFT,
			"evade": true,
			"action": FsAPlayerAction.ACTION_HEAVY,
			"interact": false,
			"delta": tick_seconds,
		},
		{
			"move": Vector2.UP,
			"evade": true,
			"action": &"",
			"interact": true,
			"delta": tick_seconds,
		},
		{
			"move": Vector2.DOWN,
			"evade": false,
			"action": &"",
			"interact": false,
			"delta": 20.0,
		},
	]
	var post_results_are_noop := true
	var post_state_is_frozen := true
	for command_spec in post_commands:
		var post_command := Phase1InputCommand.create(
			sequence,
			sequence,
			command_spec.get("move", Vector2.ZERO),
			Vector2.RIGHT,
			false,
			player.entity_id,
			&"",
			bool(command_spec.get("evade", false))
		)
		var post_result := arena.step_authority_command(
			post_command,
			command_spec.get("action", &""),
			bool(command_spec.get("interact", false)),
			float(command_spec.get("delta", 0.0))
		)
		sequence += 1
		post_results_are_noop = (
			post_results_are_noop
			and not bool(post_result.get("action_accepted", true))
			and not bool(post_result.get("harvest_collected", true))
			and not bool(post_result.get("rematch_reset", true))
			and (post_result.get("player_hit", {}) as Dictionary).is_empty()
			and (post_result.get("enemy_hit", {}) as Dictionary).is_empty()
		)
		post_state_is_frozen = (
			post_state_is_frozen
			and arena.get_snapshot() == frozen_snapshot
			and arena.get_debug_counters() == frozen_counters
			and events.size() == frozen_event_count
			and player.global_position.is_equal_approx(defeat_position)
		)
	_check(post_results_are_noop, "defeat makes move evade light heavy and interact commands no-op")
	_check(post_state_is_frozen, "defeat freezes player enemy counters events and position")
	_check(player.velocity.is_equal_approx(Vector2.ZERO), "defeat keeps player velocity stopped")
	_check(not bool(player.debug_evade_state().get("active", true)), "defeat keeps evade stopped")
	_check(defeated.get("loop_phase") == FsAGameplayLoop.LOOP_COMBAT, "arena defeat preserves combat phase")
	_check(defeated.get("boss_hp") == tuning.boss_hp_max, "arena defeat preserves boss HP")
	_check(bool(defeated.get("boss_functional", false)), "arena defeat preserves boss function")
	_check(defeated.get("parts")[0].get("hp") == tuning.part_hp_max, "arena defeat preserves part HP")
	_check(not bool(defeated.get("parts")[0].get("broken", true)), "arena defeat preserves unbroken part")
	_check(not bool(defeated.get("wreck_active", true)), "arena defeat does not spawn wreck")
	_check(_all_harvest_uncollected(defeated.get("harvest_points", [])), "arena defeat does not collect harvest")
	_check(not bool(defeated.get("result_visible", true)), "arena defeat does not create result")
	_check(not bool(defeated.get("rematch_available", true)), "arena defeat does not enable rematch")
	_check(defeated.get("result_rewards", {}).get("amount") == 0, "arena defeat does not create reward")
	var runtime := arena.runtime_counts()
	_check(runtime.get("wreck_nodes") == 0 and runtime.get("harvest_nodes") == 0, "arena defeat creates no post-combat nodes")
	arena.queue_free()
	await process_frame


func _test_gameplay_scene(tuning: FsATuning) -> void:
	var packed := load("res://scenes/fast_slice/gameplay/fs_a_gameplay_arena.tscn") as PackedScene
	_check(packed != null, "gameplay child scene loads")
	if packed == null:
		return
	var arena := packed.instantiate() as FsAGameplayArena
	arena.live_input_enabled = false
	var translated_parent := Node2D.new()
	translated_parent.position = Vector2(240.0, 160.0)
	root.add_child(translated_parent)
	translated_parent.add_child(arena)
	await process_frame
	await physics_frame
	_check(arena.is_ready_for_gameplay(), "gameplay child scene configures headless")
	var boss_authority := arena.get_node("%BossAuthority") as Node2D
	var part_authority := arena.get_node("%BreakablePartAuthority") as Node2D
	_check(boss_authority.global_position.is_equal_approx(tuning.boss_position), "translated child keeps boss authority on snapshot coordinates")
	_check(part_authority.global_position.is_equal_approx(tuning.boss_position + tuning.part_offset), "translated child keeps part authority on snapshot coordinates")
	var player := arena.get_player_actor()
	_check(player.global_position.is_equal_approx(tuning.player_start_position), "translated child keeps player on snapshot coordinates")
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
	var wreck_authority := arena.get_node("RuntimeSpawns/WreckAuthority") as Node2D
	_check(wreck_authority.global_position.is_equal_approx(tuning.boss_position), "translated child keeps wreck on snapshot coordinates")

	var harvest_points: Array = arena.get_snapshot().get("harvest_points", [])
	for point_variant in harvest_points:
		var point_for_position: Dictionary = point_variant
		var harvest_node_name := String(point_for_position.get("id", &"")).replace(".", "_")
		var harvest_node := wreck_authority.get_node(harvest_node_name) as Node2D
		_check(harvest_node.global_position.is_equal_approx(point_for_position.get("position")), "translated child keeps harvest authority on snapshot coordinates")
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
	translated_parent.queue_free()
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


func _event_count(events: Array[Dictionary], event_name: StringName) -> int:
	var count := 0
	for event in events:
		if event.get("name") == event_name:
			count += 1
	return count


func _last_event_payload(events: Array[Dictionary], event_name: StringName) -> Dictionary:
	for index in range(events.size() - 1, -1, -1):
		var event: Dictionary = events[index]
		if event.get("name") == event_name:
			return event.get("payload", {})
	return {}


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
