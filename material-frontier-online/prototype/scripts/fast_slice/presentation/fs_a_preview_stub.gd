class_name FSAPresentationPreviewStub
extends Node

signal snapshot_changed(snapshot: Dictionary)
signal presentation_event(event: Dictionary)

const STATE_ORDER: Array[String] = [
	"combat_line",
	"combat_sector",
	"wreck",
	"result",
	"reset",
]

const EVENT_ORDER: Array[String] = [
	'ActionStarted',
	'HitConfirmed',
	'PartBroken',
]

const REQUIRED_ROOT_FIELDS: Array[String] = [
	"loop_phase",
	"player_integrity",
	"player_integrity_max",
	"player_deformation",
	"player_position",
	"player_aim",
	"boss_hp",
	"boss_hp_max",
	"boss_position",
	"parts",
	"telegraph",
	"boss_functional",
	"wreck_active",
	"harvest_points",
	"result_visible",
	"rematch_available",
]

const SNAPSHOTS := {
	"combat_line": {
		"loop_phase": "combat",
		"player_integrity": 82,
		"player_integrity_max": 100,
		"player_deformation": 24,
		"player_position": Vector2(470.0, 600.0),
		"player_aim": Vector2.RIGHT,
		"boss_hp": 760,
		"boss_hp_max": 1000,
		"boss_position": Vector2(1360.0, 560.0),
		"parts": [
			{"id": "core_guard", "hp": 180, "broken": false, "position": Vector2(1268.0, 530.0)},
		],
		"telegraph": {
			"id": "sweep_line_a",
			"shape": "line",
			"duration": 1.20,
			"progress": 0.62,
			"active": true,
			"origin": Vector2(1360.0, 560.0),
			"direction": Vector2.LEFT,
			"range": 930.0,
			"half_width": 62.0,
			"half_angle": 0.0,
		},
		"boss_functional": true,
		"wreck_active": false,
		"harvest_points": [
			{"id": "salvage_a", "collected": false, "position": Vector2(1200.0, 430.0)},
			{"id": "salvage_b", "collected": false, "position": Vector2(1505.0, 455.0)},
			{"id": "salvage_c", "collected": false, "position": Vector2(1370.0, 735.0)},
		],
		"result_visible": false,
		"rematch_available": false,
	},
	"combat_sector": {
		"loop_phase": "combat",
		"player_integrity": 58,
		"player_integrity_max": 100,
		"player_deformation": 47,
		"player_position": Vector2(720.0, 760.0),
		"player_aim": Vector2.UP,
		"boss_hp": 410,
		"boss_hp_max": 1000,
		"boss_position": Vector2(1320.0, 520.0),
		"parts": [
			{"id": "core_guard", "hp": 0, "broken": true, "position": Vector2(1230.0, 555.0)},
		],
		"telegraph": {
			"id": "cleave_sector_b",
			"shape": "sector",
			"duration": 1.55,
			"progress": 0.44,
			"active": true,
			"origin": Vector2(1320.0, 520.0),
			"direction": Vector2(-0.928476, 0.371391),
			"range": 560.0,
			"half_width": 0.0,
			"half_angle": 0.68,
		},
		"boss_functional": true,
		"wreck_active": false,
		"harvest_points": [
			{"id": "salvage_a", "collected": false, "position": Vector2(1140.0, 410.0)},
			{"id": "salvage_b", "collected": false, "position": Vector2(1490.0, 420.0)},
			{"id": "salvage_c", "collected": false, "position": Vector2(1325.0, 720.0)},
		],
		"result_visible": false,
		"rematch_available": false,
	},
	"wreck": {
		"loop_phase": "wreck",
		"player_integrity": 58,
		"player_integrity_max": 100,
		"player_deformation": 47,
		"player_position": Vector2(900.0, 760.0),
		"player_aim": Vector2.LEFT,
		"boss_hp": 0,
		"boss_hp_max": 1000,
		"boss_position": Vector2(1335.0, 550.0),
		"parts": [
			{"id": "core_guard", "hp": 0, "broken": true, "position": Vector2(1245.0, 550.0)},
		],
		"telegraph": {
			"id": "none",
			"shape": "line",
			"duration": 0.0,
			"progress": 0.0,
			"active": false,
			"origin": Vector2(1335.0, 550.0),
			"direction": Vector2.LEFT,
			"range": 0.0,
			"half_width": 0.0,
			"half_angle": 0.0,
		},
		"boss_functional": false,
		"wreck_active": true,
		"harvest_points": [
			{"id": "salvage_a", "collected": true, "position": Vector2(1185.0, 445.0)},
			{"id": "salvage_b", "collected": false, "position": Vector2(1480.0, 465.0)},
			{"id": "salvage_c", "collected": false, "position": Vector2(1340.0, 695.0)},
		],
		"result_visible": false,
		"rematch_available": false,
	},
	"result": {
		"loop_phase": "result",
		"player_integrity": 58,
		"player_integrity_max": 100,
		"player_deformation": 47,
		"player_position": Vector2(1060.0, 800.0),
		"player_aim": Vector2.UP,
		"boss_hp": 0,
		"boss_hp_max": 1000,
		"boss_position": Vector2(1335.0, 550.0),
		"parts": [
			{"id": "core_guard", "hp": 0, "broken": true, "position": Vector2(1245.0, 550.0)},
		],
		"telegraph": {
			"id": "none",
			"shape": "sector",
			"duration": 0.0,
			"progress": 0.0,
			"active": false,
			"origin": Vector2(1335.0, 550.0),
			"direction": Vector2.LEFT,
			"range": 0.0,
			"half_width": 0.0,
			"half_angle": 0.0,
		},
		"boss_functional": false,
		"wreck_active": true,
		"harvest_points": [
			{"id": "salvage_a", "collected": true, "position": Vector2(1185.0, 445.0)},
			{"id": "salvage_b", "collected": true, "position": Vector2(1480.0, 465.0)},
			{"id": "salvage_c", "collected": true, "position": Vector2(1340.0, 695.0)},
		],
		"result_visible": true,
		"rematch_available": true,
	},
	"reset": {
		"loop_phase": "combat",
		"player_integrity": 100,
		"player_integrity_max": 100,
		"player_deformation": 0,
		"player_position": Vector2(520.0, 540.0),
		"player_aim": Vector2.RIGHT,
		"boss_hp": 1000,
		"boss_hp_max": 1000,
		"boss_position": Vector2(1350.0, 540.0),
		"parts": [
			{"id": "core_guard", "hp": 180, "broken": false, "position": Vector2(1265.0, 540.0)},
		],
		"telegraph": {
			"id": "none",
			"shape": "line",
			"duration": 0.0,
			"progress": 0.0,
			"active": false,
			"origin": Vector2(1350.0, 540.0),
			"direction": Vector2.LEFT,
			"range": 0.0,
			"half_width": 0.0,
			"half_angle": 0.0,
		},
		"boss_functional": true,
		"wreck_active": false,
		"harvest_points": [
			{"id": "salvage_a", "collected": false, "position": Vector2(1200.0, 435.0)},
			{"id": "salvage_b", "collected": false, "position": Vector2(1495.0, 455.0)},
			{"id": "salvage_c", "collected": false, "position": Vector2(1350.0, 685.0)},
		],
		"result_visible": false,
		"rematch_available": false,
	},
}

# Payloads are preview-only labels. The shell consumes only the reserved
# event_name and never derives gameplay state or results from these fixtures.
const EVENT_FIXTURES := {
	'ActionStarted': {
		'event_name': 'ActionStarted',
		'command_sequence': 101,
		'physics_tick': 120,
		'payload': {
			'action_id': 'heavy_attack_fixture',
			'source_id': 'player_fixture',
		},
	},
	'HitConfirmed': {
		'event_name': 'HitConfirmed',
		'command_sequence': 102,
		'physics_tick': 126,
		'payload': {
			'action_id': 'heavy_attack_fixture',
			'target_id': 'boss_fixture',
		},
	},
	'PartBroken': {
		'event_name': 'PartBroken',
		'command_sequence': 103,
		'physics_tick': 127,
		'payload': {
			'part_id': 'core_guard',
		},
	},
}

var _state_id := STATE_ORDER[0]


func _ready() -> void:
	call_deferred("_publish_snapshot")


func get_snapshot() -> Dictionary:
	return SNAPSHOTS[_state_id].duplicate(true)


func get_state_id() -> String:
	return _state_id


func set_preview_state(state_id: String) -> bool:
	if not SNAPSHOTS.has(state_id):
		return false
	_state_id = state_id
	_publish_snapshot()
	return true


func next_preview_state() -> void:
	var index := STATE_ORDER.find(_state_id)
	set_preview_state(STATE_ORDER[(index + 1) % STATE_ORDER.size()])


func previous_preview_state() -> void:
	var index := STATE_ORDER.find(_state_id)
	set_preview_state(STATE_ORDER[(index - 1 + STATE_ORDER.size()) % STATE_ORDER.size()])


func get_event_fixture(event_id: String) -> Dictionary:
	if not EVENT_FIXTURES.has(event_id):
		return {}
	return EVENT_FIXTURES[event_id].duplicate(true)


func emit_fixture_event(event_id: String) -> bool:
	var event := get_event_fixture(event_id)
	if event.is_empty():
		return false
	presentation_event.emit(event)
	return true


func contract_self_check() -> Array[String]:
	var errors: Array[String] = []
	var player_positions: Dictionary = {}
	var player_aims: Dictionary = {}
	var saw_line := false
	var saw_sector := false
	for state_id in STATE_ORDER:
		var snapshot: Dictionary = SNAPSHOTS[state_id]
		var missing_root := false
		for field in REQUIRED_ROOT_FIELDS:
			if not snapshot.has(field):
				errors.append("%s missing %s" % [state_id, field])
				missing_root = true
		if missing_root:
			continue
		if snapshot.loop_phase not in ["combat", "wreck", "result"]:
			errors.append("%s invalid loop_phase" % state_id)
		for field in ["player_position", "player_aim", "boss_position"]:
			if typeof(snapshot[field]) != TYPE_VECTOR2:
				errors.append("%s %s must be Vector2" % [state_id, field])
		if typeof(snapshot.player_position) == TYPE_VECTOR2:
			player_positions[str(snapshot.player_position)] = true
		if typeof(snapshot.player_aim) == TYPE_VECTOR2:
			var player_aim: Vector2 = snapshot.player_aim
			player_aims[str(player_aim.normalized())] = true
		if int(snapshot.player_integrity_max) <= 0 or int(snapshot.boss_hp_max) <= 0:
			errors.append("%s invalid maximum" % state_id)
		if int(snapshot.player_integrity) < 0 or int(snapshot.player_integrity) > int(snapshot.player_integrity_max):
			errors.append("%s invalid player_integrity" % state_id)
		if int(snapshot.player_deformation) < 0:
			errors.append("%s invalid player_deformation" % state_id)
		if int(snapshot.boss_hp) < 0 or int(snapshot.boss_hp) > int(snapshot.boss_hp_max):
			errors.append("%s invalid boss_hp" % state_id)
		var parts: Array = snapshot.parts
		if parts.size() < 1 or parts.size() > 2:
			errors.append("%s requires 1..2 parts" % state_id)
		else:
			for part in parts:
				if not part.has("id") or not part.has("hp") or not part.has("broken") or not part.has("position"):
					errors.append("%s invalid part schema" % state_id)
				elif typeof(part.position) != TYPE_VECTOR2:
					errors.append("%s part position must be Vector2" % state_id)
		var telegraph: Dictionary = snapshot.telegraph
		for field in ["id", "shape", "duration", "progress", "active", "origin", "direction", "range", "half_width", "half_angle"]:
			if not telegraph.has(field):
				errors.append("%s telegraph missing %s" % [state_id, field])
		if telegraph.has("shape") and telegraph.shape not in ["line", "sector"]:
			errors.append("%s invalid telegraph shape" % state_id)
		elif telegraph.has("shape"):
			saw_line = saw_line or telegraph.shape == "line"
			saw_sector = saw_sector or telegraph.shape == "sector"
		for field in ["origin", "direction"]:
			if telegraph.has(field) and typeof(telegraph[field]) != TYPE_VECTOR2:
				errors.append("%s telegraph %s must be Vector2" % [state_id, field])
		for field in ["range", "half_width", "half_angle"]:
			if telegraph.has(field) and not _is_number(telegraph[field]):
				errors.append("%s telegraph %s must be numeric" % [state_id, field])
		var harvest_points: Array = snapshot.harvest_points
		if harvest_points.size() != 3:
			errors.append("%s requires exact 3 harvest points" % state_id)
		else:
			var harvest_ids: Dictionary = {}
			for point in harvest_points:
				if not point.has("id") or not point.has("collected") or not point.has("position"):
					errors.append("%s invalid harvest schema" % state_id)
					continue
				if typeof(point.position) != TYPE_VECTOR2:
					errors.append("%s harvest position must be Vector2" % state_id)
				harvest_ids[String(point.id)] = true
			if harvest_ids.size() != 3:
				errors.append("%s harvest ids must be unique" % state_id)
	if player_positions.size() < 2:
		errors.append("fixtures require at least two player positions")
	if player_aims.size() < 2:
		errors.append("fixtures require at least two player aim directions")
	if not saw_line or not saw_sector:
		errors.append("fixtures require line and sector telegraph geometry")
	var reset_snapshot: Dictionary = SNAPSHOTS.reset
	if reset_snapshot.loop_phase != "combat" or bool(reset_snapshot.wreck_active) or bool(reset_snapshot.result_visible):
		errors.append("reset fixture must restore combat without wreck or result")
	for point_variant in reset_snapshot.harvest_points:
		var reset_point: Dictionary = point_variant
		if bool(reset_point.collected):
			errors.append("reset fixture must clear harvest points")
	for event_id in EVENT_ORDER:
		var event: Dictionary = EVENT_FIXTURES[event_id]
		for field in ['event_name', 'command_sequence', 'physics_tick', 'payload']:
			if not event.has(field):
				errors.append('%s event missing %s' % [event_id, field])
		if event.has('event_name') and String(event.event_name) != event_id:
			errors.append('%s event name mismatch' % event_id)
		if event.has('payload') and typeof(event.payload) != TYPE_DICTIONARY:
			errors.append('%s event payload must be Dictionary' % event_id)
	return errors


static func _is_number(value: Variant) -> bool:
	return typeof(value) == TYPE_INT or typeof(value) == TYPE_FLOAT


func _publish_snapshot() -> void:
	snapshot_changed.emit(get_snapshot())
