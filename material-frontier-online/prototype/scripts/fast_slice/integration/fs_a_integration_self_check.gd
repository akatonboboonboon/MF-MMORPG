extends SceneTree

const MAIN_SCENE_PATH := "res://scenes/fast_slice/fs_a_main.tscn"
const GAMEPLAY_SCENE_PATH := "res://scenes/fast_slice/gameplay/fs_a_gameplay_arena.tscn"
const PRESENTATION_SCENE_PATH := "res://scenes/fast_slice/presentation/fs_a_presentation_shell.tscn"

var _failures: Array[String] = []
var _check_count: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_test_snapshot_adapter()
	_test_event_adapter()
	var enabled_result: Dictionary = await _run_integrated_loop(true)
	var disabled_result: Dictionary = await _run_integrated_loop(false)
	if not enabled_result.is_empty() and not disabled_result.is_empty():
		_check(
			enabled_result.get("result_snapshot") == disabled_result.get("result_snapshot"),
			"Presentation enabled and disabled produce the same result authority snapshot"
		)
		_check(
			enabled_result.get("reset_snapshot") == disabled_result.get("reset_snapshot"),
			"Presentation enabled and disabled produce the same rematch reset snapshot"
		)
		_check(
			enabled_result.get("final_snapshot") == disabled_result.get("final_snapshot"),
			"Presentation enabled and disabled produce the same round-two authority snapshot"
		)
		_check(
			enabled_result.get("round_two_action_result")
			== disabled_result.get("round_two_action_result"),
			"Presentation enabled and disabled produce the same complete round-two action result"
		)
		var enabled_debug: Dictionary = enabled_result.get("debug", {})
		var disabled_debug: Dictionary = disabled_result.get("debug", {})
		_check(
			enabled_debug.get("snapshot_updates_received")
			== disabled_debug.get("snapshot_updates_received"),
			"Presentation enablement does not change Gameplay snapshot production"
		)
		_check(
			enabled_debug.get("event_updates_received")
			== disabled_debug.get("event_updates_received"),
			"Presentation enablement does not change Gameplay event production"
		)
		_check(
			int(enabled_debug.get("snapshot_updates_presented", 0)) > 0,
			"enabled Presentation receives snapshots"
		)
		_check(
			disabled_debug.get("snapshot_updates_presented") == 0,
			"disabled Presentation receives no snapshots"
		)
		_check(
			disabled_debug.get("event_updates_presented") == 0,
			"disabled Presentation receives no events"
		)

	if _failures.is_empty():
		print(
			"[MFO-FS-A-INTEGRATION] self_check=PASS checks=%d shapes=3 events=3 one_loop=true presentation_parity=true"
			% _check_count
		)
		quit(0)
		return
	for failure in _failures:
		push_error("[MFO-FS-A-INTEGRATION] %s" % failure)
	quit(3)


func _test_snapshot_adapter() -> void:
	var line_source := _snapshot_fixture(&"telegraph_line", true)
	var line_before := line_source.duplicate(true)
	var line_result := FsAIntegrationRoot.adapt_snapshot_for_presentation(line_source)
	_check(bool(line_result.get("accepted", false)), "active telegraph_line is accepted")
	var line_copy: Dictionary = line_result.get("presentation_snapshot", {})
	var line_telegraph: Dictionary = line_copy.get("telegraph", {})
	_check(line_telegraph.get("shape") == &"line", "telegraph_line maps to line")
	_check(line_telegraph.get("active") == true, "line mapping preserves active=true")
	_check(line_telegraph.get("id") == &"fixture.telegraph", "line mapping preserves telegraph id")
	_check(line_telegraph.get("duration") == 0.75, "line mapping preserves duration")
	_check(line_telegraph.get("progress") == 0.25, "line mapping preserves progress")
	_check(line_source == line_before, "line mapping does not write back to Gameplay source")
	var line_expected := line_before.duplicate(true)
	line_expected.get("telegraph")["shape"] = &"line"
	_check(line_copy == line_expected, "line mapping changes only telegraph shape")
	_check(line_result.is_read_only(), "snapshot adapter result is read-only")
	_check(line_copy.is_read_only(), "Presentation snapshot copy is read-only")
	_check(line_telegraph.is_read_only(), "Presentation telegraph copy is read-only")
	var line_parts: Array = line_copy.get("parts", [])
	_check(line_parts.is_read_only(), "Presentation nested arrays are read-only")
	var line_part: Dictionary = line_parts[0]
	_check(line_part.is_read_only(), "Presentation nested dictionaries are read-only")
	line_source.get("parts")[0]["hp"] = -999
	_check(line_part.get("hp") == 60, "source mutation cannot leak into Presentation copy")

	var sector_source := _snapshot_fixture(&"telegraph_sector", true)
	var sector_before := sector_source.duplicate(true)
	var sector_result := FsAIntegrationRoot.adapt_snapshot_for_presentation(sector_source)
	_check(bool(sector_result.get("accepted", false)), "active telegraph_sector is accepted")
	var sector_copy: Dictionary = sector_result.get("presentation_snapshot", {})
	_check(
		sector_copy.get("telegraph", {}).get("shape") == &"sector",
		"telegraph_sector maps to sector"
	)
	_check(sector_source == sector_before, "sector mapping does not write back to Gameplay source")
	var sector_expected := sector_before.duplicate(true)
	sector_expected.get("telegraph")["shape"] = &"sector"
	_check(sector_copy == sector_expected, "sector mapping changes only telegraph shape")

	var inactive_source := _snapshot_fixture(&"", false)
	var inactive_before := inactive_source.duplicate(true)
	var inactive_result := FsAIntegrationRoot.adapt_snapshot_for_presentation(inactive_source)
	_check(bool(inactive_result.get("accepted", false)), "inactive empty telegraph is accepted")
	var inactive_copy: Dictionary = inactive_result.get("presentation_snapshot", {})
	var inactive_telegraph: Dictionary = inactive_copy.get("telegraph", {})
	_check(inactive_telegraph.get("shape") == &"line", "inactive empty maps to placeholder line")
	_check(inactive_telegraph.get("active") == false, "inactive placeholder preserves active=false")
	_check(inactive_source == inactive_before, "inactive normalization does not write back")
	var inactive_expected := inactive_before.duplicate(true)
	inactive_expected.get("telegraph")["shape"] = &"line"
	_check(inactive_copy == inactive_expected, "inactive normalization changes only shape")

	var active_empty := FsAIntegrationRoot.adapt_snapshot_for_presentation(
		_snapshot_fixture(&"", true)
	)
	_check(not bool(active_empty.get("accepted", true)), "active empty telegraph fails closed")
	_check(
		active_empty.get("error") == "snapshot.telegraph_active_empty_shape",
		"active empty telegraph reports the exact rejection"
	)
	var unknown_active := FsAIntegrationRoot.adapt_snapshot_for_presentation(
		_snapshot_fixture(&"telegraph_unknown", true)
	)
	_check(not bool(unknown_active.get("accepted", true)), "unknown active shape fails closed")
	var unknown_inactive := FsAIntegrationRoot.adapt_snapshot_for_presentation(
		_snapshot_fixture(&"telegraph_unknown", false)
	)
	_check(not bool(unknown_inactive.get("accepted", true)), "unknown inactive shape fails closed")
	var missing_shape := _snapshot_fixture(&"telegraph_line", true)
	missing_shape.get("telegraph").erase("shape")
	_check(
		not bool(
			FsAIntegrationRoot.adapt_snapshot_for_presentation(missing_shape).get(
				"accepted", true
			)
		),
		"missing telegraph shape fails closed"
	)
	var missing_active := _snapshot_fixture(&"telegraph_line", true)
	missing_active.get("telegraph").erase("active")
	_check(
		not bool(
			FsAIntegrationRoot.adapt_snapshot_for_presentation(missing_active).get(
				"accepted", true
			)
		),
		"missing telegraph active fails closed"
	)


func _test_event_adapter() -> void:
	var action_payload := {
		"action_id": &"heavy",
		"nested": {"value": 1},
	}
	var action_before := action_payload.duplicate(true)
	var action_result := FsAIntegrationRoot.adapt_event_for_presentation(
		&"player_action_accepted",
		action_payload
	)
	_check(bool(action_result.get("accepted", false)), "player_action_accepted is mapped")
	var action_event: Dictionary = action_result.get("presentation_event", {})
	_check(action_event.get("event_name") == &"ActionStarted", "action event maps exactly")
	_check(action_payload == action_before, "action mapping does not write back to payload")
	_check(action_event.is_read_only(), "Presentation event envelope is read-only")
	var action_copy_payload: Dictionary = action_event.get("payload", {})
	_check(action_copy_payload.is_read_only(), "Presentation event payload is read-only")
	action_payload.get("nested")["value"] = 99
	_check(
		action_copy_payload.get("nested", {}).get("value") == 1,
		"source payload mutation cannot leak into Presentation event"
	)

	var hit_payload := {
		"hit": true,
		"target_id": &"boss.large.1",
		"nested": {"damage": 24},
	}
	var hit_before := hit_payload.duplicate(true)
	var hit_result := FsAIntegrationRoot.adapt_event_for_presentation(
		&"player_hit_resolved",
		hit_payload
	)
	_check(bool(hit_result.get("accepted", false)), "confirmed player hit is mapped")
	var hit_event: Dictionary = hit_result.get("presentation_event", {})
	_check(
		hit_event.get("event_name") == &"HitConfirmed",
		"confirmed hit maps exactly"
	)
	var hit_copy_payload: Dictionary = hit_event.get("payload", {})
	_check(hit_payload == hit_before, "hit mapping does not write back to payload")
	_check(hit_event.is_read_only(), "HitConfirmed envelope is read-only")
	_check(hit_copy_payload.is_read_only(), "HitConfirmed payload is read-only")
	_check(hit_copy_payload == hit_before, "HitConfirmed preserves the complete payload")
	hit_payload.get("nested")["damage"] = 999
	_check(
		hit_copy_payload.get("nested", {}).get("damage") == 24,
		"hit source mutation cannot leak into Presentation event"
	)
	var miss_result := FsAIntegrationRoot.adapt_event_for_presentation(
		&"player_hit_resolved",
		{"hit": false}
	)
	_check(not bool(miss_result.get("accepted", true)), "unconfirmed player hit fails closed")
	_check(
		not bool(
			FsAIntegrationRoot.adapt_event_for_presentation(
				&"player_hit_resolved",
				{}
			).get("accepted", true)
		),
		"player hit without hit field fails closed"
	)
	_check(
		not bool(
			FsAIntegrationRoot.adapt_event_for_presentation(
				&"player_hit_resolved",
				{"hit": 1}
			).get("accepted", true)
		),
		"player hit with non-bool hit field fails closed"
	)

	var part_payload := {
		"part_id": &"part.core_plate",
		"nested": {"break_count": 1},
	}
	var part_before := part_payload.duplicate(true)
	var part_result := FsAIntegrationRoot.adapt_event_for_presentation(
		&"part_broken",
		part_payload
	)
	_check(bool(part_result.get("accepted", false)), "part_broken is mapped")
	var part_event: Dictionary = part_result.get("presentation_event", {})
	_check(
		part_event.get("event_name") == &"PartBroken",
		"part break maps exactly"
	)
	var part_copy_payload: Dictionary = part_event.get("payload", {})
	_check(part_payload == part_before, "part mapping does not write back to payload")
	_check(part_event.is_read_only(), "PartBroken envelope is read-only")
	_check(part_copy_payload.is_read_only(), "PartBroken payload is read-only")
	_check(part_copy_payload == part_before, "PartBroken preserves the complete payload")
	part_payload.get("nested")["break_count"] = 99
	_check(
		part_copy_payload.get("nested", {}).get("break_count") == 1,
		"part source mutation cannot leak into Presentation event"
	)
	var unmapped_result := FsAIntegrationRoot.adapt_event_for_presentation(
		&"boss_defeated",
		{"boss_id": &"boss.large.1"}
	)
	_check(not bool(unmapped_result.get("accepted", true)), "unmapped event fails closed")


func _run_integrated_loop(presentation_enabled: bool) -> Dictionary:
	var packed := load(MAIN_SCENE_PATH) as PackedScene
	_check(packed != null, "integration main scene loads")
	if packed == null:
		return {}
	var main := packed.instantiate() as FsAIntegrationRoot
	_check(main != null, "integration main scene instantiates as FsAIntegrationRoot")
	if main == null:
		return {}
	main.presentation_enabled = presentation_enabled
	main.live_input_enabled = false
	root.add_child(main)
	await process_frame
	await physics_frame

	var mode := "enabled" if presentation_enabled else "disabled"
	_check(main.is_ready_for_integration(), "%s integration root is ready" % mode)
	_check(main.get_child_count() == 2, "%s main owns exact two composed children" % mode)
	var gameplay := main.get_gameplay_arena()
	var presentation := main.get_presentation_shell()
	_check(gameplay != null, "%s main owns Gameplay child" % mode)
	_check(presentation != null, "%s main owns pure Presentation shell" % mode)
	if not main.is_ready_for_integration() or gameplay == null or presentation == null:
		main.queue_free()
		await process_frame
		return {}
	_check(
		gameplay.scene_file_path == GAMEPLAY_SCENE_PATH,
		"%s main instances the exact Gameplay arena scene" % mode
	)
	_check(
		presentation.scene_file_path == PRESENTATION_SCENE_PATH,
		"%s main instances the exact pure Presentation shell scene" % mode
	)
	_check(presentation.visible == presentation_enabled, "%s Presentation visibility matches mode" % mode)
	_check(
		main.find_child("PreviewStub", true, false) == null,
		"%s integration does not use preview stub" % mode
	)
	var initial_debug := main.get_debug_state()
	_check(
		initial_debug.get("snapshot_signal_connections") == 1,
		"%s snapshot signal is connected exact once" % mode
	)
	_check(
		initial_debug.get("gameplay_event_connections") == 1,
		"%s Gameplay event signal is connected exact once" % mode
	)
	_check(initial_debug.get("snapshot_updates_received") == 1, "%s initial snapshot is pulled exact once" % mode)
	_check(
		initial_debug.get("snapshot_updates_presented") == (1 if presentation_enabled else 0),
		"%s initial snapshot presentation count matches mode" % mode
	)
	var initial_source := main.get_authority_snapshot()
	var initial_parts: Array = initial_source.get("parts", [])
	var tuning := gameplay.tuning
	var player := gameplay.get_player_actor()
	_check(tuning != null, "%s Gameplay tuning is present" % mode)
	_check(player != null, "%s Gameplay player is present" % mode)
	_check(not initial_parts.is_empty(), "%s initial snapshot has a part" % mode)
	if tuning == null or player == null or initial_parts.is_empty():
		main.queue_free()
		await process_frame
		return {}
	var initial_before := initial_source.duplicate(true)
	var initial_telegraph: Dictionary = initial_source.get("telegraph", {})
	_check(
		String(initial_telegraph.get("shape", "")).is_empty()
		and initial_telegraph.get("active") == false,
		"%s initial Gameplay snapshot keeps inactive empty telegraph" % mode
	)
	if presentation_enabled:
		var initial_presented := main.get_presented_snapshot()
		var presented_telegraph: Dictionary = initial_presented.get("telegraph", {})
		_check(
			presented_telegraph.get("shape") == &"line"
			and presented_telegraph.get("active") == false,
			"enabled initial Presentation receives invisible line placeholder"
		)
		_check(initial_source == initial_before, "initial Presentation forwarding preserves source")
	else:
		_check(main.get_presented_snapshot().is_empty(), "disabled Presentation has no snapshot")

	_test_runtime_adapter_path(main, gameplay, initial_source, presentation_enabled, mode)
	var fixture_debug := main.get_debug_state()
	var sequence := 10000
	var attack_position: Vector2 = gameplay.get_snapshot().get("parts")[0].get("position")
	attack_position -= Vector2(tuning.heavy_reach * 0.55, 0.0)
	player.reset_authority_state(attack_position, Vector2.RIGHT)
	var attack_count := 0
	while int(main.get_authority_snapshot().get("boss_hp", 0)) > 0 and attack_count < 12:
		var request_result := main.step_authority_command(
			_command(player, sequence),
			FsAPlayerAction.ACTION_HEAVY,
			false,
			0.0
		)
		sequence += 1
		_check(bool(request_result.get("action_accepted", false)), "%s heavy action accepts" % mode)
		var active_result := main.step_authority_command(
			_command(player, sequence),
			&"",
			false,
			tuning.heavy_windup_seconds
		)
		sequence += 1
		var player_hit: Dictionary = active_result.get("player_hit", {})
		_check(bool(player_hit.get("hit", false)), "%s heavy action resolves a hit" % mode)
		main.step_authority_command(
			_command(player, sequence),
			&"",
			false,
			tuning.heavy_active_seconds + tuning.heavy_recovery_seconds
		)
		sequence += 1
		attack_count += 1

	var wreck_snapshot := main.get_authority_snapshot()
	_check(wreck_snapshot.get("loop_phase") == &"wreck", "%s loop reaches wreck" % mode)
	_check(wreck_snapshot.get("boss_hp") == 0, "%s boss reaches HP zero" % mode)
	_check(not bool(wreck_snapshot.get("boss_functional", true)), "%s boss function stops" % mode)
	_check(bool(wreck_snapshot.get("wreck_active", false)), "%s wreck is active" % mode)
	var runtime_counts := gameplay.runtime_counts()
	_check(runtime_counts.get("wreck_nodes") == 1, "%s wreck node is exact one" % mode)
	_check(runtime_counts.get("harvest_nodes") == 3, "%s harvest nodes are exact three" % mode)
	var harvest_points: Array = wreck_snapshot.get("harvest_points", [])
	_check(harvest_points.size() == 3, "%s snapshot harvest points are exact three" % mode)
	for index in range(harvest_points.size()):
		var point: Dictionary = harvest_points[index]
		player.reset_authority_state(point.get("position"), Vector2.RIGHT)
		var collection := main.step_authority_command(
			_command(player, sequence),
			&"",
			true,
			0.0
		)
		sequence += 1
		_check(
			bool(collection.get("harvest_collected", false)),
			"%s harvest point %d collects" % [mode, index + 1]
		)
		if index == 0:
			var duplicate := main.step_authority_command(
				_command(player, sequence),
				&"",
				true,
				0.0
			)
			sequence += 1
			_check(
				not bool(duplicate.get("harvest_collected", true)),
				"%s duplicate harvest is rejected" % mode
			)

	main.step_authority_command(
		_command(player, sequence),
		&"",
		false,
		tuning.result_delay_seconds
	)
	sequence += 1
	var result_snapshot := main.get_authority_snapshot()
	_check(result_snapshot.get("loop_phase") == &"result", "%s loop reaches result" % mode)
	_check(bool(result_snapshot.get("result_visible", false)), "%s result is visible" % mode)
	_check(bool(result_snapshot.get("rematch_available", false)), "%s rematch is available" % mode)

	var rematch := main.step_authority_command(
		_command(player, sequence),
		&"",
		true,
		0.0
	)
	sequence += 1
	_check(bool(rematch.get("rematch_reset", false)), "%s rematch resets" % mode)
	var reset_snapshot := main.get_authority_snapshot()
	_check(reset_snapshot.get("loop_phase") == &"combat", "%s rematch returns to combat" % mode)
	_check(not bool(reset_snapshot.get("wreck_active", true)), "%s rematch clears wreck" % mode)
	_check(not bool(reset_snapshot.get("result_visible", true)), "%s rematch clears result" % mode)
	_check(_all_harvest_uncollected(reset_snapshot.get("harvest_points", [])), "%s rematch clears harvest" % mode)
	_check(reset_snapshot == initial_source, "%s rematch restores the complete initial authority snapshot" % mode)
	var reset_runtime_counts := gameplay.runtime_counts()
	_check(reset_runtime_counts.get("boss_nodes") == 1, "%s rematch keeps exact one boss node" % mode)
	_check(reset_runtime_counts.get("part_nodes") == 1, "%s rematch keeps exact one part node" % mode)
	_check(reset_runtime_counts.get("wreck_nodes") == 0, "%s rematch removes the wreck node" % mode)
	_check(reset_runtime_counts.get("harvest_nodes") == 0, "%s rematch removes harvest nodes" % mode)

	var part: Dictionary = reset_snapshot.get("parts")[0]
	var round_two_position: Vector2 = part.get("position")
	round_two_position -= Vector2(tuning.light_reach * 0.55, 0.0)
	player.reset_authority_state(round_two_position, Vector2.RIGHT)
	var round_two_request := main.step_authority_command(
		_command(player, sequence),
		FsAPlayerAction.ACTION_LIGHT,
		false,
		0.0
	)
	sequence += 1
	_check(bool(round_two_request.get("action_accepted", false)), "%s round-two light accepts" % mode)
	var round_two_active := main.step_authority_command(
		_command(player, sequence),
		&"",
		false,
		tuning.light_windup_seconds
	)
	var round_two_player_hit: Dictionary = round_two_active.get("player_hit", {})
	var round_two_hit := bool(round_two_player_hit.get("hit", false))
	_check(round_two_hit, "%s round-two major action hits" % mode)
	var final_snapshot := main.get_authority_snapshot()
	var final_debug := main.get_debug_state()
	_check(
		final_debug.get("snapshot_updates_rejected")
		== fixture_debug.get("snapshot_updates_rejected"),
		"%s real Gameplay snapshots add no adapter rejections" % mode
	)
	if presentation_enabled:
		var event_counts: Dictionary = final_debug.get("presented_event_counts", {})
		var expected_action_count := attack_count + 1
		var expected_hit_count := attack_count + 1
		_check(
			event_counts.get("ActionStarted") == expected_action_count,
			"enabled forwards every ActionStarted exact once"
		)
		_check(
			event_counts.get("HitConfirmed") == expected_hit_count,
			"enabled forwards every HitConfirmed exact once"
		)
		_check(event_counts.get("PartBroken") == 1, "enabled forwards PartBroken exact once")
		_check(
			final_debug.get("event_updates_presented")
			== expected_action_count + expected_hit_count + 1,
			"enabled presents only the exact mapped Gameplay events"
		)
		_check(
			final_debug.get("snapshot_updates_presented")
			== int(final_debug.get("snapshot_updates_received", 0))
			- int(final_debug.get("snapshot_updates_rejected", 0)),
			"enabled presents every accepted snapshot update exact once"
		)
		var final_adaptation := FsAIntegrationRoot.adapt_snapshot_for_presentation(final_snapshot)
		_check(bool(final_adaptation.get("accepted", false)), "enabled final snapshot adapts")
		_check(
			main.get_presented_snapshot() == final_adaptation.get("presentation_snapshot"),
			"enabled Presentation reflects the complete normalized authority snapshot"
		)

	var outcome := {
		"result_snapshot": result_snapshot,
		"reset_snapshot": reset_snapshot,
		"final_snapshot": final_snapshot,
		"round_two_action_result": {
			"request": round_two_request,
			"active": round_two_active,
		},
		"debug": final_debug,
	}
	main.queue_free()
	await process_frame
	return outcome


func _test_runtime_adapter_path(
	main: FsAIntegrationRoot,
	gameplay: FsAGameplayArena,
	authority_before: Dictionary,
	presentation_enabled: bool,
	mode: String
) -> void:
	var line_source := authority_before.duplicate(true)
	var line_telegraph: Dictionary = line_source.get("telegraph", {})
	line_telegraph["id"] = &"integration.fixture.line"
	line_telegraph["shape"] = &"telegraph_line"
	line_telegraph["duration"] = 0.6
	line_telegraph["progress"] = 0.25
	line_telegraph["active"] = true
	var line_before := line_source.duplicate(true)
	gameplay.snapshot_changed.emit(line_source)
	_check(line_source == line_before, "%s runtime line forwarding preserves signal source" % mode)
	_check(main.get_authority_snapshot() == authority_before, "%s runtime line forwarding preserves authority" % mode)
	if presentation_enabled:
		var expected_line := FsAIntegrationRoot.adapt_snapshot_for_presentation(line_source)
		_check(
			main.get_presented_snapshot() == expected_line.get("presentation_snapshot"),
			"enabled runtime signal maps line into the Presentation shell"
		)

	var sector_source := authority_before.duplicate(true)
	var sector_telegraph: Dictionary = sector_source.get("telegraph", {})
	sector_telegraph["id"] = &"integration.fixture.sector"
	sector_telegraph["shape"] = &"telegraph_sector"
	sector_telegraph["duration"] = 0.8
	sector_telegraph["progress"] = 0.5
	sector_telegraph["active"] = true
	var sector_before := sector_source.duplicate(true)
	gameplay.snapshot_changed.emit(sector_source)
	_check(sector_source == sector_before, "%s runtime sector forwarding preserves signal source" % mode)
	_check(main.get_authority_snapshot() == authority_before, "%s runtime sector forwarding preserves authority" % mode)
	if presentation_enabled:
		var expected_sector := FsAIntegrationRoot.adapt_snapshot_for_presentation(sector_source)
		_check(
			main.get_presented_snapshot() == expected_sector.get("presentation_snapshot"),
			"enabled runtime signal maps sector into the Presentation shell"
		)

	var presentation_before_rejections := main.get_presented_snapshot()
	var rejection_debug_before := main.get_debug_state()
	var active_empty := authority_before.duplicate(true)
	active_empty.get("telegraph")["shape"] = &""
	active_empty.get("telegraph")["active"] = true
	gameplay.snapshot_changed.emit(active_empty)
	var active_empty_debug := main.get_debug_state()
	_check(
		active_empty_debug.get("snapshot_updates_received")
		== int(rejection_debug_before.get("snapshot_updates_received", 0)) + 1,
		"%s runtime active-empty update is received exact once" % mode
	)
	_check(
		active_empty_debug.get("snapshot_updates_rejected")
		== int(rejection_debug_before.get("snapshot_updates_rejected", 0)) + 1,
		"%s runtime active-empty update is rejected exact once" % mode
	)
	_check(
		active_empty_debug.get("last_snapshot_error")
		== "snapshot.telegraph_active_empty_shape",
		"%s runtime active-empty update reports the exact error" % mode
	)
	_check(
		main.get_presented_snapshot() == presentation_before_rejections,
		"%s runtime active-empty rejection preserves the last Presentation update" % mode
	)
	_check(main.get_authority_snapshot() == authority_before, "%s active-empty rejection preserves authority" % mode)

	var unknown_shape := authority_before.duplicate(true)
	unknown_shape.get("telegraph")["shape"] = &"telegraph_unknown"
	unknown_shape.get("telegraph")["active"] = true
	gameplay.snapshot_changed.emit(unknown_shape)
	var unknown_debug := main.get_debug_state()
	_check(
		unknown_debug.get("snapshot_updates_rejected")
		== int(active_empty_debug.get("snapshot_updates_rejected", 0)) + 1,
		"%s runtime unknown shape update is rejected exact once" % mode
	)
	_check(
		unknown_debug.get("last_snapshot_error")
		== "snapshot.telegraph_unknown_shape:telegraph_unknown",
		"%s runtime unknown shape reports the exact error" % mode
	)
	_check(
		main.get_presented_snapshot() == presentation_before_rejections,
		"%s runtime unknown shape rejection preserves the last Presentation update" % mode
	)
	_check(main.get_authority_snapshot() == authority_before, "%s unknown shape rejection preserves authority" % mode)

	var feedback_before := main.get_presentation_shell().get_feedback_kind()
	var event_debug_before := main.get_debug_state()
	gameplay.gameplay_event.emit(&"integration_fixture_unmapped", {"nested": {"value": 1}})
	var unmapped_debug := main.get_debug_state()
	_check(
		unmapped_debug.get("event_updates_received")
		== int(event_debug_before.get("event_updates_received", 0)) + 1,
		"%s runtime unmapped event is received exact once" % mode
	)
	_check(
		unmapped_debug.get("event_updates_rejected")
		== int(event_debug_before.get("event_updates_rejected", 0)) + 1,
		"%s runtime unmapped event is rejected exact once" % mode
	)
	_check(
		unmapped_debug.get("last_event_error")
		== "event.unmapped:integration_fixture_unmapped",
		"%s runtime unmapped event reports the exact error" % mode
	)
	_check(
		main.get_presentation_shell().get_feedback_kind() == feedback_before,
		"%s runtime unmapped event preserves Presentation feedback" % mode
	)
	_check(main.get_authority_snapshot() == authority_before, "%s unmapped event preserves authority" % mode)

	gameplay.gameplay_event.emit(&"player_hit_resolved", {"hit": false})
	var miss_debug := main.get_debug_state()
	_check(
		miss_debug.get("event_updates_rejected")
		== int(unmapped_debug.get("event_updates_rejected", 0)) + 1,
		"%s runtime unconfirmed hit event is rejected exact once" % mode
	)
	_check(
		miss_debug.get("last_event_error") == "event.player_hit_resolved_not_confirmed",
		"%s runtime unconfirmed hit reports the exact error" % mode
	)
	_check(
		main.get_presentation_shell().get_feedback_kind() == feedback_before,
		"%s runtime unconfirmed hit preserves Presentation feedback" % mode
	)
	_check(main.get_authority_snapshot() == authority_before, "%s unconfirmed hit preserves authority" % mode)


func _snapshot_fixture(shape: StringName, active: bool) -> Dictionary:
	return {
		"loop_phase": &"combat",
		"player_integrity": 100,
		"player_integrity_max": 100,
		"player_deformation": 0.0,
		"boss_hp": 180,
		"boss_hp_max": 180,
		"parts": [
			{"id": &"part.core_plate", "hp": 60, "broken": false},
		],
		"telegraph": {
			"id": &"fixture.telegraph",
			"shape": shape,
			"duration": 0.75,
			"progress": 0.25,
			"active": active,
		},
		"boss_functional": true,
		"wreck_active": false,
		"harvest_points": [
			{"id": &"harvest.1", "collected": false},
			{"id": &"harvest.2", "collected": false},
			{"id": &"harvest.3", "collected": false},
		],
		"result_visible": false,
		"rematch_available": false,
	}


func _command(player: Phase1PlayerActor, sequence: int) -> Phase1InputCommand:
	return Phase1InputCommand.create(
		sequence,
		sequence,
		Vector2.ZERO,
		Vector2.RIGHT,
		false,
		player.entity_id
	)


func _all_harvest_uncollected(points: Array) -> bool:
	if points.size() != 3:
		return false
	for point_variant in points:
		var point: Dictionary = point_variant
		if bool(point.get("collected", true)):
			return false
	return true


func _check(condition: bool, description: String) -> void:
	_check_count += 1
	if condition:
		print("[MFO-FS-A-INTEGRATION] PASS: %s" % description)
		return
	_failures.append(description)
