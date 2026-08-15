class_name FsAInputAdapter
extends Node

var _legacy_adapter: Phase1InputAdapter


func bind_legacy_adapter(adapter: Phase1InputAdapter) -> bool:
	if adapter == null:
		return false
	_legacy_adapter = adapter
	return true


func ensure_input_map() -> bool:
	if _legacy_adapter == null:
		return false
	_legacy_adapter.ensure_input_map()
	return true


func capture_command(
	player: Phase1PlayerActor,
	mouse_world_position: Vector2
) -> Dictionary:
	if _legacy_adapter == null or player == null:
		return {}
	var base_command := _legacy_adapter.capture_command(
		player.global_position,
		mouse_world_position,
		player.aim_direction
	)
	var magic_modifier_held := Input.is_action_pressed(Phase1InputAdapter.ACTION_MAGIC_MODIFIER)
	return {
		"base_command": base_command,
		"light_requested": base_command.attack_a_requested,
		"heavy_requested": (
			Input.is_action_just_pressed(Phase1InputAdapter.ACTION_HEAVY)
			and not magic_modifier_held
		),
		"interact_requested": Input.is_action_just_pressed(Phase1InputAdapter.ACTION_INTERACT),
		"retry_requested": Input.is_action_just_pressed(Phase1InputAdapter.ACTION_LOCK_ON),
	}


func apply_existing_motion(
	player: Phase1PlayerActor,
	base_command: Phase1InputCommand,
	delta: float
) -> bool:
	if player == null or base_command == null:
		return false
	if base_command.evade_requested and player.can_accept_authority_evade():
		var evade_direction := base_command.move_vector
		if evade_direction == Vector2.ZERO:
			evade_direction = base_command.aim_vector
		player.begin_authority_evade(evade_direction)
	player.apply_authority_motion(base_command.move_vector, base_command.aim_vector, delta)
	return true
