extends Node

@export_category("Links")
@export var me: Enemy;

@export_category("Settings")
@export var predict_player_move: float = 1.0;
@export var memory_duration: float = 8.0;

# State
var time_since_player_detected: float = 10000;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	me.on_player_detected_frame.connect(on_player_detected);

func on_player_detected() -> void:
	time_since_player_detected = 0;

func _process(delta: float) -> void:
	if not GameState.shouldRunPhysics():
		return;
	
	time_since_player_detected += delta;
	
	if me.known_player != null and time_since_player_detected < predict_player_move:
		# Fake predict the player movement after we lost him!
		me.known_player_position = me.known_player.position;
	
	if time_since_player_detected >= memory_duration and me.known_player != null:
		print("forgot about player");
		me.known_player = null;
		me.on_player_lost.emit();
