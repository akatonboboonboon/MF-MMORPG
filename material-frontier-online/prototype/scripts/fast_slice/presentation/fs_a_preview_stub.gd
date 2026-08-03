class_name FSAPresentationPreviewStub
extends Node

signal snapshot_changed(snapshot: Dictionary)

const STATE_ORDER: Array[String] = [
	"combat_line",
	"combat_sector",
	"wreck",
	"result",
]

const REQUIRED_ROOT_FIELDS: Array[String] = [
	"loop_phase",
	"player_integrity",
	"player_integrity_max",
	"player_deformation",
	"boss_hp",
	"boss_hp_max",
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
		"boss_hp": 760,
		"boss_hp_max": 1000,
		"parts": [
			{"id": "core_guard", "hp": 180, "broken": false},
		],
		"telegraph": {
			"id": "sweep_line_a",
			"shape": "line",
			"duration": 1.20,
			"progress": 0.62,
			"active": true,
		},
		"boss_functional": true,
		"wreck_active": false,
		"harvest_points": [
			{"id": "salvage_a", "collected": false},
			{"id": "salvage_b", "collected": false},
			{"id": "salvage_c", "collected": false},
		],
		"result_visible": false,
		"rematch_available": false,
	},
	"combat_sector": {
		"loop_phase": "combat",
		"player_integrity": 58,
		"player_integrity_max": 100,
		"player_deformation": 47,
		"boss_hp": 410,
		"boss_hp_max": 1000,
		"parts": [
			{"id": "core_guard", "hp": 0, "broken": true},
		],
		"telegraph": {
			"id": "cleave_sector_b",
			"shape": "sector",
			"duration": 1.55,
			"progress": 0.44,
			"active": true,
		},
		"boss_functional": true,
		"wreck_active": false,
		"harvest_points": [
			{"id": "salvage_a", "collected": false},
			{"id": "salvage_b", "collected": false},
			{"id": "salvage_c", "collected": false},
		],
		"result_visible": false,
		"rematch_available": false,
	},
	"wreck": {
		"loop_phase": "wreck",
		"player_integrity": 58,
		"player_integrity_max": 100,
		"player_deformation": 47,
		"boss_hp": 0,
		"boss_hp_max": 1000,
		"parts": [
			{"id": "core_guard", "hp": 0, "broken": true},
		],
		"telegraph": {
			"id": "none",
			"shape": "line",
			"duration": 0.0,
			"progress": 0.0,
			"active": false,
		},
		"boss_functional": false,
		"wreck_active": true,
		"harvest_points": [
			{"id": "salvage_a", "collected": true},
			{"id": "salvage_b", "collected": false},
			{"id": "salvage_c", "collected": false},
		],
		"result_visible": false,
		"rematch_available": false,
	},
	"result": {
		"loop_phase": "result",
		"player_integrity": 58,
		"player_integrity_max": 100,
		"player_deformation": 47,
		"boss_hp": 0,
		"boss_hp_max": 1000,
		"parts": [
			{"id": "core_guard", "hp": 0, "broken": true},
		],
		"telegraph": {
			"id": "none",
			"shape": "sector",
			"duration": 0.0,
			"progress": 0.0,
			"active": false,
		},
		"boss_functional": false,
		"wreck_active": true,
		"harvest_points": [
			{"id": "salvage_a", "collected": true},
			{"id": "salvage_b", "collected": true},
			{"id": "salvage_c", "collected": true},
		],
		"result_visible": true,
		"rematch_available": true,
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


func contract_self_check() -> Array[String]:
	var errors: Array[String] = []
	for state_id in STATE_ORDER:
		var snapshot: Dictionary = SNAPSHOTS[state_id]
		for field in REQUIRED_ROOT_FIELDS:
			if not snapshot.has(field):
				errors.append("%s missing %s" % [state_id, field])
		if errors.size() > 0:
			continue
		if snapshot.loop_phase not in ["combat", "wreck", "result"]:
			errors.append("%s invalid loop_phase" % state_id)
		if int(snapshot.player_integrity_max) <= 0 or int(snapshot.boss_hp_max) <= 0:
			errors.append("%s invalid maximum" % state_id)
		if int(snapshot.player_integrity) < 0 or int(snapshot.player_integrity) > int(snapshot.player_integrity_max):
			errors.append("%s invalid player_integrity" % state_id)
		if int(snapshot.player_deformation) < 0 or int(snapshot.player_deformation) > 100:
			errors.append("%s invalid player_deformation" % state_id)
		if int(snapshot.boss_hp) < 0 or int(snapshot.boss_hp) > int(snapshot.boss_hp_max):
			errors.append("%s invalid boss_hp" % state_id)
		var parts: Array = snapshot.parts
		if parts.size() < 1 or parts.size() > 2:
			errors.append("%s requires 1..2 parts" % state_id)
		else:
			for part in parts:
				if not part.has("id") or not part.has("hp") or not part.has("broken"):
					errors.append("%s invalid part schema" % state_id)
		var telegraph: Dictionary = snapshot.telegraph
		for field in ["id", "shape", "duration", "progress", "active"]:
			if not telegraph.has(field):
				errors.append("%s telegraph missing %s" % [state_id, field])
		if telegraph.has("shape") and telegraph.shape not in ["line", "sector"]:
			errors.append("%s invalid telegraph shape" % state_id)
		var harvest_points: Array = snapshot.harvest_points
		if harvest_points.size() != 3:
			errors.append("%s requires exact 3 harvest points" % state_id)
		else:
			var harvest_ids: Dictionary = {}
			for point in harvest_points:
				if not point.has("id") or not point.has("collected"):
					errors.append("%s invalid harvest schema" % state_id)
					continue
				harvest_ids[String(point.id)] = true
			if harvest_ids.size() != 3:
				errors.append("%s harvest ids must be unique" % state_id)
	return errors


func _publish_snapshot() -> void:
	snapshot_changed.emit(get_snapshot())
