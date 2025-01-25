class_name Player
extends Character

# The camera arm, useful to check which direction we are looking in
@export var camera_arm: Node3D;

# The movement input, useful to check where the user wants to go (even if the model didn't finish rotating yet)
@export var movement: PlayerMoveInput;

# The animation handler
@export var anim_control: PlayerAnimationControl;

# When we start a kick
signal on_kick_start;
signal on_jump_started_anticipation;

# Whether we are currently ledge grabbing
var is_ledge_grabbing: bool = false;
var ledge_grab_offset: Vector3 = Vector3(0,0,0);

func _ready() -> void:
	GameState.player = self;

func play_cinematic(name: String) -> void:
	anim_control.play_cinematic(name);
