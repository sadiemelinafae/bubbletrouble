extends CineAction

@export var anim_player: AnimationPlayer;
@export var play_anim: String;
@export var play_speed: float = 1.0

func play() -> void:
	anim_player.play(play_anim, -1, play_speed);
