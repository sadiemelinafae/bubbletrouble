extends Node

@export var pause_menu: Control;
@export var main_menu: Control;

var showing_pause_menu: bool = true;
var showing_main_menu: bool = true;

func _ready() -> void:
	GameState.on_game_state_changed.connect(_on_game_state_change);
	GameState.on_cinematic_started.connect(_on_game_state_change);
	_on_game_state_change();

func _on_game_state_change() -> void:
	if showing_pause_menu != GameState.isGamePaused():
		showing_pause_menu = GameState.isGamePaused()
		if showing_pause_menu:
			pause_menu.process_mode = Node.PROCESS_MODE_ALWAYS;
			pause_menu.visible = true;
		else:
			pause_menu.process_mode = Node.PROCESS_MODE_DISABLED;
			pause_menu.visible = false;
	
	if showing_main_menu != GameState.isInMainMenu():
		showing_main_menu = GameState.isInMainMenu();
		if showing_main_menu:
			main_menu.process_mode = Node.PROCESS_MODE_ALWAYS;
			main_menu.visible = true;
		else:
			main_menu.process_mode = Node.PROCESS_MODE_DISABLED;
			main_menu.visible = false;
