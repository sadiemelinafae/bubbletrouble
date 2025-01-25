extends Area3D

@export var growth_rate = 0.2 #amount to grow per collection
@export var max_scale = 5.0



func _on_bubble_area_entered(area):
	if area.is_in_group("collectables"):
		area.queue_free()
		var new_Scale = global_transform.basis.get_scale() + Vector3(growth_rate, growth_rate, growth_rate)
		if new_Scale.x <= max_scale:
			global_scale(new_Scale)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_collision_layer_value(2,true)
	set_collision_layer_value(1,false)
	set_collision_mask_value(2, true)
	set_collision_mask_value(1, false)
	area_entered.connect(self._on_bubble_area_entered)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
