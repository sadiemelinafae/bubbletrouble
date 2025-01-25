class_name CharacterKickBack
extends Node

@export_category("Links")
@export var me: Character;
@export var kill_zone: Area3D;

@export_category("Settings")
@export var hit_damage: int = 0;
@export var time_to_hit: float = 0.2;
@export var extend_for_air_time: bool = false;

var in_progress: bool = false;
var time_since_kick: float = 1000.0;
var enemies_hit: Dictionary = Dictionary();

func _hit_enemies(enemy_kickback_force: float, player_source: Player) -> void:
	var overlapping = kill_zone.get_overlapping_bodies();
	for overlap in overlapping:
		if overlap is Enemy:
			if overlap == me:
				continue;
			if enemies_hit.has(overlap):
				continue;
			enemies_hit[overlap] = true;
			overlap.take_hit(overlap.global_position - me.global_position, enemy_kickback_force, player_source, hit_damage);

func _rotate_kill_zone(vector: Vector3) -> void:
	kill_zone.look_at(me.global_position + vector);

# Kick back the player
func kickback(impulse: Impulse, enemy_kickback_force: float, player_source: Player) -> void:
	if in_progress:
		return;
	
	# New kick
	time_since_kick = 0;
	enemies_hit.clear();
	in_progress = true;
	
	# Apply impulse
	me.set_impulse(impulse);
	
	# Delay and kickback
	while time_since_kick < time_to_hit:
		if GameState.shouldRunPhysics():
			# orient kill_zone in move direction
			_rotate_kill_zone(impulse.impulse);
			
			# hit back the enemies
			_hit_enemies(enemy_kickback_force, player_source);
		
		# wait a frame
		await get_tree().physics_frame;
	
	while extend_for_air_time and not me.is_on_floor():
		if GameState.shouldRunPhysics():
			# orient kill_zone in move direction
			_rotate_kill_zone(me.velocity);
			
			# hit back the enemies
			_hit_enemies(enemy_kickback_force, player_source);
		
		# wait a frame
		await get_tree().physics_frame;
		
	
	in_progress = false;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if GameState.shouldRunPhysics():
		time_since_kick+=delta;
