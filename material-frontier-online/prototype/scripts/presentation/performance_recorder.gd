class_name Phase1PerformanceRecorder
extends Node

const MEASURE_FLAG := "--phase1-measure"
const EMPTY_SCENARIO_FLAG := "--phase1-empty"
const REPORT_PREFIX := "--phase1-report="
const CAPTURE_PREFIX := "--phase1-capture="
const WARMUP_FRAMES := 120
const SAMPLE_FRAMES := 600

@export_enum("arena", "empty") var scenario := "arena"

var _enabled := false
var _report_path := ""
var _capture_path := ""
var _frame_index := 0
var _capture_written := false
var _finishing := false
var _frame_times_ms: Array[float] = []
var _process_times_ms: Array[float] = []
var _physics_times_ms: Array[float] = []
var _memory_bytes: Array[float] = []


func _ready() -> void:
	for raw_argument in OS.get_cmdline_user_args():
		var argument := String(raw_argument)
		if argument == MEASURE_FLAG:
			_enabled = true
		elif argument == EMPTY_SCENARIO_FLAG:
			scenario = "empty"
		elif argument.begins_with(REPORT_PREFIX):
			_report_path = argument.trim_prefix(REPORT_PREFIX)
		elif argument.begins_with(CAPTURE_PREFIX):
			_capture_path = argument.trim_prefix(CAPTURE_PREFIX)
	if _enabled:
		print(
			"[MFO-P1-MEASURE] scenario=%s warmup=%d sample=%d"
			% [scenario, WARMUP_FRAMES, SAMPLE_FRAMES]
		)


func _process(delta: float) -> void:
	if not _enabled or _finishing:
		return
	_frame_index += 1
	if _frame_index <= WARMUP_FRAMES:
		return
	_frame_times_ms.append(delta * 1000.0)
	_process_times_ms.append(Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0)
	_physics_times_ms.append(Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS) * 1000.0)
	_memory_bytes.append(Performance.get_monitor(Performance.MEMORY_STATIC))
	if _frame_times_ms.size() >= SAMPLE_FRAMES:
		_finishing = true
		_finish_measurement()


func _finish_measurement() -> void:
	var frame_summary := _summary(_frame_times_ms)
	var report := {
		"schema": "mfo.phase1.performance.v1",
		"scenario": scenario,
		"captured_at": Time.get_datetime_string_from_system(true),
		"engine": Engine.get_version_info(),
		"platform": OS.get_name(),
		"os_version": OS.get_version(),
		"processor": OS.get_processor_name(),
		"renderer": str(ProjectSettings.get_setting("rendering/renderer/rendering_method", "unknown")),
		"video_adapter": RenderingServer.get_video_adapter_name(),
		"window_size": DisplayServer.window_get_size(),
		"refresh_rate_hz": DisplayServer.screen_get_refresh_rate(),
		"warmup_frames": WARMUP_FRAMES,
		"sample_frames": SAMPLE_FRAMES,
		"frame_ms": frame_summary,
		"fps_from_average_frame": 1000.0 / maxf(0.001, _average(_frame_times_ms)),
		"cpu_process_ms": _summary(_process_times_ms),
		"cpu_physics_ms": _summary(_physics_times_ms),
		"static_memory_bytes": _summary(_memory_bytes),
		"gpu_timing_available": false,
		"gpu_timing_note": "Godot GL Compatibility export exposes adapter identity but no portable per-frame GPU timer through Performance monitors.",
		"capture_path": "",
	}
	_publish_final_hud_metrics(float(frame_summary.p95), _frame_times_ms.size())
	if not _capture_path.is_empty():
		# The 600 measured frames are already final. Wait for the HUD's final
		# values to be drawn, then capture without adding this frame to samples.
		if DisplayServer.get_name() == "headless":
			push_warning("Phase 1 capture skipped because the display server is headless")
		else:
			await RenderingServer.frame_post_draw
			_capture_written = _write_capture(_capture_path)
		if _capture_written:
			report.capture_path = _capture_path
	var success := _write_report(_report_path, report)
	print("[MFO-P1-MEASURE] %s" % JSON.stringify(report))
	get_tree().quit(0 if success else 2)


func _publish_final_hud_metrics(frame_p95_ms: float, sample_count: int) -> void:
	for hud in get_tree().get_nodes_in_group("phase1_performance_hud"):
		if hud.has_method("set_final_measurement"):
			hud.call("set_final_measurement", frame_p95_ms, sample_count)


func _write_report(path: String, report: Dictionary) -> bool:
	if path.is_empty():
		push_error("Phase 1 report path was not provided")
		return false
	var directory_error := DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	if directory_error != OK:
		push_error("Could not create report directory: %s" % error_string(directory_error))
		return false
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("Could not open report path: %s" % error_string(FileAccess.get_open_error()))
		return false
	file.store_string(JSON.stringify(report, "\t"))
	file.close()
	return true


func _write_capture(path: String) -> bool:
	var directory_error := DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	if directory_error != OK:
		push_error("Could not create capture directory: %s" % error_string(directory_error))
		return false
	var image := get_viewport().get_texture().get_image()
	var save_error := image.save_png(path)
	if save_error != OK:
		push_error("Could not save capture: %s" % error_string(save_error))
		return false
	return true


func _summary(values: Array[float]) -> Dictionary:
	return {
		"average": _average(values),
		"p50": _percentile(values, 0.50),
		"p95": _percentile(values, 0.95),
		"p99": _percentile(values, 0.99),
		"maximum": values.max() if not values.is_empty() else 0.0,
	}


func _average(values: Array[float]) -> float:
	if values.is_empty():
		return 0.0
	var total := 0.0
	for value in values:
		total += value
	return total / float(values.size())


func _percentile(values: Array[float], percentile: float) -> float:
	if values.is_empty():
		return 0.0
	var sorted: Array[float] = values.duplicate()
	sorted.sort()
	var index := clampi(ceili(float(sorted.size()) * percentile) - 1, 0, sorted.size() - 1)
	return sorted[index]
