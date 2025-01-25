extends CharacterBody3D

@export var forward_speed = 5.0  # Base movement speed
@export var vertical_speed = 20.0
@export var steering_rate = 1.0  # Steering sensitivity
@onready var camera = $Camera3D  # Reference to Camera3D

func _physics_process(delta: float) -> void:
	# Get the mouse position and viewport center
	var viewport = get_viewport()
	var mouse_position = viewport.get_mouse_position()
	var viewport_size = viewport.get_visible_rect().size
	var center = viewport_size / 2

	# Calculate normalized direction based on mouse position
	var viewport_direction = mouse_position - center
	var normalized_direction = 2 * viewport_direction / viewport_size
	normalized_direction.x = clamp(normalized_direction.x, -1, 1)
	normalized_direction.y = -clamp(normalized_direction.y, -1, 1)
	

	# Get camera basis vectors for movement
	var camera_forward = -camera.global_transform.basis.z.normalized()  # Forward
	var camera_right = camera.global_transform.basis.x.normalized()    # Right
	var camera_up = camera.global_transform.basis.y.normalized()       # Up (vertical movement)

	# Calculate movement direction based on mouse input
	var move_direction = (camera_forward * forward_speed) + \
						 #(camera_right * normalized_direction.x * steering_rate) + \
						 (camera_up * normalized_direction.y * vertical_speed)

	# Apply calculated velocity to player
	velocity = move_direction
	print("Vel: ", velocity, "\nCamera Forward: ",camera_forward, "\nMousedir: ", normalized_direction)
	# Move the player using move_and_slide
	move_and_slide()
	rotate_y(-normalized_direction.x * steering_rate * delta)

	# Debugging output (optional)
	print("Vel: ", velocity, "Height: ", position.y)
	
