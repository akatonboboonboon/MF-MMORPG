class_name Phase1LocalAuthoritySimulation
extends Node

signal domain_event_emitted(event: Phase1DomainEvent)

@export var attack_definition: Phase1ActionDefinition

var _actors_by_id: Dictionary = {}
var _actor_start_states: Dictionary = {}
var _targets_by_id: Dictionary = {}
var _hit_query_pool := Phase1HitQueryPool.new()
var _configured := false
var _definition_errors := PackedStringArray()
var _last_move_was_active := false


func configure(actors: Array, targets: Array) -> void:
	_actors_by_id.clear()
	_actor_start_states.clear()
	_targets_by_id.clear()
	_definition_errors = attack_definition.validate() if attack_definition != null else PackedStringArray(["attack_definition is required"])
	for actor_variant in actors:
		var actor := actor_variant as Phase1PlayerActor
		if actor == null:
			_definition_errors.append("actor entry must be a Phase1PlayerActor")
			continue
		if actor.entity_id.is_empty():
			_definition_errors.append("actor entity_id must not be empty")
		elif _actors_by_id.has(actor.entity_id):
			_definition_errors.append("duplicate actor entity_id: %s" % actor.entity_id)
		else:
			_actors_by_id[actor.entity_id] = actor
			_actor_start_states[actor.entity_id] = {
				"position": actor.global_position,
				"aim": actor.aim_direction,
			}
	for target_variant in targets:
		var target := target_variant as Phase1TargetDummy
		if target == null:
			_definition_errors.append("target entry must be a Phase1TargetDummy")
			continue
		if target.entity_id.is_empty():
			_definition_errors.append("target entity_id must not be empty")
		elif _targets_by_id.has(target.entity_id):
			_definition_errors.append("duplicate target entity_id: %s" % target.entity_id)
		else:
			_targets_by_id[target.entity_id] = target
	if _actors_by_id.is_empty():
		_definition_errors.append("at least one actor is required")
	var capacity := attack_definition.max_concurrent_hit_queries if attack_definition != null else 1
	_hit_query_pool.configure(capacity)
	_configured = _definition_errors.is_empty()
	if not _configured:
		for error in _definition_errors:
			push_error("Phase 1 definition error: %s" % error)
	_emit_event(&"DefinitionsValidated", 0, Engine.get_physics_frames(), {
		"ok": _configured,
		"errors": Array(_definition_errors),
		"query_capacity": _hit_query_pool.capacity(),
		"actor_count": _actors_by_id.size(),
		"target_count": _targets_by_id.size(),
	})


func step(command: Phase1InputCommand, delta: float) -> void:
	if not _configured or command == null:
		return
	var actor := _actors_by_id.get(command.actor_entity_id) as Phase1PlayerActor
	if actor == null:
		_emit_event(&"CommandRejected", command.sequence, command.physics_tick, {
			"actor_entity_id": command.actor_entity_id,
			"reason": "unknown actor",
		})
		return
	if command.evade_requested and actor.can_accept_authority_evade():
		var evade_direction := command.move_vector
		if evade_direction == Vector2.ZERO:
			evade_direction = command.aim_vector
		actor.begin_authority_evade(evade_direction)
	actor.apply_authority_motion(command.move_vector, command.aim_vector, delta)
	var moving := command.move_vector.length_squared() > 0.0001
	if moving != _last_move_was_active or (moving and command.sequence % 60 == 0):
		_emit_event(&"MovementApplied", command.sequence, command.physics_tick, {
			"actor_entity_id": command.actor_entity_id,
			"moving": moving,
			"position": actor.global_position,
			"aim": actor.aim_direction,
		})
	_last_move_was_active = moving
	if command.attack_a_requested:
		_execute_provisional_attack(command, actor)


func metrics() -> Dictionary:
	return {
		"visible_players": _actors_by_id.size(),
		"active_hit_queries": _hit_query_pool.active_count(),
		"hit_query_capacity": _hit_query_pool.capacity(),
		"definitions_ok": _configured,
		"definition_error_count": _definition_errors.size(),
	}


func definitions_are_valid() -> bool:
	return _configured


func reset_actor_to_start(actor_entity_id: StringName) -> bool:
	if not _configured:
		return false
	var actor := _actors_by_id.get(actor_entity_id) as Phase1PlayerActor
	if actor == null or not _actor_start_states.has(actor_entity_id):
		return false
	var start_state: Dictionary = _actor_start_states[actor_entity_id]
	actor.reset_authority_state(
		start_state.get("position", actor.global_position),
		start_state.get("aim", actor.aim_direction)
	)
	_last_move_was_active = false
	return true


func _execute_provisional_attack(command: Phase1InputCommand, actor: Phase1PlayerActor) -> void:
	_emit_event(&"AttackRequested", command.sequence, command.physics_tick, {
		"action_id": attack_definition.action_id,
		"actor_entity_id": command.actor_entity_id,
		"requested_target_entity_id": command.target_entity_id,
	})
	var token := _hit_query_pool.try_reserve(attack_definition.action_id)
	if token == Phase1HitQueryPool.INVALID_TOKEN:
		_emit_event(&"HitQueryReservationRejected", command.sequence, command.physics_tick, {
			"action_id": attack_definition.action_id,
			"reason": "per-action concurrency limit",
		})
		return

	var shape := CircleShape2D.new()
	shape.radius = attack_definition.query_radius
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.transform = Transform2D(0.0, actor.global_position + actor.aim_direction * attack_definition.reach * 0.55)
	query.collision_mask = 2
	query.collide_with_bodies = true
	query.collide_with_areas = false
	query.exclude = [actor.get_rid()]

	var hits := 0
	var seen: Dictionary = {}
	var results := actor.get_world_2d().direct_space_state.intersect_shape(query, attack_definition.max_targets * 2)
	for result in results:
		var collider := result.get("collider") as Phase1TargetDummy
		if collider == null or seen.has(collider.get_instance_id()):
			continue
		if not command.target_entity_id.is_empty() and collider.entity_id != command.target_entity_id:
			continue
		var to_target := (collider.global_position - actor.global_position).normalized()
		if actor.aim_direction.dot(to_target) < attack_definition.minimum_aim_dot:
			continue
		seen[collider.get_instance_id()] = true
		collider.receive_provisional_hit(attack_definition.effect.debug_hit_value, command.sequence)
		hits += 1
		_emit_event(&"HitConfirmed", command.sequence, command.physics_tick, {
			"action_id": attack_definition.action_id,
			"effect_id": attack_definition.effect.effect_id,
			"target_entity_id": collider.entity_id,
			"target_instance_id": collider.get_instance_id(),
			"debug_hit_value": attack_definition.effect.debug_hit_value,
		})
		if hits >= attack_definition.max_targets:
			break

	var released := _hit_query_pool.release(token)
	_emit_event(&"AttackResolved", command.sequence, command.physics_tick, {
		"action_id": attack_definition.action_id,
		"hits": hits,
		"query_released": released,
		"active_hit_queries": _hit_query_pool.active_count(),
	})


func _emit_event(event_name: StringName, sequence: int, tick: int, payload: Dictionary) -> void:
	var event := Phase1DomainEvent.create(event_name, sequence, tick, payload)
	print("[MFO-P1] %s" % event.to_log_line())
	domain_event_emitted.emit(event)
