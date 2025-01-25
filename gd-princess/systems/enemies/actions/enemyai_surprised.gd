extends Node

@export_category("Links")
@export var me: Enemy;
@export var cry_area: Area3D;

@export_category("Settings")
@export var time_surprised_wait: float = .7;

var time_since_surprised: float = 0;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not GameState.shouldRunPhysics():
		return;
	
	if me.state == Enemy.State.SURPRISED:
		me.cry = true;
		time_since_surprised += delta;
		if time_since_surprised > time_surprised_wait:
			if me.known_player != null:
				me.state = Enemy.State.MOVE_TO_ENGAGE;
	else:
		time_since_surprised = 0;
