class_name Phase1ActionDefinition
extends Resource

const CATEGORY_PHYSICAL: StringName = &"physical"
const CATEGORY_MAGIC: StringName = &"magic"
const CATEGORY_EVADE: StringName = &"evade"
const CATEGORY_INTERACT: StringName = &"interact"

const AIM_POLICY_FOLLOW_WINDUP_THEN_LOCK: StringName = &"follow_windup_then_lock"
const AIM_POLICY_LOCK_ON_ACCEPT: StringName = &"lock_on_accept"

@export var action_id: StringName = &""
@export_range(1.0, 500.0, 1.0) var reach: float = 150.0
@export_range(1.0, 300.0, 1.0) var query_radius: float = 88.0
@export_range(-1.0, 1.0, 0.01) var minimum_aim_dot: float = 0.25
@export_range(1, 8, 1) var max_targets: int = 1
@export_range(0, 4, 1, "or_greater") var max_concurrent_hit_queries: int = 1
@export var effect: Phase1EffectDefinition

@export_group("Common Action Scaffold")
@export var category: StringName = &""
@export var windup_seconds: float = 0.0
@export var active_seconds: float = 0.0
@export var recovery_seconds: float = 0.0
@export var cooldown_seconds: float = 0.0
@export var hit_shape_id: StringName = &""
@export var effect_ids: Array[StringName] = []
@export var hit_query_reservation_class: StringName = &""
@export var aim_policy: StringName = &""
@export var forward_movement_intent_pixels: float = 0.0

@export_group("Presentation References")
@export var animation_id: StringName = &""
@export var vfx_id: StringName = &""
@export var sfx_id: StringName = &""

@export_group("")


func validate() -> PackedStringArray:
	if _uses_common_scaffold():
		return _validate_common_scaffold()
	return _validate_legacy()


func _validate_legacy() -> PackedStringArray:
	var errors := PackedStringArray()
	if action_id.is_empty():
		errors.append("action_id must not be empty")
	if reach <= 0.0:
		errors.append("reach must be positive")
	if query_radius <= 0.0:
		errors.append("query_radius must be positive")
	if max_targets <= 0:
		errors.append("max_targets must be positive")
	if max_concurrent_hit_queries <= 0:
		errors.append("max_concurrent_hit_queries must be positive")
	if effect == null:
		errors.append("effect is required")
	else:
		for error in effect.validate():
			errors.append("effect: %s" % error)
	return errors


func _validate_common_scaffold() -> PackedStringArray:
	var errors := PackedStringArray()
	if action_id.is_empty():
		errors.append("action_id must not be empty")
	if category.is_empty():
		errors.append("category must not be empty")
	elif not _is_valid_category(category):
		errors.append("category is invalid: %s" % category)
	_validate_nonnegative_seconds(windup_seconds, "windup_seconds", errors)
	_validate_nonnegative_seconds(active_seconds, "active_seconds", errors)
	_validate_nonnegative_seconds(recovery_seconds, "recovery_seconds", errors)
	_validate_nonnegative_seconds(cooldown_seconds, "cooldown_seconds", errors)
	_validate_positive_finite(reach, "reach", errors)
	_validate_positive_finite(query_radius, "query_radius", errors)
	if not is_finite(minimum_aim_dot):
		errors.append("minimum_aim_dot must be finite")
	elif minimum_aim_dot < -1.0 or minimum_aim_dot > 1.0:
		errors.append("minimum_aim_dot must be between -1 and 1")
	if max_targets <= 0:
		errors.append("max_targets must be positive")
	if max_concurrent_hit_queries < 0:
		errors.append("max_concurrent_hit_queries must be nonnegative")
	if not Phase1HitQueryPool.is_valid_reservation_class(hit_query_reservation_class):
		errors.append("hit_query_reservation_class is invalid: %s" % hit_query_reservation_class)
	if not aim_policy.is_empty() and not is_valid_aim_policy(aim_policy):
		errors.append("aim_policy is invalid: %s" % aim_policy)
	if not is_finite(forward_movement_intent_pixels):
		errors.append("forward_movement_intent_pixels must be finite")
	elif forward_movement_intent_pixels < 0.0:
		errors.append("forward_movement_intent_pixels must be nonnegative")

	var seen_effect_ids: Dictionary = {}
	for index in range(effect_ids.size()):
		var referenced_effect_id := effect_ids[index]
		if referenced_effect_id.is_empty():
			errors.append("effect_ids[%d] must not be empty" % index)
		elif seen_effect_ids.has(referenced_effect_id):
			errors.append("effect_ids contains duplicate: %s" % referenced_effect_id)
		else:
			seen_effect_ids[referenced_effect_id] = true

	if effect != null:
		if not effect.effect_id.is_empty() and seen_effect_ids.has(effect.effect_id):
			errors.append("effect_ids duplicates legacy effect: %s" % effect.effect_id)
		for error in effect.validate():
			errors.append("effect: %s" % error)
	return errors


func _uses_common_scaffold() -> bool:
	return (
		not category.is_empty()
		or windup_seconds != 0.0
		or active_seconds != 0.0
		or recovery_seconds != 0.0
		or cooldown_seconds != 0.0
		or not hit_shape_id.is_empty()
		or not effect_ids.is_empty()
		or not hit_query_reservation_class.is_empty()
		or not aim_policy.is_empty()
		or forward_movement_intent_pixels != 0.0
		or not animation_id.is_empty()
		or not vfx_id.is_empty()
		or not sfx_id.is_empty()
	)


func _validate_nonnegative_seconds(value: float, field_name: String, errors: PackedStringArray) -> void:
	if not is_finite(value):
		errors.append("%s must be finite" % field_name)
	elif value < 0.0:
		errors.append("%s must be nonnegative" % field_name)


func _validate_positive_finite(value: float, field_name: String, errors: PackedStringArray) -> void:
	if not is_finite(value):
		errors.append("%s must be finite" % field_name)
	elif value <= 0.0:
		errors.append("%s must be positive" % field_name)


static func is_valid_aim_policy(value: StringName) -> bool:
	return (
		value == AIM_POLICY_FOLLOW_WINDUP_THEN_LOCK
		or value == AIM_POLICY_LOCK_ON_ACCEPT
	)


func _is_valid_category(value: StringName) -> bool:
	return (
		value == CATEGORY_PHYSICAL
		or value == CATEGORY_MAGIC
		or value == CATEGORY_EVADE
		or value == CATEGORY_INTERACT
	)

