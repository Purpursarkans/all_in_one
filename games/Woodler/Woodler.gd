extends Node3D

#const Woodler_BUS_LAYOUT : AudioBusLayout = preload("uid://bmpruuq2ta05c")
# Called when the node enters the scene tree for the first time.

#@onready var test = get_node("uid://bmpruuq2ta05c")

@export var ExportResourses : Array[Resource]

var load_bus : bool = false

var start : bool = false

func _ready() -> void:
	load_soud()
	pass

func load_soud():
	AudioServer.set_bus_layout(ExportResourses[0])
	var bus_count = AudioServer.get_bus_count()
	if bus_count > 1:
		load_bus = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#AudioServer.set_bus_layout(ExportResourses[0])
	pass
