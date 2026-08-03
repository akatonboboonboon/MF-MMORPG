extends SceneTree

# FS-A QA preparation only. This runner deliberately consumes only the public
# snapshot/loop seam in FAST_SLICE_CONTRACT; it does not load a gameplay or
# presentation candidate.

const REQUIRED_SNAPSHOT_KEYS := [
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

const VALID_LOOP_PHASES := [&"combat", &"wreck", &"result"]
const VALID_TELEGRAPH_SHAPES := [&"telegraph_line", &"telegraph_sector"]

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_test_public_snapshot_fixture()
	_test_loop_trace_fixture()
	_test_rematch_reset_fixture()
	if _failures.is_empty():
		print("[MFO-FS-A-QA-PREP] PASS: contract seam skeleton fixture")
		quit(0)
		return
	for failure in _failures:
		push_error("[MFO-FS-A-QA-PREP] %s" % failure)
	quit(1)


func validate_public_snapshot(snapshot: Dictionary) -> PackedStringArray:
	var errors := PackedStringArray()
	for key in REQUIRED_SNAPSHOT_KEYS:
		if not snapshot.has(key):
			errors.append("snapshot is missing %s" % key)
	if not errors.is_empty():
		return errors
	if not snapshot["loop_phase"] in VALID_LOOP_PHASES:
		errors.append("loop_phase must be combat, wreck, or result")
	if not snapshot["parts"] is Array or snapshot["parts"].size() < 1 or snapshot["parts"].size() > 2:
		errors.append("parts must contain one or two public records")
	if not snapshot["telegraph"] is Dictionary:
		errors.append("telegraph must be a public record")
	elif not snapshot["telegraph"].get("shape", &"") in VALID_TELEGRAPH_SHAPES:
		errors.append("telegraph shape must be line or sector")
	if not snapshot["harvest_points"] is Array or snapshot["harvest_points"].size() != 3:
		errors.append("harvest_points must contain exactly three records")
	return errors


func validate_loop_trace(phases: Array) -> PackedStringArray:
	var errors := PackedStringArray()
	if phases != [&"combat", &"wreck", &"result"]:
		errors.append("one-loop trace must be combat -> wreck -> result")
	return errors


func validate_rematch_reset(snapshot: Dictionary) -> PackedStringArray:
	var errors := validate_public_snapshot(snapshot)
	if not errors.is_empty():
		return errors
	if snapshot["loop_phase"] != &"combat":
		errors.append("rematch reset must return to combat")
	if snapshot["result_visible"] or snapshot["rematch_available"] or snapshot["wreck_active"]:
		errors.append("rematch reset must clear result, rematch prompt, and wreck")
	if snapshot["boss_hp"] != snapshot["boss_hp_max"]:
		errors.append("rematch reset must restore boss HP")
	if snapshot["player_integrity"] != snapshot["player_integrity_max"]:
		errors.append("rematch reset must restore player Integrity")
	for point in snapshot["harvest_points"]:
		if not point is Dictionary or point.get("collected", true):
			errors.append("rematch reset must restore every harvest point")
			break
	return errors


func _test_public_snapshot_fixture() -> void:
	_check(validate_public_snapshot(_fixture_combat_snapshot()).is_empty(), "public snapshot seam fixture is accepted")


func _test_loop_trace_fixture() -> void:
	_check(validate_loop_trace([&"combat", &"wreck", &"result"]).is_empty(), "one-loop trace fixture is accepted")


func _test_rematch_reset_fixture() -> void:
	_check(validate_rematch_reset(_fixture_combat_snapshot()).is_empty(), "rematch reset fixture is accepted")


func _fixture_combat_snapshot() -> Dictionary:
	return {
		"loop_phase": &"combat",
		"player_integrity": 100.0,
		"player_integrity_max": 100.0,
		"player_deformation": 0.0,
		"boss_hp": 300.0,
		"boss_hp_max": 300.0,
		"parts": [{"id": &"part.core", "hp": 50.0, "broken": false}],
		"telegraph": {"id": &"telegraph.line", "shape": &"telegraph_line", "duration": 1.0, "progress": 0.0, "active": false},
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


func _check(condition: bool, description: String) -> void:
	if not condition:
		_failures.append(description)
