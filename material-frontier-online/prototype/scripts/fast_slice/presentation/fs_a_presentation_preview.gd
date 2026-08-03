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
	for state_id in FSAPresentationPreviewStub.STATE_ORDER:
		var source_snapshot: Dictionary = FSAPresentationPreviewStub.SNAPSHOTS[state_id].duplicate(true)
		var expected_snapshot := source_snapshot.duplicate(true)
		if not _shell.apply_snapshot(source_snapshot):
			errors.append("%s snapshot rejected by shell" % state_id)
			continue
		if _shell.get_presented_snapshot() != expected_snapshot:
			errors.append("%s snapshot changed while copied into shell" % state_id)
		source_snapshot.player_integrity = -999
		if _shell.get_presented_snapshot().player_integrity == -999:
			errors.append("%s source mutation leaked into shell" % state_id)

	_shell.apply_snapshot(_stub.get_snapshot())
	var snapshot_before_events := _shell.get_presented_snapshot()
	_shell.set_feedback_hold(true)
	for event_id in FSAPresentationPreviewStub.EVENT_ORDER:
		var event_fixture := _stub.get_event_fixture(event_id)
		if not _shell.consume_domain_event(event_fixture):
			errors.append("%s event rejected by shell" % event_id)
		if _shell.get_presented_snapshot() != snapshot_before_events:
			errors.append("%s event changed authority snapshot" % event_id)

	var object_event := PreviewEventObject.new()
	object_event.event_name = &"HitConfirmed"
	if not _shell.consume_domain_event(object_event):
		errors.append("Object event_name seam rejected")
	if _shell.consume_domain_event({"event_name": "UnsupportedFixtureEvent"}):
		errors.append("unsupported event was accepted")
	_shell.set_feedback_hold(false)
	_shell.clear_feedback()

	if errors.is_empty():
		print("[MFO-FS-A-PRESENTATION] self_check=PASS snapshots=4 events=3 harvest_each=3 read_only=true")
		get_tree().quit(0)
		return
	for error in errors:
		push_error("[MFO-FS-A-PRESENTATION] %s" % error)
	get_tree().quit(3)


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
