extends Node

@export var me: Player;

@export var leg_swing_intensity_curve: Curve;
@export var leg_swing_intensity_loop_length: float = 20;

@export var bird_center: Vector2;

@export var limit_curve_x: Curve;
@export var limit_curve_Y: Curve;

@export var lerp_duration: float = 0.1;

var t: float = 0;
var current_bird_ratio: Vector2 = Vector2(0, 0);

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	t+=delta;
	var anim_tree = me.anim_control.anim_tree
	
	# LEG
	var intensity = leg_swing_intensity_curve.sample(fmod(t, leg_swing_intensity_loop_length)/leg_swing_intensity_loop_length);
	anim_tree["parameters/MainMenu_Anim/princess_on_balcony/LegSwingIntensity/blend_amount"] = intensity;
	
	
	# BIRD
	var mouse_pos = get_viewport().get_mouse_position()
	var screen_size = get_viewport().get_visible_rect().size;
	var mouse_ratio = (mouse_pos - screen_size/2) / screen_size.y;
	
	var bird_ratio = bird_center - mouse_ratio;
	
	bird_ratio.x = limit_curve_x.sample(bird_ratio.x+0.5) * sign(bird_ratio.x);
	bird_ratio.y = limit_curve_Y.sample(bird_ratio.y+0.5) * sign(bird_ratio.y);
	
	current_bird_ratio = lerp(current_bird_ratio, bird_ratio, delta / lerp_duration);
	
	anim_tree["parameters/MainMenu_Anim/princess_on_balcony/BirdLookSpace/blend_position"] = current_bird_ratio;
