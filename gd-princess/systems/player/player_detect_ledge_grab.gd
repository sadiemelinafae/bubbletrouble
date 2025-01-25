extends Node

@export var me: Player;
@export var ray_up: ShapeCast3D;
@export var ray_front_left: ShapeCast3D;
@export var ray_front_right: ShapeCast3D;
@export var hand_rays_parent: Node3D;
@export var ray_hand_left: ShapeCast3D;
@export var ray_hand_right: ShapeCast3D;

@export var max_hand_height_diff: float = 0.1;
@export var max_floor_angle_diff: float = 20;
@export var max_front_angle_diff: float = 35;
@export var max_front_angle_between_rays_diff: float = 60;
@export var hang_distance: float = 0.8;
@export var max_body_and_arm_length: float = 2.0;

var time_since_ledge_disconnect: float = 10;
@export var min_time_between_reconnect: float = .1;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ray_up.add_exception(me);
	ray_front_left.add_exception(me);
	ray_front_right.add_exception(me);
	ray_hand_left.add_exception(me);
	ray_hand_right.add_exception(me);
	
	me.on_jump.connect(_disconnect_ledge_grab);

func _disconnect_ledge_grab() -> void:
	me.is_ledge_grabbing = false;
	me.ledge_grab_offset = Vector3(0,0,0);
	time_since_ledge_disconnect = 0;

func _check_can_grab_ledge() -> bool:
	# 1. check if we are not on a floor
	if me.is_on_floor():
		return false;
		
	# check that we are falling downwards
	if me.velocity.y > 0:
		return false;
	
	# 2. check if there is no roof (first ray does not hit)
	#ray_up.force_shapecast_update();# first time we access the up ray this frame
	if ray_up.is_colliding():
		return false;
	
	# 3. check if there is a wall in front on a limited distance (second ray hits)
	#    -> can we check if the side which hits is the forward side of the spere (normal itself doesn't matter?)
	#ray_front_left.force_shapecast_update();
	if not ray_front_left.is_colliding():
		return false;
	
	#ray_front_right.force_shapecast_update();
	if not ray_front_right.is_colliding():
		return false;
		
	# x. check if the ray front is not hitting the roof
	var max_angle_front_to_dot = cos(deg_to_rad(90-max_front_angle_diff));
	if abs(ray_front_left.get_collision_normal(0).dot(Vector3(0,1,0))) > max_angle_front_to_dot:
		return false;
	if abs(ray_front_right.get_collision_normal(0).dot(Vector3(0,1,0))) > max_angle_front_to_dot:
		return false;
	
	# x. check if the rays on the front have somewhat the same normal
	var max_front_angle_between_rays_to_dot = cos(deg_to_rad(max_front_angle_between_rays_diff));
	if ray_front_left.get_collision_normal(0).dot(ray_front_right.get_collision_normal(0)) < max_front_angle_between_rays_to_dot:
		pass
	
	# x. rotate the hand rays to face the wall
	hand_rays_parent.global_rotation.y = _calculate_front_facing_rotation_angle();
	
	# 4. check if both hand colliders hit
	ray_hand_left.force_shapecast_update();
	ray_hand_right.force_shapecast_update();
	if not ray_hand_left.is_colliding():
		return false;
	if not ray_hand_right.is_colliding():
		return false;
		
	# x. check if the ledged is part of the same collider! (or is a static body, then we don't care)
	var collider_front_left = ray_front_left.get_collider(0);
	var collider_front_right = ray_front_right.get_collider(0);
	var collider_hand_left = ray_hand_left.get_collider(0);
	var collider_hand_right = ray_hand_right.get_collider(0);
	var is_static = collider_front_left is StaticBody3D;
	
	if not is_static == (collider_front_right is StaticBody3D):
		return false;
	if not is_static == (collider_hand_left is StaticBody3D):
		return false;
	if not is_static == (collider_hand_right is StaticBody3D):
		return false;
	
	if not is_static:
		# Hanging of something which can move...
		# Needs to be a single thing
		if collider_front_left != collider_front_right:
			return false;
		if collider_front_left != collider_hand_left:
			return false;
		if collider_front_left != collider_hand_right:
			return false;
		
		# Also, we cannot hang from enemies
		# TODO
	
	# x. calculate the angle we will use to hang from the wall before we continue
	
	# 5. check if the normal for the hands makes sense (up)
	print("checking floor angle");
	var left_hand_normal = ray_hand_left.get_collision_normal(0);
	var right_hand_normal = ray_hand_right.get_collision_normal(0);
	var max_angle_diff_to_dot = cos(deg_to_rad(max_floor_angle_diff));
	if left_hand_normal.dot(Vector3(0, 1, 0)) < max_angle_diff_to_dot:
		return false;
	if right_hand_normal.dot(Vector3(0, 1, 0)) < max_angle_diff_to_dot:
		return false;
	
	# 6. check if the height they hit is similar
	var left_hand_position = ray_hand_left.get_collision_point(0);
	var right_hand_position = ray_hand_right.get_collision_point(0);
	var hand_height_diff = abs(left_hand_position.y - right_hand_position.y);
	print("hand height diff: ", hand_height_diff);
	
	if hand_height_diff > max_hand_height_diff:
		return false;
	
	# 7. check if the wall in front is not too much of a weird angle
	# -> note: do we need to check this? having the raycast hit in the first place should be a good indication?
	
	# Ok, looks like we can grab
	return true;

func _calculate_front_facing_rotation_angle() -> float:
	# 1. derive wall normal from both forward spheres
	var left_front_position = ray_front_left.get_collision_point(0);
	var right_front_position = ray_front_right.get_collision_point(0);
	
	var left_front: Vector2 = Vector2(left_front_position.x, left_front_position.z);
	var right_front: Vector2 = Vector2(right_front_position.x, right_front_position.z);
	
	var tangent = right_front - left_front;
	var normal_out_of_wall = Vector2(tangent.y, -tangent.x);
	return -tangent.angle();

func _do_grab_current_ledge() -> void:
	# 1. rotate
	me.model.rotation.y = _calculate_front_facing_rotation_angle();
	
	# 2. derive wall normal from both forward spheres
	var left_front_position = ray_front_left.get_collision_point(0);
	var right_front_position = ray_front_right.get_collision_point(0);
	
	# Wall hit position
	var hit_position = (left_front_position + right_front_position)/2.0;
	
	# Normal
	var left_front: Vector2 = Vector2(left_front_position.x, left_front_position.z);
	var right_front: Vector2 = Vector2(right_front_position.x, right_front_position.z);
	
	var tangent = (right_front - left_front).normalized();
	var normal_out_of_wall = Vector2(tangent.y, -tangent.x);
	
	# Hang position
	var player_hang_position = hit_position - Vector3(normal_out_of_wall.x, 0, normal_out_of_wall.y) * hang_distance;
	
	# Highest grab Y
	var left_hand_position = ray_hand_left.get_collision_point(0);
	var right_hand_position = ray_hand_right.get_collision_point(0);
	
	var highest_grab_y = max(left_hand_position.y, right_hand_position.y);
	
	player_hang_position.y = highest_grab_y - max_body_and_arm_length;
	#me.global_position = player_hang_position;
	
	# TODO: REMEMBER OFFSET!!! vs movable platform
	
	me.is_ledge_grabbing = true;
	me.ledge_grab_offset = player_hang_position;

func _physics_process(delta) -> void:
	if me.is_ledge_grabbing:
		# Already grabbing a ledge
		return;
	
	time_since_ledge_disconnect+=delta;
	if time_since_ledge_disconnect < min_time_between_reconnect:
		return;
	
	if _check_can_grab_ledge():
		print("GRAB");
		_do_grab_current_ledge();
