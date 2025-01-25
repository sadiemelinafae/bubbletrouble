extends Node

@export var me: Enemy;
@export var animation_player: AnimationPlayer;

@export var idle_switch_min: float = 1.0;
@export var idle_switch_max: float = 3.0;
@export var idle_variations: Array[String] = [];

@export var blendtime_fast: float = 0.3;
@export var blendtime_slow: float = 1.0;

@export var animspeed_run: float = 1.0;
@export var animspeed_die: float = 2.0;

var is_dead: bool = false;
var is_running: bool = false;
var is_surprised: bool = false;
var time_since_idle_picked: float = -1000;
var time_next_idle_switch: float = 0;


var rng = RandomNumberGenerator.new();


func _pick_idle(reselect = false) -> void:
	var blendtime = blendtime_slow;
	if not reselect:
		blendtime = blendtime_fast;
	
	if not reselect:
		if me.idle_action == Enemy.IdleAction.DANCE:
			_play("Idle_Dance", blendtime);
		if me.idle_action == Enemy.IdleAction.DANCE2:
			_play("Idle_Dance_02", blendtime);
		if me.idle_action == Enemy.IdleAction.WALK:
			_play("Idle_Dance_02", blendtime);
	
	if me.idle_action == Enemy.IdleAction.NONE:
		var i = rng.randi_range(0, idle_variations.size()-1);
		_play(idle_variations[i], blendtime);
	
	time_since_idle_picked = 0;
	time_next_idle_switch = rng.randf_range(idle_switch_min, idle_switch_max);

func _ready() -> void:
	_pick_idle(false);
	
	me.on_die.connect(_on_dead);

func _on_dead() -> void:
	is_dead = true;
	_play("Die", blendtime_fast, animspeed_die);

func _process(delta: float) -> void:
	if not GameState.shouldRunPhysics():
		animation_player.process_mode = Node.PROCESS_MODE_DISABLED;
		return;
	else:
		animation_player.process_mode = Node.PROCESS_MODE_ALWAYS;
	
	time_since_idle_picked+=delta;
	
	if is_dead:
		return;
	
	if not is_running and me.moving:
		is_running = true;
		_play("Run", blendtime_fast, animspeed_run * me.move_control.move_speed);
	
	if is_running and not me.moving:
		is_running = false;
		
		# switch back to idle
		_pick_idle(false);
	
	if not is_surprised and me.state == Enemy.State.SURPRISED:
		is_surprised = true;
		_play("Act_Surprise", blendtime_fast);
	if is_surprised and me.state != Enemy.State.SURPRISED:
		is_surprised = false;
	
	
	var can_idle = not is_running and not is_surprised;
	
	# Switch up the idle animations sometimes
	if can_idle and time_since_idle_picked > time_next_idle_switch:
		_pick_idle(true);

func _play(to: String, blend: float, speed: float = 1.0) -> void:
	animation_player.play(to, blend, speed);
