class_name Phase1EffectDefinition
extends Resource

@export var effect_id: StringName = &""
@export_range(1, 100, 1) var debug_hit_value: int = 1


func validate() -> PackedStringArray:
	var errors := PackedStringArray()
	if effect_id.is_empty():
		errors.append("effect_id must not be empty")
	if debug_hit_value <= 0:
		errors.append("debug_hit_value must be positive")
	return errors

