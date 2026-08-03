class_name FsAPlayerAction
extends RefCounted

const ACTION_LIGHT := &"light"
const ACTION_HEAVY := &"heavy"
const STATE_IDLE := &"idle"
const STATE_WINDUP := &"windup"
const STATE_ACTIVE := &"active"
const STATE_RECOVERY := &"recovery"
const _TIME_EPSILON := 0.000001

var _tuning: FsATuning
var _state: StringName = STATE_IDLE
var _action_id: StringName = &""
var _action_sequence: int = 0
var _state_elapsed_seconds: float = 0.0
var _locked_aim := Vector2.RIGHT
var _hit_query_pending: bool = false
var _pending_hit_descriptor: Dictionary = {}
var _hit_resolution_count: int = 0


func configure(tuning: FsATuning) -> bool:
	if tuning == null or not tuning.validate().is_empty():
		return false
	_tuning = tuning
	reset()
	return true


func reset() -> void:
	_state = STATE_IDLE
	_action_id = &""
	_action_sequence = 0
	_state_elapsed_seconds = 0.0
	_locked_aim = Vector2.RIGHT
	_hit_query_pending = false
	_pending_hit_descriptor = {}
	_hit_resolution_count = 0


func cancel() -> void:
	_state = STATE_IDLE
	_action_id = &""
	_state_elapsed_seconds = 0.0
	_hit_query_pending = false
	_pending_hit_descriptor = {}


func try_accept(action_id: StringName, aim: Vector2) -> bool:
	if _tuning == null or _state != STATE_IDLE:
		return false
	if action_id != ACTION_LIGHT and action_id != ACTION_HEAVY:
		return false
	if aim.length_squared() <= 0.0001:
		return false
	if _hit_query_pending:
		commit_pending_hit(&"")
	_action_sequence += 1
	_action_id = action_id
	_locked_aim = aim.normalized()
	_state = STATE_WINDUP
	_state_elapsed_seconds = 0.0
	return true


func advance(delta_seconds: float) -> void:
	if _tuning == null or _state == STATE_IDLE:
		return
	var remaining := maxf(delta_seconds, 0.0)
	var transitions := 0
	while remaining > _TIME_EPSILON and _state != STATE_IDLE and transitions < 4:
		var duration := _state_duration()
		var until_transition := maxf(0.0, duration - _state_elapsed_seconds)
		if remaining + _TIME_EPSILON < until_transition:
			_state_elapsed_seconds += remaining
			remaining = 0.0
		else:
			_state_elapsed_seconds = duration
			remaining = maxf(0.0, remaining - until_transition)
			_transition_state()
			transitions += 1


func pending_hit_query() -> Dictionary:
	if not _hit_query_pending:
		return {}
	return _pending_hit_descriptor


func commit_pending_hit(target_id: StringName) -> Dictionary:
	if not _hit_query_pending:
		return {}
	var result: Dictionary = _pending_hit_descriptor.duplicate(true)
	_hit_query_pending = false
	_pending_hit_descriptor = {}
	_hit_resolution_count += 1
	result["target_id"] = target_id
	result["hit"] = not target_id.is_empty()
	result.make_read_only()
	return result


func state() -> StringName:
	return _state


func current_action_id() -> StringName:
	return _action_id


func current_sequence() -> int:
	return _action_sequence


func is_busy() -> bool:
	return _state != STATE_IDLE


func debug_state() -> Dictionary:
	return {
		"state": _state,
		"action_id": _action_id,
		"sequence": _action_sequence,
		"state_elapsed_seconds": _state_elapsed_seconds,
		"locked_aim": _locked_aim,
		"hit_query_pending": _hit_query_pending,
		"hit_resolution_count": _hit_resolution_count,
	}


func _transition_state() -> void:
	_state_elapsed_seconds = 0.0
	match _state:
		STATE_WINDUP:
			_state = STATE_ACTIVE
			_pending_hit_descriptor = _build_hit_descriptor()
			_pending_hit_descriptor.make_read_only()
			_hit_query_pending = true
		STATE_ACTIVE:
			_state = STATE_RECOVERY
		STATE_RECOVERY:
			_state = STATE_IDLE
			_action_id = &""
		_:
			cancel()


func _state_duration() -> float:
	var heavy := _action_id == ACTION_HEAVY
	match _state:
		STATE_WINDUP:
			return _tuning.heavy_windup_seconds if heavy else _tuning.light_windup_seconds
		STATE_ACTIVE:
			return _tuning.heavy_active_seconds if heavy else _tuning.light_active_seconds
		STATE_RECOVERY:
			return _tuning.heavy_recovery_seconds if heavy else _tuning.light_recovery_seconds
	return 0.0


func _build_hit_descriptor() -> Dictionary:
	var heavy := _action_id == ACTION_HEAVY
	var half_angle_degrees := (
		_tuning.heavy_half_angle_degrees if heavy else _tuning.light_half_angle_degrees
	)
	return {
		"action_id": _action_id,
		"sequence": _action_sequence,
		"aim": _locked_aim,
		"reach": _tuning.heavy_reach if heavy else _tuning.light_reach,
		"minimum_aim_dot": cos(deg_to_rad(half_angle_degrees)),
		"body_damage": _tuning.heavy_body_damage if heavy else _tuning.light_body_damage,
		"part_damage": _tuning.heavy_part_damage if heavy else _tuning.light_part_damage,
	}
