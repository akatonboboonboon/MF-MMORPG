class_name FsAGameplayArena
extends Node2D

signal snapshot_changed(snapshot: Dictionary)
signal gameplay_event(event_name: StringName, payload: Dictionary)

@export var tuning: FsATuning
@export var live_input_enabled: bool = true

@onready var _legacy_input: Phase1InputAdapter = %LegacyInputAdapter
@onready var _input_adapter: FsAInputAdapter = %FsAInputAdapter
@onready var _player: Phase1PlayerActor = %PlayerActor
@onready var _boss_authority: Node2D = %BossAuthority
@onready var _part_authority: Node2D = %BreakablePartAuthority
@onready var _runtime_spawns: Node2D = %RuntimeSpawns

var _loop := FsAGameplayLoop.new()
var _ready_ok: bool = false
var _wreck_node: Node2D
var _harvest_nodes: Dictionary = {}


func _ready() -> void:
	if tuning == null or not tuning.validate().is_empty():
		push_error("FS-A gameplay arena requires valid fs_provisional tuning")
		return
	if not _input_adapter.bind_legacy_adapter(_legacy_input):
		push_error("FS-A gameplay arena could not bind legacy input")
		return
	if not _input_adapter.ensure_input_map():
		push_error("FS-A gameplay arena could not ensure the existing input map")
		return
	if not _loop.configure(tuning):
		push_error("FS-A gameplay authority loop configuration failed")
		return
	_loop.gameplay_event.connect(_on_loop_gameplay_event)
	_boss_authority.global_position = tuning.boss_position
	_part_authority.global_position = tuning.boss_position + tuning.part_offset
	_player.reset_authority_state(tuning.player_start_position, tuning.player_start_aim)
	_ready_ok = true
	_sync_authority_nodes()
	_emit_snapshot()


func _physics_process(delta: float) -> void:
	if not live_input_enabled or not _ready_ok:
		return
	var input_frame := _input_adapter.capture_command(_player, get_global_mouse_position())
	if input_frame.is_empty():
		return
	var requested_action: StringName = &""
	if bool(input_frame.get("light_requested", false)):
		requested_action = FsAPlayerAction.ACTION_LIGHT
	elif bool(input_frame.get("heavy_requested", false)):
		requested_action = FsAPlayerAction.ACTION_HEAVY
	step_authority_command(
		input_frame.get("base_command") as Phase1InputCommand,
		requested_action,
		bool(input_frame.get("interact_requested", false)),
		delta
	)


func step_authority_command(
	base_command: Phase1InputCommand,
	requested_action: StringName,
	interact_requested: bool,
	delta_seconds: float
) -> Dictionary:
	var step_result := {
		"action_accepted": false,
		"harvest_collected": false,
		"rematch_reset": false,
		"player_hit": {},
		"enemy_hit": {},
	}
	if not _ready_ok or base_command == null:
		step_result.make_read_only()
		return step_result
	var before_snapshot := _loop.get_snapshot()
	if interact_requested and before_snapshot.get("loop_phase") == FsAGameplayLoop.LOOP_RESULT:
		step_result["rematch_reset"] = _perform_rematch()
		step_result.make_read_only()
		return step_result

	_input_adapter.apply_existing_motion(_player, base_command, delta_seconds)
	_loop.set_player_spatial_state(_player.global_position, _player.aim_direction)
	if not requested_action.is_empty():
		step_result["action_accepted"] = _loop.request_player_action(
			requested_action,
			_player.aim_direction
		)
	_loop.advance_authority(delta_seconds, _player.global_position, _player.aim_direction)
	step_result["player_hit"] = _loop.resolve_pending_player_hit()
	step_result["enemy_hit"] = _loop.resolve_pending_enemy_hit(_player.global_position)
	if interact_requested and _loop.get_snapshot().get("loop_phase") == FsAGameplayLoop.LOOP_WRECK:
		step_result["harvest_collected"] = _collect_nearest_harvest_point()
	_sync_authority_nodes()
	_emit_snapshot()
	step_result.make_read_only()
	return step_result


func get_snapshot() -> Dictionary:
	return _loop.get_snapshot() if _ready_ok else {}


func get_debug_counters() -> Dictionary:
	return _loop.debug_counters() if _ready_ok else {}


func get_player_actor() -> Phase1PlayerActor:
	return _player


func is_ready_for_gameplay() -> bool:
	return _ready_ok


func runtime_counts() -> Dictionary:
	var counts := {
		"boss_nodes": 1 if is_instance_valid(_boss_authority) else 0,
		"part_nodes": 1 if is_instance_valid(_part_authority) else 0,
		"wreck_nodes": 1 if is_instance_valid(_wreck_node) else 0,
		"harvest_nodes": _harvest_nodes.size(),
	}
	counts.make_read_only()
	return counts


func _perform_rematch() -> bool:
	if not _loop.request_rematch():
		return false
	_player.reset_authority_state(tuning.player_start_position, tuning.player_start_aim)
	_sync_authority_nodes()
	_emit_snapshot()
	return true


func _collect_nearest_harvest_point() -> bool:
	var nearest_id: StringName = &""
	var nearest_distance := INF
	var points: Array = _loop.get_snapshot().get("harvest_points", [])
	for point_variant in points:
		var point: Dictionary = point_variant
		if bool(point.get("collected", false)):
			continue
		var point_position: Vector2 = point.get("position", Vector2.INF)
		var distance := _player.global_position.distance_to(point_position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_id = point.get("id", &"")
	if nearest_id.is_empty():
		return false
	return _loop.collect_harvest_point(nearest_id, _player.global_position)


func _sync_authority_nodes() -> void:
	if not _ready_ok:
		return
	var snapshot := _loop.get_snapshot()
	_boss_authority.set_meta("functional", snapshot.get("boss_functional", false))
	var parts: Array = snapshot.get("parts", [])
	if not parts.is_empty():
		var part: Dictionary = parts[0]
		_part_authority.set_meta("broken", part.get("broken", false))
	if bool(snapshot.get("wreck_active", false)):
		if not is_instance_valid(_wreck_node):
			_spawn_wreck_nodes(snapshot)
		_update_harvest_node_state(snapshot)
	elif is_instance_valid(_wreck_node):
		_clear_wreck_nodes()


func _spawn_wreck_nodes(snapshot: Dictionary) -> void:
	_wreck_node = Node2D.new()
	_wreck_node.name = "WreckAuthority"
	_runtime_spawns.add_child(_wreck_node)
	_wreck_node.global_position = tuning.boss_position
	var points: Array = snapshot.get("harvest_points", [])
	for point_variant in points:
		var point: Dictionary = point_variant
		var harvest_id: StringName = point.get("id", &"")
		var harvest_node := Node2D.new()
		harvest_node.name = String(harvest_id).replace(".", "_")
		harvest_node.set_meta("harvest_id", harvest_id)
		_wreck_node.add_child(harvest_node)
		harvest_node.global_position = point.get("position", tuning.boss_position)
		_harvest_nodes[harvest_id] = harvest_node


func _update_harvest_node_state(snapshot: Dictionary) -> void:
	var points: Array = snapshot.get("harvest_points", [])
	for point_variant in points:
		var point: Dictionary = point_variant
		var harvest_id: StringName = point.get("id", &"")
		var node := _harvest_nodes.get(harvest_id) as Node2D
		if node != null:
			node.set_meta("collected", point.get("collected", false))


func _clear_wreck_nodes() -> void:
	_harvest_nodes.clear()
	if not is_instance_valid(_wreck_node):
		_wreck_node = null
		return
	_runtime_spawns.remove_child(_wreck_node)
	_wreck_node.free()
	_wreck_node = null


func _emit_snapshot() -> void:
	snapshot_changed.emit(_loop.get_snapshot())


func _on_loop_gameplay_event(event_name: StringName, payload: Dictionary) -> void:
	gameplay_event.emit(event_name, payload)
