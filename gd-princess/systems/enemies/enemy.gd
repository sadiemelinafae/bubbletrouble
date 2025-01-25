class_name Enemy
extends Character

enum State {
	# Doing nothing
	IDLE, 
	# Surprised
	SURPRISED,
	# Player spotted, go to him!
	MOVE_TO_ENGAGE, 
	# Wait, where did he go? We arrived at the location?
	PLAYER_MISSING,
	# Close to the player! Ready to attack!
	READY_TO_ATTACK, 
	
	# Dead state (playing animation)
	DEAD
}

enum IdleAction {
	NONE,
	DANCE,
	DANCE2,
	WALK
}

# Public settings
@export var idle_action: IdleAction = IdleAction.NONE;

# Signals
signal on_player_detected_frame;
signal on_player_found;
signal on_player_lost;
signal on_arrived_at_location;

signal on_hit;
signal on_die;

# State
var state: State = Enemy.State.IDLE;
var known_player: Player;
var known_player_position: Vector3;
var moving: bool = false;
var move_to_target: Vector3;

@export var hit_points: int = 1;
@export var kickback_force_impact: float = 100;

# Turn on when the enemy wants to notify other enemies of the player!
var cry: bool = false;

# Helper functions
func move_run_to(position: Vector3) -> void:
	moving = true;
	move_to_target = position;

# Helper functions
func move_stop() -> void:
	moving = false;

func notify_about_player(player: Player) -> void:
	if state == Enemy.State.IDLE or state == Enemy.State.MOVE_TO_ENGAGE:
		known_player = player;
		known_player_position = player.position;
		if state == Enemy.State.IDLE:
			on_player_found.emit();
		on_player_detected_frame.emit();

func take_hit(kickback_dir: Vector3, kickback_force: float, player: Player, hit_damage: int) -> void:
	if state == State.DEAD:
		print("Got hit while dead? Bug?");
		return;
	
	state = State.MOVE_TO_ENGAGE;#State.READY_TO_ATTACK;
	
	if state != Enemy.State.DEAD:
		hit_points -= hit_damage;
	on_hit.emit();
	
	var impulse = Impulse.new();
	impulse.lost_grip_duration = 0.1 * kickback_force;
	impulse.impulse = kickback_dir.normalized() * kickback_force * kickback_force_impact;
	print("impulse: ", impulse.impulse);
	do_kick_back(impulse, kickback_force, player);
	
	# Notify
	if player:
		notify_about_player(player);
		cry = true;
