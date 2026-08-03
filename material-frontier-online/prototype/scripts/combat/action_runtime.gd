class_name Phase2ActionRuntime
extends RefCounted

const PHASE_IDLE: StringName = &"idle"
const PHASE_WINDUP: StringName = &"windup"
const PHASE_ACTIVE: StringName = &"active"
const PHASE_RECOVERY: StringName = &"recovery"

const QUERY_STATUS_HIT: StringName = &"hit"
const QUERY_STATUS_MISS: StringName = &"miss"
const QUERY_STATUS_REJECTED: StringName = &"rejected"
const QUERY_STATUS_MALFORMED: StringName = &"malformed"

const _BOUNDARY_EPSILON_SECONDS := 0.000000001
const _MAX_PHASE_TRANSITIONS_PER_ADVANCE := 4

var _configured := false
var _action_snapshots: Dictionary = {}
var _effect_snapshots: Dictionary = {}
var _query_pool: Phase1HitQueryPool
var _query_callback: Callable = Callable()

var _phase: StringName = PHASE_IDLE
var _phase_elapsed_seconds := 0.0
var _current_action: Dictionary = {}
var _latest_aim := Vector2.ZERO
var _locked_aim := Vector2.ZERO
var _lease_token := Phase1HitQueryPool.INVALID_TOKEN
var _accepted_sequence_counter := 0
var _current_accepted_sequence := 0
var _query_callback_count := 0
var _current_effect_records: Array = _empty_read_only_array()
var _requested_forward_movement_pixels := 0.0
var _lease_release_result = null
var _query_result: Dictionary = {}


func configure(
	form_definition,
	action_definitions: Array,
	effect_definitions: Array,
	query_pool,
	query_callback: Callable
) -> PackedStringArray:
	var errors := PackedStringArray()
	if _configured:
		errors.append("runtime configuration is one-shot")
	if _phase != PHASE_IDLE or _lease_token != Phase1HitQueryPool.INVALID_TOKEN:
		errors.append("runtime must be idle before configuration")
	if not (form_definition is Phase2CombatFormDefinition):
		errors.append("form_definition must be a Phase2CombatFormDefinition")
	else:
		var form: Phase2CombatFormDefinition = form_definition
		for error in form.validate_registry(action_definitions, effect_definitions):
			errors.append("registry: %s" % error)
	if not (query_pool is Phase1HitQueryPool):
		errors.append("query_pool must be a Phase1HitQueryPool")
	if not query_callback.is_valid():
		errors.append("query_callback must be valid")
	if not errors.is_empty():
		return errors

	var new_effect_snapshots: Dictionary = {}
	for raw_effect in effect_definitions:
		var effect: Phase1EffectDefinition = raw_effect
		new_effect_snapshots[effect.effect_id] = _make_effect_snapshot(effect)
	new_effect_snapshots.make_read_only()

	var new_action_snapshots: Dictionary = {}
	for raw_action in action_definitions:
		var action: Phase1ActionDefinition = raw_action
		new_action_snapshots[action.action_id] = _make_action_snapshot(action, new_effect_snapshots)
	new_action_snapshots.make_read_only()

	_action_snapshots = new_action_snapshots
	_effect_snapshots = new_effect_snapshots
	_query_pool = query_pool
	_query_callback = query_callback
	_configured = true
	_accepted_sequence_counter = 0
	_clear_current_action_state()
	return errors


func try_accept(action_id: StringName, aim: Vector2) -> bool:
	if not _configured:
		return false
	if _phase != PHASE_IDLE:
		return false
	if action_id.is_empty() or not _action_snapshots.has(action_id):
		return false
	if not _is_valid_aim(aim):
		return false
	if not _query_callback.is_valid() or _query_pool == null:
		return false

	var action: Dictionary = _action_snapshots[action_id]
	var reservation_class: StringName = action["hit_query_reservation_class"]
	var token: int = _query_pool.try_reserve_for_class(action_id, reservation_class)
	if token == Phase1HitQueryPool.INVALID_TOKEN:
		return false

	_accepted_sequence_counter += 1
	_current_accepted_sequence = _accepted_sequence_counter
	_current_action = action
	_current_effect_records = action["effects"]
	_latest_aim = aim.normalized()
	_locked_aim = Vector2.ZERO
	if action["aim_policy"] == Phase1ActionDefinition.AIM_POLICY_LOCK_ON_ACCEPT:
		_locked_aim = _latest_aim
	_lease_token = token
	_query_callback_count = 0
	_requested_forward_movement_pixels = 0.0
	_lease_release_result = null
	_query_result = {}
	_phase = PHASE_WINDUP
	_phase_elapsed_seconds = 0.0
	return true


func advance(delta_seconds: float, latest_aim: Vector2 = Vector2.ZERO) -> bool:
	if not is_finite(delta_seconds) or delta_seconds < 0.0:
		return false
	if _phase == PHASE_IDLE:
		return false

	if (
		_phase == PHASE_WINDUP
		and _current_action.get("aim_policy", &"")
			== Phase1ActionDefinition.AIM_POLICY_FOLLOW_WINDUP_THEN_LOCK
		and _is_valid_aim(latest_aim)
	):
		_latest_aim = latest_aim.normalized()

	var remaining_delta: float = delta_seconds
	var transition_count := 0
	while _phase != PHASE_IDLE and transition_count < _MAX_PHASE_TRANSITIONS_PER_ADVANCE:
		var phase_duration: float = _current_phase_duration()
		var phase_remaining: float = maxf(0.0, phase_duration - _phase_elapsed_seconds)
		if phase_remaining > _BOUNDARY_EPSILON_SECONDS:
			if remaining_delta + _BOUNDARY_EPSILON_SECONDS < phase_remaining:
				_phase_elapsed_seconds += remaining_delta
				return true
			remaining_delta = maxf(0.0, remaining_delta - phase_remaining)

		_phase_elapsed_seconds = 0.0
		_transition_to_next_phase()
		transition_count += 1
		if _phase == PHASE_IDLE:
			break
		if remaining_delta <= _BOUNDARY_EPSILON_SECONDS:
			if _current_phase_duration() > _BOUNDARY_EPSILON_SECONDS:
				break
	return true


func reset() -> bool:
	var release_succeeded := true
	if _lease_token != Phase1HitQueryPool.INVALID_TOKEN:
		release_succeeded = _release_current_lease()
	_clear_current_action_state()
	return release_succeeded


func clear() -> bool:
	return reset()


func debug_state() -> Dictionary:
	var active_query_count := 0
	var emergency_active_count := 0
	var emergency_use_count := 0
	if _query_pool != null:
		active_query_count = _query_pool.active_count()
		emergency_active_count = _query_pool.emergency_active_count()
		emergency_use_count = _query_pool.emergency_use_count()

	var snapshot: Dictionary = {
		"configured": _configured,
		"phase": _phase,
		"phase_elapsed_seconds": _phase_elapsed_seconds,
		"action_id": _current_action.get("action_id", &""),
		"locked_aim": _locked_aim,
		"accepted_sequence": _current_accepted_sequence,
		"accepted_count": _accepted_sequence_counter,
		"query_count": _query_callback_count,
		"effects": _current_effect_records,
		"requested_forward_movement_intent_pixels": _requested_forward_movement_pixels,
		"lease_release_succeeded": _lease_release_result,
		"active_query_count": active_query_count,
		"emergency_active_count": emergency_active_count,
		"emergency_use_count": emergency_use_count,
		"has_pending_lease": _lease_token != Phase1HitQueryPool.INVALID_TOKEN,
		"has_query_result": not _query_result.is_empty(),
	}
	snapshot.make_read_only()
	return snapshot


func debug_result() -> Dictionary:
	if _query_result.is_empty():
		return _empty_read_only_dictionary()
	return _query_result


func _transition_to_next_phase() -> void:
	match _phase:
		PHASE_WINDUP:
			_enter_active_phase()
		PHASE_ACTIVE:
			_phase = PHASE_RECOVERY
			_requested_forward_movement_pixels = 0.0
		PHASE_RECOVERY:
			_finish_action()


func _enter_active_phase() -> void:
	_phase = PHASE_ACTIVE
	if _current_action["aim_policy"] == Phase1ActionDefinition.AIM_POLICY_FOLLOW_WINDUP_THEN_LOCK:
		_locked_aim = _latest_aim
	_requested_forward_movement_pixels = _current_action["forward_movement_intent_pixels"]
	_execute_query_callback_once()


func _execute_query_callback_once() -> void:
	if _query_callback_count != 0:
		return
	_query_callback_count = 1
	var request := _make_query_request()
	var callback_result = null
	if _query_callback.is_valid():
		callback_result = _query_callback.call(request)
	var status := _normalize_query_status(callback_result)
	var release_succeeded := _release_current_lease()

	var result: Dictionary = {
		"status": status,
		"request": request,
		"query_count": _query_callback_count,
		"release_succeeded": release_succeeded,
		"active_query_count": _query_pool.active_count(),
		"emergency_active_count": _query_pool.emergency_active_count(),
		"emergency_use_count": _query_pool.emergency_use_count(),
	}
	result.make_read_only()
	_query_result = result


func _make_query_request() -> Dictionary:
	var geometry: Dictionary = {
		"hit_shape_id": _current_action["hit_shape_id"],
		"reach": _current_action["reach"],
		"query_radius": _current_action["query_radius"],
		"minimum_aim_dot": _current_action["minimum_aim_dot"],
	}
	geometry.make_read_only()

	var request: Dictionary = {
		"action_id": _current_action["action_id"],
		"accepted_sequence": _current_accepted_sequence,
		"locked_aim": _locked_aim,
		"geometry": geometry,
		"max_targets": _current_action["max_targets"],
		"effects": _current_effect_records,
		"forward_movement_intent_pixels": _requested_forward_movement_pixels,
	}
	request.make_read_only()
	return request


func _normalize_query_status(callback_result) -> StringName:
	if typeof(callback_result) != TYPE_DICTIONARY:
		return QUERY_STATUS_MALFORMED
	var result: Dictionary = callback_result
	var raw_status = result.get("status", null)
	if typeof(raw_status) != TYPE_STRING_NAME:
		return QUERY_STATUS_MALFORMED
	var status: StringName = raw_status
	if status == QUERY_STATUS_HIT or status == QUERY_STATUS_MISS or status == QUERY_STATUS_REJECTED:
		return status
	return QUERY_STATUS_MALFORMED


func _release_current_lease() -> bool:
	if _lease_token == Phase1HitQueryPool.INVALID_TOKEN or _query_pool == null:
		_lease_release_result = false
		return false
	var token := _lease_token
	_lease_token = Phase1HitQueryPool.INVALID_TOKEN
	var release_succeeded := _query_pool.release(token)
	_lease_release_result = release_succeeded
	return release_succeeded


func _finish_action() -> void:
	if _lease_token != Phase1HitQueryPool.INVALID_TOKEN:
		_release_current_lease()
	_clear_current_action_state()


func _clear_current_action_state() -> void:
	_phase = PHASE_IDLE
	_phase_elapsed_seconds = 0.0
	_current_action = {}
	_latest_aim = Vector2.ZERO
	_locked_aim = Vector2.ZERO
	_lease_token = Phase1HitQueryPool.INVALID_TOKEN
	_current_accepted_sequence = 0
	_query_callback_count = 0
	_current_effect_records = _empty_read_only_array()
	_requested_forward_movement_pixels = 0.0
	_lease_release_result = null
	_query_result = {}


func _current_phase_duration() -> float:
	match _phase:
		PHASE_WINDUP:
			return _current_action.get("windup_seconds", 0.0)
		PHASE_ACTIVE:
			return _current_action.get("active_seconds", 0.0)
		PHASE_RECOVERY:
			return _current_action.get("recovery_seconds", 0.0)
	return 0.0


func _make_action_snapshot(action: Phase1ActionDefinition, effect_snapshots: Dictionary) -> Dictionary:
	var effects: Array = []
	for effect_id in action.effect_ids:
		effects.append(effect_snapshots[effect_id])
	effects.make_read_only()

	var snapshot: Dictionary = {
		"action_id": action.action_id,
		"windup_seconds": action.windup_seconds,
		"active_seconds": action.active_seconds,
		"recovery_seconds": action.recovery_seconds,
		"hit_shape_id": action.hit_shape_id,
		"reach": action.reach,
		"query_radius": action.query_radius,
		"minimum_aim_dot": action.minimum_aim_dot,
		"max_targets": action.max_targets,
		"hit_query_reservation_class": action.hit_query_reservation_class,
		"aim_policy": action.aim_policy,
		"forward_movement_intent_pixels": action.forward_movement_intent_pixels,
		"effects": effects,
	}
	snapshot.make_read_only()
	return snapshot


func _make_effect_snapshot(effect: Phase1EffectDefinition) -> Dictionary:
	var tags: Array[StringName] = []
	for tag in effect.tags:
		tags.append(tag)
	tags.make_read_only()
	var snapshot: Dictionary = {
		"effect_id": effect.effect_id,
		"effect_type": effect.effect_type,
		"channel": effect.channel,
		"magnitude": effect.magnitude,
		"duration": effect.duration,
		"target_rule": effect.target_rule,
		"stack_rule": effect.stack_rule,
		"tags": tags,
	}
	snapshot.make_read_only()
	return snapshot


func _is_valid_aim(aim: Vector2) -> bool:
	if not is_finite(aim.x) or not is_finite(aim.y):
		return false
	if aim == Vector2.ZERO:
		return false
	var aim_length := aim.length()
	return is_finite(aim_length) and aim_length > 0.0


func _empty_read_only_array() -> Array:
	var value: Array = []
	value.make_read_only()
	return value


func _empty_read_only_dictionary() -> Dictionary:
	var value: Dictionary = {}
	value.make_read_only()
	return value
