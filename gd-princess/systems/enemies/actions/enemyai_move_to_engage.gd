extends Node

@export_category("Links")
@export var me: Enemy;

@export_category("Settings")
# How close do we need to be to be able to attack? (if too far, we will run closer)
@export var engage_range: float = 6.0;

func _ready() -> void:
	me.on_arrived_at_location.connect(_on_arrived_at_location);

func _on_arrived_at_location() -> void:
	# Wait, where did the player go?
	print("enter missing state");
	me.known_player = null;
	me.state == Enemy.State.PLAYER_MISSING;

# Go to the player!
func _move_to_engage() -> void:
	me.move_run_to(me.known_player_position);

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not GameState.shouldRunPhysics():
		return;
	
	if me.state == Enemy.State.MOVE_TO_ENGAGE:
		if me.known_player == null:
			# huh, where did the player go?
			me.state = Enemy.State.IDLE;
			me.move_stop();
		else:
			# go get him!
			_move_to_engage();
