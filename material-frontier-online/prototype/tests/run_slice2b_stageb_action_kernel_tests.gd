extends SceneTree

const FORM_PATH := "res://data/phase2/combat_forms/blade_one_hand_prototype.tres"
const QUICK_PATH := "res://data/phase2/actions/quick_cut.tres"
const HEAVY_PATH := "res://data/phase2/actions/heavy_cleave.tres"
const QUICK_DAMAGE_PATH := "res://data/phase2/effects/quick_cut_damage.tres"
const QUICK_PART_PATH := "res://data/phase2/effects/quick_cut_part_damage.tres"
const HEAVY_DAMAGE_PATH := "res://data/phase2/effects/heavy_cleave_damage.tres"
const HEAVY_PART_PATH := "res://data/phase2/effects/heavy_cleave_part_damage.tres"

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
	_check(runtime is RefCounted and not (runtime is Node), "runtime is an isolated RefCounted object")
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


func _check(condition: bool, description: String) -> void:
	_assertion_count += 1
	if condition:
		print("[MFO-P2-2B-STAGEB-KERNEL-TEST] PASS: %s" % description)
	else:
		_failures.append(description)
