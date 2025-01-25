extends CineAction

@export var cinematic_name: String;

func play() -> void:
	# Play cinematic on the player
	GameState.player.play_cinematic(cinematic_name);
