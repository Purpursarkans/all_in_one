extends CharacterBody3D

const mix_view : float = -PI/2
const max_view : float = PI/2

var mouse_rotation : Vector2 = Vector2.ZERO

var JUMP_VELOCITY : int = 5
var MAX_SPEED : float = 5.0
var TOTAL_SPEED = MAX_SPEED
var SPEED_UP : float = 2

var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var PlayerRayCast : RayCast3D = $Head/PlayerRayCast3D

@onready var snow_walk: AudioStreamPlayer = %SnowWalk
@onready var snow_timer: Timer = %SnowTimer

@export var MainNode : Node

var mouse_click_left : bool = false
var mouse_click_right : bool = false

var have_log : bool = false

func _ready():
	Engine.time_scale = 1
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	var window_size = DisplayServer.window_get_size()
	last_mouse_position = window_size/2



func mouse_action_object(action_object, mouse_button):
	#print_debug(PlayerRayCast)
	#action_object = PlayerRayCast.get_collider()
	if action_object != null:
		if mouse_button == "left_mouse_button" && action_object.get_meta("left_click", false) == true:
			#print_debug(action_object.name, "\tclick")
			#print_debug("object have meta left_click")
			action_object.left_click()
		elif mouse_button == "right_mouse_button" && action_object.get_meta("right_click", false) == true:
			#print_debug("object have meta right_click")
			action_object.right_click()
		

var Flash : bool = true

var check_on_floor
var check_on_floor2

var escape : bool = false

func _physics_process(delta):
	TOTAL_SPEED = MAX_SPEED

	if Input.is_action_just_pressed("left_mouse_button_click"):
		var collider
		if !show_cursor:
			collider = PlayerRayCast.get_collider()
		else:
			if getCursourPos():
				collider = getCursourPos().collider
		if collider != null:
			if collider.get_meta("gui", false) == true:
				sprite3d = collider.get_node("guiDisplay")
				viewport = sprite3d.get_node("SubViewport")
				click_ui_left = true
				is_mouse_down_on_viewport = true

	if is_mouse_down_on_viewport:
		gui_3d_click_mouse()
		
		
		
	if Input.is_action_just_pressed("esc"):
		var focused_control
		if viewport != null:
			focused_control = viewport.gui_get_focus_owner()
		if focused_control != null:
			#print_debug(focused_control)
			focused_control.release_focus()
		else:
			if !escape:
				if MainNode.start:
					%CampfireStaticBody3D.process_mode = Node.PROCESS_MODE_DISABLED
				%PlayerLastPos.transform = transform
				%PlayerLastPos.rotation.x = mouse_rotation.x
				%PlayerLastPos.rotation.y = mouse_rotation.y

				global_position = %EscapePosition.global_position
				print_debug(rotation, "\t", %EscapePosition.rotation)
				mouse_rotation.y = %EscapePosition.rotation.y
				mouse_rotation.x = %EscapePosition.rotation.x
			else:
				if MainNode.start:
					%CampfireStaticBody3D.process_mode = Node.PROCESS_MODE_INHERIT
				transform = %PlayerLastPos.transform
				mouse_rotation.y = %PlayerLastPos.rotation.y
				mouse_rotation.x = %PlayerLastPos.rotation.x
			escape = !escape
	
	if Input.is_action_just_pressed("enter"):
		var focused_control
		if viewport != null:
			focused_control = viewport.gui_get_focus_owner()
		if focused_control != null:
			focused_control.release_focus()
	
	##show cursor if alt pressed
	#if Input.is_action_just_pressed("show_cursor"):
		#show_cursor = true
		#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		#Input.warp_mouse(last_mouse_position)
	#if Input.is_action_just_released("show_cursor"):
		#show_cursor = false
		#last_mouse_position = get_viewport().get_mouse_position()
		#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	##toggle corsor 
	
	if Input.is_action_just_pressed("show_cursor"):
		show_cursor = !show_cursor
		if show_cursor:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			Input.warp_mouse(last_mouse_position)
		else:
			last_mouse_position = get_viewport().get_mouse_position()
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	
	
	if mouse_click_left == true:
		mouse_click("left_mouse_button")
		mouse_click_left = false
	if mouse_click_right == true:
		mouse_click("right")
		mouse_click_right = false
	
	check_on_floor = check_on_floor2
	check_on_floor2 = is_on_floor()
	
	if is_on_floor() && check_on_floor == false && check_on_floor2 == true:
		#print_debug("приземление")
		snow_walk.play()
	
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_pressed("space") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	if Input.is_action_pressed("shift"):
		TOTAL_SPEED *= SPEED_UP
	
	if can_move:
		var input_dir : Vector2 = Input.get_vector("a", "d", "w", "s")
		var direction : Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			velocity.x = direction.x * TOTAL_SPEED
			velocity.z = direction.z * TOTAL_SPEED
			if is_on_floor():
				if !snow_walk.playing:
					if snow_timer.is_stopped():
						snow_timer.start()
						snow_walk.play()
		else:
			velocity.x = move_toward(velocity.x, 0, TOTAL_SPEED)
			velocity.z = move_toward(velocity.z, 0, TOTAL_SPEED)
		move_and_slide()
	
	transform.basis = Basis.from_euler(Vector3(0.0, mouse_rotation.y, 0.0))
	$Head.transform.basis = Basis.from_euler(Vector3(mouse_rotation.x, 0.0, 0.0))


func _input(e : InputEvent) -> void:
	if e is InputEventKey:
		if viewport != null:
			var focused_control = viewport.gui_get_focus_owner()
			if focused_control is LineEdit or focused_control is TextEdit:
				viewport.push_input(e)
				can_move = false
			else:
				can_move = true
	if !show_cursor:
		if e is InputEventMouseMotion:
			mouse_rotation.x = clamp(mouse_rotation.x - e.relative.y * G.Sensivity * G.FixSensivity, mix_view, max_view)
			mouse_rotation.y += -e.relative.x * G.Sensivity * G.FixSensivity
		
		if e is InputEventMouse:
			var temp_raycast = PlayerRayCast.get_collider()
			if e.is_action_pressed("left_mouse_button_click"):
				mouse_action_object(temp_raycast,"left_mouse_button")
			elif e.is_action_pressed("right_mouse_button_click"):
				mouse_action_object(temp_raycast,"right_mouse_button")
	if show_cursor:
		if e is InputEventMouse:
			if e.is_action_pressed("left_mouse_button_click"):
				mouse_click_left = true
			elif e.is_action_pressed("right_mouse_button_click"):
				mouse_click_right = true

@onready var camera_node: Camera3D = %Camera3D
@onready var player_ray_cast_3d: RayCast3D = %PlayerRayCast3D
@onready var ray_length: float = player_ray_cast_3d.target_position.y

@export var collision_masks: int = 3

func mouse_click(mouseButton : String):
	#print_debug(collision_layer)
	
	var result = getCursourPos()

	if result:
		var hit_object = result.collider
		if mouseButton == "left_mouse_button":
			mouse_action_object(hit_object, "left_mouse_button")
		if mouseButton == "right_mouse_button":
			mouse_action_object(hit_object, "right_mouse_button")

var last_mouse_position: Vector2 = Vector2.ZERO
var show_cursor : bool = false
	




var can_move : bool = true
var interact_just_released_left
var is_mouse_down_on_viewport = false
var sprite3d
var viewport
var click_ui_left = false


func getCursourPos() -> Dictionary:
	var mouse_position = get_viewport().get_mouse_position()
	var ray_origin = camera_node.project_ray_origin(mouse_position)
	var ray_normal = camera_node.project_ray_normal(mouse_position)
	var ray_end = ray_normal * ray_length + ray_origin
	
	var ray_query = PhysicsRayQueryParameters3D.new()
	ray_query.from = ray_origin
	ray_query.to = ray_end
	ray_query.collide_with_areas = true
	ray_query.collide_with_bodies = true
	ray_query.collision_mask = collision_masks

	return get_world_3d().direct_space_state.intersect_ray(ray_query)


#DONT ADD RIGHT MOUSE BUTTON FROM RAYCAST ITS DONT WORK
#RIGHT MOUSE FOR CURSOR WORK WRONG

func gui_3d_click_mouse():
	interact_just_released_left = Input.is_action_just_released("left_mouse_button_click")

	var hit_point_world

	if !show_cursor: 
		hit_point_world = PlayerRayCast.get_collision_point()
	else:
		var temp_dict = getCursourPos()
		if temp_dict:
			hit_point_world = temp_dict["position"]
		else:
			is_mouse_down_on_viewport = false
			var release_event = InputEventMouseButton.new()
			release_event.button_index = MOUSE_BUTTON_LEFT
			release_event.pressed = false
			viewport.push_input(release_event)
			return
	
	var hit_point_local_sprite3d = sprite3d.global_transform.affine_inverse() * hit_point_world
	var viewport_size = viewport.size
	var sprite_size = sprite3d.get_aabb().size

	var relative : Vector2 = Vector2((hit_point_local_sprite3d.x + sprite_size.x / 2.0) / sprite_size.x, 
									1.0 - (hit_point_local_sprite3d.y + sprite_size.y / 2.0) / sprite_size.y)

	
	var pixel : Vector2 = Vector2(relative.x * viewport_size.x,
								relative.y * viewport_size.y)


	if click_ui_left:
		var click_event = InputEventMouseButton.new()
		click_event.button_index = MOUSE_BUTTON_LEFT
		click_event.pressed = true
		click_event.position = Vector2(pixel.x, pixel.y)
		viewport.push_input(click_event)
		click_ui_left = false

	var move_event = InputEventMouseMotion.new()
	move_event.position = Vector2(pixel.x, pixel.y)
	viewport.push_input(move_event)

	if interact_just_released_left:
		is_mouse_down_on_viewport = false
		var release_event = InputEventMouseButton.new()
		release_event.button_index = MOUSE_BUTTON_LEFT
		release_event.pressed = false
		viewport.push_input(release_event)
