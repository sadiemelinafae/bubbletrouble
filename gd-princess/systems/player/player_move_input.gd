class_name PlayerMoveInput
extends CharacterMovementInputProvider

@export_category("Links")
@export var me: Player;

@export_category("Settings")
@export var dash_velocity: float = 20;
@export var dash_duration: float = 0.3;

var jump_started: bool = false;
var time_to_jump: float = 0;
var jump_now: bool = false;

var _calc_move_dir: Vector2 = Vector2(0, 0);
func calculate(delta: float) -> void:
	# Camera angle
	var camera_angle = me.camera_arm.rotation.y;
	
	# Figure out move **direction**
	var input = Input.get_vector("left", "right", "forward", "back")
	if not GameState.shouldAcceptCharacterInput():
		input = Vector2(0,0);
	var dir = Vector3(input.x, 0, input.y).rotated(Vector3.UP, camera_angle);
	_calc_move_dir = Vector2(dir.x, dir.z);
	
	
	if GameState.shouldAcceptCharacterInput() and Input.is_action_just_pressed("jump"):
		jump_started = true;
		time_to_jump = 0.1;
		me.on_jump_started_anticipation.emit();
	
	time_to_jump -= delta;
	jump_now = false;
	if jump_started and time_to_jump<0:
		jump_now = true;
		jump_started = false;

# Get movement input in rotation space
func get_move_direction() -> Vector2:
	var dir = _calc_move_dir;
	print(dir);
	return dir ;

# Which direction do we want to face?
func get_target_forward_angle() -> float:
	if not me.is_ledge_grabbing and _calc_move_dir.length() > 0:
		return forward_dir_to_angle(_calc_move_dir);
	else:
		return me.model.rotation.y;

# Do we want to jump?
func wants_to_jump() -> bool:
	return jump_now;#GameState.shouldAcceptCharacterInput() and Input.is_action_just_pressed("jump");

# Whether we are attached to something? (wall hanging)
func is_attached() -> bool:
	return me.is_ledge_grabbing;

func attached_at_position() -> Vector3:
	return me.ledge_grab_offset;
