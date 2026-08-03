extends SceneTree

const TUNING_PATH := "res://data/fast_slice/fs_a_provisional_tuning.tres"

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var tuning := load(TUNING_PATH) as FsATuning
	_check(tuning != null, "fs_provisional tuning loads")
	if tuning != null:
		_check(tuning.authority_label == FsATuning.AUTHORITY_FS_PROVISIONAL, "tuning remains fs_provisional")
		_check(tuning.validate().is_empty(), "tuning validates")
		_test_action_state(tuning)
	_test_existing_input_map()
	if _failures.is_empty():
		print("[MFO-FS-A-SELF-CHECK] PASS: action milestone")
		quit(0)
	else:
		for failure in _failures:
			push_error("[MFO-FS-A-SELF-CHECK] %s" % failure)
		quit(1)


func _test_action_state(tuning: FsATuning) -> void:
	var action := FsAPlayerAction.new()
	_check(action.configure(tuning), "player action configures")
	_check(action.try_accept(FsAPlayerAction.ACTION_LIGHT, Vector2.RIGHT), "light attack is accepted")
	_check(action.state() == FsAPlayerAction.STATE_WINDUP, "light starts in windup")
	_check(not action.try_accept(FsAPlayerAction.ACTION_HEAVY, Vector2.RIGHT), "busy action rejects overlap")
	action.advance(tuning.light_windup_seconds - 0.01)
	_check(action.pending_hit_query().is_empty(), "light cannot hit before active")
	action.advance(0.01)
	var light_query := action.pending_hit_query()
	_check(light_query.get("action_id") == FsAPlayerAction.ACTION_LIGHT, "light opens its hit query at active")
	var light_result := action.commit_pending_hit(&"part.core_plate")
	_check(light_result.get("hit", false), "light hit is committed")
	_check(action.commit_pending_hit(&"part.core_plate").is_empty(), "one action cannot commit twice")
	action.advance(tuning.light_active_seconds + tuning.light_recovery_seconds)
	_check(action.state() == FsAPlayerAction.STATE_IDLE, "light returns to idle")
	_check(action.try_accept(FsAPlayerAction.ACTION_HEAVY, Vector2.UP), "heavy attack is accepted separately")
	_check(tuning.heavy_windup_seconds > tuning.light_windup_seconds, "heavy timing differs from light")
	action.advance(tuning.heavy_windup_seconds)
	var heavy_query := action.pending_hit_query()
	_check(heavy_query.get("action_id") == FsAPlayerAction.ACTION_HEAVY, "heavy opens its own hit query")
	_check(heavy_query.get("body_damage", 0) > light_query.get("body_damage", 0), "heavy uses distinct damage")
	_check(action.commit_pending_hit(&"").get("hit", true) == false, "miss is committed exactly once")


func _test_existing_input_map() -> void:
	var legacy := Phase1InputAdapter.new()
	var adapter := FsAInputAdapter.new()
	_check(adapter.bind_legacy_adapter(legacy), "FS adapter composes legacy input")
	_check(adapter.ensure_input_map(), "legacy input map remains usable")
	var heavy_event_count := InputMap.action_get_events(Phase1InputAdapter.ACTION_HEAVY).size()
	adapter.ensure_input_map()
	_check(InputMap.action_get_events(Phase1InputAdapter.ACTION_HEAVY).size() == heavy_event_count, "input setup stays idempotent")
	_check(_has_mouse_button(Phase1InputAdapter.ACTION_HEAVY, MOUSE_BUTTON_RIGHT), "heavy keeps existing right mouse binding")
	_check(_has_key(Phase1InputAdapter.ACTION_INTERACT, KEY_E), "interact keeps existing E binding")
	adapter.free()
	legacy.free()


func _has_mouse_button(action: StringName, button_index: int) -> bool:
	for event in InputMap.action_get_events(action):
		var mouse := event as InputEventMouseButton
		if mouse != null and mouse.button_index == button_index:
			return true
	return false


func _has_key(action: StringName, keycode: Key) -> bool:
	for event in InputMap.action_get_events(action):
		var key := event as InputEventKey
		if key != null and key.physical_keycode == keycode:
			return true
	return false


func _check(condition: bool, description: String) -> void:
	if condition:
		print("[MFO-FS-A-SELF-CHECK] PASS: %s" % description)
	else:
		_failures.append(description)
