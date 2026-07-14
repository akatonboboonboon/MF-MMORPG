class_name Phase1PlayerActor
extends CharacterBody2D

const EVADE_DISTANCE_PX := 140.0
const EVADE_DURATION_SECONDS := 0.20
const EVADE_REUSE_SECONDS := 0.45
const _DIRECTION_EPSILON_SQUARED := 0.0001
const _TIME_EPSILON_SECONDS := 0.000001

@export var entity_id: StringName = &"actor.player.local.1"
@export_range(1.0, 1000.0, 1.0) var move_speed: float = 280.0
@export var movement_bounds := Rect2(72.0, 96.0, 1776.0, 888.0)

var aim_direction := Vector2.RIGHT
var _evade_active := false
var _evade_direction := Vector2.ZERO
var _evade_elapsed_seconds := 0.0
var _evade_reuse_remaining_seconds := 0.0


func can_accept_authority_evade() -> bool:
	return not _evade_active and _evade_reuse_remaining_seconds <= _TIME_EPSILON_SECONDS


func begin_authority_evade(direction: Vector2) -> bool:
	if not can_accept_authority_evade() or direction.length_squared() <= _DIRECTION_EPSILON_SQUARED:
		return false
	_evade_active = true
	_evade_direction = direction.normalized()
	_evade_elapsed_seconds = 0.0
	_evade_reuse_remaining_seconds = EVADE_REUSE_SECONDS
	return true


func apply_authority_motion(move_vector: Vector2, aim_vector: Vector2, delta: float = 1.0 / 60.0) -> void:
	if aim_vector.length_squared() > _DIRECTION_EPSILON_SQUARED:
		aim_direction = aim_vector.normalized()
	var authority_delta := maxf(delta, 0.0)
	if _evade_active:
		_apply_authority_evade_motion(authority_delta)
	else:
		velocity = move_vector.limit_length(1.0) * move_speed
		move_and_slide()
		_clamp_to_movement_bounds()
	_evade_reuse_remaining_seconds = maxf(
		0.0,
		_evade_reuse_remaining_seconds - authority_delta
	)
	queue_redraw()


func reset_authority_state(start_position: Vector2, initial_aim: Vector2) -> void:
	global_position = start_position
	_clamp_to_movement_bounds()
	aim_direction = initial_aim.normalized() if initial_aim.length_squared() > _DIRECTION_EPSILON_SQUARED else Vector2.RIGHT
	velocity = Vector2.ZERO
	_evade_active = false
	_evade_direction = Vector2.ZERO
	_evade_elapsed_seconds = 0.0
	_evade_reuse_remaining_seconds = 0.0
	queue_redraw()


func debug_evade_state() -> Dictionary:
	return {
		"active": _evade_active,
		"direction": _evade_direction,
		"elapsed_seconds": _evade_elapsed_seconds,
		"reuse_remaining_seconds": _evade_reuse_remaining_seconds,
		"distance_px": EVADE_DISTANCE_PX,
		"duration_seconds": EVADE_DURATION_SECONDS,
		"reuse_seconds": EVADE_REUSE_SECONDS,
	}


func _apply_authority_evade_motion(delta: float) -> void:
	var remaining_seconds := maxf(0.0, EVADE_DURATION_SECONDS - _evade_elapsed_seconds)
	var motion_seconds := minf(delta, remaining_seconds)
	if motion_seconds > 0.0:
		var evade_speed := EVADE_DISTANCE_PX / EVADE_DURATION_SECONDS
		velocity = _evade_direction * evade_speed
		move_and_collide(_evade_direction * evade_speed * motion_seconds)
		_clamp_to_movement_bounds()
		_evade_elapsed_seconds += motion_seconds
	if _evade_elapsed_seconds + _TIME_EPSILON_SECONDS >= EVADE_DURATION_SECONDS:
		_evade_active = false
		_evade_direction = Vector2.ZERO
		_evade_elapsed_seconds = EVADE_DURATION_SECONDS
		velocity = Vector2.ZERO


func _clamp_to_movement_bounds() -> void:
	global_position = Vector2(
		clampf(global_position.x, movement_bounds.position.x, movement_bounds.end.x),
		clampf(global_position.y, movement_bounds.position.y, movement_bounds.end.y)
	)


func _draw() -> void:
	var body_color := Color("55b9ff")
	draw_circle(Vector2.ZERO, 27.0, Color(0.04, 0.08, 0.13, 1.0))
	draw_circle(Vector2.ZERO, 23.0, body_color)
	draw_arc(Vector2.ZERO, 31.0, 0.0, TAU, 48, Color(0.7, 0.9, 1.0, 0.9), 3.0)
	draw_line(Vector2.ZERO, aim_direction * 68.0, Color(0.7, 0.95, 1.0, 0.95), 5.0, true)
	draw_circle(aim_direction * 68.0, 5.0, Color.WHITE)
