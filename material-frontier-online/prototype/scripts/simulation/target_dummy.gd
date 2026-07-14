class_name Phase1TargetDummy
extends StaticBody2D

signal provisional_hit_received(hit_count: int, value: int, command_sequence: int)

@export var entity_id: StringName = &"target.phase1.dummy.1"
var hit_count: int = 0
var last_hit_value: int = 0
var _flash_remaining: float = 0.0


func receive_provisional_hit(value: int, command_sequence: int) -> void:
	hit_count += 1
	last_hit_value = value
	_flash_remaining = 0.16
	provisional_hit_received.emit(hit_count, value, command_sequence)
	queue_redraw()


func _process(delta: float) -> void:
	if _flash_remaining <= 0.0:
		return
	_flash_remaining = maxf(0.0, _flash_remaining - delta)
	queue_redraw()


func _draw() -> void:
	var fill := Color("ffcf5a") if _flash_remaining <= 0.0 else Color.WHITE
	draw_rect(Rect2(-42.0, -42.0, 84.0, 84.0), Color(0.08, 0.07, 0.05, 1.0), true)
	draw_rect(Rect2(-37.0, -37.0, 74.0, 74.0), fill, true)
	draw_line(Vector2(-26.0, 0.0), Vector2(26.0, 0.0), Color("7e5b16"), 5.0)
	draw_line(Vector2(0.0, -26.0), Vector2(0.0, 26.0), Color("7e5b16"), 5.0)
	draw_arc(Vector2.ZERO, 50.0, 0.0, TAU, 48, Color(1.0, 0.79, 0.24, 0.75), 3.0)
