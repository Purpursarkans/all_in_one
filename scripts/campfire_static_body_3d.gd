extends StaticBody3D

var startTimer
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	startTimer = Time.get_ticks_msec()
	fuel_bar.max_value = maxFuel
	pass # Replace with function body.

@export var maxFuel : float = 1000
@export var burn : float = 50
@export var grownRate = 0.5
@export var logPercent : float = 10

var fuel = maxFuel
var onePercent = maxFuel/100

@onready var fuel_bar: ProgressBar = %fuelBar


func _process(delta: float) -> void:
	if fuel > 0:
		fuel -= burn * delta
		var fuelPersent = fuel / maxFuel 
		fuel_bar.value = fuel
		burn += grownRate * delta
	if fuel <= 0:
		$"/root/HarvestWood".start = false
		var endTimer: int = Time.get_ticks_msec()
		var totalTime: int = endTimer - startTimer
		var totalSec : float = float(totalTime) / 1000.0
		var totalMinut: float = totalSec / 60.0
		%Time.text = "you time: " + str(int(totalSec)) + " sec"
		%Time2.text = "you time: " + str(int(totalSec)) + " sec"
		player.global_position = %GameOverPosition.global_position
		player.haveLog = false
		player.get_node("WoodLog").hide()
		process_mode = Node.PROCESS_MODE_DISABLED

@onready var player = %Player
@onready var campfire_drop: AudioStreamPlayer3D = %CampfireDrop

func left_click():
	if player.haveLog:
		fuel+=onePercent*logPercent
		#print_debug("campfire")
		player.haveLog = false
		player.get_node("WoodLog").hide()
		campfire_drop.play()
		if fuel > maxFuel:
			maxFuel = fuel
			fuel_bar.max_value = maxFuel
