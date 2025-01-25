extends Node

@export_category("Links")
@export var camera_arm: Node3D;

@export_category("Settings")
@export var mouse_sensitivity = 0.0015
@export var gamepad_sensitivity = 0.05

@export var range_min: float = -90.0;
@export var range_max: float = 30.0;

func _shift_camera(shift: Vector2) -> void:
		camera_arm.rotation.x -= shift.y;
		camera_arm.rotation_degrees.x = clamp(camera_arm.rotation_degrees.x, range_min, range_max)
		camera_arm.rotation.y -= shift.x;
	

func _unhandled_input(event):
	if not GameState.shouldAcceptCharacterInput():
		return;
	
	if event is InputEventMouseMotion:
		_shift_camera(event.relative * mouse_sensitivity);

func _process(delta: float) -> void:
	if not GameState.shouldAcceptCharacterInput():
		return;
	
	# From the gamepad
	var look_input = Input.get_vector("look_left", "look_right", "look_up", "look_down");
	
	if look_input.length() > 0:
		_shift_camera(-look_input * gamepad_sensitivity);
