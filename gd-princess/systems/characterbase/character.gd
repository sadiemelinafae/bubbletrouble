class_name Character
extends CharacterBody3D

# The movement control, useful for getting the move_speed variable
@export var move_control: CharacterMovement;

# The model, useful to check the orientation of the 3D model
@export var model: Node3D;

# Kick back used when something is thrown at us
@export var kickback: CharacterKickBack;

# Signals
signal on_jump;


# State
var jumping: bool = false;
var move_blend: Vector2 = Vector2(0, 0);

var next_impulse: Impulse;

func get_impulse() -> Impulse:
	return next_impulse;

func reset_impulse() -> void:
	next_impulse = null;

func set_impulse(impulse: Impulse) -> void:
	next_impulse = impulse;

func do_kick_back(impulse: Impulse, enemy_kickback_force: float, player_source: Player) -> void:
	kickback.kickback(impulse, enemy_kickback_force, player_source);
