extends StaticBody3D

var startTimer
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


var fuel : int = 0

@onready var fuel_bar: ProgressBar = %fuelBar


func _process(delta: float) -> void:
	pass

@onready var player = %Player
@onready var campfire_drop: AudioStreamPlayer3D = %CampfireDrop

func left_click():
	if player.have_log:
		fuel += 1
		#print_debug("campfire")
		player.have_log = false
		player.get_node("WoodLog").hide()
		campfire_drop.play()
