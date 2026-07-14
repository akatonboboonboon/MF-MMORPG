class_name Phase1ActionDefinition
extends Resource

@export var action_id: StringName = &""
@export_range(1.0, 500.0, 1.0) var reach: float = 150.0
@export_range(1.0, 300.0, 1.0) var query_radius: float = 88.0
@export_range(-1.0, 1.0, 0.01) var minimum_aim_dot: float = 0.25
@export_range(1, 8, 1) var max_targets: int = 1
@export_range(1, 4, 1) var max_concurrent_hit_queries: int = 1
@export var effect: Phase1EffectDefinition


func validate() -> PackedStringArray:
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

