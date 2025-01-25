extends CineAction

@export var snap_to: Node3D;

func play() -> void:
	GameState.player.global_position = snap_to.global_position;
	GameState.player.model.rotation.y = snap_to.rotation.y + PI;
