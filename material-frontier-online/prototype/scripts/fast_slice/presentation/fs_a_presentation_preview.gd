class_name FSAPresentationPreview
extends Node2D

class PreviewEventObject:
	extends RefCounted
	var event_name: StringName

const DESIGN_SIZE := Vector2i(1920, 1080)
const CAPTURE_PREFIX := "--fs-a-capture="
const STATE_PREFIX := "--fs-a-state="
const EVENT_PREFIX := "--fs-a-event="
const GRAYSCALE_FLAG := "--fs-a-grayscale"
const SELF_CHECK_FLAG := "--fs-a-self-check"

@onready var _shell: FSAPresentationShell = $Shell
@onready var _stub: FSAPresentationPreviewStub = $PreviewStub

var _capture_path := ""
var _requested_state := "combat_line"
var _requested_event := ""
var _grayscale := false
var _self_check_requested := false


func _ready() -> void:
	for raw_argument in OS.get_cmdline_user_args():
		var argument := String(raw_argument)
		if argument == GRAYSCALE_FLAG:
			_grayscale = true
		elif argument == SELF_CHECK_FLAG:
			_self_check_requested = true
		elif argument.begins_with(CAPTURE_PREFIX):
			_capture_path = argument.trim_prefix(CAPTURE_PREFIX)
		elif argument.begins_with(STATE_PREFIX):
			_requested_state = argument.trim_prefix(STATE_PREFIX)
		elif argument.begins_with(EVENT_PREFIX):
			_requested_event = argument.trim_prefix(EVENT_PREFIX)

	if DisplayServer.get_name() != "headless":
		DisplayServer.window_set_size(DESIGN_SIZE)
	_shell.set_grayscale(_grayscale)
	_shell.set_preview_controls_visible(true)
	_stub.snapshot_changed.connect(_on_snapshot_changed)
	_stub.presentation_event.connect(_on_presentation_event)
	if not _stub.set_preview_state(_requested_state):
		push_error("Unknown FS-A presentation preview state: %s" % _requested_state)
		get_tree().quit(2)
		return
	if not _requested_event.is_empty():
		_shell.set_feedback_hold(true)
		if not _stub.emit_fixture_event(_requested_event):
			push_error("Unknown FS-A presentation preview event: %s" % _requested_event)
			get_tree().quit(2)
			return

	if _self_check_requested:
		call_deferred("_run_self_check_and_quit")
	elif not _capture_path.is_empty():
		call_deferred("_capture_and_quit")


func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return
	var key_event := event as InputEventKey
	if not key_event.pressed or key_event.echo:
		return
	var handled := true
	match key_event.keycode:
		KEY_G:
			_shell.set_grayscale(not _shell.is_grayscale())
		KEY_SPACE, KEY_RIGHT:
			_stub.next_preview_state()
		KEY_LEFT:
			_stub.previous_preview_state()
		KEY_1:
			_stub.set_preview_state("combat_line")
		KEY_2:
			_stub.set_preview_state("combat_sector")
		KEY_3:
			_stub.set_preview_state("wreck")
		KEY_4:
			_stub.set_preview_state("result")
		KEY_5:
			_stub.set_preview_state("reset")
		KEY_A:
			_stub.emit_fixture_event("ActionStarted")
		KEY_H:
			_stub.emit_fixture_event("HitConfirmed")
		KEY_B:
			_stub.emit_fixture_event("PartBroken")
		_:
			handled = false
	if handled:
		get_viewport().set_input_as_handled()


func _on_snapshot_changed(snapshot: Dictionary) -> void:
	if not _shell.apply_snapshot(snapshot):
		push_error("FS-A preview fixture emitted an invalid snapshot")


func _on_presentation_event(event: Dictionary) -> void:
	if not _shell.consume_domain_event(event):
		push_warning("FS-A preview fixture emitted an unsupported event")


func _run_self_check_and_quit() -> void:
	var errors := _stub.contract_self_check()
	var snapshots_checked := 0
	var anchor_checks := 0
	var player_positions: Dictionary = {}
	var player_aims: Dictionary = {}
	for state_id in FSAPresentationPreviewStub.STATE_ORDER:
		var source_snapshot: Dictionary = FSAPresentationPreviewStub.SNAPSHOTS[state_id].duplicate(true)
		var expected_snapshot := source_snapshot.duplicate(true)
		if not _shell.apply_snapshot(source_snapshot):
			errors.append("%s snapshot rejected by shell" % state_id)
			continue
		snapshots_checked += 1
		if _shell.get_presented_snapshot() != expected_snapshot:
			errors.append("%s snapshot changed while copied into shell" % state_id)
		if not _shell.is_presented_snapshot_deep_read_only():
			errors.append("%s shell copy is not deep read-only" % state_id)
		var geometry := _shell.get_spatial_debug_geometry()
		var geometry_errors := _spatial_geometry_errors(state_id, expected_snapshot, geometry)
		errors.append_array(geometry_errors)
		anchor_checks += 4 + expected_snapshot.parts.size() + expected_snapshot.harvest_points.size()
		player_positions[str(expected_snapshot.player_position)] = true
		var expected_aim: Vector2 = expected_snapshot.player_aim
		player_aims[str(expected_aim.normalized())] = true

		source_snapshot.player_position = Vector2(-999.0, -999.0)
		var source_parts: Array = source_snapshot.parts
		var source_part: Dictionary = source_parts[0]
		source_part.position = Vector2(-998.0, -998.0)
		var source_harvest: Array = source_snapshot.harvest_points
		var source_point: Dictionary = source_harvest[0]
		source_point.position = Vector2(-997.0, -997.0)
		var source_telegraph: Dictionary = source_snapshot.telegraph
		source_telegraph.origin = Vector2(-996.0, -996.0)
		if _shell.get_presented_snapshot() != expected_snapshot:
			errors.append("%s nested source mutation leaked into shell" % state_id)

	if player_positions.size() < 2:
		errors.append("player position fixtures did not exercise tracking")
	if player_aims.size() < 2:
		errors.append("player aim fixtures did not exercise tracking")

	var valid_source: Dictionary = FSAPresentationPreviewStub.SNAPSHOTS.combat_line.duplicate(true)
	if not _shell.apply_snapshot(valid_source):
		errors.append("valid baseline rejected before invalid-update checks")
	var last_valid_snapshot := _shell.get_presented_snapshot()
	var invalid_cases := _invalid_spatial_cases(valid_source)
	var invalid_updates_checked := 0
	for case_variant in invalid_cases:
		var invalid_case: Dictionary = case_variant
		var invalid_snapshot: Dictionary = invalid_case.snapshot
		var invalid_before := invalid_snapshot.duplicate(true)
		if _shell.apply_snapshot(invalid_snapshot):
			errors.append("%s invalid spatial update was accepted" % invalid_case.label)
		if _shell.get_presented_snapshot() != last_valid_snapshot:
			errors.append("%s invalid update replaced the last valid snapshot" % invalid_case.label)
		if invalid_snapshot != invalid_before:
			errors.append("%s invalid source snapshot was mutated" % invalid_case.label)
		invalid_updates_checked += 1

	var event_snapshot: Dictionary = FSAPresentationPreviewStub.SNAPSHOTS.combat_sector.duplicate(true)
	if not _shell.apply_snapshot(event_snapshot):
		errors.append("event anchor snapshot rejected")
	var snapshot_before_events := _shell.get_presented_snapshot()
	_shell.set_feedback_hold(true)
	var payload_variants_checked := 0
	var expected_kind_by_event := {
		"ActionStarted": "attack",
		"HitConfirmed": "hit",
		"PartBroken": "part_break",
	}
	for event_id in FSAPresentationPreviewStub.EVENT_ORDER:
		var reference_kind := ""
		var reference_anchor := Vector2.ZERO
		var reference_direction := Vector2.ZERO
		var variants: Array[Dictionary] = [
			{"event_name": event_id},
			{"event_name": event_id, "payload": {"target_id": "target_alpha", "part_id": "part_alpha"}},
			{"event_name": event_id, "payload": {"target_id": "target_beta", "part_id": "part_beta"}},
		]
		for variant_index in range(variants.size()):
			var event_fixture := variants[variant_index]
			var event_before := event_fixture.duplicate(true)
			if not _shell.consume_domain_event(event_fixture):
				errors.append("%s payload variant %d rejected" % [event_id, variant_index])
			if event_fixture != event_before:
				errors.append("%s payload variant %d was mutated" % [event_id, variant_index])
			if _shell.get_feedback_kind() != expected_kind_by_event[event_id]:
				errors.append("%s feedback kind mismatch" % event_id)
			if variant_index == 0:
				reference_kind = _shell.get_feedback_kind()
				reference_anchor = _shell.get_feedback_anchor()
				reference_direction = _shell.get_feedback_direction()
			else:
				if _shell.get_feedback_kind() != reference_kind:
					errors.append("%s payload changed feedback kind" % event_id)
				if not _shell.get_feedback_anchor().is_equal_approx(reference_anchor):
					errors.append("%s payload changed feedback anchor" % event_id)
				if not _shell.get_feedback_direction().is_equal_approx(reference_direction):
					errors.append("%s payload changed feedback direction" % event_id)
			payload_variants_checked += 1
		var expected_anchor := _expected_event_anchor(event_id, event_snapshot)
		if not reference_anchor.is_equal_approx(expected_anchor):
			errors.append("%s authority anchor mismatch" % event_id)
		var expected_direction := Vector2.ZERO
		if event_id != "PartBroken":
			var snapshot_aim: Vector2 = event_snapshot.player_aim
			expected_direction = snapshot_aim.normalized()
		if not reference_direction.is_equal_approx(expected_direction):
			errors.append("%s authority direction mismatch" % event_id)
		if _shell.get_presented_snapshot() != snapshot_before_events:
			errors.append("%s event changed authority snapshot" % event_id)

	var first_action_anchor := Vector2.ZERO
	var first_action_direction := Vector2.ZERO
	for state_index in range(2):
		var state_id: String = ["combat_line", "combat_sector"][state_index]
		var tracking_snapshot: Dictionary = FSAPresentationPreviewStub.SNAPSHOTS[state_id].duplicate(true)
		if not _shell.apply_snapshot(tracking_snapshot):
			errors.append("%s feedback tracking snapshot rejected" % state_id)
			continue
		for event_id in ["ActionStarted", "HitConfirmed"]:
			if not _shell.consume_domain_event({"event_name": event_id}):
				errors.append("%s %s feedback tracking event rejected" % [state_id, event_id])
			if not _shell.get_feedback_anchor().is_equal_approx(_expected_event_anchor(event_id, tracking_snapshot)):
				errors.append("%s %s feedback did not follow player position" % [state_id, event_id])
			var tracking_aim: Vector2 = tracking_snapshot.player_aim
			if not _shell.get_feedback_direction().is_equal_approx(tracking_aim.normalized()):
				errors.append("%s %s feedback did not follow player aim" % [state_id, event_id])
		if state_index == 0:
			first_action_anchor = _expected_event_anchor("ActionStarted", tracking_snapshot)
			var first_aim: Vector2 = tracking_snapshot.player_aim
			first_action_direction = first_aim.normalized()
		else:
			if first_action_anchor.is_equal_approx(_expected_event_anchor("ActionStarted", tracking_snapshot)):
				errors.append("ActionStarted tracking fixtures reused one player position")
			var second_aim: Vector2 = tracking_snapshot.player_aim
			if first_action_direction.is_equal_approx(second_aim.normalized()):
				errors.append("ActionStarted tracking fixtures reused one player aim")

	var object_event := PreviewEventObject.new()
	object_event.event_name = &"HitConfirmed"
	if not _shell.consume_domain_event(object_event):
		errors.append("Object event_name seam rejected")
	if _shell.consume_domain_event({"event_name": "UnsupportedFixtureEvent"}):
		errors.append("unsupported event was accepted")
	_shell.set_feedback_hold(false)
	_shell.clear_feedback()

	if errors.is_empty():
		print(
			"[MFO-FS-A-PRESENTATION] self_check=PASS snapshots=%d spatial_schema=true anchors=%d geometry=line+sector tracking_positions=%d tracking_aims=%d events=3 payload_variants=%d invalid_updates=%d deep_read_only=true"
			% [snapshots_checked, anchor_checks, player_positions.size(), player_aims.size(), payload_variants_checked, invalid_updates_checked]
		)
		get_tree().quit(0)
		return
	for error in errors:
		push_error("[MFO-FS-A-PRESENTATION] %s" % error)
	get_tree().quit(3)


func _spatial_geometry_errors(state_id: String, snapshot: Dictionary, geometry: Dictionary) -> Array[String]:
	var errors: Array[String] = []
	if not Vector2(geometry.player_position).is_equal_approx(snapshot.player_position):
		errors.append("%s player anchor mismatch" % state_id)
	var expected_aim: Vector2 = snapshot.player_aim
	if not Vector2(geometry.player_aim).is_equal_approx(expected_aim.normalized()):
		errors.append("%s player aim mismatch" % state_id)
	if not Vector2(geometry.boss_position).is_equal_approx(snapshot.boss_position):
		errors.append("%s boss anchor mismatch" % state_id)
	if not Vector2(geometry.wreck_position).is_equal_approx(snapshot.boss_position):
		errors.append("%s wreck anchor mismatch" % state_id)
	var part_positions: Array = geometry.part_positions
	for index in range(snapshot.parts.size()):
		var part: Dictionary = snapshot.parts[index]
		if not Vector2(part_positions[index]).is_equal_approx(part.position):
			errors.append("%s part %d anchor mismatch" % [state_id, index])
	var harvest_positions: Array = geometry.harvest_positions
	for index in range(snapshot.harvest_points.size()):
		var point: Dictionary = snapshot.harvest_points[index]
		if not Vector2(harvest_positions[index]).is_equal_approx(point.position):
			errors.append("%s harvest %d anchor mismatch" % [state_id, index])

	var telegraph: Dictionary = snapshot.telegraph
	var telegraph_geometry: Dictionary = geometry.telegraph
	var expected_direction: Vector2 = telegraph.direction
	expected_direction = expected_direction.normalized()
	if not Vector2(telegraph_geometry.origin).is_equal_approx(telegraph.origin):
		errors.append("%s telegraph origin mismatch" % state_id)
	if not Vector2(telegraph_geometry.direction).is_equal_approx(expected_direction):
		errors.append("%s telegraph direction mismatch" % state_id)
	if not is_equal_approx(float(telegraph_geometry.range), float(telegraph.range)):
		errors.append("%s telegraph range mismatch" % state_id)
	if telegraph.shape == "line":
		var expected_end: Vector2 = telegraph.origin + expected_direction * float(telegraph.range)
		if not Vector2(telegraph_geometry.end).is_equal_approx(expected_end):
			errors.append("%s line endpoint mismatch" % state_id)
		if not is_equal_approx(float(telegraph_geometry.half_width), float(telegraph.half_width)):
			errors.append("%s line half-width mismatch" % state_id)
		var normal := Vector2(-expected_direction.y, expected_direction.x)
		var corners: Array = telegraph_geometry.corners
		if corners.size() != 4 or not Vector2(corners[0]).is_equal_approx(telegraph.origin + normal * float(telegraph.half_width)):
			errors.append("%s line corner geometry mismatch" % state_id)
	else:
		if not is_equal_approx(float(telegraph_geometry.half_angle), float(telegraph.half_angle)):
			errors.append("%s sector half-angle mismatch" % state_id)
		if not is_equal_approx(float(telegraph_geometry.center_angle), expected_direction.angle()):
			errors.append("%s sector orientation mismatch" % state_id)
	return errors


func _invalid_spatial_cases(valid_snapshot: Dictionary) -> Array[Dictionary]:
	var cases: Array[Dictionary] = []
	for field in ["player_position", "player_aim", "boss_position"]:
		var invalid := valid_snapshot.duplicate(true)
		invalid[field] = "not_a_vector"
		cases.append({"label": "%s_type" % field, "snapshot": invalid})
	for field in ["player_position", "player_aim", "boss_position"]:
		var missing_root := valid_snapshot.duplicate(true)
		missing_root.erase(field)
		cases.append({"label": "%s_required" % field, "snapshot": missing_root})

	var invalid_part := valid_snapshot.duplicate(true)
	var invalid_parts: Array = invalid_part.parts
	var first_part: Dictionary = invalid_parts[0]
	first_part.position = "not_a_vector"
	cases.append({"label": "part_position_type", "snapshot": invalid_part})
	var missing_part := valid_snapshot.duplicate(true)
	var missing_parts: Array = missing_part.parts
	var missing_first_part: Dictionary = missing_parts[0]
	missing_first_part.erase("position")
	cases.append({"label": "part_position_required", "snapshot": missing_part})

	var invalid_harvest := valid_snapshot.duplicate(true)
	var invalid_points: Array = invalid_harvest.harvest_points
	var first_point: Dictionary = invalid_points[0]
	first_point.position = "not_a_vector"
	cases.append({"label": "harvest_position_type", "snapshot": invalid_harvest})
	var missing_harvest := valid_snapshot.duplicate(true)
	var missing_points: Array = missing_harvest.harvest_points
	var missing_first_point: Dictionary = missing_points[0]
	missing_first_point.erase("position")
	cases.append({"label": "harvest_position_required", "snapshot": missing_harvest})

	for field in ["origin", "direction"]:
		var invalid := valid_snapshot.duplicate(true)
		var invalid_telegraph: Dictionary = invalid.telegraph
		invalid_telegraph[field] = "not_a_vector"
		cases.append({"label": "telegraph_%s_type" % field, "snapshot": invalid})
	for field in ["range", "half_width", "half_angle"]:
		var invalid := valid_snapshot.duplicate(true)
		var invalid_telegraph: Dictionary = invalid.telegraph
		invalid_telegraph[field] = Vector2.ONE
		cases.append({"label": "telegraph_%s_type" % field, "snapshot": invalid})
	for field in ["origin", "direction", "range", "half_width", "half_angle"]:
		var missing_telegraph_field := valid_snapshot.duplicate(true)
		var incomplete_telegraph: Dictionary = missing_telegraph_field.telegraph
		incomplete_telegraph.erase(field)
		cases.append({"label": "telegraph_%s_required" % field, "snapshot": missing_telegraph_field})
	return cases


func _expected_event_anchor(event_id: String, snapshot: Dictionary) -> Vector2:
	var player_position: Vector2 = snapshot.player_position
	var player_aim: Vector2 = snapshot.player_aim
	match event_id:
		"ActionStarted":
			return player_position
		"HitConfirmed":
			return player_position + player_aim.normalized() * FSAPresentationShell.COSMETIC_FEEDBACK_OFFSET
		"PartBroken":
			return snapshot.boss_position
	return Vector2.ZERO


func _capture_and_quit() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("FS-A presentation capture requires a rendering display server")
		get_tree().quit(4)
		return
	await get_tree().process_frame
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var directory_error := DirAccess.make_dir_recursive_absolute(_capture_path.get_base_dir())
	if directory_error != OK:
		push_error("Could not create capture directory: %s" % error_string(directory_error))
		get_tree().quit(5)
		return
	var image := get_viewport().get_texture().get_image()
	var save_error := image.save_png(_capture_path)
	if save_error != OK:
		push_error("Could not save FS-A presentation capture: %s" % error_string(save_error))
		get_tree().quit(6)
		return
	print(
		"[MFO-FS-A-PRESENTATION] capture=PASS state=%s event=%s grayscale=%s size=%s path=%s"
		% [_stub.get_state_id(), _requested_event if not _requested_event.is_empty() else "none", str(_shell.is_grayscale()), str(image.get_size()), _capture_path]
	)
	get_tree().quit(0)
