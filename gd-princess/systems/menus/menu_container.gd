class_name MenuContainer
extends Control

@export var main_menu: Control;
@export var options_menu: Control;

var options_menu_shown: bool = false;;

func goto_menu(menu_id: String):
	if menu_id == "options":
		options_menu_shown = true;
		options_menu.visible = true;
		main_menu.visible = false;

func back_to_previous_menu():
	if options_menu_shown:
		options_menu.visible = false;
		main_menu.visible = true;
		return;
	
	if GameState.isGamePaused():
		# Future: handle sub-menus and such
		GameState.continueGame();

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		back_to_previous_menu();
