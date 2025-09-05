extends "res://scripts/player.gd"

func _init() -> void:
	JUMP_VELOCITY = 5

func _ready():
	super._ready()
	await MainNode.ready
	print_debug(MainNode.load_bus)
	var bus_count = AudioServer.get_bus_count()
	print_debug("Общее количество шин: ", bus_count)
	%SnowWalk.bus = "snow"
	
	global_position = %StartPosition.global_position
	#global_position = %EscapePosition.global_position
