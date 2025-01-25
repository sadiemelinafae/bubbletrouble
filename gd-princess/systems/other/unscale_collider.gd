extends StaticBody3D

@export var collider: CollisionShape3D;

func _ready() -> void:
	if collider.shape is SphereShape3D:
		var sphere_shape: SphereShape3D = collider.shape;
		sphere_shape.radius = sphere_shape.radius * (scale.x+scale.y+scale.z)/3.0;
		scale = Vector3(1, 1, 1);
	elif collider.shape is BoxShape3D:
		var box_shape: BoxShape3D = collider.shape;
		box_shape.size = box_shape.size * scale;
		scale = Vector3(1, 1, 1);
	elif collider.shape is CylinderShape3D:
		var cylinder_shape: CylinderShape3D = collider.shape;
		cylinder_shape.radius = cylinder_shape.radius * (scale.x+scale.z)/2.0;
		cylinder_shape.height = cylinder_shape.height * scale.y;
		scale = Vector3(1, 1, 1);
	else:
		printerr("Not implemented... Unknown collision shape")
