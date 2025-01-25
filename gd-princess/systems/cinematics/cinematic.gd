class_name Cinematic
extends Node

@export_category("Details")
@export var cinematic_name: String;
@export var cinematic_skipable: bool = true;

@export_category("Continue")
@export var cinematic_text_and_continue: bool = true;
@export var cinematic_text_after: float = 1.0;
@export var cinematic_text: String = "";
@export var cinematic_next: String = "";

# If ANYTHING pauses the game, we pause these
@export_category("Pausable")
@export var pausables: Array[Node];

# If ANYTHING stops the cinematic, we cancel these
# Some things might keep playing after the cinematic, like an explosion or something
# Maybe even the whole cinematic...
@export_category("Cancelable")
@export var cancelable_animators: Array[AnimationPlayer];
@export var cancelable_audio: Array[AudioStreamPlayer3D];

# TODO:
# - camera control?
#   => pick prio camera
#   => but animation is handled by an animator? (or even a script if complex => script should handle pause itself?)
# - subtitles
#   => or handled by an animator? => can call a function, so fine!?
# - skip

var started: bool = false;

var step_time: float = 0;

func _ready() -> void:
	GameState.on_cinematic_started.connect(_check_cinematic_start);
	GameState.on_cinematic_ending.connect(_check_cinematic_end);

func _check_cinematic_start() -> void:
	if GameState.isCinematicOngoing(cinematic_name) and not started:
		started = true;
		
		for step in get_children():
			if step is CineStep:
				step.play(self);
				if step.duration > 0:
					step_time = 0;
					while started and step_time < step.duration:
						await get_tree().process_frame;
				else:
					await get_tree().process_frame;
				if not started:
					return;

func _check_cinematic_end() -> void:
	if GameState.isCinematicOngoing(cinematic_name) and started:
		started = false;
		for anim in cancelable_animators:
			anim.stop();
		for audio in cancelable_audio:
			audio.stop();

func _check_pause() -> void:
	if GameState.isGamePaused():
		for pausable in pausables:
			pausable.process_mode = Node.PROCESS_MODE_DISABLED;
	else:
		for pausable in pausables:
			pausable.process_mode = Node.PROCESS_MODE_ALWAYS;
	
func _process(delta: float) -> void:
	if not GameState.isGamePaused():
		step_time += delta;
	_check_cinematic_start();
	_check_pause();
