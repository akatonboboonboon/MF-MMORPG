extends Node

const EMPTY_SCENARIO_FLAG := "--phase1-empty"
const ARENA_SCENE := "res://scenes/phase1/phase1_arena.tscn"
const EMPTY_SCENE := "res://scenes/phase1/phase1_empty.tscn"


func _ready() -> void:
	var destination := ARENA_SCENE
	for raw_argument in OS.get_cmdline_user_args():
		if String(raw_argument) == EMPTY_SCENARIO_FLAG:
			destination = EMPTY_SCENE
			break
	call_deferred("_route_to_scenario", destination)


func _route_to_scenario(destination: String) -> void:
	var change_error := get_tree().change_scene_to_file(destination)
	if change_error != OK:
		push_error("Could not load Phase 1 scenario: %s" % error_string(change_error))
		get_tree().quit(3)
