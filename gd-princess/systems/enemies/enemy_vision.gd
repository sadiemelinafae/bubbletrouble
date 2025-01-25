extends Node

@export_category("Links")
@export var me: Enemy;
@export var timer: Timer;
@export var vision_origin: Node3D;
@export var area: Area3D;
@export var ray: RayCast3D;
@export var player_head_height: float = 1.8;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.timeout.connect(on_check);

# Mark the player as seen!
func set_player_seen(player: Player) -> void:
	var first_detection = me.known_player == null;
	me.known_player = player;
	me.known_player_position = player.position;
	me.on_player_detected_frame.emit();
	if first_detection:
		me.on_player_found.emit();

func check_line_of_sight(player: Player) -> bool:
	var target = player.position+Vector3(0, player_head_height, 0);
	ray.target_position = Vector3(0, 0, -((target-vision_origin.global_position).length()+1));
	ray.look_at(target);
	ray.force_raycast_update();
	if ray.is_colliding():
		var collider = ray.get_collider();
		if collider is Player:
			return true;
	return false;

# Look for the player
func on_check() -> void:
	if me.state == Enemy.State.DEAD:
		return;
	
	if not GameState.shouldRunPhysics():
		return;
	
	var overlaps = area.get_overlapping_bodies();
	if overlaps.size() > 0:
		for overlap in overlaps:
			if overlap is Player:
				if check_line_of_sight(overlap):
					set_player_seen(overlap);
				break;
