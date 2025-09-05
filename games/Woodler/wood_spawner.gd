#@tool
extends Node3D

@export var player : CharacterBody3D

@export var min_x : int = -10
@export var max_x : int = 10

@export var min_y : int = -10
@export var max_y : int = 10

@export var step : int = 3

var woodLog = preload("uid://bx7k7jxwisjld") #wood_log.tscn

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if self != null && player != null:
		if logs < 10:
			_spawn()


var logs : int = 0

func _spawn():
	var log = woodLog.instantiate()
	log.player = player
	log.spawner = self
	add_child(log,true)
	log.owner = get_tree().edited_scene_root
	log.position = Vector3(get_random_number_with_step(min_x,max_x,step),0,get_random_number_with_step(min_y,max_y,step))
	log.rotation.y = randf_range(0.0, TAU)
	logs += 1

func get_random_number_with_step(min_val: float, max_val: float, step: float) -> float:
	var num_steps = floor((max_val - min_val) / step)
	var random_step_index = randi_range(0, num_steps)
	var result = min_val + random_step_index * step
	return result

@onready var pick_up_log: AudioStreamPlayer = %PickUpLog

func pickUp():
	pick_up_log.play()
