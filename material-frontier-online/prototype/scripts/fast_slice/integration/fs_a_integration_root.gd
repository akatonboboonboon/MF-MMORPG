class_name FsAIntegrationRoot
extends Node2D

const GAMEPLAY_SHAPE_LINE := "telegraph_line"
const GAMEPLAY_SHAPE_SECTOR := "telegraph_sector"
const PRESENTATION_SHAPE_LINE := &"line"
const PRESENTATION_SHAPE_SECTOR := &"sector"
const GAMEPLAY_EVENT_ACTION := &"player_action_accepted"
const GAMEPLAY_EVENT_HIT := &"player_hit_resolved"
const GAMEPLAY_EVENT_PART_BREAK := &"part_broken"
const PRESENTATION_EVENT_ACTION := &"ActionStarted"
const PRESENTATION_EVENT_HIT := &"HitConfirmed"
const PRESENTATION_EVENT_PART_BREAK := &"PartBroken"

@export var presentation_enabled: bool = true
@export var live_input_enabled: bool = true

@onready var _gameplay: FsAGameplayArena = %Gameplay
@onready var _presentation: FSAPresentationShell = %Presentation

var _ready_ok: bool = false
var _snapshot_updates_received: int = 0
var _snapshot_updates_presented: int = 0
var _snapshot_updates_rejected: int = 0
var _event_updates_received: int = 0
var _event_updates_presented: int = 0
var _event_updates_rejected: int = 0
var _last_snapshot_error: String = ""
var _last_event_error: String = ""
var _presented_event_counts: Dictionary = {}


func _ready() -> void:
	if _gameplay == null or _presentation == null:
		push_error("FS-A integration requires Gameplay and Presentation children")
		return
	if not _gameplay.is_ready_for_gameplay():
		push_error("FS-A integration Gameplay child was not ready")
		return

	_gameplay.live_input_enabled = live_input_enabled
	_presentation.visible = presentation_enabled
	var snapshot_callable := Callable(self, "_on_gameplay_snapshot")
	var event_callable := Callable(self, "_on_gameplay_event")
	if _gameplay.snapshot_changed.is_connected(snapshot_callable):
		push_error("FS-A integration snapshot signal was already connected")
		return
	if _gameplay.gameplay_event.is_connected(event_callable):
		push_error("FS-A integration gameplay event signal was already connected")
		return
	_gameplay.snapshot_changed.connect(snapshot_callable)
	_gameplay.gameplay_event.connect(event_callable)
	_ready_ok = true

	# The Gameplay child publishes during its own _ready(), before this parent can connect.
	# Pull exactly one initial authority snapshot after both children are ready.
	_on_gameplay_snapshot(_gameplay.get_snapshot())


func is_ready_for_integration() -> bool:
	return _ready_ok


func get_gameplay_arena() -> FsAGameplayArena:
	return _gameplay


func get_presentation_shell() -> FSAPresentationShell:
	return _presentation


func get_authority_snapshot() -> Dictionary:
	return _gameplay.get_snapshot() if _ready_ok else {}


func get_presented_snapshot() -> Dictionary:
	return _presentation.get_presented_snapshot() if _ready_ok else {}


func step_authority_command(
	base_command: Phase1InputCommand,
	requested_action: StringName,
	interact_requested: bool,
	delta_seconds: float
) -> Dictionary:
	if not _ready_ok:
		return {}
	return _gameplay.step_authority_command(
		base_command,
		requested_action,
		interact_requested,
		delta_seconds
	)


func get_debug_state() -> Dictionary:
	var snapshot_connection_count := 0
	var event_connection_count := 0
	if _gameplay != null:
		snapshot_connection_count = _gameplay.get_signal_connection_list(&"snapshot_changed").size()
		event_connection_count = _gameplay.get_signal_connection_list(&"gameplay_event").size()
	return _deep_read_only({
		"ready": _ready_ok,
		"presentation_enabled": presentation_enabled,
		"snapshot_updates_received": _snapshot_updates_received,
		"snapshot_updates_presented": _snapshot_updates_presented,
		"snapshot_updates_rejected": _snapshot_updates_rejected,
		"event_updates_received": _event_updates_received,
		"event_updates_presented": _event_updates_presented,
		"event_updates_rejected": _event_updates_rejected,
		"last_snapshot_error": _last_snapshot_error,
		"last_event_error": _last_event_error,
		"presented_event_counts": _presented_event_counts,
		"snapshot_signal_connections": snapshot_connection_count,
		"gameplay_event_connections": event_connection_count,
	})


static func adapt_snapshot_for_presentation(source_snapshot: Dictionary) -> Dictionary:
	if not source_snapshot.has("telegraph"):
		return _snapshot_rejection("snapshot.telegraph_missing")
	var telegraph_variant: Variant = source_snapshot.get("telegraph")
	if not telegraph_variant is Dictionary:
		return _snapshot_rejection("snapshot.telegraph_not_dictionary")
	var source_telegraph: Dictionary = telegraph_variant
	if not source_telegraph.has("shape"):
		return _snapshot_rejection("snapshot.telegraph_shape_missing")
	if not source_telegraph.has("active") or typeof(source_telegraph.get("active")) != TYPE_BOOL:
		return _snapshot_rejection("snapshot.telegraph_active_missing_or_not_bool")

	var source_shape := String(source_telegraph.get("shape"))
	var source_active := bool(source_telegraph.get("active"))
	var presentation_shape: StringName
	match source_shape:
		GAMEPLAY_SHAPE_LINE:
			presentation_shape = PRESENTATION_SHAPE_LINE
		GAMEPLAY_SHAPE_SECTOR:
			presentation_shape = PRESENTATION_SHAPE_SECTOR
		"":
			if source_active:
				return _snapshot_rejection("snapshot.telegraph_active_empty_shape")
			presentation_shape = PRESENTATION_SHAPE_LINE
		_:
			return _snapshot_rejection(
				"snapshot.telegraph_unknown_shape:%s" % source_shape
			)

	var presentation_snapshot: Dictionary = source_snapshot.duplicate(true)
	var presentation_telegraph: Dictionary = presentation_snapshot.get("telegraph")
	presentation_telegraph["shape"] = presentation_shape
	return _deep_read_only({
		"accepted": true,
		"error": "",
		"presentation_snapshot": presentation_snapshot,
	})


static func adapt_event_for_presentation(
	event_name: StringName,
	payload: Dictionary
) -> Dictionary:
	var presentation_event_name: StringName
	match event_name:
		GAMEPLAY_EVENT_ACTION:
			presentation_event_name = PRESENTATION_EVENT_ACTION
		GAMEPLAY_EVENT_HIT:
			var hit_value: Variant = payload.get("hit")
			if typeof(hit_value) != TYPE_BOOL or not bool(hit_value):
				return _event_rejection("event.player_hit_resolved_not_confirmed")
			presentation_event_name = PRESENTATION_EVENT_HIT
		GAMEPLAY_EVENT_PART_BREAK:
			presentation_event_name = PRESENTATION_EVENT_PART_BREAK
		_:
			return _event_rejection("event.unmapped:%s" % String(event_name))

	return _deep_read_only({
		"accepted": true,
		"error": "",
		"presentation_event": {
			"event_name": presentation_event_name,
			"payload": payload.duplicate(true),
		},
	})


func _on_gameplay_snapshot(source_snapshot: Dictionary) -> void:
	_snapshot_updates_received += 1
	var adaptation := adapt_snapshot_for_presentation(source_snapshot)
	if not bool(adaptation.get("accepted", false)):
		_snapshot_updates_rejected += 1
		_last_snapshot_error = String(adaptation.get("error", "snapshot.rejected"))
		push_warning("[MFO-FS-A-INTEGRATION] Presentation snapshot update rejected: %s" % _last_snapshot_error)
		return
	_last_snapshot_error = ""
	if not presentation_enabled:
		return
	var presentation_snapshot: Dictionary = adaptation.get("presentation_snapshot", {})
	if not _presentation.apply_snapshot(presentation_snapshot):
		_snapshot_updates_rejected += 1
		_last_snapshot_error = "snapshot.presentation_shell_rejected"
		push_warning("[MFO-FS-A-INTEGRATION] Presentation shell rejected adapted snapshot")
		return
	_snapshot_updates_presented += 1


func _on_gameplay_event(event_name: StringName, payload: Dictionary) -> void:
	_event_updates_received += 1
	var adaptation := adapt_event_for_presentation(event_name, payload)
	if not bool(adaptation.get("accepted", false)):
		_event_updates_rejected += 1
		_last_event_error = String(adaptation.get("error", "event.rejected"))
		return
	_last_event_error = ""
	if not presentation_enabled:
		return
	var presentation_event: Dictionary = adaptation.get("presentation_event", {})
	if not _presentation.consume_domain_event(presentation_event):
		_event_updates_rejected += 1
		_last_event_error = "event.presentation_shell_rejected"
		push_warning("[MFO-FS-A-INTEGRATION] Presentation shell rejected adapted event")
		return
	_event_updates_presented += 1
	var presented_name := String(presentation_event.get("event_name", ""))
	_presented_event_counts[presented_name] = int(_presented_event_counts.get(presented_name, 0)) + 1


static func _snapshot_rejection(error: String) -> Dictionary:
	return _deep_read_only({
		"accepted": false,
		"error": error,
		"presentation_snapshot": {},
	})


static func _event_rejection(error: String) -> Dictionary:
	return _deep_read_only({
		"accepted": false,
		"error": error,
		"presentation_event": {},
	})


static func _deep_read_only(value: Variant) -> Variant:
	if value is Dictionary:
		var dictionary: Dictionary = value.duplicate(true)
		for key in dictionary.keys():
			dictionary[key] = _deep_read_only(dictionary[key])
		dictionary.make_read_only()
		return dictionary
	if value is Array:
		var array: Array = value.duplicate(true)
		for index in range(array.size()):
			array[index] = _deep_read_only(array[index])
		array.make_read_only()
		return array
	return value
