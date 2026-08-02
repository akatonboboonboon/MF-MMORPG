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
	_check(not runtime.try_accept(Phase2CombatFormDefinition.ACTION_QUICK_CUT, Vector2.RIGHT), "unconfigured runtime rejects acceptance")
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
	_check(not runtime.try_accept(&"", Vector2.RIGHT) and not runtime.try_accept(&"unknown", Vector2.RIGHT), "runtime rejects empty and unknown actions")
	_check(not runtime.try_accept(Phase2CombatFormDefinition.ACTION_QUICK_CUT, Vector2.ZERO), "runtime rejects zero aim")
	_check(not runtime.try_accept(Phase2CombatFormDefinition.ACTION_QUICK_CUT, Vector2(INF, 0.0)), "runtime rejects nonfinite aim")
	var state := runtime.debug_state()
	_check(state.is_read_only() and state["phase"] == Phase2ActionRuntime.PHASE_IDLE and not state["has_pending_lease"], "idle debug state is readonly and has no lease")
	_check(runtime.debug_result().is_read_only() and runtime.debug_result().is_empty(), "empty debug result is readonly")


func _test_quick_runtime_contract() -> void:
	var runtime := _configured_runtime()
	_requests.clear()
	_next_callback_status = Phase2ActionRuntime.QUERY_STATUS_HIT
	_check(runtime.try_accept(Phase2CombatFormDefinition.ACTION_QUICK_CUT, Vector2.RIGHT), "quick accept reserves before windup")
	_check(not runtime.try_accept(Phase2CombatFormDefinition.ACTION_HEAVY_CLEAVE, Vector2.UP), "busy runtime rejects without buffering")
	_check(runtime.debug_state()["has_pending_lease"] and runtime.debug_state()["active_query_count"] == 1, "quick accepted state owns one PlayerCritical lease")
	_check(runtime.advance(0.05, Vector2.UP), "quick accepts partial windup advance")
	_check(runtime.debug_state()["phase"] == Phase2ActionRuntime.PHASE_WINDUP and runtime.debug_state()["query_count"] == 0, "quick remains windup before exact boundary")
	_check(runtime.advance(0.05, Vector2.UP), "quick crosses exact windup boundary")
	_check(runtime.debug_state()["phase"] == Phase2ActionRuntime.PHASE_ACTIVE and runtime.debug_state()["query_count"] == 1, "quick enters active with exactly one callback")
	_check(_requests.size() == 1 and _requests[0].is_read_only(), "quick callback gets one readonly request")
	var request: Dictionary = _requests[0]
	_check(request["action_id"] == Phase2CombatFormDefinition.ACTION_QUICK_CUT and request["accepted_sequence"] == 1, "quick request preserves action and sequence")
	_check(request["locked_aim"].is_equal_approx(Vector2.UP) and request["forward_movement_intent_pixels"] == 0.0, "quick follows windup aim then locks with zero intent")
	_check(request["geometry"].is_read_only() and request["geometry"]["reach"] == 150.0 and request["max_targets"] == 1, "quick request snapshot preserves geometry and target cap")
	_check(request["effects"].is_read_only() and request["effects"].size() == 2 and request["effects"][0].is_read_only(), "quick request effects are readonly snapshots")
	_check(runtime.debug_result().is_read_only() and runtime.debug_result()["status"] == Phase2ActionRuntime.QUERY_STATUS_HIT and runtime.debug_result()["release_succeeded"], "quick hit result releases its lease")
	_check(runtime.debug_state()["active_query_count"] == 0 and not runtime.debug_state()["has_pending_lease"], "callback release restores pool before recovery")
	_check(runtime.advance(0.10), "quick crosses active boundary")
	_check(runtime.debug_state()["phase"] == Phase2ActionRuntime.PHASE_RECOVERY and runtime.debug_state()["requested_forward_movement_intent_pixels"] == 0.0, "quick recovery has no movement intent")
	_check(runtime.advance(0.20), "quick completes recovery")
	_check(_is_final_idle(runtime), "quick ends idle with no pending result/effect/lease")


func _test_heavy_runtime_contract() -> void:
	var runtime := _configured_runtime()
	_requests.clear()
	_next_callback_status = Phase2ActionRuntime.QUERY_STATUS_MISS
	_check(runtime.try_accept(Phase2CombatFormDefinition.ACTION_HEAVY_CLEAVE, Vector2.RIGHT), "heavy accept succeeds")
	_check(runtime.debug_state()["locked_aim"].is_equal_approx(Vector2.RIGHT), "heavy locks aim at acceptance")
	_check(runtime.advance(0.40, Vector2.UP), "heavy crosses 24-tick windup boundary")
	_check(_requests.size() == 1 and _requests[0]["locked_aim"].is_equal_approx(Vector2.RIGHT), "heavy ignores changed aim after acceptance")
	_check(_requests[0]["forward_movement_intent_pixels"] == 48.0, "heavy request carries 48 pixel active-only intent")
	_check(runtime.debug_state()["phase"] == Phase2ActionRuntime.PHASE_ACTIVE and runtime.debug_state()["requested_forward_movement_intent_pixels"] == 48.0, "heavy exposes intent only while active")
	_check(runtime.advance(0.10) and runtime.debug_state()["phase"] == Phase2ActionRuntime.PHASE_RECOVERY, "heavy reaches recovery at 6-tick active boundary")
	_check(runtime.debug_state()["requested_forward_movement_intent_pixels"] == 0.0, "heavy clears intent after active phase")
	_check(runtime.advance(0.50), "heavy completes 30-tick recovery")
	_check(_is_final_idle(runtime), "heavy ends idle without queued action")


func _test_release_reset_and_clear_contract() -> void:
	var runtime := _configured_runtime()
	_requests.clear()
	_next_callback_status = Phase2ActionRuntime.QUERY_STATUS_REJECTED
	_check(runtime.try_accept(Phase2CombatFormDefinition.ACTION_QUICK_CUT, Vector2.RIGHT), "reset case accepts quick")
	_check(runtime.reset(), "reset during windup releases reservation")
	_check(_is_final_idle(runtime), "reset leaves exact idle state")
	_check(runtime.reset() and runtime.clear(), "repeated reset and clear are idempotent")
	_check(runtime.try_accept(Phase2CombatFormDefinition.ACTION_HEAVY_CLEAVE, Vector2.RIGHT), "malformed callback case accepts heavy")
	_next_callback_status = &"not_supported"
	_check(runtime.advance(0.40), "heavy enters active for malformed callback")
	_check(runtime.debug_result()["status"] == Phase2ActionRuntime.QUERY_STATUS_MALFORMED, "unsupported callback status fails closed as malformed")
	_check(runtime.clear() and _is_final_idle(runtime), "clear after callback restores idle without stale lease")
	var pool := _pool()
	var held := pool.try_reserve_for_class(&"held", Phase1HitQueryPool.RESERVATION_PLAYER_CRITICAL)
	var unavailable := Phase2ActionRuntime.new()
	_check(unavailable.configure(_form(), [_quick(), _heavy()], _effects(), pool, Callable(self, "_query_callback")).is_empty(), "unavailable-pool runtime config succeeds")
	_check(not unavailable.try_accept(Phase2CombatFormDefinition.ACTION_QUICK_CUT, Vector2.RIGHT), "unavailable reservation rejects without queue or callback")
	_check(_requests.is_empty() or _requests.size() == 1, "rejected acceptance adds no callback request")
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
	return state["phase"] == Phase2ActionRuntime.PHASE_IDLE and not state["has_pending_lease"] and state["query_count"] == 0 and not state["has_query_result"] and state["effects"].is_empty() and state["requested_forward_movement_intent_pixels"] == 0.0 and state["active_query_count"] == 0 and state["emergency_active_count"] == 0 and state["emergency_use_count"] == 0


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
	_check(not form.validate_registry([], []).is_empty(), "registry rejects empty action and effect registries")
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
	_check(effects[0].channel == &"physical" and effects[0].target_rule == &"hit_target" and effects[0].stack_rule == &"instant", "literal effect metadata vocabulary is approved")
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
	_check(rejected_runtime.advance(0.40), "one advance deterministically crosses quick multi-phase boundaries")
	_check(_requests.size() == 1 and rejected_runtime.debug_result()["status"] == Phase2ActionRuntime.QUERY_STATUS_REJECTED, "executed callback records canonical rejected result exactly once")
	_check(rejected_runtime.debug_result()["release_succeeded"] and rejected_runtime.debug_state()["active_query_count"] == 0 and rejected_runtime.debug_state()["emergency_active_count"] == 0 and rejected_runtime.debug_state()["emergency_use_count"] == 0, "rejected callback releases lease immediately without emergency use")
	_check(_is_final_idle(rejected_runtime) and not rejected_runtime.advance(0.1) and _requests.size() == 1, "multi-boundary completion is idle and cannot invoke a second callback")
	var reset_runtime := _configured_runtime()
	_requests.clear()
	_check(reset_runtime.try_accept(Phase2CombatFormDefinition.ACTION_QUICK_CUT, Vector2.RIGHT), "reset-before-active accepts")
	_check(reset_runtime.reset() and _requests.is_empty() and _is_final_idle(reset_runtime), "reset-before-active releases without callback")
	var clear_runtime := _configured_runtime()
	_requests.clear()
	_check(clear_runtime.try_accept(Phase2CombatFormDefinition.ACTION_HEAVY_CLEAVE, Vector2.RIGHT), "clear-before-active accepts")
	_check(clear_runtime.clear() and _requests.is_empty() and _is_final_idle(clear_runtime), "clear-before-active releases without callback")
	var invalidated_runtime := _configured_runtime_with_probe()
	var probe: CallbackProbe = invalidated_runtime["probe"]
	var runtime: Phase2ActionRuntime = invalidated_runtime["runtime"]
	_check(runtime.try_accept(Phase2CombatFormDefinition.ACTION_QUICK_CUT, Vector2.RIGHT), "invalidated-callback scenario accepts and reserves")
	_check(probe.calls == 0, "invalidated callback target has no pre-active invocation")
	probe.free()
	_check(not invalidated_runtime["callback"].is_valid(), "callback target becomes invalid before active entry")
	_check(runtime.advance(0.10) and runtime.debug_result()["status"] == Phase2ActionRuntime.QUERY_STATUS_MALFORMED, "invalidated callback records malformed without invocation")
	_check(runtime.debug_result()["release_succeeded"] and runtime.debug_state()["active_query_count"] == 0 and not runtime.debug_state()["has_pending_lease"], "invalidated callback releases same lease before cleanup")
	_check(runtime.clear() and _is_final_idle(runtime), "invalidated callback final cleanup is idle")
	var quick_boundary := _configured_runtime()
	_requests.clear()
	_next_callback_status = Phase2ActionRuntime.QUERY_STATUS_HIT
	_check(quick_boundary.try_accept(Phase2CombatFormDefinition.ACTION_QUICK_CUT, Vector2.RIGHT), "quick boundary fixture accepts")
	_check(quick_boundary.advance(5.0 / 60.0) and quick_boundary.debug_state()["phase"] == Phase2ActionRuntime.PHASE_WINDUP, "quick remains windup immediately before six-tick boundary")
	_check(quick_boundary.advance(1.0 / 60.0) and quick_boundary.debug_state()["phase"] == Phase2ActionRuntime.PHASE_ACTIVE, "quick crosses active at exact six-tick boundary")
	_check(quick_boundary.advance(5.0 / 60.0) and quick_boundary.debug_state()["phase"] == Phase2ActionRuntime.PHASE_ACTIVE, "quick remains active immediately before second six-tick boundary")
	_check(quick_boundary.advance(1.0 / 60.0) and quick_boundary.debug_state()["phase"] == Phase2ActionRuntime.PHASE_RECOVERY, "quick crosses recovery at exact second six-tick boundary")
	_check(quick_boundary.advance(11.0 / 60.0) and quick_boundary.debug_state()["phase"] == Phase2ActionRuntime.PHASE_RECOVERY, "quick remains recovery immediately before twelve-tick boundary")
	_check(quick_boundary.advance(1.0 / 60.0) and _is_final_idle(quick_boundary), "quick completes at exact twelve-tick boundary")
	var heavy_boundary := _configured_runtime()
	_requests.clear()
	_next_callback_status = Phase2ActionRuntime.QUERY_STATUS_MISS
	_check(heavy_boundary.try_accept(Phase2CombatFormDefinition.ACTION_HEAVY_CLEAVE, Vector2.RIGHT), "heavy boundary fixture accepts")
	_check(heavy_boundary.advance(23.0 / 60.0) and heavy_boundary.debug_state()["phase"] == Phase2ActionRuntime.PHASE_WINDUP, "heavy remains windup immediately before twenty-four-tick boundary")
	_check(heavy_boundary.advance(1.0 / 60.0) and heavy_boundary.debug_state()["phase"] == Phase2ActionRuntime.PHASE_ACTIVE, "heavy crosses active at exact twenty-four-tick boundary")
	_check(heavy_boundary.advance(5.0 / 60.0) and heavy_boundary.debug_state()["phase"] == Phase2ActionRuntime.PHASE_ACTIVE, "heavy remains active immediately before six-tick boundary")
	_check(heavy_boundary.advance(1.0 / 60.0) and heavy_boundary.debug_state()["phase"] == Phase2ActionRuntime.PHASE_RECOVERY, "heavy crosses recovery at exact six-tick boundary")
	_check(heavy_boundary.advance(29.0 / 60.0) and heavy_boundary.debug_state()["phase"] == Phase2ActionRuntime.PHASE_RECOVERY, "heavy remains recovery immediately before thirty-tick boundary")
	_check(heavy_boundary.advance(1.0 / 60.0) and _is_final_idle(heavy_boundary), "heavy completes at exact thirty-tick boundary")


func _test_complete_debug_record_contract() -> void:
	var runtime := _configured_runtime()
	_requests.clear()
	_next_callback_status = Phase2ActionRuntime.QUERY_STATUS_HIT
	_check(runtime.try_accept(Phase2CombatFormDefinition.ACTION_QUICK_CUT, Vector2.RIGHT) and runtime.advance(0.10, Vector2.UP), "debug/request fixture reaches quick active")
	var request: Dictionary = _requests[0]
	var geometry: Dictionary = request["geometry"]
	var effect_records: Array = request["effects"]
	_check(request.is_read_only() and geometry.is_read_only() and effect_records.is_read_only() and effect_records[0].is_read_only(), "request geometry and effect records are readonly")
	_check(request["action_id"] == &"action.physical.quick_cut" and request["accepted_sequence"] == 1 and request["locked_aim"].is_equal_approx(Vector2.UP), "quick request carries exact action sequence and locked aim")
	_check(geometry["hit_shape_id"] == &"hit_shape.physical.prototype.safe_circle" and geometry["reach"] == 150.0 and geometry["query_radius"] == 88.0 and geometry["minimum_aim_dot"] == 0.25 and request["max_targets"] == 1, "quick request carries exact complete geometry")
	_check(effect_records.size() == 2 and effect_records[0]["effect_id"] == &"effect.physical.quick_cut.damage" and effect_records[0]["effect_type"] == &"damage" and effect_records[0]["magnitude"] == 10.0 and effect_records[1]["effect_id"] == &"effect.physical.quick_cut.part_damage" and effect_records[1]["effect_type"] == &"part_damage" and effect_records[1]["magnitude"] == 6.0, "quick request carries exact ordered effect records")
	_check(effect_records[0]["channel"] == &"physical" and effect_records[0]["duration"] == 0.0 and effect_records[0]["target_rule"] == &"hit_target" and effect_records[0]["stack_rule"] == &"instant" and effect_records[0]["tags"].is_read_only(), "effect record carries exact immutable metadata")
	var state := runtime.debug_state()
	var result := runtime.debug_result()
	var state_keys := [&"phase", &"phase_elapsed_seconds", &"locked_aim", &"accepted_sequence", &"accepted_count", &"query_count", &"effects", &"requested_forward_movement_intent_pixels", &"lease_release_succeeded", &"active_query_count", &"emergency_active_count", &"emergency_use_count", &"has_pending_lease", &"has_query_result"]
	var state_complete := true
	for key in state_keys:
		state_complete = state_complete and state.has(key)
	_check(state.is_read_only() and state_complete, "debug state is readonly and has every required field")
	var result_keys := [&"status", &"request", &"query_count", &"release_succeeded", &"active_query_count", &"emergency_active_count", &"emergency_use_count"]
	var result_complete := true
	for key in result_keys:
		result_complete = result_complete and result.has(key)
	_check(result.is_read_only() and result_complete, "debug result is readonly and has every required field")


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
