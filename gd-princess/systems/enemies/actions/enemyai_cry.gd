extends Node

@export_category("Links")
@export var me: Enemy;
@export var cry_area: Area3D;

@export_category("Settings")
@export var time_cry_wait: float = .4;

var time_since_cry: float = 0;

func _notify_other_enemies() -> void:
	var overlapping = cry_area.get_overlapping_bodies();
	for other in overlapping:
		if other is Enemy:
			other.notify_about_player(me.known_player);

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not GameState.shouldRunPhysics():
		return;
	
	if me.cry:
		time_since_cry += delta;
		if time_since_cry > time_cry_wait:
			_notify_other_enemies();
	else:
		time_since_cry = 0;
