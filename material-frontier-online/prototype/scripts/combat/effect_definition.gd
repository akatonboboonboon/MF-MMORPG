class_name Phase1EffectDefinition
extends Resource

const EFFECT_TYPE_DAMAGE: StringName = &"damage"
const EFFECT_TYPE_PART_DAMAGE: StringName = &"part_damage"
const CHANNEL_PHYSICAL: StringName = &"physical"
const TARGET_HIT_TARGET: StringName = &"hit_target"
const STACK_INSTANT: StringName = &"instant"

@export var effect_id: StringName = &""
@export_range(1, 100, 1) var debug_hit_value: int = 1

@export_group("Common Effect Scaffold")
@export var effect_type: StringName = &""
@export var channel: StringName = &""
@export var magnitude: float = 0.0
@export var duration: float = 0.0
@export var target_rule: StringName = &""
@export var stack_rule: StringName = &""
@export var tags: Array[StringName] = []

@export_group("")


func validate() -> PackedStringArray:
	if _uses_common_scaffold():
		return _validate_common_scaffold()
	return _validate_legacy()


func _validate_legacy() -> PackedStringArray:
	var errors := PackedStringArray()
	if effect_id.is_empty():
		errors.append("effect_id must not be empty")
	if debug_hit_value <= 0:
		errors.append("debug_hit_value must be positive")
	return errors


func _validate_common_scaffold() -> PackedStringArray:
	var errors := PackedStringArray()
	if effect_id.is_empty():
		errors.append("effect_id must not be empty")
	if effect_type.is_empty():
		errors.append("effect_type must not be empty")
	if channel.is_empty():
		errors.append("channel must not be empty")
	if not is_finite(magnitude):
		errors.append("magnitude must be finite")
	if not is_finite(duration):
		errors.append("duration must be finite")
	elif duration < 0.0:
		errors.append("duration must be nonnegative")
	if target_rule.is_empty():
		errors.append("target_rule must not be empty")
	if stack_rule.is_empty():
		errors.append("stack_rule must not be empty")
	for index in range(tags.size()):
		if tags[index].is_empty():
			errors.append("tags[%d] must not be empty" % index)
	return errors


func _uses_common_scaffold() -> bool:
	return (
		not effect_type.is_empty()
		or not channel.is_empty()
		or magnitude != 0.0
		or duration != 0.0
		or not target_rule.is_empty()
		or not stack_rule.is_empty()
		or not tags.is_empty()
	)


static func is_isolated_physical_effect_type(value: StringName) -> bool:
	return value == EFFECT_TYPE_DAMAGE or value == EFFECT_TYPE_PART_DAMAGE
