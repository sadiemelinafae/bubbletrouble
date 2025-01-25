extends Node

@export_category("Links")
@export var me: Enemy;

func _process(delta: float) -> void:
	if not GameState.shouldRunPhysics():
		return;
	
	if me.state == Enemy.State.PLAYER_MISSING:
		if me.known_player == null:
			# huh, where did the player go?
			me.state = Enemy.State.IDLE;
			me.move_stop();
		else:
			# look for him
			# TODO?
			
			# check if we see him
			if me.known_player != null:
				me.state = Enemy.State.SURPRISED;
				# Oh, we found him back!
