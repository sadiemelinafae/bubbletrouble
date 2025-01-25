extends Area3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_collision_layer_value(2,true)
	set_collision_layer_value(1,false)
	set_collision_mask_value(2, true)
	set_collision_mask_value(1, false)




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
