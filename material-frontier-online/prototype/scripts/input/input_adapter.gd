class_name Phase1InputAdapter
extends Node

const ACTION_MOVE_LEFT := &"move_left"
const ACTION_MOVE_RIGHT := &"move_right"
const ACTION_MOVE_UP := &"move_up"
const ACTION_MOVE_DOWN := &"move_down"
const ACTION_AIM_LEFT := &"aim_left"
const ACTION_AIM_RIGHT := &"aim_right"
const ACTION_AIM_UP := &"aim_up"
const ACTION_AIM_DOWN := &"aim_down"
const ACTION_ATTACK_A := &"physical_light"
const ACTION_HEAVY := &"physical_heavy"
const ACTION_EVADE := &"evade"
const ACTION_LOCK_ON := &"lock_on"
const ACTION_INTERACT := &"interact"
const ACTION_MAGIC_MODIFIER := &"magic_modifier"
const ACTION_MAGIC_1 := &"magic_1"
const ACTION_MAGIC_2 := &"magic_2"
const ACTION_MAGIC_3 := &"magic_3"

var _sequence: int = 0
var _last_aim: Vector2 = Vector2.RIGHT
var _has_aim_sample: bool = false
var _gamepad_aim_latched: bool = false


func _input(event: InputEvent) -> void:
	var mouse_motion := event as InputEventMouseMotion
	if mouse_motion != null and mouse_motion.relative.length_squared() > 0.0:
		_gamepad_aim_latched = false


func ensure_input_map() -> void:
	_add_action(ACTION_MOVE_LEFT)
	_add_key(ACTION_MOVE_LEFT, KEY_A)
	_add_joy_motion(ACTION_MOVE_LEFT, JOY_AXIS_LEFT_X, -1.0)
	_add_action(ACTION_MOVE_RIGHT)
	_add_key(ACTION_MOVE_RIGHT, KEY_D)
	_add_joy_motion(ACTION_MOVE_RIGHT, JOY_AXIS_LEFT_X, 1.0)
	_add_action(ACTION_MOVE_UP)
	_add_key(ACTION_MOVE_UP, KEY_W)
	_add_joy_motion(ACTION_MOVE_UP, JOY_AXIS_LEFT_Y, -1.0)
	_add_action(ACTION_MOVE_DOWN)
	_add_key(ACTION_MOVE_DOWN, KEY_S)
	_add_joy_motion(ACTION_MOVE_DOWN, JOY_AXIS_LEFT_Y, 1.0)

	_add_action(ACTION_AIM_LEFT)
	_add_joy_motion(ACTION_AIM_LEFT, JOY_AXIS_RIGHT_X, -1.0)
	_add_action(ACTION_AIM_RIGHT)
	_add_joy_motion(ACTION_AIM_RIGHT, JOY_AXIS_RIGHT_X, 1.0)
	_add_action(ACTION_AIM_UP)
	_add_joy_motion(ACTION_AIM_UP, JOY_AXIS_RIGHT_Y, -1.0)
	_add_action(ACTION_AIM_DOWN)
	_add_joy_motion(ACTION_AIM_DOWN, JOY_AXIS_RIGHT_Y, 1.0)

	_add_action(ACTION_ATTACK_A)
	_add_mouse_button(ACTION_ATTACK_A, MOUSE_BUTTON_LEFT)
	_add_joy_button(ACTION_ATTACK_A, JOY_BUTTON_X)
	_add_action(ACTION_HEAVY)
	_add_mouse_button(ACTION_HEAVY, MOUSE_BUTTON_RIGHT)
	_add_joy_button(ACTION_HEAVY, JOY_BUTTON_Y)
	_add_action(ACTION_EVADE)
	_add_key(ACTION_EVADE, KEY_SPACE)
	_add_joy_button(ACTION_EVADE, JOY_BUTTON_A)
	_add_action(ACTION_LOCK_ON)
	_add_key(ACTION_LOCK_ON, KEY_Q)
	_add_joy_button(ACTION_LOCK_ON, JOY_BUTTON_LEFT_SHOULDER)
	_add_action(ACTION_INTERACT)
	_add_key(ACTION_INTERACT, KEY_E)
	_add_joy_button(ACTION_INTERACT, JOY_BUTTON_RIGHT_SHOULDER)
	_add_action(ACTION_MAGIC_MODIFIER)
	_add_joy_motion(ACTION_MAGIC_MODIFIER, JOY_AXIS_TRIGGER_LEFT, 1.0)
	_add_action(ACTION_MAGIC_1)
	_add_key(ACTION_MAGIC_1, KEY_1)
	_add_joy_button(ACTION_MAGIC_1, JOY_BUTTON_X)
	_add_action(ACTION_MAGIC_2)
	_add_key(ACTION_MAGIC_2, KEY_2)
	_add_joy_button(ACTION_MAGIC_2, JOY_BUTTON_Y)
	_add_action(ACTION_MAGIC_3)
	_add_key(ACTION_MAGIC_3, KEY_3)
	_add_joy_button(ACTION_MAGIC_3, JOY_BUTTON_B)


func capture_command(
	actor_origin: Vector2,
	mouse_world_position: Vector2,
	fallback_aim: Vector2
) -> Phase1InputCommand:
	_sequence += 1
	var move := Input.get_vector(
		ACTION_MOVE_LEFT,
		ACTION_MOVE_RIGHT,
		ACTION_MOVE_UP,
		ACTION_MOVE_DOWN
	)
	var stick_aim := Input.get_vector(
		ACTION_AIM_LEFT,
		ACTION_AIM_RIGHT,
		ACTION_AIM_UP,
		ACTION_AIM_DOWN
	)
	if not _has_aim_sample:
		if fallback_aim.length_squared() > 0.0001:
			_last_aim = fallback_aim.normalized()
		_has_aim_sample = true
	if stick_aim.length() >= 0.35:
		_last_aim = stick_aim.normalized()
		_gamepad_aim_latched = true
	elif not _gamepad_aim_latched:
		var mouse_delta := mouse_world_position - actor_origin
		if mouse_delta.length_squared() > 16.0:
			_last_aim = mouse_delta.normalized()
	var magic_modifier_held := Input.is_action_pressed(ACTION_MAGIC_MODIFIER)
	var request_attack_a := Input.is_action_just_pressed(ACTION_ATTACK_A) and not magic_modifier_held
	return Phase1InputCommand.create(
		_sequence,
		Engine.get_physics_frames(),
		move,
		_last_aim,
		request_attack_a
	)


func _add_action(action: StringName, deadzone: float = 0.25) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action, deadzone)


func _add_key(action: StringName, keycode: int) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = keycode
	_add_unique_event(action, event)


func _add_mouse_button(action: StringName, button_index: int) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = button_index
	_add_unique_event(action, event)


func _add_joy_button(action: StringName, button_index: int) -> void:
	var event := InputEventJoypadButton.new()
	event.button_index = button_index
	_add_unique_event(action, event)


func _add_joy_motion(action: StringName, axis: int, axis_value: float) -> void:
	var event := InputEventJoypadMotion.new()
	event.axis = axis
	event.axis_value = axis_value
	_add_unique_event(action, event)


func _add_unique_event(action: StringName, event: InputEvent) -> void:
	for current in InputMap.action_get_events(action):
		if current.as_text() == event.as_text():
			return
	InputMap.action_add_event(action, event)
