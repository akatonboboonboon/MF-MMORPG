class_name Phase1HitQueryPool
extends RefCounted

const INVALID_TOKEN := -1
const RESERVATION_PLAYER_CRITICAL: StringName = &"PlayerCritical"
const RESERVATION_BOSS_CRITICAL: StringName = &"BossCritical"
const RESERVATION_ENVIRONMENT: StringName = &"Environment"
const RESERVATION_LOW_PRIORITY: StringName = &"LowPriority"

var _capacity := 0
var _configured_capacities: Dictionary = {}
var _free_slots_by_class: Dictionary = {}
var _emergency_capacity := 0
var _free_emergency_slots: Array[int] = []
var _emergency_use_count := 0
var _active_tokens: Dictionary = {}
var _next_slot_id := 0
var _next_token := 0


func configure(player_critical_capacity: int) -> void:
	configure_reservations({RESERVATION_PLAYER_CRITICAL: maxi(1, player_critical_capacity)})


func configure_reservations(capacities: Dictionary, emergency_capacity: int = 0) -> PackedStringArray:
	var errors := PackedStringArray()
	var normalized_capacities: Dictionary = {}
	if emergency_capacity < 0:
		errors.append("emergency_capacity must be nonnegative")

	for raw_class in capacities:
		if typeof(raw_class) != TYPE_STRING_NAME:
			errors.append("reservation capacity key must be a StringName")
			continue
		var reservation_class: StringName = raw_class
		if not is_valid_reservation_class(reservation_class):
			errors.append("reservation class is invalid: %s" % reservation_class)
			continue
		var raw_capacity = capacities[raw_class]
		if typeof(raw_capacity) != TYPE_INT:
			errors.append("capacity for %s must be an integer" % reservation_class)
			continue
		var class_capacity: int = raw_capacity
		if class_capacity < 0:
			errors.append("capacity for %s must be nonnegative" % reservation_class)
			continue
		normalized_capacities[reservation_class] = class_capacity

	if not errors.is_empty():
		return errors

	_configured_capacities.clear()
	for reservation_class in reservation_classes():
		_configured_capacities[reservation_class] = normalized_capacities.get(reservation_class, 0)
	_emergency_capacity = emergency_capacity
	_emergency_use_count = 0
	_rebuild_available_slots()
	return errors


func try_reserve(action_id: StringName) -> int:
	return try_reserve_for_class(action_id, RESERVATION_PLAYER_CRITICAL)


func try_reserve_for_class(action_id: StringName, reservation_class: StringName) -> int:
	if not is_valid_reservation_class(reservation_class):
		return INVALID_TOKEN
	var free_slots: Array = _free_slots_by_class.get(reservation_class, [])
	if free_slots.is_empty():
		return INVALID_TOKEN
	var slot_id: int = free_slots.pop_back()
	_free_slots_by_class[reservation_class] = free_slots
	return _activate_slot(action_id, reservation_class, slot_id, false)


func try_reserve_emergency(action_id: StringName, reservation_class: StringName) -> int:
	if reservation_class != RESERVATION_PLAYER_CRITICAL and reservation_class != RESERVATION_BOSS_CRITICAL:
		return INVALID_TOKEN
	if _free_emergency_slots.is_empty():
		return INVALID_TOKEN
	var slot_id: int = _free_emergency_slots.pop_back()
	_emergency_use_count += 1
	return _activate_slot(action_id, reservation_class, slot_id, true)


func release(token: int) -> bool:
	if not _active_tokens.has(token):
		return false
	var record: Dictionary = _active_tokens[token]
	var slot_id := int(record.get("slot_id", -1))
	if slot_id < 0:
		return false

	if record.get("uses_emergency", false):
		if _free_emergency_slots.has(slot_id):
			return false
		_active_tokens.erase(token)
		_free_emergency_slots.append(slot_id)
		return true

	var reservation_class := StringName(record.get("reservation_class", &""))
	if not is_valid_reservation_class(reservation_class):
		return false
	if not _free_slots_by_class.has(reservation_class):
		return false
	var free_slots: Array = _free_slots_by_class[reservation_class]
	if free_slots.has(slot_id):
		return false
	_active_tokens.erase(token)
	free_slots.append(slot_id)
	_free_slots_by_class[reservation_class] = free_slots
	return true


func clear() -> void:
	_rebuild_available_slots()


func reset() -> void:
	clear()


func active_count() -> int:
	return _active_tokens.size()


func active_count_for_class(reservation_class: StringName) -> int:
	if not is_valid_reservation_class(reservation_class):
		return 0
	var count := 0
	for raw_record in _active_tokens.values():
		var record: Dictionary = raw_record
		if record.get("reservation_class", &"") == reservation_class:
			count += 1
	return count


func emergency_active_count() -> int:
	var count := 0
	for raw_record in _active_tokens.values():
		var record: Dictionary = raw_record
		if record.get("uses_emergency", false):
			count += 1
	return count


func capacity() -> int:
	return _capacity


func capacity_for_class(reservation_class: StringName) -> int:
	if not is_valid_reservation_class(reservation_class):
		return 0
	return int(_configured_capacities.get(reservation_class, 0))


func available_capacity_for_class(reservation_class: StringName) -> int:
	if not is_valid_reservation_class(reservation_class):
		return 0
	var free_slots: Array = _free_slots_by_class.get(reservation_class, [])
	return free_slots.size()


func emergency_capacity() -> int:
	return _emergency_capacity


func emergency_available_count() -> int:
	return _free_emergency_slots.size()


func emergency_use_count() -> int:
	return _emergency_use_count


func has_emergency_use() -> bool:
	return _emergency_use_count > 0


static func is_valid_reservation_class(reservation_class: StringName) -> bool:
	return (
		reservation_class == RESERVATION_PLAYER_CRITICAL
		or reservation_class == RESERVATION_BOSS_CRITICAL
		or reservation_class == RESERVATION_ENVIRONMENT
		or reservation_class == RESERVATION_LOW_PRIORITY
	)


static func reservation_classes() -> Array[StringName]:
	return [
		RESERVATION_PLAYER_CRITICAL,
		RESERVATION_BOSS_CRITICAL,
		RESERVATION_ENVIRONMENT,
		RESERVATION_LOW_PRIORITY,
	]


func _activate_slot(
	action_id: StringName,
	reservation_class: StringName,
	slot_id: int,
	uses_emergency: bool
) -> int:
	var token := _next_token
	_next_token += 1
	_active_tokens[token] = {
		"action_id": action_id,
		"reservation_class": reservation_class,
		"slot_id": slot_id,
		"uses_emergency": uses_emergency,
	}
	return token


func _rebuild_available_slots() -> void:
	_active_tokens.clear()
	_free_slots_by_class.clear()
	_free_emergency_slots.clear()
	_capacity = _emergency_capacity

	for reservation_class in reservation_classes():
		var free_slots: Array[int] = []
		var class_capacity := int(_configured_capacities.get(reservation_class, 0))
		_capacity += class_capacity
		for _slot in range(class_capacity):
			free_slots.append(_allocate_slot())
		_free_slots_by_class[reservation_class] = free_slots

	for _slot in range(_emergency_capacity):
		_free_emergency_slots.append(_allocate_slot())


func _allocate_slot() -> int:
	var slot_id := _next_slot_id
	_next_slot_id += 1
	return slot_id
