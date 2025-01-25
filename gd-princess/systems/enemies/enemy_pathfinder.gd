extends CharacterMovementInputProvider

@export_category("Links")
@export var me: Enemy;
@export var navagent: NavigationAgent3D;

# State
var move_dir: Vector2 = Vector2(0, 0);

func calculate(delta: float) -> void:
	move_dir = Vector2(0.0, 0.0);
	
	if not GameState.shouldRunPhysics():
		return;
	
	if me.moving:
		navagent.target_position = me.move_to_target;
		
		if navagent.is_navigation_finished():
			print("navigation done!");
			me.moving = false;
			me.on_arrived_at_location.emit();
			return;
		
		var next_position = navagent.get_next_path_position();
		
		var diff = (next_position - me.position);
		move_dir = Vector2(diff.x, diff.z).normalized();

# Get movement input in rotation space
func get_move_direction() -> Vector2:
	return move_dir;

# Which direction do we want to face?
func get_target_forward_angle() -> float:
	if me.moving and GameState.shouldRunPhysics():
		return forward_dir_to_angle(move_dir);
	else:
		return me.rotation.y;

# Do we want to jump?
func wants_to_jump() -> bool:
	return false;
