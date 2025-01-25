extends CineAction

@export var use_camera: PhantomCamera3D;

func play() -> void:
	use_camera.priority = 100;
