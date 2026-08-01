class_name Phase2CombatFormDefinition
extends Resource

const COMBAT_FORM_BLADE_ONE_HAND_PROTOTYPE: StringName = &"combat_form.blade.one_hand.prototype"
const ACTION_QUICK_CUT: StringName = &"action.physical.quick_cut"
const ACTION_HEAVY_CLEAVE: StringName = &"action.physical.heavy_cleave"

const EFFECT_QUICK_CUT_DAMAGE: StringName = &"effect.physical.quick_cut.damage"
const EFFECT_QUICK_CUT_PART_DAMAGE: StringName = &"effect.physical.quick_cut.part_damage"
const EFFECT_HEAVY_CLEAVE_DAMAGE: StringName = &"effect.physical.heavy_cleave.damage"
const EFFECT_HEAVY_CLEAVE_PART_DAMAGE: StringName = &"effect.physical.heavy_cleave.part_damage"

const HIT_SHAPE_SAFE_CIRCLE: StringName = &"hit_shape.physical.prototype.safe_circle"

@export var combat_form_id: StringName = &""
@export var action_set_ids: Array[StringName] = []


func validate() -> PackedStringArray:
	var errors := PackedStringArray()
	if combat_form_id.is_empty():
		errors.append("combat_form_id must not be empty")
	elif combat_form_id != COMBAT_FORM_BLADE_ONE_HAND_PROTOTYPE:
		errors.append("combat_form_id is not the approved partial form: %s" % combat_form_id)

	var seen_action_ids: Dictionary = {}
	for index in range(action_set_ids.size()):
		var action_id: StringName = action_set_ids[index]
		if action_id.is_empty():
			errors.append("action_set_ids[%d] must not be empty" % index)
		elif seen_action_ids.has(action_id):
			errors.append("action_set_ids contains duplicate: %s" % action_id)
		else:
			seen_action_ids[action_id] = true

	if action_set_ids.size() != 2:
		errors.append("partial form must contain exactly two actions")
	else:
		if action_set_ids[0] != ACTION_QUICK_CUT:
			errors.append("action_set_ids[0] must be quick cut")
		if action_set_ids[1] != ACTION_HEAVY_CLEAVE:
			errors.append("action_set_ids[1] must be heavy cleave")
	return errors


func validate_registry(action_definitions: Array, effect_definitions: Array) -> PackedStringArray:
	var errors := validate()
	var action_registry: Dictionary = {}
	var effect_registry: Dictionary = {}

	for index in range(action_definitions.size()):
		var raw_action = action_definitions[index]
		if not (raw_action is Phase1ActionDefinition):
			errors.append("action_definitions[%d] must be a Phase1ActionDefinition" % index)
			continue
		var action: Phase1ActionDefinition = raw_action
		if action.action_id.is_empty():
			errors.append("action_definitions[%d].action_id must not be empty" % index)
			continue
		if action_registry.has(action.action_id):
			errors.append("duplicate action definition ID: %s" % action.action_id)
			continue
		action_registry[action.action_id] = action
		for error in action.validate():
			errors.append("action %s: %s" % [action.action_id, error])

	for index in range(effect_definitions.size()):
		var raw_effect = effect_definitions[index]
		if not (raw_effect is Phase1EffectDefinition):
			errors.append("effect_definitions[%d] must be a Phase1EffectDefinition" % index)
			continue
		var effect: Phase1EffectDefinition = raw_effect
		if effect.effect_id.is_empty():
			errors.append("effect_definitions[%d].effect_id must not be empty" % index)
			continue
		if effect_registry.has(effect.effect_id):
			errors.append("duplicate effect definition ID: %s" % effect.effect_id)
			continue
		effect_registry[effect.effect_id] = effect
		for error in effect.validate():
			errors.append("effect %s: %s" % [effect.effect_id, error])

	if action_registry.size() != action_set_ids.size():
		errors.append("action registry must contain exactly the form action definitions")
	for raw_action_id in action_registry:
		var action_id: StringName = raw_action_id
		if not action_set_ids.has(action_id):
			errors.append("action definition is outside the form: %s" % action_id)

	var referenced_effect_ids: Dictionary = {}
	for raw_action_id in action_set_ids:
		var action_id: StringName = raw_action_id
		if not action_registry.has(action_id):
			errors.append("unknown action reference: %s" % action_id)
			continue
		var action: Phase1ActionDefinition = action_registry[action_id]
		_validate_action_definition(action, errors)
		for referenced_effect_id in action.effect_ids:
			referenced_effect_ids[referenced_effect_id] = true
			if not effect_registry.has(referenced_effect_id):
				errors.append("action %s has unknown effect reference: %s" % [
					action.action_id,
					referenced_effect_id,
				])

	if effect_registry.size() != referenced_effect_ids.size():
		errors.append("effect registry must contain exactly the four referenced effects")
	for raw_effect_id in effect_registry:
		var effect_id: StringName = raw_effect_id
		if not referenced_effect_ids.has(effect_id):
			errors.append("effect definition is outside the form registry: %s" % effect_id)
		var effect: Phase1EffectDefinition = effect_registry[effect_id]
		_validate_effect_definition(effect, errors)
	return errors


func _validate_action_definition(action: Phase1ActionDefinition, errors: PackedStringArray) -> void:
	if action.category != Phase1ActionDefinition.CATEGORY_PHYSICAL:
		errors.append("action %s must use the physical category" % action.action_id)
	if action.hit_query_reservation_class != Phase1HitQueryPool.RESERVATION_PLAYER_CRITICAL:
		errors.append("action %s must use PlayerCritical reservation" % action.action_id)
	if action.max_concurrent_hit_queries != 1:
		errors.append("action %s must allow exactly one concurrent query" % action.action_id)
	if action.hit_shape_id != HIT_SHAPE_SAFE_CIRCLE:
		errors.append("action %s must use the approved safe-circle hit shape" % action.action_id)
	if action.aim_policy.is_empty():
		errors.append("action %s must define an aim policy" % action.action_id)
	elif not Phase1ActionDefinition.is_valid_aim_policy(action.aim_policy):
		errors.append("action %s has an invalid aim policy: %s" % [action.action_id, action.aim_policy])
	if action.effect != null:
		errors.append("action %s must not use the legacy effect field" % action.action_id)
	if not action.animation_id.is_empty() or not action.vfx_id.is_empty() or not action.sfx_id.is_empty():
		errors.append("action %s must not contain presentation references" % action.action_id)

	var expected_effect_ids := _expected_effect_ids(action.action_id)
	if expected_effect_ids.is_empty():
		errors.append("action is outside the approved partial form: %s" % action.action_id)
	elif action.effect_ids != expected_effect_ids:
		errors.append("action %s effect references must match the approved order" % action.action_id)

	if action.action_id == ACTION_QUICK_CUT:
		if action.aim_policy != Phase1ActionDefinition.AIM_POLICY_FOLLOW_WINDUP_THEN_LOCK:
			errors.append("quick cut must follow aim through windup")
	elif action.action_id == ACTION_HEAVY_CLEAVE:
		if action.aim_policy != Phase1ActionDefinition.AIM_POLICY_LOCK_ON_ACCEPT:
			errors.append("heavy cleave must lock aim on acceptance")
	_validate_exact_action_values(action, errors)


func _validate_effect_definition(effect: Phase1EffectDefinition, errors: PackedStringArray) -> void:
	var expected_type := _expected_effect_type(effect.effect_id)
	if expected_type.is_empty():
		errors.append("effect is outside the approved registry: %s" % effect.effect_id)
	elif effect.effect_type != expected_type:
		errors.append("effect %s has the wrong effect type" % effect.effect_id)
	if not Phase1EffectDefinition.is_isolated_physical_effect_type(effect.effect_type):
		errors.append("effect %s must be damage or part_damage" % effect.effect_id)
	if effect.channel != Phase1EffectDefinition.CHANNEL_PHYSICAL:
		errors.append("effect %s must use the physical channel" % effect.effect_id)
	if effect.duration != 0.0:
		errors.append("effect %s must have zero duration" % effect.effect_id)
	if effect.target_rule != Phase1EffectDefinition.TARGET_HIT_TARGET:
		errors.append("effect %s must target the hit target" % effect.effect_id)
	if effect.stack_rule != Phase1EffectDefinition.STACK_INSTANT:
		errors.append("effect %s must use the instant stack rule" % effect.effect_id)
	if not effect.tags.is_empty():
		errors.append("effect %s must have empty tags" % effect.effect_id)
	_validate_exact_effect_magnitude(effect, errors)


func _validate_exact_action_values(action: Phase1ActionDefinition, errors: PackedStringArray) -> void:
	if action.reach != 150.0:
		errors.append("action %s must use reach 150" % action.action_id)
	if action.query_radius != 88.0:
		errors.append("action %s must use query radius 88" % action.action_id)
	if action.minimum_aim_dot != 0.25:
		errors.append("action %s must use minimum aim dot 0.25" % action.action_id)
	if action.max_targets != 1:
		errors.append("action %s must target at most one actor" % action.action_id)
	if action.active_seconds != 0.10:
		errors.append("action %s must use active duration 0.10" % action.action_id)
	if action.cooldown_seconds != 0.0:
		errors.append("action %s must use zero cooldown" % action.action_id)

	if action.action_id == ACTION_QUICK_CUT:
		if action.windup_seconds != 0.10:
			errors.append("quick cut must use windup 0.10")
		if action.recovery_seconds != 0.20:
			errors.append("quick cut must use recovery 0.20")
		if action.forward_movement_intent_pixels != 0.0:
			errors.append("quick cut must use zero forward movement intent")
	elif action.action_id == ACTION_HEAVY_CLEAVE:
		if action.windup_seconds != 0.40:
			errors.append("heavy cleave must use windup 0.40")
		if action.recovery_seconds != 0.50:
			errors.append("heavy cleave must use recovery 0.50")
		if action.forward_movement_intent_pixels != 48.0:
			errors.append("heavy cleave must use forward movement intent 48")


func _validate_exact_effect_magnitude(effect: Phase1EffectDefinition, errors: PackedStringArray) -> void:
	var expected_magnitude := 0.0
	var has_expected_magnitude := true
	match effect.effect_id:
		EFFECT_QUICK_CUT_DAMAGE:
			expected_magnitude = 10.0
		EFFECT_QUICK_CUT_PART_DAMAGE:
			expected_magnitude = 6.0
		EFFECT_HEAVY_CLEAVE_DAMAGE:
			expected_magnitude = 14.0
		EFFECT_HEAVY_CLEAVE_PART_DAMAGE:
			expected_magnitude = 18.0
		_:
			has_expected_magnitude = false
	if has_expected_magnitude and effect.magnitude != expected_magnitude:
		errors.append("effect %s has the wrong approved magnitude" % effect.effect_id)


func _expected_effect_ids(action_id: StringName) -> Array[StringName]:
	if action_id == ACTION_QUICK_CUT:
		return [EFFECT_QUICK_CUT_DAMAGE, EFFECT_QUICK_CUT_PART_DAMAGE]
	if action_id == ACTION_HEAVY_CLEAVE:
		return [EFFECT_HEAVY_CLEAVE_DAMAGE, EFFECT_HEAVY_CLEAVE_PART_DAMAGE]
	return []


func _expected_effect_type(effect_id: StringName) -> StringName:
	if effect_id == EFFECT_QUICK_CUT_DAMAGE or effect_id == EFFECT_HEAVY_CLEAVE_DAMAGE:
		return Phase1EffectDefinition.EFFECT_TYPE_DAMAGE
	if effect_id == EFFECT_QUICK_CUT_PART_DAMAGE or effect_id == EFFECT_HEAVY_CLEAVE_PART_DAMAGE:
		return Phase1EffectDefinition.EFFECT_TYPE_PART_DAMAGE
	return &""
