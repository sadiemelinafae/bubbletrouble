extends Node3D

enum State {
	RUNNING,
	CINEMATIC,
}

var state: State = State.RUNNING;
var running_cinematic: String = "";
var paused: bool = false;

var player: Player;

signal on_game_state_changed;
signal on_cinematic_ending;
signal on_cinematic_started;

func shouldAcceptCharacterInput() -> bool:
	return state == State.RUNNING and not paused;

func shouldRunPhysics() -> bool:
	return state == State.RUNNING and not paused;

func isGameplayRunning() -> bool:
	return state == State.RUNNING and not paused;

# NOTE: isGamePaused should be checked as well to pause the cinematic
func isCinematicOngoing(name: String) -> bool:
	return state == State.CINEMATIC and running_cinematic == name;

func isInMainMenu() -> bool:
	return isCinematicOngoing("main_menu");

func isGamePaused() -> bool:
	return paused;


#
# CHANGE STATE
#
func enter_cinematic(name: String) -> void:
	if state == State.CINEMATIC and name == "":
		# Stop cinematics
		state = State.RUNNING;
		running_cinematic = "";
		on_game_state_changed.emit();
		on_cinematic_ending.emit();
		return;
	
	var previous_state = state;
	if state == State.RUNNING or state == State.CINEMATIC:
		# Start (next) cinematic
		
		# Change
		state = State.CINEMATIC;
		var cine_change = running_cinematic != name;
		if cine_change:
			on_cinematic_ending.emit();
			running_cinematic = name;
		
		# Emit
		if previous_state != state:
			on_game_state_changed.emit();
		if cine_change:
			on_cinematic_started.emit();

func pauseGame() -> void:
	if isInMainMenu():
		return;
	
	if !paused:
		paused = true;
		on_game_state_changed.emit();
		

func continueGame() -> void:
	if paused:
		paused = false;
		on_game_state_changed.emit();
