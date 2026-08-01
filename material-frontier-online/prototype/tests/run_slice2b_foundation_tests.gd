extends SceneTree

var _failures: Array[String] = []
var _assertion_count := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_test_legacy_compatibility()
	_test_common_action_definition()
	_test_common_effect_definition()
	_test_reservation_query_pool()
	if _failures.is_empty():
		print("[MFO-P2-2B-FOUNDATION-TEST] PASS: %d assertions" % _assertion_count)
		quit(0)
	else:
		for failure in _failures:
			push_error("[MFO-P2-2B-FOUNDATION-TEST] %s" % failure)
		print("[MFO-P2-2B-FOUNDATION-TEST] FAIL: %d / %d assertions failed" % [
			_failures.size(),
			_assertion_count,
		])
		quit(1)


func _test_legacy_compatibility() -> void:
	var legacy_effect := Phase1EffectDefinition.new()
	legacy_effect.effect_id = &"legacy.effect"
	legacy_effect.debug_hit_value = 1
	_check(legacy_effect.validate().is_empty(), "legacy effect definition remains valid")

	var legacy_action := Phase1ActionDefinition.new()
	legacy_action.action_id = &"legacy.action"
	legacy_action.effect = legacy_effect
	_check(legacy_action.validate().is_empty(), "legacy action definition remains valid")
	_check(legacy_action.max_concurrent_hit_queries == 1, "legacy action query export remains usable")

	var pool := Phase1HitQueryPool.new()
	pool.configure(1)
	var first := pool.try_reserve(&"legacy.action")
	_check(first != Phase1HitQueryPool.INVALID_TOKEN, "legacy pool configure and reserve remain usable")
	_check(pool.try_reserve(&"legacy.action") == Phase1HitQueryPool.INVALID_TOKEN, "legacy pool capacity remains enforced")
	_check(pool.release(first), "legacy pool release remains usable")
	_check(pool.active_count() == 0, "legacy pool release restores active count")


func _test_common_action_definition() -> void:
	var action := _valid_common_action()
	_check(action.validate().is_empty(), "valid common action scaffold validates")
	_check(action.hit_shape_id == &"shape.qa.arc", "hit identifier is stored without execution")
	_check(action.effect_ids == [&"effect.qa.primary"], "effect references are stored without execution")
	_check(action.hit_query_reservation_class == Phase1HitQueryPool.RESERVATION_PLAYER_CRITICAL, "reservation identifier is stored")
	_check(action.animation_id == &"animation.qa", "presentation animation identifier is stored")
	_check(action.vfx_id == &"vfx.qa" and action.sfx_id == &"sfx.qa", "presentation identifiers are stored")

	var empty_id := _valid_common_action()
	empty_id.action_id = &""
	_check(_contains(empty_id.validate(), "action_id must not be empty"), "common action rejects empty action ID")
	var empty_category := _valid_common_action()
	empty_category.category = &""
	_check(_contains(empty_category.validate(), "category must not be empty"), "common action rejects empty category")
	var unsupported_category := _valid_common_action()
	unsupported_category.category = &"unsupported"
	_check(_contains(unsupported_category.validate(), "category is invalid"), "common action rejects unsupported category")

	var invalid_timing := _valid_common_action()
	invalid_timing.windup_seconds = INF
	invalid_timing.active_seconds = NAN
	invalid_timing.recovery_seconds = -0.1
	invalid_timing.cooldown_seconds = -0.1
	var timing_errors := invalid_timing.validate()
	_check(_contains(timing_errors, "windup_seconds must be finite"), "common action rejects non-finite windup")
	_check(_contains(timing_errors, "active_seconds must be finite"), "common action rejects non-finite active duration")
	_check(_contains(timing_errors, "recovery_seconds must be nonnegative"), "common action rejects negative recovery")
	_check(_contains(timing_errors, "cooldown_seconds must be nonnegative"), "common action rejects negative cooldown")

	var negative_queries := _valid_common_action()
	negative_queries.max_concurrent_hit_queries = -1
	_check(_contains(negative_queries.validate(), "max_concurrent_hit_queries must be nonnegative"), "common action rejects negative max query count")
	var invalid_reservation := _valid_common_action()
	invalid_reservation.hit_query_reservation_class = &"UnknownReservation"
	_check(_contains(invalid_reservation.validate(), "hit_query_reservation_class is invalid"), "common action rejects invalid reservation class")

	var empty_effect_reference := _valid_common_action()
	empty_effect_reference.effect_ids = [&""]
	_check(_contains(empty_effect_reference.validate(), "effect_ids[0] must not be empty"), "common action rejects empty effect reference")
	var duplicate_effect_reference := _valid_common_action()
	duplicate_effect_reference.effect_ids = [&"effect.qa.primary", &"effect.qa.primary"]
	_check(_contains(duplicate_effect_reference.validate(), "effect_ids contains duplicate"), "common action rejects duplicate common effect reference")
	var legacy_duplicate := _valid_common_action()
	legacy_duplicate.effect_ids = [&"effect.qa.legacy"]
	var legacy_effect := Phase1EffectDefinition.new()
	legacy_effect.effect_id = &"effect.qa.legacy"
	legacy_duplicate.effect = legacy_effect
	_check(_contains(legacy_duplicate.validate(), "effect_ids duplicates legacy effect"), "common action rejects common and legacy duplicate reference")


func _test_common_effect_definition() -> void:
	var effect := _valid_common_effect()
	effect.magnitude = -3.5
	_check(effect.validate().is_empty(), "valid common effect allows signed magnitude")
	effect.magnitude = 0.0
	_check(effect.validate().is_empty(), "valid common effect allows zero magnitude")
	_check(not _has_property(effect, &"damage"), "common effect exposes no damage interpretation field")
	_check(not _has_property(effect, &"part_damage"), "common effect exposes no part-damage interpretation field")
	_check(not _has_property(effect, &"force"), "common effect exposes no force interpretation field")
	_check(not _has_property(effect, &"heat"), "common effect exposes no heat interpretation field")
	_check(not _has_property(effect, &"status"), "common effect exposes no status interpretation field")

	var invalid := _valid_common_effect()
	invalid.effect_id = &""
	invalid.effect_type = &""
	invalid.channel = &""
	invalid.magnitude = INF
	invalid.duration = NAN
	invalid.target_rule = &""
	invalid.stack_rule = &""
	invalid.tags = [&""]
	var errors := invalid.validate()
	_check(_contains(errors, "effect_id must not be empty"), "common effect rejects empty effect ID")
	_check(_contains(errors, "effect_type must not be empty"), "common effect rejects empty type")
	_check(_contains(errors, "channel must not be empty"), "common effect rejects empty channel")
	_check(_contains(errors, "magnitude must be finite"), "common effect rejects non-finite magnitude")
	_check(_contains(errors, "duration must be finite"), "common effect rejects non-finite duration")
	_check(_contains(errors, "target_rule must not be empty"), "common effect rejects empty target rule")
	_check(_contains(errors, "stack_rule must not be empty"), "common effect rejects empty stack rule")
	_check(_contains(errors, "tags[0] must not be empty"), "common effect rejects empty tag")
	var negative_duration := _valid_common_effect()
	negative_duration.duration = -0.01
	_check(_contains(negative_duration.validate(), "duration must be nonnegative"), "common effect rejects negative duration")


func _test_reservation_query_pool() -> void:
	var pool := Phase1HitQueryPool.new()
	var capacities: Dictionary = {
		Phase1HitQueryPool.RESERVATION_PLAYER_CRITICAL: 2,
		Phase1HitQueryPool.RESERVATION_BOSS_CRITICAL: 2,
		Phase1HitQueryPool.RESERVATION_ENVIRONMENT: 1,
		Phase1HitQueryPool.RESERVATION_LOW_PRIORITY: 1,
	}
	_check(pool.configure_reservations(capacities, 2).is_empty(), "caller-injected reservation capacities configure")
	_check(pool.capacity_for_class(Phase1HitQueryPool.RESERVATION_PLAYER_CRITICAL) == 2, "PlayerCritical capacity is caller supplied")
	_check(pool.capacity_for_class(Phase1HitQueryPool.RESERVATION_BOSS_CRITICAL) == 2, "BossCritical capacity is caller supplied")
	_check(pool.capacity_for_class(Phase1HitQueryPool.RESERVATION_ENVIRONMENT) == 1, "Environment capacity is caller supplied")
	_check(pool.capacity_for_class(Phase1HitQueryPool.RESERVATION_LOW_PRIORITY) == 1, "LowPriority capacity is caller supplied")
	_check(pool.emergency_capacity() == 2, "emergency capacity is caller supplied")

	var low := pool.try_reserve_for_class(&"low", Phase1HitQueryPool.RESERVATION_LOW_PRIORITY)
	var environment := pool.try_reserve_for_class(&"environment", Phase1HitQueryPool.RESERVATION_ENVIRONMENT)
	_check(low != Phase1HitQueryPool.INVALID_TOKEN and environment != Phase1HitQueryPool.INVALID_TOKEN, "normal classes reserve their own capacity")
	_check(pool.try_reserve_for_class(&"low-again", Phase1HitQueryPool.RESERVATION_LOW_PRIORITY) == Phase1HitQueryPool.INVALID_TOKEN, "LowPriority cannot consume PlayerCritical or emergency capacity")
	_check(pool.try_reserve_for_class(&"environment-again", Phase1HitQueryPool.RESERVATION_ENVIRONMENT) == Phase1HitQueryPool.INVALID_TOKEN, "Environment cannot consume BossCritical or emergency capacity")
	_check(pool.try_reserve_emergency(&"low-emergency", Phase1HitQueryPool.RESERVATION_LOW_PRIORITY) == Phase1HitQueryPool.INVALID_TOKEN, "LowPriority cannot use emergency capacity")
	_check(pool.try_reserve_emergency(&"environment-emergency", Phase1HitQueryPool.RESERVATION_ENVIRONMENT) == Phase1HitQueryPool.INVALID_TOKEN, "Environment cannot use emergency capacity")
	var player_emergency := pool.try_reserve_emergency(&"player-emergency", Phase1HitQueryPool.RESERVATION_PLAYER_CRITICAL)
	var boss_emergency := pool.try_reserve_emergency(&"boss-emergency", Phase1HitQueryPool.RESERVATION_BOSS_CRITICAL)
	_check(player_emergency != Phase1HitQueryPool.INVALID_TOKEN and boss_emergency != Phase1HitQueryPool.INVALID_TOKEN, "only PlayerCritical and BossCritical may use emergency capacity")
	_check(pool.emergency_active_count() == 2 and pool.emergency_use_count() == 2 and pool.has_emergency_use(), "emergency use telemetry is observable")

	var first_player := pool.try_reserve_for_class(&"player-one", Phase1HitQueryPool.RESERVATION_PLAYER_CRITICAL)
	var second_player := pool.try_reserve_for_class(&"player-two", Phase1HitQueryPool.RESERVATION_PLAYER_CRITICAL)
	_check(first_player != Phase1HitQueryPool.INVALID_TOKEN and second_player != Phase1HitQueryPool.INVALID_TOKEN and second_player > first_player, "lease tokens are unique and monotonic")
	_check(not pool.release(999999), "unknown token release is rejected")
	_check(pool.release(first_player), "active lease release succeeds")
	_check(not pool.release(first_player), "duplicate released-token release is rejected")
	var telemetry_before_reset := pool.emergency_use_count()
	pool.reset()
	_check(pool.active_count() == 0 and pool.emergency_active_count() == 0, "reset clears all active reservations")
	_check(pool.available_capacity_for_class(Phase1HitQueryPool.RESERVATION_PLAYER_CRITICAL) == 2, "reset restores configured class capacity")
	_check(pool.emergency_available_count() == 2, "reset restores emergency capacity")
	_check(pool.emergency_use_count() >= telemetry_before_reset, "reset preserves observable emergency telemetry")
	_check(not pool.release(second_player), "pre-reset stale token release is rejected")

	var before_invalid_capacity := pool.capacity_for_class(Phase1HitQueryPool.RESERVATION_PLAYER_CRITICAL)
	var invalid_errors := pool.configure_reservations({"not-a-string-name": 1}, 0)
	_check(not invalid_errors.is_empty(), "invalid reservation key fails reconfiguration")
	_check(pool.capacity_for_class(Phase1HitQueryPool.RESERVATION_PLAYER_CRITICAL) == before_invalid_capacity, "invalid reconfiguration preserves prior valid capacity")
	var incomplete_errors := pool.configure_reservations({Phase1HitQueryPool.RESERVATION_PLAYER_CRITICAL: -1}, 0)
	_check(not incomplete_errors.is_empty(), "negative reservation capacity fails reconfiguration")
	_check(pool.capacity_for_class(Phase1HitQueryPool.RESERVATION_BOSS_CRITICAL) == 2, "incomplete reconfiguration does not corrupt prior classes")

	var large_pool := Phase1HitQueryPool.new()
	_check(large_pool.configure_reservations({Phase1HitQueryPool.RESERVATION_PLAYER_CRITICAL: 51}, 0).is_empty(), "caller-injected capacity 51 configures without product cap")
	var leases: Array[int] = []
	for index in range(51):
		var token := large_pool.try_reserve_for_class(&"capacity-%d" % index, Phase1HitQueryPool.RESERVATION_PLAYER_CRITICAL)
		if token != Phase1HitQueryPool.INVALID_TOKEN:
			leases.append(token)
	_check(leases.size() == 51, "all 51 caller-injected PlayerCritical queries reserve")
	_check(large_pool.try_reserve_for_class(&"capacity-overflow", Phase1HitQueryPool.RESERVATION_PLAYER_CRITICAL) == Phase1HitQueryPool.INVALID_TOKEN, "52nd query follows configured capacity without a special 51st case")
	large_pool.clear()
	_check(large_pool.active_count() == 0 and large_pool.available_capacity_for_class(Phase1HitQueryPool.RESERVATION_PLAYER_CRITICAL) == 51, "clear removes all active reservations and restores configured capacity")


func _valid_common_action() -> Phase1ActionDefinition:
	var action := Phase1ActionDefinition.new()
	action.action_id = &"action.qa.common"
	action.category = Phase1ActionDefinition.CATEGORY_PHYSICAL
	action.windup_seconds = 0.1
	action.active_seconds = 0.2
	action.recovery_seconds = 0.3
	action.cooldown_seconds = 0.4
	action.hit_shape_id = &"shape.qa.arc"
	action.effect_ids = [&"effect.qa.primary"]
	action.hit_query_reservation_class = Phase1HitQueryPool.RESERVATION_PLAYER_CRITICAL
	action.animation_id = &"animation.qa"
	action.vfx_id = &"vfx.qa"
	action.sfx_id = &"sfx.qa"
	return action


func _valid_common_effect() -> Phase1EffectDefinition:
	var effect := Phase1EffectDefinition.new()
	effect.effect_id = &"effect.qa.common"
	effect.effect_type = &"open.vocabulary"
	effect.channel = &"qa.channel"
	effect.magnitude = 1.0
	effect.duration = 0.0
	effect.target_rule = &"qa.target"
	effect.stack_rule = &"qa.stack"
	effect.tags = [&"qa.tag"]
	return effect


func _contains(errors: PackedStringArray, expected: String) -> bool:
	for error in errors:
		if error.contains(expected):
			return true
	return false


func _has_property(resource: Resource, property_name: StringName) -> bool:
	for property in resource.get_property_list():
		if StringName(property.name) == property_name:
			return true
	return false


func _check(condition: bool, description: String) -> void:
	_assertion_count += 1
	if condition:
		print("[MFO-P2-2B-FOUNDATION-TEST] PASS: %s" % description)
	else:
		_failures.append(description)
