class_name Phase1DomainEvent
extends RefCounted

var event_name: StringName
var command_sequence: int
var physics_tick: int
var payload: Dictionary


static func create(
	name: StringName,
	sequence: int,
	tick: int,
	data: Dictionary = {}
) -> Phase1DomainEvent:
	var event := Phase1DomainEvent.new()
	event.event_name = name
	event.command_sequence = sequence
	event.physics_tick = tick
	event.payload = data.duplicate(true)
	return event


func to_log_line() -> String:
	return "tick=%d seq=%d event=%s payload=%s" % [
		physics_tick,
		command_sequence,
		String(event_name),
		str(payload),
	]

