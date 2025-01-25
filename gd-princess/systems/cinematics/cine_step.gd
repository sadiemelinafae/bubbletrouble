class_name CineStep
extends Node

@export var duration: float;

func play(cinematic: Cinematic) -> void:
	for step in get_children():
		if step is CineAction:
			step.play();
