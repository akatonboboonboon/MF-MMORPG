class_name Phase1InputCommand
extends RefCounted

var sequence: int
var physics_tick: int
var move_vector: Vector2
var aim_vector: Vector2
var attack_a_requested: bool
var evade_requested: bool
var debug_action_id: StringName
var actor_entity_id: StringName
var target_entity_id: StringName


static func create(
	command_sequence: int,
	tick: int,
	move: Vector2,
	aim: Vector2,
	request_attack_a: bool,
	actor_id: StringName = &"actor.player.local.1",
	target_id: StringName = &"",
	request_evade: bool = false
) -> Phase1InputCommand:
	var command := Phase1InputCommand.new()
	command.sequence = command_sequence
	command.physics_tick = tick
	command.move_vector = move.limit_length(1.0)
	command.aim_vector = aim.normalized() if aim.length_squared() > 0.0001 else Vector2.RIGHT
	command.attack_a_requested = request_attack_a
	command.evade_requested = request_evade
	command.debug_action_id = &"phase1.attack_a" if request_attack_a else &""
	command.actor_entity_id = actor_id
	command.target_entity_id = target_id
	return command
