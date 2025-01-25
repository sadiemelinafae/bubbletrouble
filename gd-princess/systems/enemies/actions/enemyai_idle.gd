extends Node

@export_category("Links")
@export var me: Enemy;

func _idle_enemy_thought_process() -> void:
	if me.known_player != null:
		me.state = Enemy.State.SURPRISED;


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not GameState.shouldRunPhysics():
		return;
	
	if me.state == Enemy.State.IDLE:
		_idle_enemy_thought_process();
