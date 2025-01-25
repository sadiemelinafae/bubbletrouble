class_name PlayerAnimationControl
extends Node

@export_category("Links")
@export var me: Player;

@export var anim_tree: AnimationTree;

@export var run_speed_scale_factor: float;

@export var velocity_smoothing_factor: float = 0.9;
@export var accel_tilt_amount: Vector2 = Vector2(.2, 3.0);

@export var blend_smoothing_factor: float = 0.9;
@export var backwards_multiply_factor: float = 1.0;
@export var forward_from_speed: float = .3;

@export var landing_soft_duration: float = .5;

@export var velocity_blend_curve: Curve;

@export var jump_anim_stretch_factor: float = 0.4;

var smooth_velocity: Vector2;

var smooth_blenddiff: Vector2;

var jumping_playing_since: float = 10000;
var jumping_playing: bool = false;
var in_air: bool = false;
var land_soft_playing: float = 0;

var land_velocity: float = 0;
var max_soft_land_velocity_height: float = 4;

var is_ledge_grabbing: bool = false;

var rng = RandomNumberGenerator.new();

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	me.on_kick_start.connect(_on_kick);
	me.on_jump_started_anticipation.connect(_on_jump);

func play_cinematic(name: String) -> void:
	if name == "main_menu":
		_one_shot("parameters/cine_main_menu/request");
	elif name == "balcony_intro":
		_travel("parameters/MainMenu_Anim/playback", "princess_balcony_intro");
	elif name == "balcony_put_down_book":
		_travel("parameters/MainMenu_Anim/playback", "princess_balcony_put_down_book");

func _on_kick() -> void:
	_one_shot("parameters/Kick/request");

func _on_jump() -> void:
	jumping_playing = true;
	jumping_playing_since = 0;
	_one_shot("parameters/Jump/request");
	anim_tree.set("parameters/JumpBlend/blend_amount", 1.0);

func _do_land_add() -> void:
	var max_soft_land_velocity = Math.speed_after_time(me.move_control.gravity * me.move_control.gravity_down, Math.time_for_accelerated_to_distance(me.move_control.gravity * me.move_control.gravity_down, 0, max_soft_land_velocity_height));
	var max: float = land_velocity / max_soft_land_velocity;
	if max > 2:
		max = 2;
		#print("fell from too high")
	#print(max);
	land_soft_playing = rng.randf_range(0.8 * max, 1.0 * max);
	_one_shot("parameters/Land_Small_OneShot/request");
	land_velocity = 0;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if GameState.isGamePaused():
		anim_tree.process_mode = Node.PROCESS_MODE_DISABLED;
		return;
	else:
		anim_tree.process_mode = Node.PROCESS_MODE_ALWAYS;
	
	#
	# RUNNING AND SWITCHING DIRECTION
	#
	var run_speed_factor = me.move_blend.length();
	var current_actual_velocity = Vector2(me.velocity.x, me.velocity.z)
	
	# Convert to "blend_diff"
	var velocity_diff_2D = (current_actual_velocity - smooth_velocity);
	var velocity_diff_3D_local = Vector3(velocity_diff_2D.x, 0, velocity_diff_2D.y) * me.model.transform.basis;
	var blend_diff = Vector2(velocity_diff_3D_local.x, -velocity_diff_3D_local.z) * accel_tilt_amount;
	if blend_diff.length() > 1:
		blend_diff = blend_diff / blend_diff.length();
	blend_diff = smooth_blenddiff * blend_smoothing_factor + blend_diff * (1.0-blend_smoothing_factor)
	smooth_blenddiff = blend_diff;
	if smooth_blenddiff.y < 0:
		smooth_blenddiff.y *= backwards_multiply_factor;
	smooth_blenddiff.y += forward_from_speed * run_speed_factor;
	
	# Show player walking in the right direction
	if me.move_blend.length() > 0.05:
		anim_tree.set("parameters/IsRunning/blend_amount", run_speed_factor * 1.0);
		anim_tree.set("parameters/RunSpeed/scale", run_speed_factor * run_speed_scale_factor);
		#print(blend_diff);
		anim_tree.set("parameters/RunAccel/blend_position", blend_diff);
	else:
		anim_tree.set("parameters/IsRunning/blend_amount", 0.0);
	
	
	smooth_velocity = smooth_velocity * velocity_smoothing_factor + current_actual_velocity * (1.0 - velocity_smoothing_factor)
	
	#
	# Track land velocity
	#
	if not me.is_on_floor() and me.velocity.y < -land_velocity:
		land_velocity = -me.velocity.y;
	
	#
	# JUMP / IN AIR  END
	#
	if jumping_playing:
		jumping_playing_since+=delta;
		if jumping_playing_since > 0.15:
			if me.is_on_floor():
				in_air = false;
				jumping_playing = false;
				anim_tree.set("parameters/JumpBlend/blend_amount", 0);
				_travel("parameters/JumpState/playback", "End");
				_do_land_add();
	else:
		if in_air and me.is_on_floor():
			in_air = false;
			_do_land_add();
		if not me.is_on_floor():
			in_air = true;
	
	#if in_air:
	var vertical_velocity_blend = velocity_blend_curve.sample(clamp((me.velocity.y / me.move_control.get_jump_velocity()+2.0)/4.0, 0.0, 1.0));
	#print(vertical_velocity_blend);
	anim_tree.set("parameters/JumpState/BlendTree_InAir/Vertical_Velocity_Blended/blend_amount", clamp(vertical_velocity_blend, -1, 1)*jump_anim_stretch_factor);
	
	#
	# LANDING ADD
	#
	land_soft_playing -= delta * landing_soft_duration;
	if land_soft_playing < 0.0:
		land_soft_playing = 0;
	anim_tree.set("parameters/LandingSoftAdd/add_amount", land_soft_playing);
	
	#
	# LEDGE GRABBING
	#
	if not is_ledge_grabbing and me.is_ledge_grabbing:
		is_ledge_grabbing = me.is_ledge_grabbing;
		_one_shot("parameters/LedgeGrabOneShot/request");
	
	if is_ledge_grabbing and not me.is_ledge_grabbing:
		is_ledge_grabbing = me.is_ledge_grabbing
		anim_tree.set("parameters/LedgeGrabOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT);

func _one_shot(param: String) -> void:
	anim_tree.set(param, AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE);

func _travel(param: String, to: String) -> void:
	anim_tree[param].travel(to);
