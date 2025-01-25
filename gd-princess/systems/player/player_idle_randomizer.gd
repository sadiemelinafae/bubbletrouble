class_name PlayerIdleAnimation
extends Node

@export var me: Player;

@export var min_time_between: float = 0.3;
@export var max_time_between: float = 14;

@export var possible_anims: Array[IdleEntry];

@export var vary_time_scale_node: String;
@export var time_scale_min: float = 1.0;
@export var time_scale_max: float = 2.0;

var rng = RandomNumberGenerator.new()

# Whether this idling animation is active (we are allowed to play animations)
var _idling_active: bool = true;

var _time: float = 0;

# Toggle idling of the tail
func toggle(idle: bool) -> void:
	if _idling_active != idle:
		_idling_active = idle;
		if !_idling_active:
			pass
			# TODO: ABORT SUPPORT?
			#anim.idle_head_abort();

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_anim_coroutine();

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_time += delta;

func _anim_coroutine() -> void:
	var prev_anim = 0;
	while true:
		var time_between: float = rng.randf_range(min_time_between, max_time_between);
		
		_time = 0;
		while _time < time_between:
			await get_tree().process_frame;
	
		if _idling_active:
			# trigger one of the tail animations at random
			var next_anim = rng.randi_range(0,possible_anims.size()-1);
			if possible_anims.size() > 1:
				next_anim = rng.randi_range(0,possible_anims.size()-2);
				if next_anim >= prev_anim:
					next_anim += 1; # Avoid the same animation twice after each other
			prev_anim = next_anim;
			
			if vary_time_scale_node:
				var new_time_scale = rng.randf_range(time_scale_min, time_scale_max);
				me.anim_control.anim_tree.set(vary_time_scale_node, new_time_scale);
			
			var anim = possible_anims[next_anim];
			var one_shot = anim.one_shot;
			me.anim_control.anim_tree.set(one_shot, AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE);
