extends Node

@export var cinematic: String = "main_menu";

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameState.enter_cinematic(cinematic);
