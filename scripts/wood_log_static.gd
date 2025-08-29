extends StaticBody3D

@onready var player = get_parent().player
@onready var spawner = get_parent().spawner

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func left_click():
	#print_debug("wood Left Click")
	#print_debug(player)
	if !player.have_log:
		player.have_log = true
		player.get_node("WoodLog").show()
		get_parent().get_parent().remove_child(get_parent())
		get_parent().queue_free()
		spawner.logs -= 1
		spawner.pickUp()
