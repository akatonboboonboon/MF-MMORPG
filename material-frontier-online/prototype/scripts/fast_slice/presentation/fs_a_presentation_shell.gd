class_name FSAPresentationShell
extends Node2D

const DESIGN_SIZE := Vector2(1920.0, 1080.0)
const CAPTURE_PREFIX := "--fs-a-capture="
const STATE_PREFIX := "--fs-a-state="
const GRAYSCALE_FLAG := "--fs-a-grayscale"
const SELF_CHECK_FLAG := "--fs-a-self-check"

@onready var _stub: FSAPresentationPreviewStub = $PreviewStub

var _snapshot: Dictionary = {}
var _grayscale := false
var _capture_path := ""
var _requested_state := "combat_line"
var _self_check_requested := false


func _ready() -> void:
	for raw_argument in OS.get_cmdline_user_args():
		var argument := String(raw_argument)
		if argument == GRAYSCALE_FLAG:
			_grayscale = true
		elif argument == SELF_CHECK_FLAG:
			_self_check_requested = true
		elif argument.begins_with(CAPTURE_PREFIX):
			_capture_path = argument.trim_prefix(CAPTURE_PREFIX)
		elif argument.begins_with(STATE_PREFIX):
			_requested_state = argument.trim_prefix(STATE_PREFIX)

	if DisplayServer.get_name() != "headless":
		DisplayServer.window_set_size(Vector2i(int(DESIGN_SIZE.x), int(DESIGN_SIZE.y)))
	_stub.snapshot_changed.connect(_on_snapshot_changed)
	if not _stub.set_preview_state(_requested_state):
		push_error("Unknown FS-A presentation preview state: %s" % _requested_state)
		get_tree().quit(2)
		return
	_snapshot = _stub.get_snapshot()
	queue_redraw()

	if _self_check_requested:
		call_deferred("_run_self_check_and_quit")
	elif not _capture_path.is_empty():
		call_deferred("_capture_and_quit")


func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return
	var key_event := event as InputEventKey
	if not key_event.pressed or key_event.echo:
		return
	match key_event.keycode:
		KEY_G:
			_grayscale = not _grayscale
			queue_redraw()
		KEY_SPACE, KEY_RIGHT:
			_stub.next_preview_state()
		KEY_LEFT:
			_stub.previous_preview_state()
		KEY_1:
			_stub.set_preview_state("combat_line")
		KEY_2:
			_stub.set_preview_state("combat_sector")
		KEY_3:
			_stub.set_preview_state("wreck")
		KEY_4:
			_stub.set_preview_state("result")
	get_viewport().set_input_as_handled()


func _on_snapshot_changed(snapshot: Dictionary) -> void:
	_snapshot = snapshot
	queue_redraw()


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

	_text("READ-ONLY SNAPSHOT PRESENTATION", Vector2(84.0, 184.0), 22, _color("9ac7d5"))
	_text("NO GAMEPLAY AUTHORITY", Vector2(84.0, 212.0), 18, _color("f2c879"))


func _draw_telegraph() -> void:
	var telegraph: Dictionary = _snapshot.telegraph
	if not bool(telegraph.active):
		return
	if String(telegraph.shape) == "line":
		_draw_line_telegraph(telegraph)
	else:
		_draw_sector_telegraph(telegraph)


func _draw_line_telegraph(telegraph: Dictionary) -> void:
	var origin := Vector2(1275.0, 590.0)
	var target := Vector2(420.0, 665.0)
	var direction := (target - origin).normalized()
	var normal := Vector2(-direction.y, direction.x)
	var half_width := 72.0
	var polygon := PackedVector2Array([
		origin + normal * half_width,
		target + normal * half_width,
		target - normal * half_width,
		origin - normal * half_width,
	])
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
	var label_position := origin.lerp(target, 0.45) + normal * 112.0
	_draw_tag(label_position, "LINE ATTACK  //  PARALLEL RAILS", _color("ffb056"))
	_draw_telegraph_progress(Vector2(680.0, 744.0), telegraph)


func _draw_sector_telegraph(telegraph: Dictionary) -> void:
	var origin := Vector2(1280.0, 590.0)
	var radius := 520.0
	var center_angle := PI
	var half_angle := 0.54
	var points := PackedVector2Array([origin])
	for index in range(25):
		var angle := lerpf(center_angle - half_angle, center_angle + half_angle, float(index) / 24.0)
		points.append(origin + Vector2.from_angle(angle) * radius)
	draw_colored_polygon(points, _color("d45d4c", 0.20))
	draw_arc(origin, radius, center_angle - half_angle, center_angle + half_angle, 32, _color("ffb056"), 6.0, true)
	for angle in [center_angle - half_angle, center_angle, center_angle + half_angle]:
		draw_line(origin, origin + Vector2.from_angle(angle) * radius, _color("fff1c1", 0.76), 4.0)
	for inner_radius in [210.0, 330.0, 440.0]:
		draw_arc(origin, inner_radius, center_angle - half_angle, center_angle + half_angle, 28, _color("fff1c1", 0.45), 2.0, true)
	for index in range(7):
		var angle := lerpf(center_angle - half_angle * 0.82, center_angle + half_angle * 0.82, float(index) / 6.0)
		var start := origin + Vector2.from_angle(angle) * 360.0
		var end := origin + Vector2.from_angle(angle) * 430.0
		draw_line(start, end, _color("ffb056", 0.80), 7.0)
	_draw_tag(Vector2(720.0, 382.0), "SECTOR ATTACK  //  FAN + RADIAL RIBS", _color("ffb056"))
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
		20,
		_color("fff1c1")
	)


func _draw_knight_proxy() -> void:
	var center := Vector2(430.0, 660.0)
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

	var shield_center := center + Vector2(-74.0, 20.0)
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

	draw_line(center + Vector2(55.0, 14.0), center + Vector2(112.0, -94.0), _color("e6f5f7"), 9.0)
	draw_line(center + Vector2(83.0, -42.0), center + Vector2(118.0, -20.0), _color("ffcf73"), 8.0)
	_text("KNIGHT / IRON", center + Vector2(-104.0, 138.0), 24, _color("e6f5f7"), 208.0, HORIZONTAL_ALIGNMENT_CENTER)
	_text("PLAYER PROXY", center + Vector2(-104.0, 166.0), 17, _color("9ac7d5"), 208.0, HORIZONTAL_ALIGNMENT_CENTER)


func _draw_enemy_proxy() -> void:
	if bool(_snapshot.wreck_active):
		_draw_wreck_proxy()
		return
	var center := Vector2(1330.0, 590.0)
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

	var part: Dictionary = _snapshot.parts[0]
	var part_center := center + Vector2(-166.0, -56.0)
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

	_text("LARGE ENEMY PROXY", center + Vector2(-175.0, 222.0), 25, _color("f7f0dc"), 350.0, HORIZONTAL_ALIGNMENT_CENTER)
	_draw_function_badge(Vector2(1170.0, 340.0), bool(_snapshot.boss_functional))
	var part_label := "PART 01  BROKEN" if bool(part.broken) else "PART 01  INTACT"
	_draw_tag(Vector2(1034.0, 455.0), part_label, part_color)


func _draw_wreck_proxy() -> void:
	var center := Vector2(1330.0, 690.0)
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
	_draw_function_badge(Vector2(1170.0, 362.0), false)
	_text("WRECK  //  EXACT ONE", center + Vector2(-180.0, 176.0), 25, _color("e8e2d4"), 360.0, HORIZONTAL_ALIGNMENT_CENTER)


func _draw_harvest_markers() -> void:
	var positions := [Vector2(930.0, 860.0), Vector2(1190.0, 874.0), Vector2(1480.0, 850.0)]
	var points: Array = _snapshot.harvest_points
	for index in range(points.size()):
		var point: Dictionary = points[index]
		var collected := bool(point.collected)
		var center: Vector2 = positions[index]
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
		_text("%d" % (index + 1), center + Vector2(-16.0, 8.0), 20, _color("f7f0dc"), 32.0, HORIZONTAL_ALIGNMENT_CENTER)
		var state_label := "COLLECTED" if collected else "AVAILABLE"
		_text("SALVAGE %s  %s" % [String.chr(65 + index), state_label], center + Vector2(-94.0, 66.0), 17, marker_color, 188.0, HORIZONTAL_ALIGNMENT_CENTER)


func _draw_player_hud() -> void:
	var panel := Rect2(38.0, 28.0, 540.0, 208.0)
	_draw_panel(panel, _color("4fa1b5"))
	_text("KNIGHT / IRON", panel.position + Vector2(24.0, 38.0), 27, _color("e6f5f7"))
	_text("READ-ONLY PLAYER STATE", panel.position + Vector2(24.0, 66.0), 16, _color("9ac7d5"))
	_draw_bar(
		Rect2(panel.position + Vector2(24.0, 90.0), Vector2(492.0, 34.0)),
		float(_snapshot.player_integrity),
		float(_snapshot.player_integrity_max),
		"INTEGRITY  //  BLOCK",
		_color("66c6d8"),
		"blocks"
	)
	_draw_bar(
		Rect2(panel.position + Vector2(24.0, 152.0), Vector2(492.0, 34.0)),
		float(_snapshot.player_deformation),
		100.0,
		"DEFORMATION  //  HATCH",
		_color("e8ad5a"),
		"hatch"
	)


func _draw_boss_hud() -> void:
	var panel := Rect2(608.0, 28.0, 1274.0, 208.0)
	_draw_panel(panel, _color("e17a5a"))
	_text("LARGE ENEMY", panel.position + Vector2(24.0, 38.0), 27, _color("f7f0dc"))
	var function_label := "FUNCTIONAL" if bool(_snapshot.boss_functional) else "FUNCTION STOP"
	_text(function_label, panel.position + Vector2(820.0, 38.0), 23, _color("73d2a1") if bool(_snapshot.boss_functional) else _color("f08a62"), 420.0, HORIZONTAL_ALIGNMENT_RIGHT)
	_draw_bar(
		Rect2(panel.position + Vector2(24.0, 90.0), Vector2(1226.0, 42.0)),
		float(_snapshot.boss_hp),
		float(_snapshot.boss_hp_max),
		"BOSS HP  //  SOLID",
		_color("e17a5a"),
		"solid"
	)
	var part: Dictionary = _snapshot.parts[0]
	var part_state := "BROKEN" if bool(part.broken) else "INTACT"
	var part_color := _color("f08a62") if bool(part.broken) else _color("66c6d8")
	_draw_tag(panel.position + Vector2(24.0, 158.0), "PART 01 / %s / HP %d" % [part_state, int(part.hp)], part_color)
	_text("PHASE  %s" % String(_snapshot.loop_phase).to_upper(), panel.position + Vector2(928.0, 184.0), 20, _color("b8c8cd"), 322.0, HORIZONTAL_ALIGNMENT_RIGHT)


func _draw_preview_header() -> void:
	var mode := "GRAYSCALE REVIEW" if _grayscale else "NORMAL REVIEW"
	_text("FS-A PLACEHOLDER SHELL", Vector2(84.0, 1042.0), 20, _color("dbeaec"))
	_text("SNAPSHOT %s" % _stub.get_state_id().to_upper(), Vector2(640.0, 1042.0), 20, _color("dbeaec"), 500.0, HORIZONTAL_ALIGNMENT_CENTER)
	_text(mode, Vector2(1450.0, 1042.0), 20, _color("f0c85f"), 386.0, HORIZONTAL_ALIGNMENT_RIGHT)


func _draw_footer() -> void:
	_text("1 LINE   2 SECTOR/BROKEN   3 WRECK   4 RESULT   LEFT/RIGHT OR SPACE CYCLE   G GRAYSCALE", Vector2(252.0, 1005.0), 18, _color("9ac7d5"), 1416.0, HORIZONTAL_ALIGNMENT_CENTER)


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
	_text("preview only / authority binding pending", panel.position + Vector2(48.0, 362.0), 18, _color("9ac7d5"), 744.0, HORIZONTAL_ALIGNMENT_CENTER)


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
	_text(label, rect.position + Vector2(8.0, -7.0), 16, _color("dbeaec"))
	_text("%d / %d" % [roundi(value), roundi(maximum)], rect.position + Vector2(0.0, 26.0), 20, _color("ffffff"), rect.size.x - 10.0, HORIZONTAL_ALIGNMENT_RIGHT)


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
	_text(label, rect.position + Vector2(18.0, 27.0), 18, _color("f7f0dc"))


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


func _run_self_check_and_quit() -> void:
	var errors := _stub.contract_self_check()
	if errors.is_empty():
		print("[MFO-FS-A-PRESENTATION] self_check=PASS snapshots=4 harvest_each=3")
		get_tree().quit(0)
		return
	for error in errors:
		push_error("[MFO-FS-A-PRESENTATION] %s" % error)
	get_tree().quit(3)


func _capture_and_quit() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("FS-A presentation capture requires a rendering display server")
		get_tree().quit(4)
		return
	await get_tree().process_frame
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var directory_error := DirAccess.make_dir_recursive_absolute(_capture_path.get_base_dir())
	if directory_error != OK:
		push_error("Could not create capture directory: %s" % error_string(directory_error))
		get_tree().quit(5)
		return
	var image := get_viewport().get_texture().get_image()
	var save_error := image.save_png(_capture_path)
	if save_error != OK:
		push_error("Could not save FS-A presentation capture: %s" % error_string(save_error))
		get_tree().quit(6)
		return
	print(
		"[MFO-FS-A-PRESENTATION] capture=PASS state=%s grayscale=%s size=%s path=%s"
		% [_stub.get_state_id(), str(_grayscale), str(image.get_size()), _capture_path]
	)
	get_tree().quit(0)
