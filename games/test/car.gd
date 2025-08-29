extends VehicleBody3D


@export var MAX_STEER = 0.3
@export var ENGINE_POWER = 3000

var frametime = 0.3

func _physics_process(delta: float) -> void:
	var speed := linear_velocity.length()
	
	engine_force = Input.get_axis("s", "w") * ENGINE_POWER
	#steering = clamp(steering, -MAX_STEER, MAX_STEER)
	print_debug(speed)
	
	if speed > 0.1:
		steering = move_toward(steering,Input.get_axis("d","a")*MAX_STEER, delta * frametime)
	else:
		steering = move_toward(steering,steering + Input.get_axis("d","a")*MAX_STEER, delta * frametime)
		steering = clamp(steering, -MAX_STEER, MAX_STEER)
	
	%Speedometor.text = ("%.1f" % speed + " m/s"+"\n"+"%.0f" % (speed * 3.6) + " km/h")
