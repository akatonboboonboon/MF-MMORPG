class_name FsAGameplayLoop
extends RefCounted

signal gameplay_event(event_name: StringName, payload: Dictionary)

const LOOP_COMBAT := &"combat"
const LOOP_WRECK := &"wreck"
const LOOP_RESULT := &"result"
const PLAYER_COMBAT_FORM := &"Knight"
const PLAYER_MATERIAL_JOB := &"Iron"
const BOSS_ID := &"boss.large.1"
const PART_ID := &"part.core_plate"
const TELEGRAPH_LINE := &"telegraph_line"
const TELEGRAPH_SECTOR := &"telegraph_sector"
const ENEMY_STOPPED := &"stopped"
const ENEMY_COOLDOWN := &"cooldown"
const ENEMY_TELEGRAPH := &"telegraph"
const ENEMY_ACTIVE := &"active"
const ENEMY_RECOVERY := &"recovery"
const HARVEST_IDS := [&"harvest.1", &"harvest.2", &"harvest.3"]
const _TIME_EPSILON := 0.000001

var _tuning: FsATuning
var _player_action := FsAPlayerAction.new()
var _configured: bool = false
var _round_index: int = 1
var _loop_phase: StringName = LOOP_COMBAT
var _player_integrity: int = 0
var _player_deformation: float = 0.0
var _player_position := Vector2.ZERO
var _player_aim := Vector2.RIGHT
var _boss_hp: int = 0
var _boss_functional: bool = false
var _part_hp: int = 0
var _part_broken: bool = false
var _enemy_state: StringName = ENEMY_STOPPED
var _enemy_state_elapsed_seconds: float = 0.0
var _enemy_cooldown_duration_seconds: float = 0.0
var _enemy_attack_index: int = 0
var _enemy_attack_serial: int = 0
var _enemy_attack_id: StringName = &""
var _telegraph_shape: StringName = &""
var _telegraph_direction := Vector2.LEFT
var _enemy_hit_pending: bool = false
var _defeat_committed: bool = false
var _player_defeat_latched: bool = false
var _wreck_active: bool = false
var _harvest_collected: Dictionary = {}
var _result_visible: bool = false
var _rematch_available: bool = false
var _player_hit_confirmation_count: int = 0
var _enemy_attack_start_count: int = 0
var _enemy_hit_resolution_count: int = 0
var _enemy_hit_confirmation_count: int = 0
var _part_break_count: int = 0
var _boss_defeat_transition_count: int = 0
var _wreck_spawn_count: int = 0
var _harvest_collection_count: int = 0
var _all_harvest_collected: bool = false
var _result_delay_remaining_seconds: float = 0.0
var _result_transition_count: int = 0
var _reward_total: int = 0
var _rematch_reset_count: int = 0
var _player_defeat_latch_count: int = 0


func configure(tuning: FsATuning) -> bool:
	_configured = false
	if tuning == null or not tuning.validate().is_empty():
		return false
	if not _player_action.configure(tuning):
		return false
	_tuning = tuning
	_configured = true
	_round_index = 1
	_rematch_reset_count = 0
	_reset_round_state()
	return true


func is_configured() -> bool:
	return _configured


func set_player_spatial_state(position: Vector2, aim: Vector2) -> void:
	if _player_defeat_latched:
		return
	_player_position = position
	if aim.length_squared() > 0.0001:
		_player_aim = aim.normalized()


func request_player_action(action_id: StringName, aim: Vector2) -> bool:
	if not _configured or _player_defeat_latched or _loop_phase != LOOP_COMBAT or not _boss_functional:
		return false
	var accepted := _player_action.try_accept(action_id, aim)
	if accepted:
		_emit_event(&"player_action_accepted", {
			"action_id": action_id,
			"sequence": _player_action.current_sequence(),
		})
	return accepted


func advance_authority(delta_seconds: float, player_position: Vector2, player_aim: Vector2) -> void:
	if _player_defeat_latched:
		return
	set_player_spatial_state(player_position, player_aim)
	advance_player_action(delta_seconds)
	advance_enemy(delta_seconds, player_position)
	advance_post_combat(delta_seconds)


func advance_player_action(delta_seconds: float) -> void:
	if not _configured or _player_defeat_latched or _loop_phase != LOOP_COMBAT or not _boss_functional:
		return
	_player_action.advance(delta_seconds)


func pending_player_hit_query() -> Dictionary:
	if not _configured or _player_defeat_latched or _loop_phase != LOOP_COMBAT or not _boss_functional:
		return {}
	return _player_action.pending_hit_query()


func resolve_pending_player_hit() -> Dictionary:
	if _player_defeat_latched:
		return {}
	var query := pending_player_hit_query()
	if query.is_empty():
		return {}
	var target_id := _select_player_hit_target(query)
	var resolution := _player_action.commit_pending_hit(target_id)
	if resolution.is_empty():
		return {}
	var outcome: Dictionary = resolution.duplicate(true)
	if target_id == PART_ID:
		_apply_part_hit(int(resolution.get("part_damage", 0)), int(resolution.get("body_damage", 0)))
		_player_hit_confirmation_count += 1
	elif target_id == BOSS_ID:
		_apply_boss_damage(int(resolution.get("body_damage", 0)))
		_player_hit_confirmation_count += 1
	_emit_event(&"player_hit_resolved", {
		"action_id": resolution.get("action_id", &""),
		"sequence": resolution.get("sequence", 0),
		"target_id": target_id,
		"hit": not target_id.is_empty(),
		"boss_hp": _boss_hp,
		"part_hp": _part_hp,
	})
	outcome["boss_hp_after"] = _boss_hp
	outcome["part_hp_after"] = _part_hp
	return _deep_read_only(outcome)


func advance_enemy(delta_seconds: float, player_position: Vector2) -> void:
	if _player_defeat_latched:
		return
	_player_position = player_position
	if not _configured or _loop_phase != LOOP_COMBAT or not _boss_functional:
		return
	if _enemy_hit_pending:
		return
	var remaining := maxf(delta_seconds, 0.0)
	var transitions := 0
	while remaining > _TIME_EPSILON and transitions < 8 and _boss_functional and not _player_defeat_latched:
		var duration := _enemy_state_duration()
		var until_transition := maxf(0.0, duration - _enemy_state_elapsed_seconds)
		if remaining + _TIME_EPSILON < until_transition:
			_enemy_state_elapsed_seconds += remaining
			remaining = 0.0
		else:
			_enemy_state_elapsed_seconds = duration
			remaining = maxf(0.0, remaining - until_transition)
			_transition_enemy_state(player_position)
			transitions += 1
			if _enemy_hit_pending:
				break


func resolve_pending_enemy_hit(player_position: Vector2) -> Dictionary:
	if _player_defeat_latched:
		return {}
	_player_position = player_position
	if not _configured or not _boss_functional or not _enemy_hit_pending:
		return {}
	var resolved_attack_id := _enemy_attack_id
	var resolved_shape := _telegraph_shape
	_enemy_hit_pending = false
	_enemy_hit_resolution_count += 1
	var hit := _enemy_attack_contains(player_position)
	var integrity_damage := 0
	var deformation := 0.0
	if hit:
		if resolved_shape == TELEGRAPH_LINE:
			integrity_damage = _tuning.line_integrity_damage
			deformation = _tuning.line_deformation
		else:
			integrity_damage = _tuning.sector_integrity_damage
			deformation = _tuning.sector_deformation
		var previous_integrity := _player_integrity
		_player_integrity = maxi(0, _player_integrity - integrity_damage)
		_player_deformation += deformation
		_enemy_hit_confirmation_count += 1
		if previous_integrity > 0 and _player_integrity == 0:
			_commit_player_defeat()
	var result := {
		"attack_id": resolved_attack_id,
		"shape": resolved_shape,
		"hit": hit,
		"integrity_damage": integrity_damage,
		"deformation": deformation,
		"player_integrity_after": _player_integrity,
		"player_deformation_after": _player_deformation,
	}
	_emit_event(&"enemy_hit_resolved", result)
	return _deep_read_only(result)


func collect_harvest_point(harvest_id: StringName, collector_position: Vector2) -> bool:
	if not _configured or _loop_phase != LOOP_WRECK or not _wreck_active:
		return false
	if not HARVEST_IDS.has(harvest_id) or bool(_harvest_collected.get(harvest_id, false)):
		return false
	var point_position := _harvest_position(harvest_id)
	if collector_position.distance_to(point_position) > _tuning.harvest_interaction_range:
		return false
	_harvest_collected[harvest_id] = true
	_harvest_collection_count += 1
	_reward_total += _tuning.reward_per_harvest_point
	_emit_event(&"harvest_collected", {
		"id": harvest_id,
		"reward_id": _tuning.reward_id,
		"reward_amount": _tuning.reward_per_harvest_point,
	})
	if _harvest_collection_count == HARVEST_IDS.size():
		_all_harvest_collected = true
		_result_delay_remaining_seconds = _tuning.result_delay_seconds
		if _result_delay_remaining_seconds <= _TIME_EPSILON:
			_commit_result()
	return true


func advance_post_combat(delta_seconds: float) -> void:
	if not _configured or _loop_phase != LOOP_WRECK or not _all_harvest_collected:
		return
	_result_delay_remaining_seconds = maxf(
		0.0,
		_result_delay_remaining_seconds - maxf(delta_seconds, 0.0)
	)
	if _result_delay_remaining_seconds <= _TIME_EPSILON:
		_commit_result()


func get_reward_data() -> Dictionary:
	var rewards := {
		"reward_id": _tuning.reward_id if _tuning != null else &"",
		"amount": _reward_total,
		"collected_points": _harvest_collection_count,
		"source_point_count": HARVEST_IDS.size(),
		"persistent": false,
	}
	return _deep_read_only(rewards)


func request_rematch() -> bool:
	if not _configured or _loop_phase != LOOP_RESULT or not _rematch_available:
		return false
	_round_index += 1
	_rematch_reset_count += 1
	_reset_round_state()
	_emit_event(&"rematch_reset", {"round_index": _round_index})
	return true


func request_player_defeat_retry() -> bool:
	if not _configured or not _player_defeat_latched or _player_integrity != 0:
		return false
	_reset_round_state()
	return true


func get_snapshot() -> Dictionary:
	var parts: Array = [{
		"id": PART_ID,
		"hp": _part_hp,
		"broken": _part_broken,
		"position": part_position(),
	}]
	var harvest_points: Array = []
	var offsets := _tuning.harvest_offsets() if _tuning != null else [Vector2.ZERO, Vector2.ZERO, Vector2.ZERO]
	for index in range(HARVEST_IDS.size()):
		var harvest_id: StringName = HARVEST_IDS[index]
		harvest_points.append({
			"id": harvest_id,
			"collected": bool(_harvest_collected.get(harvest_id, false)),
			"position": boss_position() + offsets[index],
		})
	var snapshot := {
		"loop_phase": _loop_phase,
		"player_build": {
			"combat_form": PLAYER_COMBAT_FORM,
			"material_job": PLAYER_MATERIAL_JOB,
		},
		"player_integrity": _player_integrity,
		"player_integrity_max": _tuning.player_integrity_max if _tuning != null else 0,
		"player_deformation": _player_deformation,
		"player_position": _player_position,
		"player_aim": _player_aim,
		"player_action": _player_action.debug_state(),
		"boss_hp": _boss_hp,
		"boss_hp_max": _tuning.boss_hp_max if _tuning != null else 0,
		"boss_position": boss_position(),
		"parts": parts,
		"telegraph": _telegraph_snapshot(),
		"boss_functional": _boss_functional,
		"wreck_active": _wreck_active,
		"harvest_points": harvest_points,
		"result_visible": _result_visible,
		"rematch_available": _rematch_available,
		"result_rewards": get_reward_data(),
	}
	return _deep_read_only(snapshot)


func debug_counters() -> Dictionary:
	var action_debug := _player_action.debug_state()
	return _deep_read_only({
		"round_index": _round_index,
		"player_hit_resolutions": action_debug.get("hit_resolution_count", 0),
		"player_hit_confirmations": _player_hit_confirmation_count,
		"enemy_attack_starts": _enemy_attack_start_count,
		"enemy_hit_resolutions": _enemy_hit_resolution_count,
		"enemy_hit_confirmations": _enemy_hit_confirmation_count,
		"player_defeat_latches": _player_defeat_latch_count,
		"part_breaks": _part_break_count,
		"boss_defeat_transitions": _boss_defeat_transition_count,
		"wreck_spawns": _wreck_spawn_count,
		"harvest_collections": _harvest_collection_count,
		"result_transitions": _result_transition_count,
		"rematch_resets": _rematch_reset_count,
	})


func boss_position() -> Vector2:
	return _tuning.boss_position if _tuning != null else Vector2.ZERO


func part_position() -> Vector2:
	return boss_position() + (_tuning.part_offset if _tuning != null else Vector2.ZERO)


func _reset_round_state() -> void:
	_player_action.reset()
	_loop_phase = LOOP_COMBAT
	_player_integrity = _tuning.player_integrity_max
	_player_deformation = 0.0
	_player_position = _tuning.player_start_position
	_player_aim = _tuning.player_start_aim.normalized()
	_boss_hp = _tuning.boss_hp_max
	_boss_functional = true
	_part_hp = _tuning.part_hp_max
	_part_broken = false
	_enemy_state = ENEMY_COOLDOWN
	_enemy_state_elapsed_seconds = 0.0
	_enemy_cooldown_duration_seconds = _tuning.enemy_initial_cooldown_seconds
	_enemy_attack_index = 0
	_enemy_attack_serial = 0
	_enemy_attack_id = &""
	_telegraph_shape = &""
	_telegraph_direction = Vector2.LEFT
	_enemy_hit_pending = false
	_defeat_committed = false
	_player_defeat_latched = false
	_wreck_active = false
	_harvest_collected.clear()
	for harvest_id in HARVEST_IDS:
		_harvest_collected[harvest_id] = false
	_result_visible = false
	_rematch_available = false
	_harvest_collection_count = 0
	_all_harvest_collected = false
	_result_delay_remaining_seconds = 0.0
	_result_transition_count = 0
	_reward_total = 0
	_player_hit_confirmation_count = 0
	_enemy_attack_start_count = 0
	_enemy_hit_resolution_count = 0
	_enemy_hit_confirmation_count = 0
	_part_break_count = 0
	_boss_defeat_transition_count = 0
	_wreck_spawn_count = 0
	_player_defeat_latch_count = 0


func _select_player_hit_target(query: Dictionary) -> StringName:
	if not _part_broken and _target_inside_player_query(query, part_position(), _tuning.part_target_radius):
		return PART_ID
	if _target_inside_player_query(query, boss_position(), _tuning.boss_target_radius):
		return BOSS_ID
	return &""


func _target_inside_player_query(query: Dictionary, target_position: Vector2, target_radius: float) -> bool:
	var offset := target_position - _player_position
	var distance := offset.length()
	if distance > float(query.get("reach", 0.0)) + target_radius:
		return false
	if distance <= _TIME_EPSILON:
		return true
	var aim: Vector2 = query.get("aim", Vector2.RIGHT)
	return aim.normalized().dot(offset / distance) >= float(query.get("minimum_aim_dot", 1.0))


func _apply_part_hit(part_damage: int, body_damage: int) -> void:
	if _part_broken or not _boss_functional:
		return
	_part_hp = maxi(0, _part_hp - maxi(0, part_damage))
	var linked_body_damage := roundi(float(maxi(0, body_damage)) * _tuning.part_hit_body_damage_ratio)
	if linked_body_damage > 0:
		_apply_boss_damage(linked_body_damage)
	if _part_hp == 0 and not _part_broken:
		_part_broken = true
		_part_break_count += 1
		_emit_event(&"part_broken", {"part_id": PART_ID})


func _apply_boss_damage(damage: int) -> void:
	if damage <= 0 or not _boss_functional:
		return
	var previous_hp := _boss_hp
	_boss_hp = maxi(0, _boss_hp - damage)
	if previous_hp > 0 and _boss_hp == 0:
		_commit_boss_defeat()


func _commit_player_defeat() -> void:
	if _player_defeat_latched:
		return
	_player_defeat_latched = true
	_player_defeat_latch_count += 1
	_player_action.cancel()
	_stop_enemy()


func _commit_boss_defeat() -> void:
	if _defeat_committed:
		return
	_defeat_committed = true
	_boss_hp = 0
	_boss_functional = false
	_loop_phase = LOOP_WRECK
	_boss_defeat_transition_count += 1
	_player_action.cancel()
	_stop_enemy()
	_spawn_wreck()
	_emit_event(&"boss_defeated", {
		"boss_id": BOSS_ID,
		"transition_count": _boss_defeat_transition_count,
	})


func _spawn_wreck() -> void:
	if _wreck_active:
		return
	_wreck_active = true
	_wreck_spawn_count += 1
	_emit_event(&"wreck_spawned", {"spawn_count": _wreck_spawn_count})


func _commit_result() -> void:
	if _loop_phase != LOOP_WRECK or _result_visible:
		return
	_loop_phase = LOOP_RESULT
	_result_visible = true
	_rematch_available = true
	_result_transition_count += 1
	_emit_event(&"result_ready", {
		"reward": get_reward_data(),
		"transition_count": _result_transition_count,
	})


func _harvest_position(harvest_id: StringName) -> Vector2:
	var index := HARVEST_IDS.find(harvest_id)
	if index < 0:
		return Vector2.INF
	return boss_position() + _tuning.harvest_offsets()[index]


func _stop_enemy() -> void:
	_enemy_state = ENEMY_STOPPED
	_enemy_state_elapsed_seconds = 0.0
	_enemy_attack_id = &""
	_telegraph_shape = &""
	_enemy_hit_pending = false


func _transition_enemy_state(player_position: Vector2) -> void:
	_enemy_state_elapsed_seconds = 0.0
	match _enemy_state:
		ENEMY_COOLDOWN:
			_begin_enemy_telegraph(player_position)
		ENEMY_TELEGRAPH:
			_enemy_state = ENEMY_ACTIVE
			_enemy_hit_pending = true
		ENEMY_ACTIVE:
			_enemy_state = ENEMY_RECOVERY
		ENEMY_RECOVERY:
			var completed_shape := _telegraph_shape
			_enemy_state = ENEMY_COOLDOWN
			_enemy_cooldown_duration_seconds = (
				_tuning.line_cooldown_seconds
				if completed_shape == TELEGRAPH_LINE
				else _tuning.sector_cooldown_seconds
			)
			_enemy_attack_id = &""
			_telegraph_shape = &""
		_:
			_stop_enemy()


func _begin_enemy_telegraph(player_position: Vector2) -> void:
	_enemy_state = ENEMY_TELEGRAPH
	_telegraph_shape = TELEGRAPH_LINE if _enemy_attack_index % 2 == 0 else TELEGRAPH_SECTOR
	_enemy_attack_index += 1
	_enemy_attack_serial += 1
	_enemy_attack_id = StringName("enemy.%s.%d" % [_telegraph_shape, _enemy_attack_serial])
	var direction := player_position - boss_position()
	_telegraph_direction = direction.normalized() if direction.length_squared() > 0.0001 else Vector2.LEFT
	_enemy_attack_start_count += 1
	_emit_event(&"telegraph_started", {
		"id": _enemy_attack_id,
		"shape": _telegraph_shape,
		"direction": _telegraph_direction,
	})


func _enemy_state_duration() -> float:
	match _enemy_state:
		ENEMY_COOLDOWN:
			return _enemy_cooldown_duration_seconds
		ENEMY_TELEGRAPH:
			return _telegraph_duration()
		ENEMY_ACTIVE:
			return _tuning.line_active_seconds if _telegraph_shape == TELEGRAPH_LINE else _tuning.sector_active_seconds
		ENEMY_RECOVERY:
			return _tuning.line_recovery_seconds if _telegraph_shape == TELEGRAPH_LINE else _tuning.sector_recovery_seconds
	return 0.0


func _telegraph_duration() -> float:
	return _tuning.line_telegraph_seconds if _telegraph_shape == TELEGRAPH_LINE else _tuning.sector_telegraph_seconds


func _telegraph_snapshot() -> Dictionary:
	var duration := _telegraph_duration() if not _telegraph_shape.is_empty() else 0.0
	var progress := 0.0
	if _enemy_state == ENEMY_TELEGRAPH and duration > 0.0:
		progress = clampf(_enemy_state_elapsed_seconds / duration, 0.0, 1.0)
	elif _enemy_state == ENEMY_ACTIVE or _enemy_state == ENEMY_RECOVERY:
		progress = 1.0
	return {
		"id": _enemy_attack_id,
		"shape": _telegraph_shape,
		"duration": duration,
		"progress": progress,
		"active": _enemy_state == ENEMY_TELEGRAPH,
		"origin": boss_position(),
		"direction": _telegraph_direction,
		"range": (
			_tuning.line_range
			if _telegraph_shape == TELEGRAPH_LINE
			else (_tuning.sector_range if _telegraph_shape == TELEGRAPH_SECTOR else 0.0)
		),
		"half_width": _tuning.line_half_width if _telegraph_shape == TELEGRAPH_LINE else 0.0,
		"half_angle": (
			deg_to_rad(_tuning.sector_half_angle_degrees)
			if _telegraph_shape == TELEGRAPH_SECTOR
			else 0.0
		),
	}


func _enemy_attack_contains(player_position: Vector2) -> bool:
	var offset := player_position - boss_position()
	if _telegraph_shape == TELEGRAPH_LINE:
		var along := offset.dot(_telegraph_direction)
		var lateral := absf(offset.dot(_telegraph_direction.orthogonal()))
		return along >= 0.0 and along <= _tuning.line_range and lateral <= _tuning.line_half_width
	if _telegraph_shape == TELEGRAPH_SECTOR:
		var distance := offset.length()
		if distance > _tuning.sector_range:
			return false
		if distance <= _TIME_EPSILON:
			return true
		var minimum_dot := cos(deg_to_rad(_tuning.sector_half_angle_degrees))
		return _telegraph_direction.dot(offset / distance) >= minimum_dot
	return false


func _emit_event(event_name: StringName, payload: Dictionary) -> void:
	gameplay_event.emit(event_name, _deep_read_only(payload))


func _deep_read_only(value: Variant) -> Variant:
	if value is Dictionary:
		var dictionary: Dictionary = value.duplicate(true)
		for key in dictionary.keys():
			dictionary[key] = _deep_read_only(dictionary[key])
		dictionary.make_read_only()
		return dictionary
	if value is Array:
		var array: Array = value.duplicate(true)
		for index in range(array.size()):
			array[index] = _deep_read_only(array[index])
		array.make_read_only()
		return array
	return value
