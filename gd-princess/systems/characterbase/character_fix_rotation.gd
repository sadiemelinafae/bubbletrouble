extends Node

@export var me: Character;

@export var also_rotate: Array[Node3D];

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	me.model.rotation.y = me.global_rotation.y;
	me.global_rotation = Vector3(0,0,0);
	
	for n in also_rotate:
		n.rotation.y = me.model.rotation.y;
