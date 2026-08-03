extends SceneTree

const FORM_PATH := "res://data/phase2/combat_forms/blade_one_hand_prototype.tres"
const QUICK_PATH := "res://data/phase2/actions/quick_cut.tres"
const HEAVY_PATH := "res://data/phase2/actions/heavy_cleave.tres"
const QUICK_DAMAGE_PATH := "res://data/phase2/effects/quick_cut_damage.tres"
const QUICK_PART_PATH := "res://data/phase2/effects/quick_cut_part_damage.tres"
const HEAVY_DAMAGE_PATH := "res://data/phase2/effects/heavy_cleave_damage.tres"
const HEAVY_PART_PATH := "res://data/phase2/effects/heavy_cleave_part_damage.tres"

class CallbackProbe extends Node:
	var calls := 0
	var status: StringName = &"hit"

	func invoke(_request: Dictionary) -> Dictionary:
		calls += 1
		return {"status": status}

var _failures: Array[String] = []
var _assertion_count := 0
var _requests: Array = []
var _next_callback_status: StringName = &"hit"


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_test_resources_and_registry()
	_test_registry_rejects_invalid_variants()
	_test_runtime_configuration_and_rejection()
	_test_quick_runtime_contract()
	_test_heavy_runtime_contract()
	_test_release_reset_and_clear_contract()
	_test_complete_registry_negatives()
	_test_literal_vocabulary_and_source_isolation()
	_test_complete_callback_and_boundary_contract()
	_test_complete_debug_record_contract()
	if _failures.is_empty():
		print("[MFO-P2-2B-STAGEB-KERNEL-TEST] PASS: %d assertions" % _assertion_count)
		quit(0)
	else:
		for failure in _failures:
			push_error("[MFO-P2-2B-STAGEB-KERNEL-TEST] %s" % failure)
		print("[MFO-P2-2B-STAGEB-KERNEL-TEST] FAIL: %d / %d assertions failed" % [_failures.size(), _assertion_count])
		quit(1)


func _test_resources_and_registry() -> void:
	var form := _form()
	var quick := _quick()
	var heavy := _heavy()
	var effects := _effects()
	_check(form != null and quick != null and heavy != null and effects.size() == 4, "seven Stage B resources load")
	_check(form.validate().is_empty(), "approved combat form validates")
	_check(form.combat_form_id == Phase2CombatFormDefinition.COMBAT_FORM_BLADE_ONE_HAND_PROTOTYPE, "form uses approved combat-form ID")
	_check(form.action_set_ids == [Phase2CombatFormDefinition.ACTION_QUICK_CUT, Phase2CombatFormDefinition.ACTION_HEAVY_CLEAVE], "form action order is quick then heavy")
	_check(quick.validate().is_empty() and heavy.validate().is_empty(), "both action resources validate")
	_check(quick.action_id == Phase2CombatFormDefinition.ACTION_QUICK_CUT and heavy.action_id == Phase2CombatFormDefinition.ACTION_HEAVY_CLEAVE, "action IDs are exact")
	_check(quick.category == Phase1ActionDefinition.CATEGORY_PHYSICAL and heavy.category == Phase1ActionDefinition.CATEGORY_PHYSICAL, "actions use physical category")
	_check(quick.reach == 150.0 and heavy.reach == 150.0 and quick.query_radius == 88.0 and heavy.query_radius == 88.0, "shared geometry is 150 reach and 88 radius")
	_check(quick.minimum_aim_dot == 0.25 and heavy.minimum_aim_dot == 0.25 and quick.max_targets == 1 and heavy.max_targets == 1, "shared target geometry is exact")
	_check(quick.hit_shape_id == Phase2CombatFormDefinition.HIT_SHAPE_SAFE_CIRCLE and heavy.hit_shape_id == Phase2CombatFormDefinition.HIT_SHAPE_SAFE_CIRCLE, "actions use safe-circle shape identifier")
	_check(quick.hit_query_reservation_class == Phase1HitQueryPool.RESERVATION_PLAYER_CRITICAL and heavy.hit_query_reservation_class == Phase1HitQueryPool.RESERVATION_PLAYER_CRITICAL, "actions reserve PlayerCritical only")
	_check(quick.max_concurrent_hit_queries == 1 and heavy.max_concurrent_hit_queries == 1, "actions allow one concurrent query")
	_check(quick.windup_seconds == 0.10 and quick.active_seconds == 0.10 and quick.recovery_seconds == 0.20 and quick.cooldown_seconds == 0.0, "quick timing is 6/6/12 nominal ticks")
	_check(heavy.windup_seconds == 0.40 and heavy.active_seconds == 0.10 and heavy.recovery_seconds == 0.50 and heavy.cooldown_seconds == 0.0, "heavy timing is 24/6/30 nominal ticks")
	_check(quick.aim_policy == Phase1ActionDefinition.AIM_POLICY_FOLLOW_WINDUP_THEN_LOCK and heavy.aim_policy == Phase1ActionDefinition.AIM_POLICY_LOCK_ON_ACCEPT, "aim policies are exact")
	_check(quick.forward_movement_intent_pixels == 0.0 and heavy.forward_movement_intent_pixels == 48.0, "only heavy has 48 pixel active intent")
	_check(quick.effect == null and heavy.effect == null, "legacy effect field is null")
	_check(quick.animation_id.is_empty() and quick.vfx_id.is_empty() and quick.sfx_id.is_empty() and heavy.animation_id.is_empty() and heavy.vfx_id.is_empty() and heavy.sfx_id.is_empty(), "actions have no presentation references")
	_check(quick.effect_ids == [Phase2CombatFormDefinition.EFFECT_QUICK_CUT_DAMAGE, Phase2CombatFormDefinition.EFFECT_QUICK_CUT_PART_DAMAGE], "quick effect order is exact")
	_check(heavy.effect_ids == [Phase2CombatFormDefinition.EFFECT_HEAVY_CLEAVE_DAMAGE, Phase2CombatFormDefinition.EFFECT_HEAVY_CLEAVE_PART_DAMAGE], "heavy effect order is exact")
	var expected_ids: Array[StringName] = [Phase2CombatFormDefinition.EFFECT_QUICK_CUT_DAMAGE, Phase2CombatFormDefinition.EFFECT_QUICK_CUT_PART_DAMAGE, Phase2CombatFormDefinition.EFFECT_HEAVY_CLEAVE_DAMAGE, Phase2CombatFormDefinition.EFFECT_HEAVY_CLEAVE_PART_DAMAGE]
	var expected_types: Array[StringName] = [Phase1EffectDefinition.EFFECT_TYPE_DAMAGE, Phase1EffectDefinition.EFFECT_TYPE_PART_DAMAGE, Phase1EffectDefinition.EFFECT_TYPE_DAMAGE, Phase1EffectDefinition.EFFECT_TYPE_PART_DAMAGE]
	var expected_magnitudes := [10.0, 6.0, 14.0, 18.0]
	for index in range(effects.size()):
		var effect: Phase1EffectDefinition = effects[index]
		_check(effect.validate().is_empty(), "effect %d validates" % index)
		_check(effect.effect_id == expected_ids[index] and effect.effect_type == expected_types[index] and effect.magnitude == expected_magnitudes[index], "effect %d has approved identity/type/magnitude" % index)
		_check(effect.channel == Phase1EffectDefinition.CHANNEL_PHYSICAL and effect.duration == 0.0 and effect.target_rule == Phase1EffectDefinition.TARGET_HIT_TARGET and effect.stack_rule == Phase1EffectDefinition.STACK_INSTANT and effect.tags.is_empty(), "effect %d remains isolated physical instant data" % index)
	_check(form.validate_registry([quick, heavy], effects).is_empty(), "exact Stage B action/effect registry validates")


func _test_registry_rejects_invalid_variants() -> void:
	var form := _form()
	var quick := _quick()
	var heavy := _heavy()
	var effects := _effects()
	var reordered_form := _form()
	reordered_form.action_set_ids = [Phase2CombatFormDefinition.ACTION_HEAVY_CLEAVE, Phase2CombatFormDefinition.ACTION_QUICK_CUT]
	_check(not reordered_form.validate().is_empty(), "form rejects reordered actions")
	var duplicate_form := _form()
	duplicate_form.action_set_ids = [Phase2CombatFormDefinition.ACTION_QUICK_CUT, Phase2CombatFormDefinition.ACTION_QUICK_CUT]
	_check(not duplicate_form.validate().is_empty(), "form rejects duplicate actions")
	var missing_actions: Array = [quick]
	_check(not form.validate_registry(missing_actions, effects).is_empty(), "registry rejects missing action")
	var duplicate_actions: Array = [quick, quick]
	_check(not form.validate_registry(duplicate_actions, effects).is_empty(), "registry rejects duplicate action definition")
	var extra_action := _copy_action(quick)
	extra_action.action_id = &"action.physical.extra"
	_check(not form.validate_registry([quick, heavy, extra_action], effects).is_empty(), "registry rejects extra action")
	var missing_effects: Array = [effects[0], effects[1], effects[2]]
	_check(not form.validate_registry([quick, heavy], missing_effects).is_empty(), "registry rejects missing effect")
	var duplicate_effects: Array = [effects[0], effects[0], effects[2], effects[3]]
	_check(not form.validate_registry([quick, heavy], duplicate_effects).is_empty(), "registry rejects duplicate effect definition")
	var extra_effect := _copy_effect(effects[0])
	extra_effect.effect_id = &"effect.physical.extra"
	_check(not form.validate_registry([quick, heavy], [effects[0], effects[1], effects[2], effects[3], extra_effect]).is_empty(), "registry rejects extra effect")
	var crosswired_quick := _copy_action(quick)
	crosswired_quick.effect_ids = [Phase2CombatFormDefinition.EFFECT_HEAVY_CLEAVE_DAMAGE, Phase2CombatFormDefinition.EFFECT_HEAVY_CLEAVE_PART_DAMAGE]
	_check(not form.validate_registry([crosswired_quick, heavy], effects).is_empty(), "registry rejects crosswired action effects")
	var malformed := _copy_action(quick)
	malformed.reach = INF
	malformed.active_seconds = NAN
	malformed.aim_policy = &"bad_policy"
	malformed.forward_movement_intent_pixels = -1.0
	_check(not form.validate_registry([malformed, heavy], effects).is_empty(), "registry rejects nonfinite geometry/timing and invalid policy/intent")


func _test_runtime_configuration_and_rejection() -> void:
	var runtime := Phase2ActionRuntime.new()
	_check(runtime is RefCounted, "runtime is an isolated RefCounted object")
	var unconfigured_rejected := not runtime.try_accept(Phase2CombatFormDefinition.ACTION_QUICK_CUT, Vector2.RIGHT)
	var unconfigured_state := runtime.debug_state()
	var unconfigured_result := runtime.debug_result()
	_check(unconfigured_rejected and _is_final_idle(runtime) and unconfigured_state.is_read_only() and unconfigured_state.has("accepted_sequence") and unconfigured_state["accepted_sequence"] is int and unconfigured_state["accepted_sequence"] == 0 and unconfigured_state.has("accepted_count") and unconfigured_state["accepted_count"] is int and unconfigured_state["accepted_count"] == 0 and unconfigured_state.has("query_count") and unconfigured_state["query_count"] is int and unconfigured_state["query_count"] == 0 and unconfigured_result.is_read_only() and unconfigured_result.is_empty() and _requests.is_empty(), "unconfigured runtime rejects acceptance")
	_check(not runtime.advance(0.1), "idle runtime rejects advance")
	var invalid_form_errors := runtime.configure(RefCounted.new(), [_quick(), _heavy()], _effects(), _pool(), Callable(self, "_query_callback"))
	_check(not invalid_form_errors.is_empty(), "configuration rejects non-form object")
	var invalid_pool = RefCounted.new()
	_check(not runtime.configure(_form(), [_quick(), _heavy()], _effects(), invalid_pool, Callable(self, "_query_callback")).is_empty(), "configuration rejects non-query-pool object")
	_check(not runtime.configure(_form(), [_quick(), _heavy()], _effects(), _pool(), Callable()).is_empty(), "configuration rejects invalid callback")
	var invalid_registry_quick := _copy_action(_quick())
	invalid_registry_quick.effect_ids = [&"effect.missing"]
	_check(not runtime.configure(_form(), [invalid_registry_quick, _heavy()], _effects(), _pool(), Callable(self, "_query_callback")).is_empty(), "configuration rejects invalid registry")
	var pool := _pool()
	_check(runtime.configure(_form(), [_quick(), _heavy()], _effects(), pool, Callable(self, "_query_callback")).is_empty(), "valid runtime configuration succeeds")
	_check(not runtime.configure(_form(), [_quick(), _heavy()], _effects(), pool, Callable(self, "_query_callback")).is_empty(), "configuration is one-shot")
	var rejection_request_baseline := _requests.size()
	var empty_rejected := not runtime.try_accept(&"", Vector2.RIGHT)
	var empty_state := runtime.debug_state()
	var empty_result := runtime.debug_result()
	var empty_request_count := _requests.size()
	var unknown_rejected := not runtime.try_accept(&"unknown", Vector2.RIGHT)
	var unknown_state := runtime.debug_state()
	var unknown_result := runtime.debug_result()
	var unknown_request_count := _requests.size()
	var empty_unchanged: bool = empty_state.is_read_only() and empty_state.has("phase") and empty_state["phase"] is StringName and empty_state["phase"] == Phase2ActionRuntime.PHASE_IDLE and empty_state.has("accepted_sequence") and empty_state["accepted_sequence"] is int and empty_state["accepted_sequence"] == 0 and empty_state.has("accepted_count") and empty_state["accepted_count"] is int and empty_state["accepted_count"] == 0 and empty_state.has("query_count") and empty_state["query_count"] is int and empty_state["query_count"] == 0 and empty_state.has("has_pending_lease") and empty_state["has_pending_lease"] is bool and not empty_state["has_pending_lease"] and empty_state.has("has_query_result") and empty_state["has_query_result"] is bool and not empty_state["has_query_result"] and empty_state.has("effects") and empty_state["effects"] is Array and empty_state["effects"].is_read_only() and empty_state["effects"].is_empty() and empty_state.has("requested_forward_movement_intent_pixels") and empty_state["requested_forward_movement_intent_pixels"] is float and empty_state["requested_forward_movement_intent_pixels"] == 0.0 and empty_state.has("active_query_count") and empty_state["active_query_count"] is int and empty_state["active_query_count"] == 0 and empty_state.has("emergency_active_count") and empty_state["emergency_active_count"] is int and empty_state["emergency_active_count"] == 0 and empty_state.has("emergency_use_count") and empty_state["emergency_use_count"] is int and empty_state["emergency_use_count"] == 0 and empty_result.is_read_only() and empty_result.is_empty() and empty_request_count == rejection_request_baseline
	var unknown_unchanged: bool = unknown_state.is_read_only() and unknown_state.has("phase") and unknown_state["phase"] is StringName and unknown_state["phase"] == Phase2ActionRuntime.PHASE_IDLE and unknown_state.has("accepted_sequence") and unknown_state["accepted_sequence"] is int and unknown_state["accepted_sequence"] == 0 and unknown_state.has("accepted_count") and unknown_state["accepted_count"] is int and unknown_state["accepted_count"] == 0 and unknown_state.has("query_count") and unknown_state["query_count"] is int and unknown_state["query_count"] == 0 and unknown_state.has("has_pending_lease") and unknown_state["has_pending_lease"] is bool and not unknown_state["has_pending_lease"] and unknown_state.has("has_query_result") and unknown_state["has_query_result"] is bool and not unknown_state["has_query_result"] and unknown_state.has("effects") and unknown_state["effects"] is Array and unknown_state["effects"].is_read_only() and unknown_state["effects"].is_empty() and unknown_state.has("requested_forward_movement_intent_pixels") and unknown_state["requested_forward_movement_intent_pixels"] is float and unknown_state["requested_forward_movement_intent_pixels"] == 0.0 and unknown_state.has("active_query_count") and unknown_state["active_query_count"] is int and unknown_state["active_query_count"] == 0 and unknown_state.has("emergency_active_count") and unknown_state["emergency_active_count"] is int and unknown_state["emergency_active_count"] == 0 and unknown_state.has("emergency_use_count") and unknown_state["emergency_use_count"] is int and unknown_state["emergency_use_count"] == 0 and unknown_result.is_read_only() and unknown_result.is_empty() and unknown_request_count == rejection_request_baseline
	_check(empty_rejected and empty_unchanged and unknown_rejected and unknown_unchanged, "runtime rejects empty and unknown actions")
	var zero_rejected := not runtime.try_accept(Phase2CombatFormDefinition.ACTION_QUICK_CUT, Vector2.ZERO)
	var zero_state := runtime.debug_state()
	var zero_result := runtime.debug_result()
	_check(zero_rejected and _is_final_idle(runtime) and zero_state.is_read_only() and zero_state.has("accepted_sequence") and zero_state["accepted_sequence"] is int and zero_state["accepted_sequence"] == 0 and zero_state.has("accepted_count") and zero_state["accepted_count"] is int and zero_state["accepted_count"] == 0 and zero_result.is_read_only() and zero_result.is_empty() and _requests.size() == rejection_request_baseline, "runtime rejects zero aim")
	var nonfinite_rejected := not runtime.try_accept(Phase2CombatFormDefinition.ACTION_QUICK_CUT, Vector2(INF, 0.0))
	var nonfinite_state := runtime.debug_state()
	var nonfinite_result := runtime.debug_result()
	_check(nonfinite_rejected and _is_final_idle(runtime) and nonfinite_state.is_read_only() and nonfinite_state.has("accepted_sequence") and nonfinite_state["accepted_sequence"] is int and nonfinite_state["accepted_sequence"] == 0 and nonfinite_state.has("accepted_count") and nonfinite_state["accepted_count"] is int and nonfinite_state["accepted_count"] == 0 and nonfinite_state.has("has_pending_lease") and nonfinite_state["has_pending_lease"] is bool and not nonfinite_state["has_pending_lease"] and nonfinite_result.is_read_only() and nonfinite_result.is_empty() and _requests.size() == rejection_request_baseline, "runtime rejects nonfinite aim")
	var state := runtime.debug_state()
	_check(state.is_read_only() and state.has("phase") and state["phase"] is StringName and state["phase"] == Phase2ActionRuntime.PHASE_IDLE and state.has("has_pending_lease") and state["has_pending_lease"] is bool and not state["has_pending_lease"], "idle debug state is readonly and has no lease")
	_check(runtime.debug_result().is_read_only() and runtime.debug_result().is_empty(), "empty debug result is readonly")


func _test_quick_runtime_contract() -> void:
	var runtime := _configured_runtime()
	_requests.clear()
	_next_callback_status = Phase2ActionRuntime.QUERY_STATUS_HIT
	_check(runtime.try_accept(Phase2CombatFormDefinition.ACTION_QUICK_CUT, Vector2.RIGHT), "quick accept reserves before windup")
	var busy_rejected := not runtime.try_accept(Phase2CombatFormDefinition.ACTION_HEAVY_CLEAVE, Vector2.UP)
	var busy_state := runtime.debug_state()
	var busy_result := runtime.debug_result()
	_check(busy_rejected and busy_state.is_read_only() and busy_state.has("action_id") and busy_state["action_id"] is StringName and busy_state["action_id"] == Phase2CombatFormDefinition.ACTION_QUICK_CUT and busy_state.has("phase") and busy_state["phase"] is StringName and busy_state["phase"] == Phase2ActionRuntime.PHASE_WINDUP and busy_state.has("accepted_sequence") and busy_state["accepted_sequence"] is int and busy_state["accepted_sequence"] == 1 and busy_state.has("accepted_count") and busy_state["accepted_count"] is int and busy_state["accepted_count"] == 1 and busy_state.has("query_count") and busy_state["query_count"] is int and busy_state["query_count"] == 0 and busy_state.has("active_query_count") and busy_state["active_query_count"] is int and busy_state["active_query_count"] == 1 and busy_state.has("emergency_active_count") and busy_state["emergency_active_count"] is int and busy_state["emergency_active_count"] == 0 and busy_state.has("emergency_use_count") and busy_state["emergency_use_count"] is int and busy_state["emergency_use_count"] == 0 and busy_state.has("has_pending_lease") and busy_state["has_pending_lease"] is bool and busy_state["has_pending_lease"] and busy_state.has("has_query_result") and busy_state["has_query_result"] is bool and not busy_state["has_query_result"] and busy_state.has("effects") and busy_state["effects"] is Array and busy_state["effects"].is_read_only() and busy_state["effects"].size() == 2 and busy_state.has("requested_forward_movement_intent_pixels") and busy_state["requested_forward_movement_intent_pixels"] is float and busy_state["requested_forward_movement_intent_pixels"] == 0.0 and busy_result.is_read_only() and busy_result.is_empty() and _requests.is_empty(), "busy runtime rejects without buffering")
	_check(busy_state.has("has_pending_lease") and busy_state["has_pending_lease"] is bool and busy_state["has_pending_lease"] and busy_state.has("active_query_count") and busy_state["active_query_count"] is int and busy_state["active_query_count"] == 1 and busy_state.has("query_count") and busy_state["query_count"] is int and busy_state["query_count"] == 0 and _requests.is_empty(), "quick accepted state owns one PlayerCritical lease")
	_check(runtime.advance(0.05, Vector2.UP), "quick accepts partial windup advance")
	var quick_windup_state := runtime.debug_state()
	_check(quick_windup_state.has("phase") and quick_windup_state["phase"] is StringName and quick_windup_state["phase"] == Phase2ActionRuntime.PHASE_WINDUP and quick_windup_state.has("query_count") and quick_windup_state["query_count"] is int and quick_windup_state["query_count"] == 0 and _requests.is_empty(), "quick remains windup before exact boundary")
	_check(runtime.advance(0.05, Vector2.UP), "quick crosses exact windup boundary")
	var quick_active_state := runtime.debug_state()
	var quick_active_result := runtime.debug_result()
	_check(quick_active_state.has("phase") and quick_active_state["phase"] is StringName and quick_active_state["phase"] == Phase2ActionRuntime.PHASE_ACTIVE and quick_active_state.has("query_count") and quick_active_state["query_count"] is int and quick_active_state["query_count"] == 1 and quick_active_result.has("query_count") and quick_active_result["query_count"] is int and quick_active_result["query_count"] == 1 and _requests.size() == 1, "quick enters active with exactly one callback")
	_check(_requests.size() == 1 and _requests[0] is Dictionary and _requests[0].is_read_only(), "quick callback gets one readonly request")
	var request: Dictionary = _requests[0] if _requests.size() == 1 and _requests[0] is Dictionary else {}
	var quick_geometry: Dictionary = request["geometry"] if request.has("geometry") and request["geometry"] is Dictionary else {}
	var quick_effects: Array = request["effects"] if request.has("effects") and request["effects"] is Array else []
	var quick_effect_0: Dictionary = quick_effects[0] if quick_effects.size() == 2 and quick_effects[0] is Dictionary else {}
	var quick_effect_1: Dictionary = quick_effects[1] if quick_effects.size() == 2 and quick_effects[1] is Dictionary else {}
	_check(request.has("action_id") and request["action_id"] is StringName and request["action_id"] == Phase2CombatFormDefinition.ACTION_QUICK_CUT and request.has("accepted_sequence") and request["accepted_sequence"] is int and request["accepted_sequence"] == 1, "quick request preserves action and sequence")
	_check(request.has("locked_aim") and request["locked_aim"] is Vector2 and request["locked_aim"].is_equal_approx(Vector2.UP) and request.has("forward_movement_intent_pixels") and request["forward_movement_intent_pixels"] is float and request["forward_movement_intent_pixels"] == 0.0, "quick follows windup aim then locks with zero intent")
	_check(quick_geometry.is_read_only() and quick_geometry.has("hit_shape_id") and quick_geometry["hit_shape_id"] is StringName and quick_geometry["hit_shape_id"] == &"hit_shape.physical.prototype.safe_circle" and quick_geometry.has("reach") and quick_geometry["reach"] is float and quick_geometry["reach"] == 150.0 and quick_geometry.has("query_radius") and quick_geometry["query_radius"] is float and quick_geometry["query_radius"] == 88.0 and quick_geometry.has("minimum_aim_dot") and quick_geometry["minimum_aim_dot"] is float and quick_geometry["minimum_aim_dot"] == 0.25 and request.has("max_targets") and request["max_targets"] is int and request["max_targets"] == 1, "quick request snapshot preserves geometry and target cap")
	_check(quick_effects.is_read_only() and quick_effects.size() == 2 and quick_effect_0.is_read_only() and quick_effect_1.is_read_only() and quick_effect_0.has("effect_id") and quick_effect_0["effect_id"] is StringName and quick_effect_0["effect_id"] == &"effect.physical.quick_cut.damage" and quick_effect_0.has("effect_type") and quick_effect_0["effect_type"] is StringName and quick_effect_0["effect_type"] == &"damage" and quick_effect_0.has("magnitude") and quick_effect_0["magnitude"] is float and quick_effect_0["magnitude"] == 10.0 and quick_effect_1.has("effect_id") and quick_effect_1["effect_id"] is StringName and quick_effect_1["effect_id"] == &"effect.physical.quick_cut.part_damage" and quick_effect_1.has("effect_type") and quick_effect_1["effect_type"] is StringName and quick_effect_1["effect_type"] == &"part_damage" and quick_effect_1.has("magnitude") and quick_effect_1["magnitude"] is float and quick_effect_1["magnitude"] == 6.0 and quick_effect_0.has("channel") and quick_effect_0["channel"] is StringName and quick_effect_0["channel"] == &"physical" and quick_effect_0.has("duration") and quick_effect_0["duration"] is float and quick_effect_0["duration"] == 0.0 and quick_effect_0.has("target_rule") and quick_effect_0["target_rule"] is StringName and quick_effect_0["target_rule"] == &"hit_target" and quick_effect_0.has("stack_rule") and quick_effect_0["stack_rule"] is StringName and quick_effect_0["stack_rule"] == &"instant" and quick_effect_0.has("tags") and quick_effect_0["tags"] is Array and quick_effect_0["tags"].is_read_only() and quick_effect_0["tags"].is_empty() and quick_effect_1.has("channel") and quick_effect_1["channel"] is StringName and quick_effect_1["channel"] == &"physical" and quick_effect_1.has("duration") and quick_effect_1["duration"] is float and quick_effect_1["duration"] == 0.0 and quick_effect_1.has("target_rule") and quick_effect_1["target_rule"] is StringName and quick_effect_1["target_rule"] == &"hit_target" and quick_effect_1.has("stack_rule") and quick_effect_1["stack_rule"] is StringName and quick_effect_1["stack_rule"] == &"instant" and quick_effect_1.has("tags") and quick_effect_1["tags"] is Array and quick_effect_1["tags"].is_read_only() and quick_effect_1["tags"].is_empty(), "quick request effects are readonly snapshots")
	_check(quick_active_result.is_read_only() and quick_active_result.has("status") and quick_active_result["status"] is StringName and quick_active_result["status"] == Phase2ActionRuntime.QUERY_STATUS_HIT and quick_active_result.has("query_count") and quick_active_result["query_count"] is int and quick_active_result["query_count"] == 1 and quick_active_result.has("release_succeeded") and quick_active_result["release_succeeded"] is bool and quick_active_result["release_succeeded"] and quick_active_result.has("active_query_count") and quick_active_result["active_query_count"] is int and quick_active_result["active_query_count"] == 0 and quick_active_result.has("emergency_active_count") and quick_active_result["emergency_active_count"] is int and quick_active_result["emergency_active_count"] == 0 and quick_active_result.has("emergency_use_count") and quick_active_result["emergency_use_count"] is int and quick_active_result["emergency_use_count"] == 0, "quick hit result releases its lease")
	_check(quick_active_state.has("active_query_count") and quick_active_state["active_query_count"] is int and quick_active_state["active_query_count"] == 0 and quick_active_state.has("emergency_active_count") and quick_active_state["emergency_active_count"] is int and quick_active_state["emergency_active_count"] == 0 and quick_active_state.has("emergency_use_count") and quick_active_state["emergency_use_count"] is int and quick_active_state["emergency_use_count"] == 0 and quick_active_state.has("has_pending_lease") and quick_active_state["has_pending_lease"] is bool and not quick_active_state["has_pending_lease"], "callback release restores pool before recovery")
	var quick_active_advance := runtime.advance(0.10)
	var quick_recovery_state := runtime.debug_state()
	var quick_recovery_result := runtime.debug_result()
	_check(quick_active_advance, "quick crosses active boundary")
	_check(quick_recovery_state.has("phase") and quick_recovery_state["phase"] is StringName and quick_recovery_state["phase"] == Phase2ActionRuntime.PHASE_RECOVERY and quick_recovery_state.has("requested_forward_movement_intent_pixels") and quick_recovery_state["requested_forward_movement_intent_pixels"] is float and quick_recovery_state["requested_forward_movement_intent_pixels"] == 0.0 and quick_recovery_state.has("query_count") and quick_recovery_state["query_count"] is int and quick_recovery_state["query_count"] == 1 and quick_recovery_result.has("query_count") and quick_recovery_result["query_count"] is int and quick_recovery_result["query_count"] == 1 and _requests.size() == 1, "quick recovery has no movement intent")
	var quick_completed := runtime.advance(0.20)
	_check(quick_completed, "quick completes recovery")
	var quick_request_count_before_idle_advance := _requests.size()
	var quick_idle_advance_rejected := not runtime.advance(0.1)
	_check(_is_final_idle(runtime) and quick_request_count_before_idle_advance == 1 and quick_idle_advance_rejected and _requests.size() == 1, "quick ends idle with no pending result/effect/lease")


func _test_heavy_runtime_contract() -> void:
	var runtime := _configured_runtime()
	_requests.clear()
	_next_callback_status = Phase2ActionRuntime.QUERY_STATUS_MISS
	_check(runtime.try_accept(Phase2CombatFormDefinition.ACTION_HEAVY_CLEAVE, Vector2.RIGHT), "heavy accept succeeds")
	var heavy_accepted_state := runtime.debug_state()
	_check(heavy_accepted_state.has("locked_aim") and heavy_accepted_state["locked_aim"] is Vector2 and heavy_accepted_state["locked_aim"].is_equal_approx(Vector2.RIGHT), "heavy locks aim at acceptance")
	_check(runtime.advance(0.40, Vector2.UP), "heavy crosses 24-tick windup boundary")
	var heavy_request: Dictionary = _requests[0] if _requests.size() == 1 and _requests[0] is Dictionary else {}
	var heavy_geometry: Dictionary = heavy_request["geometry"] if heavy_request.has("geometry") and heavy_request["geometry"] is Dictionary else {}
	var heavy_effects: Array = heavy_request["effects"] if heavy_request.has("effects") and heavy_request["effects"] is Array else []
	var heavy_effect_0: Dictionary = heavy_effects[0] if heavy_effects.size() == 2 and heavy_effects[0] is Dictionary else {}
	var heavy_effect_1: Dictionary = heavy_effects[1] if heavy_effects.size() == 2 and heavy_effects[1] is Dictionary else {}
	var heavy_active_state := runtime.debug_state()
	var heavy_active_result := runtime.debug_result()
	_check(_requests.size() == 1 and heavy_request.is_read_only() and heavy_request.has("action_id") and heavy_request["action_id"] is StringName and heavy_request["action_id"] == Phase2CombatFormDefinition.ACTION_HEAVY_CLEAVE and heavy_request.has("accepted_sequence") and heavy_request["accepted_sequence"] is int and heavy_request["accepted_sequence"] == 1 and heavy_request.has("locked_aim") and heavy_request["locked_aim"] is Vector2 and heavy_request["locked_aim"].is_equal_approx(Vector2.RIGHT), "heavy ignores changed aim after acceptance")
	_check(_requests.size() == 1 and heavy_request.has("forward_movement_intent_pixels") and heavy_request["forward_movement_intent_pixels"] is float and heavy_request["forward_movement_intent_pixels"] == 48.0 and heavy_geometry.is_read_only() and heavy_geometry.has("hit_shape_id") and heavy_geometry["hit_shape_id"] is StringName and heavy_geometry["hit_shape_id"] == &"hit_shape.physical.prototype.safe_circle" and heavy_geometry.has("reach") and heavy_geometry["reach"] is float and heavy_geometry["reach"] == 150.0 and heavy_geometry.has("query_radius") and heavy_geometry["query_radius"] is float and heavy_geometry["query_radius"] == 88.0 and heavy_geometry.has("minimum_aim_dot") and heavy_geometry["minimum_aim_dot"] is float and heavy_geometry["minimum_aim_dot"] == 0.25 and heavy_request.has("max_targets") and heavy_request["max_targets"] is int and heavy_request["max_targets"] == 1 and heavy_effects.is_read_only() and heavy_effects.size() == 2 and heavy_effect_0.is_read_only() and heavy_effect_1.is_read_only() and heavy_effect_0.has("effect_id") and heavy_effect_0["effect_id"] is StringName and heavy_effect_0["effect_id"] == &"effect.physical.heavy_cleave.damage" and heavy_effect_0.has("effect_type") and heavy_effect_0["effect_type"] is StringName and heavy_effect_0["effect_type"] == &"damage" and heavy_effect_0.has("magnitude") and heavy_effect_0["magnitude"] is float and heavy_effect_0["magnitude"] == 14.0 and heavy_effect_1.has("effect_id") and heavy_effect_1["effect_id"] is StringName and heavy_effect_1["effect_id"] == &"effect.physical.heavy_cleave.part_damage" and heavy_effect_1.has("effect_type") and heavy_effect_1["effect_type"] is StringName and heavy_effect_1["effect_type"] == &"part_damage" and heavy_effect_1.has("magnitude") and heavy_effect_1["magnitude"] is float and heavy_effect_1["magnitude"] == 18.0 and heavy_effect_0.has("channel") and heavy_effect_0["channel"] is StringName and heavy_effect_0["channel"] == &"physical" and heavy_effect_0.has("duration") and heavy_effect_0["duration"] is float and heavy_effect_0["duration"] == 0.0 and heavy_effect_0.has("target_rule") and heavy_effect_0["target_rule"] is StringName and heavy_effect_0["target_rule"] == &"hit_target" and heavy_effect_0.has("stack_rule") and heavy_effect_0["stack_rule"] is StringName and heavy_effect_0["stack_rule"] == &"instant" and heavy_effect_0.has("tags") and heavy_effect_0["tags"] is Array and heavy_effect_0["tags"].is_read_only() and heavy_effect_0["tags"].is_empty() and heavy_effect_1.has("channel") and heavy_effect_1["channel"] is StringName and heavy_effect_1["channel"] == &"physical" and heavy_effect_1.has("duration") and heavy_effect_1["duration"] is float and heavy_effect_1["duration"] == 0.0 and heavy_effect_1.has("target_rule") and heavy_effect_1["target_rule"] is StringName and heavy_effect_1["target_rule"] == &"hit_target" and heavy_effect_1.has("stack_rule") and heavy_effect_1["stack_rule"] is StringName and heavy_effect_1["stack_rule"] == &"instant" and heavy_effect_1.has("tags") and heavy_effect_1["tags"] is Array and heavy_effect_1["tags"].is_read_only() and heavy_effect_1["tags"].is_empty(), "heavy request carries 48 pixel active-only intent")
	_check(heavy_active_state.has("phase") and heavy_active_state["phase"] is StringName and heavy_active_state["phase"] == Phase2ActionRuntime.PHASE_ACTIVE and heavy_active_state.has("requested_forward_movement_intent_pixels") and heavy_active_state["requested_forward_movement_intent_pixels"] is float and heavy_active_state["requested_forward_movement_intent_pixels"] == 48.0 and heavy_active_state.has("query_count") and heavy_active_state["query_count"] is int and heavy_active_state["query_count"] == 1 and heavy_active_result.is_read_only() and heavy_active_result.has("status") and heavy_active_result["status"] is StringName and heavy_active_result["status"] == Phase2ActionRuntime.QUERY_STATUS_MISS and heavy_active_result.has("query_count") and heavy_active_result["query_count"] is int and heavy_active_result["query_count"] == 1 and heavy_active_result.has("release_succeeded") and heavy_active_result["release_succeeded"] is bool and heavy_active_result["release_succeeded"] and heavy_active_result.has("active_query_count") and heavy_active_result["active_query_count"] is int and heavy_active_result["active_query_count"] == 0 and heavy_active_result.has("emergency_active_count") and heavy_active_result["emergency_active_count"] is int and heavy_active_result["emergency_active_count"] == 0 and heavy_active_result.has("emergency_use_count") and heavy_active_result["emergency_use_count"] is int and heavy_active_result["emergency_use_count"] == 0 and heavy_active_state.has("active_query_count") and heavy_active_state["active_query_count"] is int and heavy_active_state["active_query_count"] == 0 and heavy_active_state.has("emergency_active_count") and heavy_active_state["emergency_active_count"] is int and heavy_active_state["emergency_active_count"] == 0 and heavy_active_state.has("emergency_use_count") and heavy_active_state["emergency_use_count"] is int and heavy_active_state["emergency_use_count"] == 0 and heavy_active_state.has("has_pending_lease") and heavy_active_state["has_pending_lease"] is bool and not heavy_active_state["has_pending_lease"] and _requests.size() == 1, "heavy exposes intent only while active")
	var heavy_active_advance := runtime.advance(0.10)
	var heavy_recovery_state := runtime.debug_state()
	var heavy_recovery_result := runtime.debug_result()
	_check(heavy_active_advance and heavy_recovery_state.has("phase") and heavy_recovery_state["phase"] is StringName and heavy_recovery_state["phase"] == Phase2ActionRuntime.PHASE_RECOVERY, "heavy reaches recovery at 6-tick active boundary")
	_check(heavy_recovery_state.has("requested_forward_movement_intent_pixels") and heavy_recovery_state["requested_forward_movement_intent_pixels"] is float and heavy_recovery_state["requested_forward_movement_intent_pixels"] == 0.0 and heavy_recovery_state.has("query_count") and heavy_recovery_state["query_count"] is int and heavy_recovery_state["query_count"] == 1 and heavy_recovery_result.has("query_count") and heavy_recovery_result["query_count"] is int and heavy_recovery_result["query_count"] == 1 and _requests.size() == 1, "heavy clears intent after active phase")
	var heavy_completed := runtime.advance(0.50)
	_check(heavy_completed, "heavy completes 30-tick recovery")
	var heavy_request_count_before_idle_advance := _requests.size()
	var heavy_idle_advance_rejected := not runtime.advance(0.1)
	_check(_is_final_idle(runtime) and heavy_request_count_before_idle_advance == 1 and heavy_idle_advance_rejected and _requests.size() == 1, "heavy ends idle without queued action")


func _test_release_reset_and_clear_contract() -> void:
	var runtime := _configured_runtime()
	_requests.clear()
	_next_callback_status = Phase2ActionRuntime.QUERY_STATUS_REJECTED
	_check(runtime.try_accept(Phase2CombatFormDefinition.ACTION_QUICK_CUT, Vector2.RIGHT), "reset case accepts quick")
	var reset_request_count_before := _requests.size()
	var reset_succeeded := runtime.reset()
	var reset_state := runtime.debug_state()
	var reset_result := runtime.debug_result()
	_check(reset_succeeded and reset_request_count_before == 0 and _requests.size() == 0 and _is_final_idle(runtime) and reset_state.has("active_query_count") and reset_state["active_query_count"] is int and reset_state["active_query_count"] == 0 and reset_state.has("emergency_active_count") and reset_state["emergency_active_count"] is int and reset_state["emergency_active_count"] == 0 and reset_state.has("emergency_use_count") and reset_state["emergency_use_count"] is int and reset_state["emergency_use_count"] == 0 and reset_state.has("has_pending_lease") and reset_state["has_pending_lease"] is bool and not reset_state["has_pending_lease"], "reset during windup releases reservation")
	_check(_is_final_idle(runtime) and reset_state.is_read_only() and reset_result.is_read_only() and reset_result.is_empty() and _requests.is_empty(), "reset leaves exact idle state")
	_check(runtime.reset() and runtime.clear(), "repeated reset and clear are idempotent")
	_check(runtime.try_accept(Phase2CombatFormDefinition.ACTION_HEAVY_CLEAVE, Vector2.RIGHT), "malformed callback case accepts heavy")
	_next_callback_status = &"not_supported"
	var malformed_advance := runtime.advance(0.40)
	var malformed_state := runtime.debug_state()
	var malformed_result := runtime.debug_result()
	_check(malformed_advance, "heavy enters active for malformed callback")
	_check(malformed_result.is_read_only() and malformed_result.has("status") and malformed_result["status"] is StringName and malformed_result["status"] == Phase2ActionRuntime.QUERY_STATUS_MALFORMED and malformed_result.has("query_count") and malformed_result["query_count"] is int and malformed_result["query_count"] == 1 and malformed_result.has("release_succeeded") and malformed_result["release_succeeded"] is bool and malformed_result["release_succeeded"] and malformed_result.has("active_query_count") and malformed_result["active_query_count"] is int and malformed_result["active_query_count"] == 0 and malformed_result.has("emergency_active_count") and malformed_result["emergency_active_count"] is int and malformed_result["emergency_active_count"] == 0 and malformed_result.has("emergency_use_count") and malformed_result["emergency_use_count"] is int and malformed_result["emergency_use_count"] == 0 and malformed_state.has("active_query_count") and malformed_state["active_query_count"] is int and malformed_state["active_query_count"] == 0 and malformed_state.has("emergency_active_count") and malformed_state["emergency_active_count"] is int and malformed_state["emergency_active_count"] == 0 and malformed_state.has("emergency_use_count") and malformed_state["emergency_use_count"] is int and malformed_state["emergency_use_count"] == 0 and malformed_state.has("has_pending_lease") and malformed_state["has_pending_lease"] is bool and not malformed_state["has_pending_lease"] and _requests.size() == 1, "unsupported callback status fails closed as malformed")
	_check(runtime.clear() and _is_final_idle(runtime), "clear after callback restores idle without stale lease")
	var pool := _pool()
	var held := pool.try_reserve_for_class(&"held", Phase1HitQueryPool.RESERVATION_PLAYER_CRITICAL)
	var unavailable := Phase2ActionRuntime.new()
	_check(unavailable.configure(_form(), [_quick(), _heavy()], _effects(), pool, Callable(self, "_query_callback")).is_empty(), "unavailable-pool runtime config succeeds")
	var unavailable_requests_before := _requests.size()
	var unavailable_rejected := not unavailable.try_accept(Phase2CombatFormDefinition.ACTION_QUICK_CUT, Vector2.RIGHT)
	var unavailable_state := unavailable.debug_state()
	var unavailable_result := unavailable.debug_result()
	var unavailable_requests_after := _requests.size()
	_check(unavailable_rejected and unavailable_state.is_read_only() and unavailable_state.has("phase") and unavailable_state["phase"] is StringName and unavailable_state["phase"] == Phase2ActionRuntime.PHASE_IDLE and unavailable_state.has("accepted_sequence") and unavailable_state["accepted_sequence"] is int and unavailable_state["accepted_sequence"] == 0 and unavailable_state.has("accepted_count") and unavailable_state["accepted_count"] is int and unavailable_state["accepted_count"] == 0 and unavailable_state.has("query_count") and unavailable_state["query_count"] is int and unavailable_state["query_count"] == 0 and unavailable_state.has("effects") and unavailable_state["effects"] is Array and unavailable_state["effects"].is_read_only() and unavailable_state["effects"].is_empty() and unavailable_state.has("requested_forward_movement_intent_pixels") and unavailable_state["requested_forward_movement_intent_pixels"] is float and unavailable_state["requested_forward_movement_intent_pixels"] == 0.0 and unavailable_state.has("active_query_count") and unavailable_state["active_query_count"] is int and unavailable_state["active_query_count"] == 1 and unavailable_state.has("emergency_active_count") and unavailable_state["emergency_active_count"] is int and unavailable_state["emergency_active_count"] == 0 and unavailable_state.has("emergency_use_count") and unavailable_state["emergency_use_count"] is int and unavailable_state["emergency_use_count"] == 0 and unavailable_state.has("has_pending_lease") and unavailable_state["has_pending_lease"] is bool and not unavailable_state["has_pending_lease"] and unavailable_state.has("has_query_result") and unavailable_state["has_query_result"] is bool and not unavailable_state["has_query_result"] and unavailable_result.is_read_only() and unavailable_result.is_empty(), "unavailable reservation rejects without queue or callback")
	_check(unavailable_requests_after == unavailable_requests_before, "rejected acceptance adds no callback request")
	_check(pool.release(held) and pool.active_count() == 0 and pool.emergency_active_count() == 0 and pool.emergency_use_count() == 0, "pool returns to PlayerCritical-only idle without emergency use")


func _configured_runtime() -> Phase2ActionRuntime:
	var runtime := Phase2ActionRuntime.new()
	var errors := runtime.configure(_form(), [_quick(), _heavy()], _effects(), _pool(), Callable(self, "_query_callback"))
	_check(errors.is_empty(), "runtime fixture configures")
	return runtime


func _query_callback(request: Dictionary) -> Dictionary:
	_requests.append(request)
	return {"status": _next_callback_status}


func _pool() -> Phase1HitQueryPool:
	var pool := Phase1HitQueryPool.new()
	var errors := pool.configure_reservations({Phase1HitQueryPool.RESERVATION_PLAYER_CRITICAL: 1}, 0)
	_check(errors.is_empty(), "caller pool configures PlayerCritical=1 emergency=0")
	return pool


func _is_final_idle(runtime: Phase2ActionRuntime) -> bool:
	var state := runtime.debug_state()
	return state.is_read_only() and state.has("phase") and state["phase"] is StringName and state["phase"] == Phase2ActionRuntime.PHASE_IDLE and state.has("has_pending_lease") and state["has_pending_lease"] is bool and not state["has_pending_lease"] and state.has("query_count") and state["query_count"] is int and state["query_count"] == 0 and state.has("has_query_result") and state["has_query_result"] is bool and not state["has_query_result"] and state.has("effects") and state["effects"] is Array and state["effects"].is_read_only() and state["effects"].is_empty() and state.has("requested_forward_movement_intent_pixels") and state["requested_forward_movement_intent_pixels"] is float and state["requested_forward_movement_intent_pixels"] == 0.0 and state.has("active_query_count") and state["active_query_count"] is int and state["active_query_count"] == 0 and state.has("emergency_active_count") and state["emergency_active_count"] is int and state["emergency_active_count"] == 0 and state.has("emergency_use_count") and state["emergency_use_count"] is int and state["emergency_use_count"] == 0


func _form() -> Phase2CombatFormDefinition:
	return load(FORM_PATH) as Phase2CombatFormDefinition


func _quick() -> Phase1ActionDefinition:
	return load(QUICK_PATH) as Phase1ActionDefinition


func _heavy() -> Phase1ActionDefinition:
	return load(HEAVY_PATH) as Phase1ActionDefinition


func _effects() -> Array:
	return [
		load(QUICK_DAMAGE_PATH) as Phase1EffectDefinition,
		load(QUICK_PART_PATH) as Phase1EffectDefinition,
		load(HEAVY_DAMAGE_PATH) as Phase1EffectDefinition,
		load(HEAVY_PART_PATH) as Phase1EffectDefinition,
	]


func _copy_action(source: Phase1ActionDefinition) -> Phase1ActionDefinition:
	return source.duplicate() as Phase1ActionDefinition


func _copy_effect(source: Phase1EffectDefinition) -> Phase1EffectDefinition:
	return source.duplicate() as Phase1EffectDefinition



func _test_complete_registry_negatives() -> void:
	var form := _form()
	var quick := _quick()
	var heavy := _heavy()
	var effects := _effects()
	var empty_action_registry_errors := form.validate_registry([], effects)
	var empty_effect_registry_errors := form.validate_registry([quick, heavy], [])
	_check(not empty_action_registry_errors.is_empty() and not empty_effect_registry_errors.is_empty(), "registry rejects empty action and effect registries")
	var empty_member_form := _form()
	empty_member_form.action_set_ids = [&"", Phase2CombatFormDefinition.ACTION_HEAVY_CLEAVE]
	_check(not empty_member_form.validate_registry([quick, heavy], effects).is_empty(), "registry rejects empty form action membership ID")
	var empty_action_id := _copy_action(quick)
	empty_action_id.action_id = &""
	_check(not form.validate_registry([empty_action_id, heavy], effects).is_empty(), "registry rejects empty action registry entry ID")
	var empty_effect_id := _copy_effect(effects[0])
	empty_effect_id.effect_id = &""
	_check(not form.validate_registry([quick, heavy], [empty_effect_id, effects[1], effects[2], effects[3]]).is_empty(), "registry rejects empty effect registry entry ID")
	var unknown_member_form := _form()
	unknown_member_form.action_set_ids = [&"action.physical.unknown", Phase2CombatFormDefinition.ACTION_HEAVY_CLEAVE]
	_check(not unknown_member_form.validate_registry([quick, heavy], effects).is_empty(), "registry rejects unknown form action reference")
	var unknown_effect_action := _copy_action(quick)
	unknown_effect_action.effect_ids = [&"effect.physical.unknown", Phase2CombatFormDefinition.EFFECT_QUICK_CUT_PART_DAMAGE]
	_check(not form.validate_registry([unknown_effect_action, heavy], effects).is_empty(), "registry rejects unknown effect reference")
	var reordered_effect_action := _copy_action(quick)
	reordered_effect_action.effect_ids = [Phase2CombatFormDefinition.EFFECT_QUICK_CUT_PART_DAMAGE, Phase2CombatFormDefinition.EFFECT_QUICK_CUT_DAMAGE]
	_check(not form.validate_registry([reordered_effect_action, heavy], effects).is_empty(), "registry rejects reordered action effect references")
	var nonfinite_geometry := _copy_action(quick)
	nonfinite_geometry.reach = INF
	_check(not nonfinite_geometry.validate().is_empty(), "action rejects isolated nonfinite geometry")
	var nonfinite_timing := _copy_action(quick)
	nonfinite_timing.windup_seconds = NAN
	_check(not nonfinite_timing.validate().is_empty(), "action rejects isolated nonfinite timing")
	var invalid_policy := _copy_action(quick)
	invalid_policy.aim_policy = &"bad_policy"
	_check(not invalid_policy.validate().is_empty(), "action rejects isolated invalid aim policy")
	var nonfinite_intent := _copy_action(quick)
	nonfinite_intent.forward_movement_intent_pixels = INF
	_check(not nonfinite_intent.validate().is_empty(), "action rejects isolated nonfinite forward intent")


func _test_literal_vocabulary_and_source_isolation() -> void:
	var form := _form()
	var quick := _quick()
	var heavy := _heavy()
	var effects := _effects()
	_check(form.combat_form_id == &"combat_form.blade.one_hand.prototype", "literal form vocabulary is approved")
	_check(form.action_set_ids == [&"action.physical.quick_cut", &"action.physical.heavy_cleave"], "literal action vocabulary and order are approved")
	_check(quick.hit_shape_id == &"hit_shape.physical.prototype.safe_circle" and heavy.hit_shape_id == &"hit_shape.physical.prototype.safe_circle", "literal hit-shape vocabulary is approved")
	_check(quick.category == &"physical" and heavy.category == &"physical" and quick.hit_query_reservation_class == &"PlayerCritical" and heavy.hit_query_reservation_class == &"PlayerCritical", "literal category and reservation vocabulary are approved")
	_check(quick.aim_policy == &"follow_windup_then_lock" and heavy.aim_policy == &"lock_on_accept", "literal aim-policy vocabulary is approved")
	_check(effects[0].effect_id == &"effect.physical.quick_cut.damage" and effects[1].effect_id == &"effect.physical.quick_cut.part_damage" and effects[2].effect_id == &"effect.physical.heavy_cleave.damage" and effects[3].effect_id == &"effect.physical.heavy_cleave.part_damage", "literal effect vocabulary is approved")
	_check(effects[0].effect_type == &"damage" and effects[1].effect_type == &"part_damage" and effects[2].effect_type == &"damage" and effects[3].effect_type == &"part_damage", "literal effect-type vocabulary is approved")
	_check(effects.size() == 4 and effects[0].channel == &"physical" and effects[0].duration == 0.0 and effects[0].target_rule == &"hit_target" and effects[0].stack_rule == &"instant" and effects[0].tags.is_empty() and effects[1].channel == &"physical" and effects[1].duration == 0.0 and effects[1].target_rule == &"hit_target" and effects[1].stack_rule == &"instant" and effects[1].tags.is_empty() and effects[2].channel == &"physical" and effects[2].duration == 0.0 and effects[2].target_rule == &"hit_target" and effects[2].stack_rule == &"instant" and effects[2].tags.is_empty() and effects[3].channel == &"physical" and effects[3].duration == 0.0 and effects[3].target_rule == &"hit_target" and effects[3].stack_rule == &"instant" and effects[3].tags.is_empty(), "literal effect metadata vocabulary is approved")
	_check(Phase2ActionRuntime.PHASE_IDLE == &"idle" and Phase2ActionRuntime.PHASE_WINDUP == &"windup" and Phase2ActionRuntime.PHASE_ACTIVE == &"active" and Phase2ActionRuntime.PHASE_RECOVERY == &"recovery", "literal runtime phase vocabulary is approved")
	_check(Phase2ActionRuntime.QUERY_STATUS_HIT == &"hit" and Phase2ActionRuntime.QUERY_STATUS_MISS == &"miss" and Phase2ActionRuntime.QUERY_STATUS_REJECTED == &"rejected" and Phase2ActionRuntime.QUERY_STATUS_MALFORMED == &"malformed", "literal query-status vocabulary is approved")
	var runtime_source := FileAccess.get_file_as_string("res://scripts/combat/action_runtime.gd")
	var form_source := FileAccess.get_file_as_string("res://scripts/combat/combat_form_definition.gd")
	_check(runtime_source.contains("extends RefCounted") and not runtime_source.contains("extends Node") and not runtime_source.contains("func _ready"), "runtime source has RefCounted ownership and no Node lifecycle")
	_check(not runtime_source.contains("Input.") and not runtime_source.contains("Physics") and not runtime_source.contains("emit_signal") and not runtime_source.contains("damage") and not runtime_source.contains("presentation"), "runtime source has no input physics damage event or presentation connection")
	_check(form_source.contains("action_set_ids") and not form_source.contains("@export var effect_definitions"), "combat form owns ordered action membership without effect registry")
	_check(runtime_source.contains("forward_movement_intent_pixels") and not runtime_source.contains("move_and_slide") and not runtime_source.contains("global_position"), "48 pixel value remains request intent without actor movement")


func _test_complete_callback_and_boundary_contract() -> void:
	var rejected_runtime := _configured_runtime()
	_requests.clear()
	_next_callback_status = Phase2ActionRuntime.QUERY_STATUS_REJECTED
	_check(rejected_runtime.try_accept(Phase2CombatFormDefinition.ACTION_QUICK_CUT, Vector2.RIGHT), "executed rejected callback scenario accepts")
	var rejected_advance := rejected_runtime.advance(0.20)
	var rejected_state := rejected_runtime.debug_state()
	var rejected_result := rejected_runtime.debug_result()
	_check(rejected_advance and rejected_state.has("phase") and rejected_state["phase"] is StringName and rejected_state["phase"] == Phase2ActionRuntime.PHASE_RECOVERY, "one advance deterministically crosses quick multi-phase boundaries")
	_check(_requests.size() == 1 and rejected_result.is_read_only() and rejected_result.has("status") and rejected_result["status"] is StringName and rejected_result["status"] == Phase2ActionRuntime.QUERY_STATUS_REJECTED and rejected_result.has("query_count") and rejected_result["query_count"] is int and rejected_result["query_count"] == 1, "executed callback records canonical rejected result exactly once")
	_check(rejected_result.has("release_succeeded") and rejected_result["release_succeeded"] is bool and rejected_result["release_succeeded"] and rejected_result.has("active_query_count") and rejected_result["active_query_count"] is int and rejected_result["active_query_count"] == 0 and rejected_result.has("emergency_active_count") and rejected_result["emergency_active_count"] is int and rejected_result["emergency_active_count"] == 0 and rejected_result.has("emergency_use_count") and rejected_result["emergency_use_count"] is int and rejected_result["emergency_use_count"] == 0 and rejected_state.has("active_query_count") and rejected_state["active_query_count"] is int and rejected_state["active_query_count"] == 0 and rejected_state.has("emergency_active_count") and rejected_state["emergency_active_count"] is int and rejected_state["emergency_active_count"] == 0 and rejected_state.has("emergency_use_count") and rejected_state["emergency_use_count"] is int and rejected_state["emergency_use_count"] == 0 and rejected_state.has("has_pending_lease") and rejected_state["has_pending_lease"] is bool and not rejected_state["has_pending_lease"], "rejected callback releases lease immediately without emergency use")
	var rejected_completed := rejected_runtime.advance(0.20)
	var rejected_request_count_before_idle_advance := _requests.size()
	var rejected_idle_advance_rejected := not rejected_runtime.advance(0.1)
	_check(rejected_completed and _is_final_idle(rejected_runtime) and rejected_request_count_before_idle_advance == 1 and rejected_idle_advance_rejected and _requests.size() == 1, "multi-boundary completion is idle and cannot invoke a second callback")
	var reset_runtime := _configured_runtime()
	_requests.clear()
	_check(reset_runtime.try_accept(Phase2CombatFormDefinition.ACTION_QUICK_CUT, Vector2.RIGHT), "reset-before-active accepts")
	var reset_before_active := reset_runtime.reset()
	var reset_before_active_state := reset_runtime.debug_state()
	_check(reset_before_active and _requests.is_empty() and _is_final_idle(reset_runtime) and reset_before_active_state.has("active_query_count") and reset_before_active_state["active_query_count"] is int and reset_before_active_state["active_query_count"] == 0 and reset_before_active_state.has("emergency_active_count") and reset_before_active_state["emergency_active_count"] is int and reset_before_active_state["emergency_active_count"] == 0 and reset_before_active_state.has("emergency_use_count") and reset_before_active_state["emergency_use_count"] is int and reset_before_active_state["emergency_use_count"] == 0 and reset_before_active_state.has("has_pending_lease") and reset_before_active_state["has_pending_lease"] is bool and not reset_before_active_state["has_pending_lease"], "reset-before-active releases without callback")
	var clear_runtime := _configured_runtime()
	_requests.clear()
	_check(clear_runtime.try_accept(Phase2CombatFormDefinition.ACTION_HEAVY_CLEAVE, Vector2.RIGHT), "clear-before-active accepts")
	var clear_before_active := clear_runtime.clear()
	var clear_before_active_state := clear_runtime.debug_state()
	_check(clear_before_active and _requests.is_empty() and _is_final_idle(clear_runtime) and clear_before_active_state.has("active_query_count") and clear_before_active_state["active_query_count"] is int and clear_before_active_state["active_query_count"] == 0 and clear_before_active_state.has("emergency_active_count") and clear_before_active_state["emergency_active_count"] is int and clear_before_active_state["emergency_active_count"] == 0 and clear_before_active_state.has("emergency_use_count") and clear_before_active_state["emergency_use_count"] is int and clear_before_active_state["emergency_use_count"] == 0 and clear_before_active_state.has("has_pending_lease") and clear_before_active_state["has_pending_lease"] is bool and not clear_before_active_state["has_pending_lease"], "clear-before-active releases without callback")
	var invalidated_runtime := _configured_runtime_with_probe()
	var probe: CallbackProbe = invalidated_runtime["probe"]
	var runtime: Phase2ActionRuntime = invalidated_runtime["runtime"]
	_check(runtime.try_accept(Phase2CombatFormDefinition.ACTION_QUICK_CUT, Vector2.RIGHT), "invalidated-callback scenario accepts and reserves")
	_check(probe.calls == 0, "invalidated callback target has no pre-active invocation")
	probe.free()
	_check(not invalidated_runtime["callback"].is_valid(), "callback target becomes invalid before active entry")
	var invalidated_advance := runtime.advance(0.10)
	var invalidated_state := runtime.debug_state()
	var invalidated_result := runtime.debug_result()
	_check(invalidated_advance and invalidated_result.is_read_only() and invalidated_result.has("status") and invalidated_result["status"] is StringName and invalidated_result["status"] == Phase2ActionRuntime.QUERY_STATUS_MALFORMED and invalidated_result.has("query_count") and invalidated_result["query_count"] is int and invalidated_result["query_count"] == 1, "invalidated callback records malformed without invocation")
	_check(invalidated_result.has("release_succeeded") and invalidated_result["release_succeeded"] is bool and invalidated_result["release_succeeded"] and invalidated_result.has("active_query_count") and invalidated_result["active_query_count"] is int and invalidated_result["active_query_count"] == 0 and invalidated_result.has("emergency_active_count") and invalidated_result["emergency_active_count"] is int and invalidated_result["emergency_active_count"] == 0 and invalidated_result.has("emergency_use_count") and invalidated_result["emergency_use_count"] is int and invalidated_result["emergency_use_count"] == 0 and invalidated_state.has("active_query_count") and invalidated_state["active_query_count"] is int and invalidated_state["active_query_count"] == 0 and invalidated_state.has("emergency_active_count") and invalidated_state["emergency_active_count"] is int and invalidated_state["emergency_active_count"] == 0 and invalidated_state.has("emergency_use_count") and invalidated_state["emergency_use_count"] is int and invalidated_state["emergency_use_count"] == 0 and invalidated_state.has("has_pending_lease") and invalidated_state["has_pending_lease"] is bool and not invalidated_state["has_pending_lease"], "invalidated callback releases same lease before cleanup")
	_check(runtime.clear() and _is_final_idle(runtime), "invalidated callback final cleanup is idle")
	var quick_boundary := _configured_runtime()
	_requests.clear()
	_next_callback_status = Phase2ActionRuntime.QUERY_STATUS_HIT
	_check(quick_boundary.try_accept(Phase2CombatFormDefinition.ACTION_QUICK_CUT, Vector2.RIGHT), "quick boundary fixture accepts")
	var quick_before_active_advance := quick_boundary.advance(5.0 / 60.0)
	var quick_before_active_state := quick_boundary.debug_state()
	_check(quick_before_active_advance and quick_before_active_state.has("phase") and quick_before_active_state["phase"] is StringName and quick_before_active_state["phase"] == Phase2ActionRuntime.PHASE_WINDUP and quick_before_active_state.has("query_count") and quick_before_active_state["query_count"] is int and quick_before_active_state["query_count"] == 0 and _requests.is_empty(), "quick remains windup immediately before six-tick boundary")
	var quick_active_boundary_advance := quick_boundary.advance(1.0 / 60.0)
	var quick_active_boundary_state := quick_boundary.debug_state()
	var quick_active_boundary_result := quick_boundary.debug_result()
	_check(quick_active_boundary_advance and quick_active_boundary_state.has("phase") and quick_active_boundary_state["phase"] is StringName and quick_active_boundary_state["phase"] == Phase2ActionRuntime.PHASE_ACTIVE and quick_active_boundary_state.has("query_count") and quick_active_boundary_state["query_count"] is int and quick_active_boundary_state["query_count"] == 1 and quick_active_boundary_result.has("query_count") and quick_active_boundary_result["query_count"] is int and quick_active_boundary_result["query_count"] == 1 and _requests.size() == 1, "quick crosses active at exact six-tick boundary")
	var quick_before_recovery_advance := quick_boundary.advance(5.0 / 60.0)
	var quick_before_recovery_state := quick_boundary.debug_state()
	var quick_before_recovery_result := quick_boundary.debug_result()
	_check(quick_before_recovery_advance and quick_before_recovery_state.has("phase") and quick_before_recovery_state["phase"] is StringName and quick_before_recovery_state["phase"] == Phase2ActionRuntime.PHASE_ACTIVE and quick_before_recovery_state.has("query_count") and quick_before_recovery_state["query_count"] is int and quick_before_recovery_state["query_count"] == 1 and quick_before_recovery_result.has("query_count") and quick_before_recovery_result["query_count"] is int and quick_before_recovery_result["query_count"] == 1 and _requests.size() == 1, "quick remains active immediately before second six-tick boundary")
	var quick_recovery_boundary_advance := quick_boundary.advance(1.0 / 60.0)
	var quick_recovery_boundary_state := quick_boundary.debug_state()
	var quick_recovery_boundary_result := quick_boundary.debug_result()
	_check(quick_recovery_boundary_advance and quick_recovery_boundary_state.has("phase") and quick_recovery_boundary_state["phase"] is StringName and quick_recovery_boundary_state["phase"] == Phase2ActionRuntime.PHASE_RECOVERY and quick_recovery_boundary_state.has("query_count") and quick_recovery_boundary_state["query_count"] is int and quick_recovery_boundary_state["query_count"] == 1 and quick_recovery_boundary_result.has("query_count") and quick_recovery_boundary_result["query_count"] is int and quick_recovery_boundary_result["query_count"] == 1 and _requests.size() == 1, "quick crosses recovery at exact second six-tick boundary")
	var quick_before_idle_advance := quick_boundary.advance(11.0 / 60.0)
	var quick_before_idle_state := quick_boundary.debug_state()
	var quick_before_idle_result := quick_boundary.debug_result()
	_check(quick_before_idle_advance and quick_before_idle_state.has("phase") and quick_before_idle_state["phase"] is StringName and quick_before_idle_state["phase"] == Phase2ActionRuntime.PHASE_RECOVERY and quick_before_idle_state.has("query_count") and quick_before_idle_state["query_count"] is int and quick_before_idle_state["query_count"] == 1 and quick_before_idle_result.has("query_count") and quick_before_idle_result["query_count"] is int and quick_before_idle_result["query_count"] == 1 and _requests.size() == 1, "quick remains recovery immediately before twelve-tick boundary")
	var quick_idle_boundary_advance := quick_boundary.advance(1.0 / 60.0)
	var quick_boundary_requests_before_rejected_idle := _requests.size()
	var quick_boundary_idle_rejected := not quick_boundary.advance(0.1)
	_check(quick_idle_boundary_advance and _is_final_idle(quick_boundary) and quick_boundary_requests_before_rejected_idle == 1 and quick_boundary_idle_rejected and _requests.size() == 1, "quick completes at exact twelve-tick boundary")
	var heavy_boundary := _configured_runtime()
	_requests.clear()
	_next_callback_status = Phase2ActionRuntime.QUERY_STATUS_MISS
	_check(heavy_boundary.try_accept(Phase2CombatFormDefinition.ACTION_HEAVY_CLEAVE, Vector2.RIGHT), "heavy boundary fixture accepts")
	var heavy_before_active_advance := heavy_boundary.advance(23.0 / 60.0)
	var heavy_before_active_state := heavy_boundary.debug_state()
	_check(heavy_before_active_advance and heavy_before_active_state.has("phase") and heavy_before_active_state["phase"] is StringName and heavy_before_active_state["phase"] == Phase2ActionRuntime.PHASE_WINDUP and heavy_before_active_state.has("query_count") and heavy_before_active_state["query_count"] is int and heavy_before_active_state["query_count"] == 0 and _requests.is_empty(), "heavy remains windup immediately before twenty-four-tick boundary")
	var heavy_active_boundary_advance := heavy_boundary.advance(1.0 / 60.0)
	var heavy_active_boundary_state := heavy_boundary.debug_state()
	var heavy_active_boundary_result := heavy_boundary.debug_result()
	_check(heavy_active_boundary_advance and heavy_active_boundary_state.has("phase") and heavy_active_boundary_state["phase"] is StringName and heavy_active_boundary_state["phase"] == Phase2ActionRuntime.PHASE_ACTIVE and heavy_active_boundary_state.has("query_count") and heavy_active_boundary_state["query_count"] is int and heavy_active_boundary_state["query_count"] == 1 and heavy_active_boundary_result.has("query_count") and heavy_active_boundary_result["query_count"] is int and heavy_active_boundary_result["query_count"] == 1 and _requests.size() == 1, "heavy crosses active at exact twenty-four-tick boundary")
	var heavy_before_recovery_advance := heavy_boundary.advance(5.0 / 60.0)
	var heavy_before_recovery_state := heavy_boundary.debug_state()
	var heavy_before_recovery_result := heavy_boundary.debug_result()
	_check(heavy_before_recovery_advance and heavy_before_recovery_state.has("phase") and heavy_before_recovery_state["phase"] is StringName and heavy_before_recovery_state["phase"] == Phase2ActionRuntime.PHASE_ACTIVE and heavy_before_recovery_state.has("query_count") and heavy_before_recovery_state["query_count"] is int and heavy_before_recovery_state["query_count"] == 1 and heavy_before_recovery_result.has("query_count") and heavy_before_recovery_result["query_count"] is int and heavy_before_recovery_result["query_count"] == 1 and _requests.size() == 1, "heavy remains active immediately before six-tick boundary")
	var heavy_recovery_boundary_advance := heavy_boundary.advance(1.0 / 60.0)
	var heavy_recovery_boundary_state := heavy_boundary.debug_state()
	var heavy_recovery_boundary_result := heavy_boundary.debug_result()
	_check(heavy_recovery_boundary_advance and heavy_recovery_boundary_state.has("phase") and heavy_recovery_boundary_state["phase"] is StringName and heavy_recovery_boundary_state["phase"] == Phase2ActionRuntime.PHASE_RECOVERY and heavy_recovery_boundary_state.has("query_count") and heavy_recovery_boundary_state["query_count"] is int and heavy_recovery_boundary_state["query_count"] == 1 and heavy_recovery_boundary_result.has("query_count") and heavy_recovery_boundary_result["query_count"] is int and heavy_recovery_boundary_result["query_count"] == 1 and _requests.size() == 1, "heavy crosses recovery at exact six-tick boundary")
	var heavy_before_idle_advance := heavy_boundary.advance(29.0 / 60.0)
	var heavy_before_idle_state := heavy_boundary.debug_state()
	var heavy_before_idle_result := heavy_boundary.debug_result()
	_check(heavy_before_idle_advance and heavy_before_idle_state.has("phase") and heavy_before_idle_state["phase"] is StringName and heavy_before_idle_state["phase"] == Phase2ActionRuntime.PHASE_RECOVERY and heavy_before_idle_state.has("query_count") and heavy_before_idle_state["query_count"] is int and heavy_before_idle_state["query_count"] == 1 and heavy_before_idle_result.has("query_count") and heavy_before_idle_result["query_count"] is int and heavy_before_idle_result["query_count"] == 1 and _requests.size() == 1, "heavy remains recovery immediately before thirty-tick boundary")
	var heavy_idle_boundary_advance := heavy_boundary.advance(1.0 / 60.0)
	var heavy_boundary_requests_before_rejected_idle := _requests.size()
	var heavy_boundary_idle_rejected := not heavy_boundary.advance(0.1)
	_check(heavy_idle_boundary_advance and _is_final_idle(heavy_boundary) and heavy_boundary_requests_before_rejected_idle == 1 and heavy_boundary_idle_rejected and _requests.size() == 1, "heavy completes at exact thirty-tick boundary")


func _test_complete_debug_record_contract() -> void:
	var runtime := _configured_runtime()
	_requests.clear()
	_next_callback_status = Phase2ActionRuntime.QUERY_STATUS_HIT
	_check(runtime.try_accept(Phase2CombatFormDefinition.ACTION_QUICK_CUT, Vector2.RIGHT) and runtime.advance(0.10, Vector2.UP), "debug/request fixture reaches quick active")
	var request: Dictionary = _requests[0] if _requests.size() == 1 and _requests[0] is Dictionary else {}
	var geometry: Dictionary = request["geometry"] if request.has("geometry") and request["geometry"] is Dictionary else {}
	var effect_records: Array = request["effects"] if request.has("effects") and request["effects"] is Array else []
	var effect_record_0: Dictionary = effect_records[0] if effect_records.size() == 2 and effect_records[0] is Dictionary else {}
	var effect_record_1: Dictionary = effect_records[1] if effect_records.size() == 2 and effect_records[1] is Dictionary else {}
	_check(request.is_read_only() and geometry.is_read_only() and effect_records.is_read_only() and effect_records.size() == 2 and effect_record_0.is_read_only() and effect_record_1.is_read_only(), "request geometry and effect records are readonly")
	_check(request.has("action_id") and request["action_id"] is StringName and request["action_id"] == &"action.physical.quick_cut" and request.has("accepted_sequence") and request["accepted_sequence"] is int and request["accepted_sequence"] == 1 and request.has("locked_aim") and request["locked_aim"] is Vector2 and request["locked_aim"].is_equal_approx(Vector2.UP), "quick request carries exact action sequence and locked aim")
	_check(geometry.has("hit_shape_id") and geometry["hit_shape_id"] is StringName and geometry["hit_shape_id"] == &"hit_shape.physical.prototype.safe_circle" and geometry.has("reach") and geometry["reach"] is float and geometry["reach"] == 150.0 and geometry.has("query_radius") and geometry["query_radius"] is float and geometry["query_radius"] == 88.0 and geometry.has("minimum_aim_dot") and geometry["minimum_aim_dot"] is float and geometry["minimum_aim_dot"] == 0.25 and request.has("max_targets") and request["max_targets"] is int and request["max_targets"] == 1, "quick request carries exact complete geometry")
	_check(effect_record_0.has("effect_id") and effect_record_0["effect_id"] is StringName and effect_record_0["effect_id"] == &"effect.physical.quick_cut.damage" and effect_record_0.has("effect_type") and effect_record_0["effect_type"] is StringName and effect_record_0["effect_type"] == &"damage" and effect_record_0.has("magnitude") and effect_record_0["magnitude"] is float and effect_record_0["magnitude"] == 10.0 and effect_record_1.has("effect_id") and effect_record_1["effect_id"] is StringName and effect_record_1["effect_id"] == &"effect.physical.quick_cut.part_damage" and effect_record_1.has("effect_type") and effect_record_1["effect_type"] is StringName and effect_record_1["effect_type"] == &"part_damage" and effect_record_1.has("magnitude") and effect_record_1["magnitude"] is float and effect_record_1["magnitude"] == 6.0, "quick request carries exact ordered effect records")
	_check(effect_record_0.has("channel") and effect_record_0["channel"] is StringName and effect_record_0["channel"] == &"physical" and effect_record_0.has("duration") and effect_record_0["duration"] is float and effect_record_0["duration"] == 0.0 and effect_record_0.has("target_rule") and effect_record_0["target_rule"] is StringName and effect_record_0["target_rule"] == &"hit_target" and effect_record_0.has("stack_rule") and effect_record_0["stack_rule"] is StringName and effect_record_0["stack_rule"] == &"instant" and effect_record_0.has("tags") and effect_record_0["tags"] is Array and effect_record_0["tags"].is_read_only() and effect_record_0["tags"].is_empty() and effect_record_1.has("channel") and effect_record_1["channel"] is StringName and effect_record_1["channel"] == &"physical" and effect_record_1.has("duration") and effect_record_1["duration"] is float and effect_record_1["duration"] == 0.0 and effect_record_1.has("target_rule") and effect_record_1["target_rule"] is StringName and effect_record_1["target_rule"] == &"hit_target" and effect_record_1.has("stack_rule") and effect_record_1["stack_rule"] is StringName and effect_record_1["stack_rule"] == &"instant" and effect_record_1.has("tags") and effect_record_1["tags"] is Array and effect_record_1["tags"].is_read_only() and effect_record_1["tags"].is_empty(), "effect record carries exact immutable metadata")
	var state := runtime.debug_state()
	var result := runtime.debug_result()
	var state_keys := [&"phase", &"phase_elapsed_seconds", &"locked_aim", &"accepted_sequence", &"accepted_count", &"query_count", &"effects", &"requested_forward_movement_intent_pixels", &"lease_release_succeeded", &"active_query_count", &"emergency_active_count", &"emergency_use_count", &"has_pending_lease", &"has_query_result"]
	var state_complete := true
	for key in state_keys:
		state_complete = state_complete and state.has(key)
	_check(state.is_read_only() and state_complete and state["phase"] is StringName and state["phase"] == Phase2ActionRuntime.PHASE_ACTIVE and state["phase_elapsed_seconds"] is float and state["phase_elapsed_seconds"] == 0.0 and state["locked_aim"] is Vector2 and state["locked_aim"].is_equal_approx(Vector2.UP) and state["accepted_sequence"] is int and state["accepted_sequence"] == 1 and state["accepted_count"] is int and state["accepted_count"] == 1 and state["query_count"] is int and state["query_count"] == 1 and state["effects"] is Array and state["effects"].is_read_only() and state["effects"].size() == 2 and state["requested_forward_movement_intent_pixels"] is float and state["requested_forward_movement_intent_pixels"] == 0.0 and state["lease_release_succeeded"] is bool and state["lease_release_succeeded"] and state["active_query_count"] is int and state["active_query_count"] == 0 and state["emergency_active_count"] is int and state["emergency_active_count"] == 0 and state["emergency_use_count"] is int and state["emergency_use_count"] == 0 and state["has_pending_lease"] is bool and not state["has_pending_lease"] and state["has_query_result"] is bool and state["has_query_result"], "debug state is readonly and has every required field")
	var result_keys := [&"status", &"request", &"query_count", &"release_succeeded", &"active_query_count", &"emergency_active_count", &"emergency_use_count"]
	var result_complete := true
	for key in result_keys:
		result_complete = result_complete and result.has(key)
	_check(result.is_read_only() and result_complete and result["status"] is StringName and result["status"] == Phase2ActionRuntime.QUERY_STATUS_HIT and result["request"] is Dictionary and result["request"].is_read_only() and result["query_count"] is int and result["query_count"] == 1 and result["release_succeeded"] is bool and result["release_succeeded"] and result["active_query_count"] is int and result["active_query_count"] == 0 and result["emergency_active_count"] is int and result["emergency_active_count"] == 0 and result["emergency_use_count"] is int and result["emergency_use_count"] == 0, "debug result is readonly and has every required field")


func _configured_runtime_with_probe() -> Dictionary:
	var probe := CallbackProbe.new()
	var callback := Callable(probe, "invoke")
	var runtime := Phase2ActionRuntime.new()
	var errors := runtime.configure(_form(), [_quick(), _heavy()], _effects(), _pool(), callback)
	_check(errors.is_empty(), "invalidated callback fixture configures before target removal")
	return {"runtime": runtime, "probe": probe, "callback": callback}
func _check(condition: bool, description: String) -> void:
	_assertion_count += 1
	if condition:
		print("[MFO-P2-2B-STAGEB-KERNEL-TEST] PASS: %s" % description)
	else:
		_failures.append(description)
