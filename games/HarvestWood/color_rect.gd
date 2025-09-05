extends ColorRect


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var action_object = %PlayerRayCast3D.get_collider()
	if action_object != null:
		color = Color(0,255,0)
	else:
		color = Color(255,0,0)
	pass
