class_name Phase1HitQueryPool
extends RefCounted

const INVALID_TOKEN := -1

var _capacity: int
var _free_tokens: Array[int] = []
var _active_tokens: Dictionary = {}


func configure(player_critical_capacity: int) -> void:
	_capacity = maxi(1, player_critical_capacity)
	_free_tokens.clear()
	_active_tokens.clear()
	for token in range(_capacity):
		_free_tokens.append(token)


func try_reserve(action_id: StringName) -> int:
	if _free_tokens.is_empty():
		return INVALID_TOKEN
	var token: int = _free_tokens.pop_back()
	_active_tokens[token] = action_id
	return token


func release(token: int) -> bool:
	if not _active_tokens.has(token):
		return false
	_active_tokens.erase(token)
	_free_tokens.append(token)
	return true


func active_count() -> int:
	return _active_tokens.size()


func capacity() -> int:
	return _capacity
