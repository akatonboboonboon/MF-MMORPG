class_name FSAPresentationShell
extends Node2D

const DESIGN_SIZE := Vector2(1920.0, 1080.0)
const FEEDBACK_DURATION := 0.65
const COSMETIC_FEEDBACK_OFFSET := 120.0
const REQUIRED_ROOT_FIELDS: Array[String] = [
	"loop_phase",
	"player_integrity",
	"player_integrity_max",
	"player_deformation",
	"player_position",
	"player_aim",
	"boss_hp",
	"boss_hp_max",
	"boss_position",
	"parts",
	"telegraph",
	"boss_functional",
	"wreck_active",
	"harvest_points",
	"result_visible",
	"rematch_available",
]
const FEEDBACK_BY_EVENT := {
	"ActionStarted": "attack",
	"HitConfirmed": "hit",
	"PartBroken": "part_break",
}

signal snapshot_presented(snapshot: Dictionary)
signal feedback_presented(event_name: StringName)

var _snapshot: Dictionary = {}
var _grayscale := false
var _feedback_kind := ""
var _feedback_elapsed := 0.0
var _feedback_hold := false
var _feedback_anchor := Vector2.ZERO
var _feedback_direction := Vector2.ZERO
var _preview_controls_visible := false


func _ready() -> void:
	set_process(false)


func apply_snapshot(snapshot: Dictionary) -> bool:
	var errors := snapshot_schema_errors(snapshot)
	if not errors.is_empty():
		for error in errors:
			push_warning("[MFO-FS-A-PRESENTATION] snapshot rejected: %s" % error)
		return false
	_snapshot = _deep_read_only(snapshot)
	snapshot_presented.emit(_snapshot)
	queue_redraw()
	return true


func consume_domain_event(event: Variant) -> bool:
	var event_name := _event_name_from(event)
	if not FEEDBACK_BY_EVENT.has(event_name) or _snapshot.is_empty():
		return false
	_feedback_kind = String(FEEDBACK_BY_EVENT[event_name])
	_feedback_direction = _player_aim_direction()
	match _feedback_kind:
		"attack":
			_feedback_anchor = _player_position()
		"hit":
			_feedback_anchor = _player_position() + _feedback_direction * COSMETIC_FEEDBACK_OFFSET
		"part_break":
			_feedback_anchor = _boss_position()
			_feedback_direction = Vector2.ZERO
	_feedback_elapsed = 0.0
	if not _feedback_hold:
		set_process(true)
	feedback_presented.emit(StringName(event_name))
	queue_redraw()
	return true


func set_grayscale(enabled: bool) -> void:
	_grayscale = enabled
	queue_redraw()


func is_grayscale() -> bool:
	return _grayscale


func set_feedback_hold(enabled: bool) -> void:
	_feedback_hold = enabled
	set_process(not enabled and not _feedback_kind.is_empty())


func set_preview_controls_visible(visible: bool) -> void:
	_preview_controls_visible = visible
	queue_redraw()


func get_presented_snapshot() -> Dictionary:
	return _snapshot.duplicate(true)


func get_feedback_kind() -> String:
	return _feedback_kind


func get_feedback_anchor() -> Vector2:
	return _feedback_anchor


func get_feedback_direction() -> Vector2:
	return _feedback_direction


func is_presented_snapshot_deep_read_only() -> bool:
	return not _snapshot.is_empty() and _is_deep_read_only(_snapshot)


func get_spatial_debug_geometry() -> Dictionary:
	if _snapshot.is_empty():
		return {}
	var part_positions: Array[Vector2] = []
	for part_variant in _snapshot.parts:
		var part: Dictionary = part_variant
		part_positions.append(part.position)
	var harvest_positions: Array[Vector2] = []
	for point_variant in _snapshot.harvest_points:
		var point: Dictionary = point_variant
		harvest_positions.append(point.position)
	var telegraph: Dictionary = _snapshot.telegraph
	var telegraph_geometry := (
		_line_telegraph_geometry(telegraph)
		if String(telegraph.shape) == "line"
		else _sector_telegraph_geometry(telegraph)
	)
	return _deep_read_only({
		"player_position": _player_position(),
		"player_aim": _player_aim_direction(),
		"boss_position": _boss_position(),
		"wreck_position": _boss_position(),
		"part_positions": part_positions,
		"harvest_positions": harvest_positions,
		"telegraph": telegraph_geometry,
	})


func clear_feedback() -> void:
	_feedback_kind = ""
	_feedback_elapsed = 0.0
	_feedback_anchor = Vector2.ZERO
	_feedback_direction = Vector2.ZERO
	set_process(false)
	queue_redraw()


func snapshot_schema_errors(snapshot: Dictionary) -> Array[String]:
	var errors: Array[String] = []
	for field in REQUIRED_ROOT_FIELDS:
		if not snapshot.has(field):
			errors.append("missing root field %s" % field)
	if not errors.is_empty():
		return errors
	if String(snapshot.loop_phase) not in ["combat", "wreck", "result"]:
		errors.append("invalid loop_phase")
	for field in ["player_integrity", "player_integrity_max", "player_deformation", "boss_hp", "boss_hp_max"]:
		if not _is_number(snapshot[field]):
			errors.append("%s must be numeric" % field)
	for field in ["player_position", "player_aim", "boss_position"]:
		if typeof(snapshot[field]) != TYPE_VECTOR2:
			errors.append("%s must be Vector2" % field)
	for field in ["boss_functional", "wreck_active", "result_visible", "rematch_available"]:
		if typeof(snapshot[field]) != TYPE_BOOL:
			errors.append("%s must be bool" % field)

	if typeof(snapshot.parts) != TYPE_ARRAY:
		errors.append("parts must be Array")
	else:
		var parts: Array = snapshot.parts
		if parts.size() < 1 or parts.size() > 2:
			errors.append("parts requires 1..2 entries")
		for part in parts:
			if typeof(part) != TYPE_DICTIONARY:
				errors.append("part must be Dictionary")
				continue
			for field in ["id", "hp", "broken", "position"]:
				if not part.has(field):
					errors.append("part missing %s" % field)
			if part.has("position") and typeof(part.position) != TYPE_VECTOR2:
				errors.append("part position must be Vector2")

	if typeof(snapshot.telegraph) != TYPE_DICTIONARY:
		errors.append("telegraph must be Dictionary")
	else:
		var telegraph: Dictionary = snapshot.telegraph
		for field in ["id", "shape", "duration", "progress", "active", "origin", "direction", "range", "half_width", "half_angle"]:
			if not telegraph.has(field):
				errors.append("telegraph missing %s" % field)
		if telegraph.has("shape") and String(telegraph.shape) not in ["line", "sector"]:
			errors.append("telegraph shape must be line or sector")
		for field in ["origin", "direction"]:
			if telegraph.has(field) and typeof(telegraph[field]) != TYPE_VECTOR2:
				errors.append("telegraph %s must be Vector2" % field)
		for field in ["range", "half_width", "half_angle"]:
			if telegraph.has(field) and not _is_number(telegraph[field]):
				errors.append("telegraph %s must be numeric" % field)

	if typeof(snapshot.harvest_points) != TYPE_ARRAY:
		errors.append("harvest_points must be Array")
	else:
		var harvest_points: Array = snapshot.harvest_points
		if harvest_points.size() != 3:
			errors.append("harvest_points requires exact 3 entries")
		for point in harvest_points:
			if typeof(point) != TYPE_DICTIONARY:
				errors.append("harvest point must be Dictionary")
				continue
			for field in ["id", "collected", "position"]:
				if not point.has(field):
					errors.append("harvest point missing %s" % field)
			if point.has("position") and typeof(point.position) != TYPE_VECTOR2:
				errors.append("harvest point position must be Vector2")
	return errors


func _process(delta: float) -> void:
	if _feedback_hold or _feedback_kind.is_empty():
		return
	_feedback_elapsed += delta
	if _feedback_elapsed >= FEEDBACK_DURATION:
		clear_feedback()
		return
	queue_redraw()


func _event_name_from(event: Variant) -> String:
	if event is Dictionary:
		var event_dictionary: Dictionary = event
		if event_dictionary.has("event_name"):
			return String(event_dictionary.event_name)
	elif event is Object:
		var object_event_name: Variant = event.get("event_name")
		if object_event_name != null:
			return String(object_event_name)
	return ""


static func _is_number(value: Variant) -> bool:
	return typeof(value) == TYPE_INT or typeof(value) == TYPE_FLOAT


static func _deep_read_only(value: Variant) -> Variant:
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


static func _is_deep_read_only(value: Variant) -> bool:
	if value is Dictionary:
		var dictionary: Dictionary = value
		if not dictionary.is_read_only():
			return false
		for nested_value in dictionary.values():
			if not _is_deep_read_only(nested_value):
				return false
	elif value is Array:
		var array: Array = value
		if not array.is_read_only():
			return false
		for nested_value in array:
			if not _is_deep_read_only(nested_value):
				return false
	return true


func _player_position() -> Vector2:
	var position: Vector2 = _snapshot.player_position
	return position


func _player_aim_direction() -> Vector2:
	var aim: Vector2 = _snapshot.player_aim
	return aim.normalized()


func _boss_position() -> Vector2:
	var position: Vector2 = _snapshot.boss_position
	return position


func _line_telegraph_geometry(telegraph: Dictionary) -> Dictionary:
	var origin: Vector2 = telegraph.origin
	var direction: Vector2 = telegraph.direction
	direction = direction.normalized()
	var attack_range := float(telegraph.range)
	var half_width := float(telegraph.half_width)
	var normal := Vector2(-direction.y, direction.x)
	var end := origin + direction * attack_range
	var corners: Array[Vector2] = [
		origin + normal * half_width,
		end + normal * half_width,
		end - normal * half_width,
		origin - normal * half_width,
	]
	return {
		"shape": "line",
		"origin": origin,
		"direction": direction,
		"range": attack_range,
		"half_width": half_width,
		"end": end,
		"normal": normal,
		"corners": corners,
	}


func _sector_telegraph_geometry(telegraph: Dictionary) -> Dictionary:
	var origin: Vector2 = telegraph.origin
	var direction: Vector2 = telegraph.direction
	direction = direction.normalized()
	var attack_range := float(telegraph.range)
	var half_angle := float(telegraph.half_angle)
	var center_angle := direction.angle()
	return {
		"shape": "sector",
		"origin": origin,
		"direction": direction,
		"range": attack_range,
		"half_angle": half_angle,
		"center_angle": center_angle,
		"start_angle": center_angle - half_angle,
		"end_angle": center_angle + half_angle,
	}


func _draw() -> void:
	if _snapshot.is_empty():
		return
	var viewport_size := get_viewport_rect().size
	var presentation_scale := minf(viewport_size.x / DESIGN_SIZE.x, viewport_size.y / DESIGN_SIZE.y)
	var offset := (viewport_size - DESIGN_SIZE * presentation_scale) * 0.5
	draw_set_transform(offset, 0.0, Vector2.ONE * presentation_scale)

	_draw_stage()
	_draw_telegraph()
	_draw_harvest_markers()
	_draw_enemy_proxy()
	_draw_knight_proxy()
	_draw_event_feedback()
	_draw_player_hud()
	_draw_boss_hud()
	_draw_preview_header()
	_draw_footer()
	if bool(_snapshot.result_visible):
		_draw_result_overlay()


func _draw_stage() -> void:
	draw_rect(Rect2(Vector2.ZERO, DESIGN_SIZE), _color("071018"), true)
	draw_rect(Rect2(0.0, 0.0, 1920.0, 116.0), _color("0b1722"), true)
	for x in range(0, 1921, 80):
		var alpha := 0.18 if x % 320 == 0 else 0.07
		draw_line(Vector2(x, 116.0), Vector2(x, 1012.0), _color("79a9ba", alpha), 1.0)
	for y in range(116, 1013, 80):
		var alpha := 0.18 if (y - 116) % 320 == 0 else 0.07
		draw_line(Vector2(0.0, y), Vector2(1920.0, y), _color("79a9ba", alpha), 1.0)

	var arena := Rect2(68.0, 150.0, 1784.0, 830.0)
	draw_rect(arena, _color("132838", 0.72), true)
	draw_rect(arena, _color("78bed0", 0.55), false, 3.0)
	draw_line(Vector2(68.0, 790.0), Vector2(1852.0, 790.0), _color("78bed0", 0.20), 2.0)
	for x in range(132, 1852, 160):
		draw_line(Vector2(x, 790.0), Vector2(x - 42.0, 980.0), _color("78bed0", 0.11), 2.0)

	_text("READ-ONLY SNAPSHOT PRESENTATION", Vector2(84.0, 304.0), 24, _color("9ac7d5"))
	_text("NO GAMEPLAY AUTHORITY", Vector2(84.0, 334.0), 24, _color("f2c879"))


func _draw_telegraph() -> void:
	var telegraph: Dictionary = _snapshot.telegraph
	if not bool(telegraph.active):
		return
	if String(telegraph.shape) == "line":
		_draw_line_telegraph(telegraph)
	else:
		_draw_sector_telegraph(telegraph)


func _draw_line_telegraph(telegraph: Dictionary) -> void:
	var geometry := _line_telegraph_geometry(telegraph)
	var origin: Vector2 = geometry.origin
	var target: Vector2 = geometry.end
	var normal: Vector2 = geometry.normal
	var polygon := PackedVector2Array(geometry.corners)
	draw_colored_polygon(polygon, _color("d45d4c", 0.24))
	draw_polyline(
		PackedVector2Array([polygon[0], polygon[1], polygon[2], polygon[3], polygon[0]]),
		_color("ffb056", 0.95),
		5.0,
		true
	)
	for index in range(1, 8):
		var center := origin.lerp(target, float(index) / 8.0)
		var wing := 30.0 if index % 2 == 0 else 18.0
		draw_line(center - normal * wing, center + normal * wing, _color("fff1c1", 0.70), 3.0)
	var label_position := Vector2(700.0, 420.0)
	_draw_tag(label_position, "LINE ATTACK  //  PARALLEL RAILS", _color("ffb056"))
	_draw_telegraph_progress(Vector2(680.0, 744.0), telegraph)


func _draw_sector_telegraph(telegraph: Dictionary) -> void:
	var geometry := _sector_telegraph_geometry(telegraph)
	var origin: Vector2 = geometry.origin
	var radius: float = geometry.range
	var center_angle: float = geometry.center_angle
	var half_angle: float = geometry.half_angle
	var points := PackedVector2Array([origin])
	for index in range(33):
		var angle := lerpf(center_angle - half_angle, center_angle + half_angle, float(index) / 32.0)
		points.append(origin + Vector2.from_angle(angle) * radius)
	draw_colored_polygon(points, _color("d45d4c", 0.20))
	draw_arc(origin, radius, center_angle - half_angle, center_angle + half_angle, 32, _color("ffb056"), 6.0, true)
	for angle in [center_angle - half_angle, center_angle, center_angle + half_angle]:
		draw_line(origin, origin + Vector2.from_angle(angle) * radius, _color("fff1c1", 0.76), 4.0)
	for inner_radius in [radius * 0.40, radius * 0.63, radius * 0.85]:
		draw_arc(origin, inner_radius, center_angle - half_angle, center_angle + half_angle, 28, _color("fff1c1", 0.45), 2.0, true)
	for index in range(7):
		var angle := lerpf(center_angle - half_angle * 0.82, center_angle + half_angle * 0.82, float(index) / 6.0)
		var start := origin + Vector2.from_angle(angle) * radius * 0.69
		var end := origin + Vector2.from_angle(angle) * radius * 0.83
		draw_line(start, end, _color("ffb056", 0.80), 7.0)
	_draw_tag(Vector2(620.0, 382.0), "SECTOR ATTACK  //  FAN + RADIAL RIBS", _color("ffb056"))
	_draw_telegraph_progress(Vector2(680.0, 744.0), telegraph)


func _draw_telegraph_progress(position: Vector2, telegraph: Dictionary) -> void:
	var progress := clampf(float(telegraph.progress), 0.0, 1.0)
	var rect := Rect2(position, Vector2(430.0, 18.0))
	draw_rect(rect, _color("071018", 0.92), true)
	draw_rect(Rect2(rect.position, Vector2(rect.size.x * progress, rect.size.y)), _color("ffb056"), true)
	draw_rect(rect, _color("fff1c1", 0.80), false, 2.0)
	_text(
		"TELEGRAPH  %02d%%   %.2fs" % [roundi(progress * 100.0), float(telegraph.duration)],
		position + Vector2(0.0, -10.0),
		24,
		_color("fff1c1")
	)


func _draw_event_feedback() -> void:
	if _feedback_kind.is_empty():
		return
	var alpha := 1.0 if _feedback_hold else clampf(1.0 - _feedback_elapsed / FEEDBACK_DURATION, 0.0, 1.0)
	match _feedback_kind:
		"attack":
			_draw_attack_feedback(alpha)
		"hit":
			_draw_hit_feedback(alpha)
		"part_break":
			_draw_part_break_feedback(alpha)


func _draw_attack_feedback(alpha: float) -> void:
	var origin := _feedback_anchor
	var direction := _feedback_direction
	var normal := Vector2(-direction.y, direction.x)
	var center_angle := direction.angle()
	for index in range(3):
		var radius := 138.0 + float(index) * 34.0
		draw_arc(
			origin,
			radius,
			center_angle - 0.70,
			center_angle + 0.70,
			24,
			_color("fff1c1", alpha * (1.0 - float(index) * 0.18)),
			10.0 - float(index) * 2.0,
			true
		)
	draw_line(origin + direction * 72.0 - normal * 26.0, origin + direction * 292.0 - normal * 26.0, _color("ffcf73", alpha), 9.0)
	draw_line(origin + direction * 86.0 + normal * 18.0, origin + direction * 306.0 + normal * 18.0, _color("ffffff", alpha * 0.72), 4.0)
	_draw_feedback_tag(Vector2(540.0, 326.0), "ATTACK STARTED  //  SLASH ARC", _color("ffcf73", alpha), alpha)


func _draw_hit_feedback(alpha: float) -> void:
	var center := _feedback_anchor
	draw_circle(center, 48.0, _color("ffffff", alpha * 0.22))
	draw_arc(center, 64.0, 0.0, TAU, 32, _color("fff1c1", alpha), 8.0, true)
	for index in range(12):
		var direction := Vector2.from_angle(TAU * float(index) / 12.0)
		var inner := center + direction * (72.0 if index % 2 == 0 else 58.0)
		var outer := center + direction * (132.0 if index % 2 == 0 else 104.0)
		draw_line(inner, outer, _color("ff8b62", alpha), 8.0 if index % 2 == 0 else 5.0)
	_draw_feedback_tag(Vector2(1390.0, 650.0), "HIT CONFIRMED  //  RADIAL BURST", _color("ff8b62", alpha), alpha)


func _draw_part_break_feedback(alpha: float) -> void:
	var center := _feedback_anchor
	draw_arc(center, 88.0, 0.0, TAU, 28, _color("ffffff", alpha), 7.0, true)
	for index in range(10):
		var direction := Vector2.from_angle(TAU * float(index) / 10.0)
		var tangent := Vector2(-direction.y, direction.x)
		var shard_center := center + direction * (116.0 + float(index % 2) * 22.0)
		var shard := PackedVector2Array([
			shard_center + direction * 24.0,
			shard_center - direction * 16.0 + tangent * 12.0,
			shard_center - direction * 16.0 - tangent * 12.0,
		])
		draw_colored_polygon(shard, _color("f08a62", alpha * 0.74))
		draw_polyline(PackedVector2Array([shard[0], shard[1], shard[2], shard[0]]), _color("ffffff", alpha), 3.0, true)
	draw_line(center + Vector2(-46.0, -46.0), center + Vector2(46.0, 46.0), _color("ffffff", alpha), 10.0)
	draw_line(center + Vector2(46.0, -46.0), center + Vector2(-46.0, 46.0), _color("ffffff", alpha), 10.0)
	_draw_feedback_tag(Vector2(160.0, 382.0), "PART BROKEN  //  SHARD + X", _color("f08a62", alpha), alpha)


func _draw_feedback_tag(position: Vector2, label: String, accent: Color, alpha: float) -> void:
	var rect := Rect2(position, Vector2(430.0, 56.0))
	draw_rect(rect, _color("071018", alpha * 0.92), true)
	draw_rect(rect, accent, false, 4.0)
	_text(label, rect.position + Vector2(18.0, 38.0), 24, _color("ffffff", alpha))


func _draw_knight_proxy() -> void:
	var center := _player_position()
	var aim := _player_aim_direction()
	var aim_normal := Vector2(-aim.y, aim.x)
	draw_circle(center + Vector2(0.0, 122.0), 74.0, _color("071018", 0.42))
	draw_circle(center + Vector2(0.0, -82.0), 34.0, _color("c5d4d7"))
	draw_arc(center + Vector2(0.0, -82.0), 34.0, 0.0, TAU, 32, _color("f2fbff"), 5.0)
	draw_line(center + Vector2(-25.0, -90.0), center + Vector2(25.0, -90.0), _color("5e7480"), 8.0)
	var torso := PackedVector2Array([
		center + Vector2(-42.0, -50.0),
		center + Vector2(38.0, -50.0),
		center + Vector2(58.0, 42.0),
		center + Vector2(0.0, 88.0),
		center + Vector2(-58.0, 42.0),
	])
	draw_colored_polygon(torso, _color("718997"))
	draw_polyline(PackedVector2Array([torso[0], torso[1], torso[2], torso[3], torso[4], torso[0]]), _color("e6f5f7"), 5.0, true)
	for y in [-22.0, 8.0, 38.0]:
		draw_line(center + Vector2(-38.0, y), center + Vector2(40.0, y), _color("263c49", 0.75), 5.0)

	var shield_center := center - aim_normal * 74.0 + aim * 20.0
	var shield := PackedVector2Array([
		shield_center + Vector2(-38.0, -54.0),
		shield_center + Vector2(38.0, -54.0),
		shield_center + Vector2(44.0, 18.0),
		shield_center + Vector2(0.0, 72.0),
		shield_center + Vector2(-44.0, 18.0),
	])
	draw_colored_polygon(shield, _color("2d5668"))
	draw_polyline(PackedVector2Array([shield[0], shield[1], shield[2], shield[3], shield[4], shield[0]]), _color("aee9ef"), 5.0, true)
	draw_line(shield_center + Vector2(0.0, -38.0), shield_center + Vector2(0.0, 44.0), _color("aee9ef"), 5.0)
	draw_line(shield_center + Vector2(-24.0, 2.0), shield_center + Vector2(24.0, 2.0), _color("aee9ef"), 5.0)

	var sword_start := center + aim * 46.0 + aim_normal * 22.0
	var sword_end := center + aim * 158.0 + aim_normal * 22.0
	draw_line(sword_start, sword_end, _color("e6f5f7"), 9.0)
	draw_line(sword_start + aim * 34.0 - aim_normal * 22.0, sword_start + aim * 34.0 + aim_normal * 22.0, _color("ffcf73"), 8.0)
	var aim_end := center + aim * 224.0
	draw_line(center + aim * 96.0, aim_end, _color("ffcf73", 0.72), 4.0)
	draw_line(aim_end, aim_end - aim * 26.0 + aim_normal * 15.0, _color("ffcf73"), 5.0)
	draw_line(aim_end, aim_end - aim * 26.0 - aim_normal * 15.0, _color("ffcf73"), 5.0)
	_text("KNIGHT / IRON", center + Vector2(-104.0, 138.0), 24, _color("e6f5f7"), 208.0, HORIZONTAL_ALIGNMENT_CENTER)
	_text("AUTHORITY POSITION + AIM", center + Vector2(-142.0, 170.0), 24, _color("9ac7d5"), 284.0, HORIZONTAL_ALIGNMENT_CENTER)


func _draw_enemy_proxy() -> void:
	if bool(_snapshot.wreck_active):
		_draw_wreck_proxy()
		return
	var center := _boss_position()
	draw_circle(center + Vector2(0.0, 168.0), 162.0, _color("071018", 0.42))
	var body := PackedVector2Array([
		center + Vector2(-126.0, -118.0),
		center + Vector2(118.0, -118.0),
		center + Vector2(166.0, 88.0),
		center + Vector2(84.0, 174.0),
		center + Vector2(-92.0, 174.0),
		center + Vector2(-166.0, 78.0),
	])
	draw_colored_polygon(body, _color("443f43"))
	draw_polyline(PackedVector2Array([body[0], body[1], body[2], body[3], body[4], body[5], body[0]]), _color("f08a62"), 8.0, true)
	for y in [-70.0, -12.0, 46.0, 104.0]:
		draw_line(center + Vector2(-120.0, y), center + Vector2(120.0, y), _color("221f24", 0.72), 8.0)
	draw_circle(center + Vector2(-54.0, -48.0), 13.0, _color("ffcf73"))
	draw_circle(center + Vector2(54.0, -48.0), 13.0, _color("ffcf73"))

	_text("LARGE ENEMY PROXY", center + Vector2(-175.0, 222.0), 25, _color("f7f0dc"), 350.0, HORIZONTAL_ALIGNMENT_CENTER)
	_draw_function_badge(center + Vector2(-160.0, -250.0), bool(_snapshot.boss_functional))
	var parts: Array = _snapshot.parts
	for index in range(parts.size()):
		var part: Dictionary = parts[index]
		var part_center: Vector2 = part.position
		var label_position := part_center + Vector2(-130.0, -132.0 - float(index) * 46.0)
		_draw_enemy_part(part_center, part, index, label_position)


func _draw_enemy_part(part_center: Vector2, part: Dictionary, index: int, label_position: Vector2) -> void:
	var part_color := _color("e14e50") if bool(part.broken) else _color("4fa1b5")
	draw_rect(Rect2(part_center - Vector2(50.0, 64.0), Vector2(100.0, 128.0)), _color("141c24"), true)
	draw_rect(Rect2(part_center - Vector2(44.0, 58.0), Vector2(88.0, 116.0)), part_color, true)
	draw_rect(Rect2(part_center - Vector2(50.0, 64.0), Vector2(100.0, 128.0)), _color("f7f0dc"), false, 5.0)
	if bool(part.broken):
		draw_line(part_center + Vector2(-34.0, -48.0), part_center + Vector2(36.0, 50.0), _color("f7f0dc"), 8.0)
		draw_line(part_center + Vector2(34.0, -48.0), part_center + Vector2(-36.0, 50.0), _color("f7f0dc"), 8.0)
	else:
		for y in [-32.0, 0.0, 32.0]:
			draw_line(part_center + Vector2(-30.0, y), part_center + Vector2(30.0, y), _color("dff8f7"), 5.0)
	var state_label := "BROKEN" if bool(part.broken) else "INTACT"
	_draw_tag(label_position, "PART %02d  %s" % [index + 1, state_label], part_color)


func _draw_wreck_proxy() -> void:
	var center := _boss_position()
	draw_circle(center + Vector2(0.0, 94.0), 184.0, _color("071018", 0.44))
	var wreck := PackedVector2Array([
		center + Vector2(-196.0, 42.0),
		center + Vector2(-112.0, -58.0),
		center + Vector2(36.0, -22.0),
		center + Vector2(154.0, -70.0),
		center + Vector2(204.0, 54.0),
		center + Vector2(102.0, 126.0),
		center + Vector2(-126.0, 118.0),
	])
	draw_colored_polygon(wreck, _color("393b3d"))
	draw_polyline(PackedVector2Array([wreck[0], wreck[1], wreck[2], wreck[3], wreck[4], wreck[5], wreck[6], wreck[0]]), _color("aaaca5"), 7.0, true)
	for offset in [-124.0, -62.0, 0.0, 62.0, 124.0]:
		draw_line(center + Vector2(offset - 38.0, -20.0), center + Vector2(offset + 32.0, 76.0), _color("777a78"), 6.0)
	draw_line(center + Vector2(-86.0, -84.0), center + Vector2(-8.0, 112.0), _color("e8e2d4"), 8.0)
	draw_line(center + Vector2(88.0, -92.0), center + Vector2(22.0, 118.0), _color("e8e2d4"), 8.0)
	_draw_function_badge(center + Vector2(-160.0, -250.0), false)
	_text("WRECK  //  EXACT ONE", center + Vector2(-180.0, -140.0), 25, _color("e8e2d4"), 360.0, HORIZONTAL_ALIGNMENT_CENTER)


func _draw_harvest_markers() -> void:
	if not bool(_snapshot.wreck_active) and not bool(_snapshot.result_visible):
		return
	var points: Array = _snapshot.harvest_points
	for index in range(points.size()):
		var point: Dictionary = points[index]
		var collected := bool(point.collected)
		var center: Vector2 = point.position
		var marker_color := _color("73d2a1") if collected else _color("f0c85f")
		var diamond := PackedVector2Array([
			center + Vector2(0.0, -34.0),
			center + Vector2(34.0, 0.0),
			center + Vector2(0.0, 34.0),
			center + Vector2(-34.0, 0.0),
		])
		draw_colored_polygon(diamond, _color("0b1722", 0.95))
		draw_polyline(PackedVector2Array([diamond[0], diamond[1], diamond[2], diamond[3], diamond[0]]), marker_color, 5.0, true)
		if collected:
			draw_line(center + Vector2(-16.0, 0.0), center + Vector2(-4.0, 14.0), marker_color, 6.0)
			draw_line(center + Vector2(-4.0, 14.0), center + Vector2(20.0, -16.0), marker_color, 6.0)
		else:
			draw_circle(center, 9.0, marker_color)
		_text("%d" % (index + 1), center + Vector2(-16.0, 9.0), 24, _color("f7f0dc"), 32.0, HORIZONTAL_ALIGNMENT_CENTER)
		var state_label := "COLLECTED" if collected else "AVAILABLE"
		_text("SALVAGE %s" % String.chr(65 + index), center + Vector2(-100.0, 70.0), 24, marker_color, 200.0, HORIZONTAL_ALIGNMENT_CENTER)
		_text(state_label, center + Vector2(-100.0, 98.0), 24, marker_color, 200.0, HORIZONTAL_ALIGNMENT_CENTER)


func _draw_player_hud() -> void:
	var panel := Rect2(38.0, 28.0, 540.0, 208.0)
	_draw_panel(panel, _color("4fa1b5"))
	_text("KNIGHT / IRON", panel.position + Vector2(24.0, 38.0), 27, _color("e6f5f7"))
	_draw_bar(
		Rect2(panel.position + Vector2(24.0, 90.0), Vector2(492.0, 34.0)),
		float(_snapshot.player_integrity),
		float(_snapshot.player_integrity_max),
		"INTEGRITY  //  BLOCK",
		_color("66c6d8"),
		"blocks"
	)
	_draw_scalar(
		Rect2(panel.position + Vector2(24.0, 152.0), Vector2(492.0, 34.0)),
		float(_snapshot.player_deformation),
		"DEFORMATION  //  VALUE + HATCH",
		_color("e8ad5a")
	)


func _draw_boss_hud() -> void:
	var panel := Rect2(608.0, 28.0, 1274.0, 208.0)
	_draw_panel(panel, _color("e17a5a"))
	_text("LARGE ENEMY", panel.position + Vector2(24.0, 38.0), 27, _color("f7f0dc"))
	var function_label := "FUNCTIONAL" if bool(_snapshot.boss_functional) else "FUNCTION STOP"
	_text(function_label, panel.position + Vector2(820.0, 38.0), 24, _color("73d2a1") if bool(_snapshot.boss_functional) else _color("f08a62"), 420.0, HORIZONTAL_ALIGNMENT_RIGHT)
	_draw_bar(
		Rect2(panel.position + Vector2(24.0, 90.0), Vector2(1226.0, 42.0)),
		float(_snapshot.boss_hp),
		float(_snapshot.boss_hp_max),
		"BOSS HP  //  SOLID",
		_color("e17a5a"),
		"solid"
	)
	var parts: Array = _snapshot.parts
	for index in range(parts.size()):
		var part: Dictionary = parts[index]
		var part_state := "BROKEN" if bool(part.broken) else "INTACT"
		var part_color := _color("f08a62") if bool(part.broken) else _color("66c6d8")
		_draw_tag(
			panel.position + Vector2(24.0 + float(index) * 420.0, 158.0),
			"PART %02d / %s / HP %d" % [index + 1, part_state, int(part.hp)],
			part_color
		)
	_text("PHASE  %s" % String(_snapshot.loop_phase).to_upper(), panel.position + Vector2(928.0, 184.0), 24, _color("b8c8cd"), 322.0, HORIZONTAL_ALIGNMENT_RIGHT)


func _draw_preview_header() -> void:
	var mode := "GRAYSCALE REVIEW" if _grayscale else "NORMAL REVIEW"
	_text("FS-A PLACEHOLDER SHELL", Vector2(84.0, 1042.0), 24, _color("dbeaec"))
	_text("READ-ONLY SNAPSHOT / %s" % String(_snapshot.loop_phase).to_upper(), Vector2(620.0, 1042.0), 24, _color("dbeaec"), 680.0, HORIZONTAL_ALIGNMENT_CENTER)
	_text(mode, Vector2(1450.0, 1042.0), 24, _color("f0c85f"), 386.0, HORIZONTAL_ALIGNMENT_RIGHT)


func _draw_footer() -> void:
	if not _preview_controls_visible:
		return
	_text("1 LINE  2 SECTOR  3 WRECK  4 RESULT  5 RESET  |  A ACTION  H HIT  B BREAK  |  G GRAYSCALE", Vector2(92.0, 1005.0), 24, _color("9ac7d5"), 1736.0, HORIZONTAL_ALIGNMENT_CENTER)


func _draw_result_overlay() -> void:
	draw_rect(Rect2(0.0, 116.0, 1920.0, 864.0), _color("031019", 0.68), true)
	var panel := Rect2(540.0, 318.0, 840.0, 420.0)
	_draw_panel(panel, _color("73d2a1"))
	_text("SALVAGE COMPLETE", panel.position + Vector2(48.0, 92.0), 48, _color("e8fff3"), 744.0, HORIZONTAL_ALIGNMENT_CENTER)
	_text("HARVEST  3 / 3", panel.position + Vector2(48.0, 156.0), 28, _color("73d2a1"), 744.0, HORIZONTAL_ALIGNMENT_CENTER)
	draw_line(panel.position + Vector2(106.0, 196.0), panel.position + Vector2(734.0, 196.0), _color("73d2a1", 0.60), 3.0)
	_text("RESULT VISIBLE", panel.position + Vector2(48.0, 252.0), 28, _color("f7f0dc"), 744.0, HORIZONTAL_ALIGNMENT_CENTER)
	var rematch_label := "REMATCH AVAILABLE" if bool(_snapshot.rematch_available) else "REMATCH UNAVAILABLE"
	_text(rematch_label, panel.position + Vector2(48.0, 316.0), 34, _color("f0c85f"), 744.0, HORIZONTAL_ALIGNMENT_CENTER)
	_text("preview only / authority binding pending", panel.position + Vector2(48.0, 366.0), 24, _color("9ac7d5"), 744.0, HORIZONTAL_ALIGNMENT_CENTER)


func _draw_bar(rect: Rect2, value: float, maximum: float, label: String, fill_color: Color, pattern: String) -> void:
	var ratio := clampf(value / maxf(maximum, 1.0), 0.0, 1.0)
	var fill_rect := Rect2(rect.position, Vector2(rect.size.x * ratio, rect.size.y))
	draw_rect(rect, _color("071018", 0.95), true)
	draw_rect(fill_rect, fill_color, true)
	if pattern == "blocks":
		for x in range(int(rect.position.x) + 18, int(fill_rect.end.x), 24):
			draw_line(Vector2(x, rect.position.y + 4.0), Vector2(x, rect.end.y - 4.0), _color("e8fff3", 0.55), 3.0)
	elif pattern == "hatch":
		for x in range(int(rect.position.x) - 24, int(fill_rect.end.x), 20):
			var line_start := Vector2(maxf(float(x), rect.position.x), rect.end.y - 4.0)
			var line_end := Vector2(minf(float(x) + 28.0, fill_rect.end.x), rect.position.y + 4.0)
			if line_end.x > line_start.x:
				draw_line(line_start, line_end, _color("fff1c1", 0.65), 3.0)
	draw_rect(rect, _color("e6f5f7", 0.86), false, 2.0)
	_text(label, rect.position + Vector2(8.0, -7.0), 24, _color("dbeaec"))
	_text("%d / %d" % [roundi(value), roundi(maximum)], rect.position + Vector2(0.0, 28.0), 24, _color("ffffff"), rect.size.x - 10.0, HORIZONTAL_ALIGNMENT_RIGHT)


func _draw_scalar(rect: Rect2, value: float, label: String, accent: Color) -> void:
	draw_rect(rect, _color("071018", 0.95), true)
	draw_rect(Rect2(rect.position, Vector2(8.0, rect.size.y)), accent, true)
	for x in range(int(rect.position.x) - 24, int(rect.end.x), 20):
		var line_start := Vector2(maxf(float(x), rect.position.x), rect.end.y - 4.0)
		var line_end := Vector2(minf(float(x) + 28.0, rect.end.x), rect.position.y + 4.0)
		if line_end.x > line_start.x:
			draw_line(line_start, line_end, _color("fff1c1", 0.50), 3.0)
	draw_rect(rect, accent, false, 2.0)
	_text(label, rect.position + Vector2(8.0, -7.0), 24, _color("dbeaec"))
	_text("VALUE %d" % roundi(value), rect.position + Vector2(0.0, 28.0), 24, _color("ffffff"), rect.size.x - 10.0, HORIZONTAL_ALIGNMENT_RIGHT)


func _draw_panel(rect: Rect2, accent: Color) -> void:
	draw_rect(rect, _color("0b1722", 0.96), true)
	draw_rect(Rect2(rect.position, Vector2(8.0, rect.size.y)), accent, true)
	draw_rect(rect, _color("acc8cf", 0.42), false, 2.0)


func _draw_tag(position: Vector2, label: String, accent: Color) -> void:
	var width := maxf(260.0, float(label.length()) * 12.0 + 32.0)
	var rect := Rect2(position, Vector2(width, 38.0))
	draw_rect(rect, _color("071018", 0.93), true)
	draw_rect(Rect2(rect.position, Vector2(7.0, rect.size.y)), accent, true)
	draw_rect(rect, accent, false, 2.0)
	_text(label, rect.position + Vector2(18.0, 30.0), 24, _color("f7f0dc"))


func _draw_function_badge(position: Vector2, functional: bool) -> void:
	var accent := _color("73d2a1") if functional else _color("f08a62")
	var label := "FUNCTIONAL" if functional else "FUNCTION STOP"
	var rect := Rect2(position, Vector2(320.0, 64.0))
	draw_rect(rect, _color("071018", 0.95), true)
	draw_rect(rect, accent, false, 4.0)
	if not functional:
		for x in range(int(rect.position.x) - 32, int(rect.end.x), 28):
			draw_line(Vector2(x, rect.end.y), Vector2(x + 48.0, rect.position.y), _color("f08a62", 0.36), 4.0)
	_text(label, rect.position + Vector2(18.0, 43.0), 26, accent, rect.size.x - 36.0, HORIZONTAL_ALIGNMENT_CENTER)


func _text(
	text: String,
	position: Vector2,
	font_size: int,
	color: Color,
	width: float = -1.0,
	alignment: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT
) -> void:
	draw_string(ThemeDB.fallback_font, position, text, alignment, width, font_size, color)


func _color(hex: String, alpha: float = 1.0) -> Color:
	var source := Color(hex)
	source.a = alpha
	if not _grayscale:
		return source
	var luminance := source.r * 0.2126 + source.g * 0.7152 + source.b * 0.0722
	return Color(luminance, luminance, luminance, alpha)
