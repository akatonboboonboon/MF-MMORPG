class_name Phase1PlayerActor
extends CharacterBody2D

@export var entity_id: StringName = &"actor.player.local.1"
@export_range(1.0, 1000.0, 1.0) var move_speed: float = 280.0
@export var movement_bounds := Rect2(72.0, 96.0, 1776.0, 888.0)

var aim_direction := Vector2.RIGHT


func apply_authority_motion(move_vector: Vector2, aim_vector: Vector2) -> void:
	velocity = move_vector.limit_length(1.0) * move_speed
	move_and_slide()
	global_position = Vector2(
		clampf(global_position.x, movement_bounds.position.x, movement_bounds.end.x),
		clampf(global_position.y, movement_bounds.position.y, movement_bounds.end.y)
	)
	if aim_vector.length_squared() > 0.0001:
		aim_direction = aim_vector.normalized()
	queue_redraw()


func _draw() -> void:
	var body_color := Color("55b9ff")
	draw_circle(Vector2.ZERO, 27.0, Color(0.04, 0.08, 0.13, 1.0))
	draw_circle(Vector2.ZERO, 23.0, body_color)
	draw_arc(Vector2.ZERO, 31.0, 0.0, TAU, 48, Color(0.7, 0.9, 1.0, 0.9), 3.0)
	draw_line(Vector2.ZERO, aim_direction * 68.0, Color(0.7, 0.95, 1.0, 0.95), 5.0, true)
	draw_circle(aim_direction * 68.0, 5.0, Color.WHITE)
