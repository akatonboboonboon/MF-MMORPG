class_name Phase1DebugHud
extends CanvasLayer

var _simulation: Phase1LocalAuthoritySimulation
var _player: Phase1PlayerActor
var _target: Phase1TargetDummy
var _metrics_label: Label
var _events_label: Label
var _event_lines: Array[String] = []
var _frame_samples: Array[float] = []
var _refresh_remaining: float = 0.0
var _final_frame_p95_ms := 0.0
var _final_sample_count := 0
var _has_final_measurement := false
var _automated_measurement := false


func _ready() -> void:
	_automated_measurement = "--phase1-measure" in OS.get_cmdline_user_args()
	add_to_group("phase1_performance_hud")
	var panel := PanelContainer.new()
	panel.position = Vector2(24.0, 24.0)
	panel.custom_minimum_size = Vector2(510.0, 0.0)
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.025, 0.045, 0.065, 0.94)
	panel_style.border_color = Color(0.2, 0.65, 0.9, 0.8)
	panel_style.set_border_width_all(2)
	panel_style.set_corner_radius_all(8)
	panel_style.content_margin_left = 18.0
	panel_style.content_margin_right = 18.0
	panel_style.content_margin_top = 14.0
	panel_style.content_margin_bottom = 14.0
	panel.add_theme_stylebox_override("panel", panel_style)
	add_child(panel)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 8)
	panel.add_child(column)
	var title := Label.new()
	title.text = "MATERIAL FRONTIER ONLINE  /  PHASE 1"
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color("72d1ff"))
	column.add_child(title)
	var subtitle := Label.new()
	subtitle.text = "LOCAL AUTHORITY CALIBRATION  •  GATE 0 OPEN"
	subtitle.add_theme_font_size_override("font_size", 14)
	subtitle.add_theme_color_override("font_color", Color(0.65, 0.75, 0.82, 1.0))
	column.add_child(subtitle)
	column.add_child(HSeparator.new())
	_metrics_label = Label.new()
	_metrics_label.add_theme_font_size_override("font_size", 16)
	column.add_child(_metrics_label)
	_events_label = Label.new()
	_events_label.custom_minimum_size = Vector2(474.0, 154.0)
	_events_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_events_label.add_theme_font_size_override("font_size", 13)
	_events_label.add_theme_color_override("font_color", Color(0.8, 0.88, 0.92, 1.0))
	column.add_child(_events_label)
	column.add_child(HSeparator.new())
	var controls := Label.new()
	controls.text = "MOVE  WASD / LS     AIM  MOUSE / RS     ATTACK A  LMB / X"
	controls.add_theme_font_size_override("font_size", 13)
	controls.add_theme_color_override("font_color", Color("ffcf5a"))
	column.add_child(controls)


func bind(
	simulation: Phase1LocalAuthoritySimulation,
	player: Phase1PlayerActor,
	target: Phase1TargetDummy
) -> void:
	_simulation = simulation
	_player = player
	_target = target
	if not _simulation.domain_event_emitted.is_connected(on_domain_event):
		_simulation.domain_event_emitted.connect(on_domain_event)
	_refresh_metrics()


func on_domain_event(event: Phase1DomainEvent) -> void:
	_event_lines.push_front(event.to_log_line())
	if _event_lines.size() > 6:
		_event_lines.resize(6)
	if is_instance_valid(_events_label):
		_events_label.text = "EVENT TRACE\n" + "\n".join(_event_lines)


func set_final_measurement(frame_p95_ms: float, sample_count: int) -> void:
	_final_frame_p95_ms = frame_p95_ms
	_final_sample_count = sample_count
	_has_final_measurement = true
	_refresh_metrics()


func _process(delta: float) -> void:
	if _automated_measurement:
		# The recorder owns the 600-frame acceptance sample. Avoid periodic
		# text relayout and percentile sorting while that sample is running.
		return
	_frame_samples.append(delta * 1000.0)
	if _frame_samples.size() > 300:
		_frame_samples.pop_front()
	_refresh_remaining -= delta
	if _refresh_remaining > 0.0 or not is_instance_valid(_simulation):
		return
	_refresh_remaining = 0.2
	_refresh_metrics()


func _refresh_metrics() -> void:
	if not is_instance_valid(_simulation) or not is_instance_valid(_metrics_label):
		return
	var metrics := _simulation.metrics()
	var frame_p95_ms := _final_frame_p95_ms if _has_final_measurement else _percentile_95(_frame_samples)
	var frame_p95_label := (
		"FRAME P95 (%d)" % _final_sample_count if _has_final_measurement else "FRAME P95"
	)
	_metrics_label.text = (
		"FPS                   %6.1f\n" % Performance.get_monitor(Performance.TIME_FPS)
		+ "%-22s %6.2f ms\n" % [frame_p95_label, frame_p95_ms]
		+ "VISIBLE PLAYERS        %6d\n" % metrics.visible_players
		+ "ACTIVE HIT QUERIES     %3d / %d\n" % [metrics.active_hit_queries, metrics.hit_query_capacity]
		+ "TARGET HIT COUNT       %6d\n" % (_target.hit_count if is_instance_valid(_target) else 0)
		+ "DEFINITIONS            %6s\n" % ("OK" if metrics.definitions_ok else "ERROR")
		+ "PLAYER POSITION     %s" % (str(_player.global_position.round()) if is_instance_valid(_player) else "n/a")
	)


func _percentile_95(values: Array[float]) -> float:
	if values.is_empty():
		return 0.0
	var sorted := values.duplicate()
	sorted.sort()
	var index := clampi(ceili(float(sorted.size()) * 0.95) - 1, 0, sorted.size() - 1)
	return sorted[index]
