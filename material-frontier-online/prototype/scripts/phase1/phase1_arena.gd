class_name Phase1Arena
extends Node2D

const MEASURE_FLAG := "--phase1-measure"

@onready var input_adapter: Phase1InputAdapter = %InputAdapter
@onready var simulation: Phase1LocalAuthoritySimulation = %LocalAuthoritySimulation
@onready var player: Phase1PlayerActor = %PlayerActor
@onready var target: Phase1TargetDummy = %TargetDummy
@onready var debug_hud: Phase1DebugHud = %DebugHUD
@onready var runtime_guardrails: Phase1RuntimeGuardrailValidator = %RuntimeGuardrails

var live_input_enabled := true


func _ready() -> void:
	if MEASURE_FLAG in OS.get_cmdline_user_args():
		# Keep automated measurements deterministic. Manual input/feel is a
		# separate Gate 1 check and must not be mixed into the idle baseline.
		live_input_enabled = false
	input_adapter.ensure_input_map()
	debug_hud.bind(simulation, player, target)
	simulation.configure([player], [target])
	runtime_guardrails.validate_startup(self)
	queue_redraw()


func _physics_process(delta: float) -> void:
	if not live_input_enabled:
		return
	var command := input_adapter.capture_command(
		player.global_position,
		get_global_mouse_position(),
		player.aim_direction
	)
	simulation.step(command, delta)


func _draw() -> void:
	draw_rect(Rect2(0.0, 0.0, 1920.0, 1080.0), Color("07111d"), true)
	for x in range(0, 1921, 96):
		var alpha := 0.16 if x % 384 == 0 else 0.07
		draw_line(Vector2(x, 0.0), Vector2(x, 1080.0), Color(0.25, 0.65, 0.82, alpha), 2.0)
	for y in range(0, 1081, 96):
		var alpha := 0.16 if y % 384 == 0 else 0.07
		draw_line(Vector2(0.0, y), Vector2(1920.0, y), Color(0.25, 0.65, 0.82, alpha), 2.0)
	draw_rect(Rect2(54.0, 78.0, 1812.0, 924.0), Color(0.13, 0.46, 0.62, 0.34), false, 4.0)
	draw_rect(Rect2(1220.0, 360.0, 390.0, 360.0), Color(1.0, 0.75, 0.18, 0.035), true)
	draw_rect(Rect2(1220.0, 360.0, 390.0, 360.0), Color(1.0, 0.75, 0.18, 0.28), false, 3.0)
	for spawn in [Vector2(360, 360), Vector2(360, 720), Vector2(680, 360), Vector2(680, 720)]:
		draw_circle(spawn, 38.0, Color(0.2, 0.75, 1.0, 0.08))
		draw_arc(spawn, 38.0, 0.0, TAU, 32, Color(0.2, 0.75, 1.0, 0.3), 2.0)
