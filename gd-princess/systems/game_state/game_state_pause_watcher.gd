extends Node

func _ready():
	GameState.continueGame();

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if !GameState.isGamePaused():
			GameState.pauseGame();
	
	if event.is_action_pressed("gamepad_start"):
		if !GameState.isGamePaused():
			GameState.pauseGame();
		else:
			GameState.continueGame();
	
	#if event.is_action_pressed("click"):
	#	if GameState.isGamePaused():
	#		get_viewport().set_input_as_handled();
	#		GameState.continueGame();
