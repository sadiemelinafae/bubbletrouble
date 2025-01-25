extends Node

@export_category("Links")
@export var me: Player;
@export var kick_back: CharacterKickBack;
@export var nearby_for_kick: Area3D;

@export_category("Settings")
@export var dash_velocity: float = 20;
@export var dash_duration: float = 0.3;
@export var enemy_kickback_force: float = 1;
@export var kick_force_impulse_duration: float = 0.1;

@export_category("Autocorrect")
@export var autocorrect_max_distance: float = 5.0;
@export var autocorrect_max_angle: float = 45;
@export var autocorrect_dot_factor: float = 0.7;
@export var autocorrect_prioritize_front_multiplier: float = 1.0;

var time_since_kick: float = 1000.0;

func kick() -> void:
	time_since_kick = 0;
	
	# Notify the animation and such
	me.on_kick_start.emit();
	
	# Get last known move_direction forward angle
	var angle = me.movement.get_target_forward_angle();
	
	# Make dash impulse
	var dir = Vector3(0, 0, -1.0).rotated(Vector3.UP, angle);
	
	# Correct the impulse towards the nearest enemy in that direction
	var nearby_enemies = nearby_for_kick.get_overlapping_bodies();
	var current_best_score = 10000.0;
	var current_best_enemy = null;
	for enemy in nearby_enemies:
		if enemy is Enemy:
			var posdiff = enemy.global_position - me.global_position;
			var distance = posdiff.length();
			if distance > autocorrect_max_distance:
				continue;
			
			var directional_dot = 1.0 - posdiff.normalized().dot(dir);
			var autocorrect_max_dot_diff = cos(deg_to_rad(90-autocorrect_max_angle));
			if directional_dot > autocorrect_max_dot_diff:
				continue;# behind the player
			
			# Find the best one based on score
			var score = posdiff.length() + directional_dot * autocorrect_max_distance * autocorrect_prioritize_front_multiplier;
			if score < current_best_score:
				current_best_score = score;
				current_best_enemy = enemy;
	
	if current_best_enemy != null:
		dir = current_best_enemy.global_position - me.global_position;
		dir.y = 0;
		dir = dir.normalized();
	
	# Make impulse
	var impulse = Impulse.new();
	impulse.impulse = dir * dash_velocity;
	impulse.lost_grip_duration = dash_duration;
	
	# Kickback
	kick_back.kickback(impulse, enemy_kickback_force, me);
	
	# Instantly rotate in the dash direction
	me.model.rotation.y = CharacterMovementInputProvider.forward_dir_to_angle(Vector2(dir.x, dir.z));
	
	# Set the input again to make sure we move (after kicking the enemies)
	while time_since_kick < kick_force_impulse_duration:
		await get_tree().physics_frame;
		me.set_impulse(impulse);

func _input(event: InputEvent) -> void:
	if GameState.shouldAcceptCharacterInput():
		if event.is_action_pressed("attack"):
			# Ok, start kick
			kick();

func _process(delta: float) -> void:
	if not GameState.shouldRunPhysics():
		return;
	
	time_since_kick+=delta;
