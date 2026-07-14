class_name Phase1RuntimeGuardrailValidator
extends Node

const BREAKABLE_PART_GROUP := &"mfo_breakable_part"
const RULE_AUTHORITY_GROUP := &"mfo_rule_authority"
const TEMPERATURE_GROUP := &"mfo_temperature_simulation"
const CORROSION_GROUP := &"mfo_corrosion_simulation"

var _results: Array[Dictionary] = []
var _violations: Array[String] = []


func validate_startup(active_root: Node) -> void:
	_results.clear()
	_violations.clear()
	_validate_breakable_parts(active_root)
	_validate_visual_particles(active_root)
	_validate_low_frequency_simulation(active_root)
	print("[MFO-P1-RHL] %s" % JSON.stringify(summary()))


func summary() -> Dictionary:
	return {
		"results": _results.duplicate(true),
		"violation_count": _violations.size(),
		"violations": _violations.duplicate(),
	}


func has_violations() -> bool:
	return not _violations.is_empty()


func _validate_breakable_parts(active_root: Node) -> void:
	var parts := _nodes_in_subtree_group(active_root, BREAKABLE_PART_GROUP)
	if parts.is_empty():
		_record(&"RHL-001", "not_applicable", "Phase 1 has no breakable-part definitions")
		return
	if parts.size() > 7:
		_violate(&"RHL-001", "breakable part count %d exceeds 7" % parts.size())
	else:
		_record(&"RHL-001", "pass", "breakable part count %d is within 7" % parts.size())


func _validate_visual_particles(active_root: Node) -> void:
	var particle_nodes: Array[Node] = []
	_collect_particle_nodes(active_root, particle_nodes)
	for particle in particle_nodes:
		if particle.is_in_group(RULE_AUTHORITY_GROUP):
			_violate(&"RHL-002", "visual particle node is marked as rule authority: %s" % particle.get_path())
			return
	_record(&"RHL-002", "pass", "%d visual particle nodes; none are rule authority" % particle_nodes.size())


func _validate_low_frequency_simulation(active_root: Node) -> void:
	var scheduled := (
		_nodes_in_subtree_group(active_root, TEMPERATURE_GROUP)
		+ _nodes_in_subtree_group(active_root, CORROSION_GROUP)
	)
	if scheduled.is_empty():
		_record(&"RHL-003", "not_applicable", "Phase 1 has no temperature or corrosion simulation")
		return
	var violation_count_before := _violations.size()
	for node in scheduled:
		var rate_variant = node.get("updates_per_second")
		if rate_variant == null:
			_violate(&"RHL-003", "scheduled node lacks updates_per_second: %s" % node.get_path())
			continue
		var rate := float(rate_variant)
		if rate < 2.0 or rate > 5.0:
			_violate(&"RHL-003", "update rate %.2f is outside 2-5 Hz: %s" % [rate, node.get_path()])
	if _violations.size() == violation_count_before:
		_record(&"RHL-003", "pass", "%d scheduled nodes are within 2-5 Hz" % scheduled.size())


func _nodes_in_subtree_group(active_root: Node, group: StringName) -> Array[Node]:
	var matches: Array[Node] = []
	for node in get_tree().get_nodes_in_group(group):
		if active_root == node or active_root.is_ancestor_of(node):
			matches.append(node)
	return matches


func _collect_particle_nodes(node: Node, output: Array[Node]) -> void:
	if node is GPUParticles2D or node is CPUParticles2D:
		output.append(node)
	for child in node.get_children():
		_collect_particle_nodes(child, output)


func _record(id: StringName, status: String, detail: String) -> void:
	_results.append({"id": id, "status": status, "detail": detail})


func _violate(id: StringName, detail: String) -> void:
	_violations.append("%s: %s" % [id, detail])
	_record(id, "violation", detail)
