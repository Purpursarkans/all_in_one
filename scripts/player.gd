extends CharacterBody3D

const mix_view : float = -PI/2
const max_view : float = PI/2

var test1

var mouseRotation : Vector2 = Vector2.ZERO

var GUIVISIBLE : bool = true

const JUMP_VELOCITY : int = 5

var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var PlayerRayCast : RayCast3D = $Head/PlayerRayCast3D

@onready var snow_walk: AudioStreamPlayer = %SnowWalk
@onready var snow_timer: Timer = %SnowTimer

var haveLog : bool = false

@export var MainNode : Node

var mouse_click_left : bool = false
var mouse_click_right : bool = false

func _ready():
	Engine.time_scale = 1
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	var window_size = DisplayServer.window_get_size()
	lastMousePosition = window_size/2
	
	await MainNode.ready
	print_debug(MainNode.load_bus)
	var bus_count = AudioServer.get_bus_count()
	print_debug("Общее количество шин: ", bus_count)
	%SnowWalk.bus = "snow"
	
	global_position = %StartPosition.global_position
	#global_position = %EscapePosition.global_position
	
	
var action_object = null

func actionLeft():
	actionLeftCursor(PlayerRayCast.get_collider())

func actionRight():
	actionRightCursor(PlayerRayCast.get_collider())

func actionLeftCursor(action_object):
	#print_debug(PlayerRayCast)
	#action_object = PlayerRayCast.get_collider()
	if action_object != null:
		#print_debug(action_object.name, "\tclick")
		if action_object.get_meta("LeftClick") == true:
			#print_debug("object have meta leftClick")
			action_object.leftClick()
		
func actionRightCursor(action_object):
	if action_object != null:
		#print_debug(action_object.name, "\tclick")
		if action_object.get_meta("rightClick") == true:
			#print_debug("object have meta rightClick")
			action_object.rightClick()

var Flash : bool = true

var tempFloor
var tempFloor2

var escape : bool = false

func _physics_process(delta):
		
	if Input.is_action_just_pressed("left_mouse_button_click"):
		var collider
		if !showCursor:
			collider = PlayerRayCast.get_collider()
		else:
			if getCursourPos():
				collider = getCursourPos().collider
		if collider != null:
			if collider.get_meta("gui") == true:
				sprite3d = collider.get_node("guiDisplay")
				viewport = sprite3d.get_node("SubViewport")
				clickUI = true
				is_mouse_down_on_viewport = true
	
	if is_mouse_down_on_viewport:
		gui3dClickMouse()
		
		
		
	if Input.is_action_just_pressed("esc"):
		var focused_control
		if viewport != null:
			focused_control = viewport.gui_get_focus_owner()
		if focused_control != null:
			print_debug(focused_control)
			focused_control.release_focus()
		else:
			if !escape:
				if MainNode.start:
					%CampfireStaticBody3D.process_mode = Node.PROCESS_MODE_DISABLED
				%PlayerLastPos.transform = transform
				%PlayerLastPos.rotation.x = mouseRotation.x
				%PlayerLastPos.rotation.y = mouseRotation.y

				global_position = %EscapePosition.global_position
				print_debug(rotation, "\t", %EscapePosition.rotation)
				mouseRotation.y = %EscapePosition.rotation.y
				mouseRotation.x = %EscapePosition.rotation.x
			else:
				if MainNode.start:
					%CampfireStaticBody3D.process_mode = Node.PROCESS_MODE_INHERIT
				transform = %PlayerLastPos.transform
				mouseRotation.y = %PlayerLastPos.rotation.y
				mouseRotation.x = %PlayerLastPos.rotation.x
			escape = !escape
	
	if Input.is_action_just_pressed("enter"):
		var focused_control
		if viewport != null:
			focused_control = viewport.gui_get_focus_owner()
		if focused_control != null:
			focused_control.release_focus()

	if Input.is_action_just_pressed("e"):
		changeMouse()
	
	
	if mouse_click_left == true:
		mouseClick("left")
		mouse_click_left = false
	elif mouse_click_right == true:
		mouseClick("right")
		mouse_click_right = false
	
	tempFloor = tempFloor2
	tempFloor2 = is_on_floor()
	
	if is_on_floor() && tempFloor == false && tempFloor2 == true:
		#print_debug("приземление")
		snow_walk.play()
	
	var SPEED : float = 5.0
	const SPEED_UP : float = 2
	
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_pressed("space") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	if Input.is_action_pressed("shift"):
		SPEED *= SPEED_UP
	
	if canMove:
		var input_dir : Vector2 = Input.get_vector("a", "d", "w", "s")
		var direction : Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
			if is_on_floor():
				if !snow_walk.playing:
					if snow_timer.is_stopped():
						snow_timer.start()
						snow_walk.play()
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
		move_and_slide()
	
	transform.basis = Basis.from_euler(Vector3(0.0, mouseRotation.y, 0.0))
	$Head.transform.basis = Basis.from_euler(Vector3(mouseRotation.x, 0.0, 0.0))


func _input(e : InputEvent) -> void:
	if e is InputEventKey:
		if viewport != null:
			var focused_control = viewport.gui_get_focus_owner()
			if focused_control is LineEdit or focused_control is TextEdit:
				viewport.push_input(e)
				canMove = false
			else:
				canMove = true
	if !showCursor:
		if e is InputEventMouseMotion:
			mouseRotation.x = clamp(mouseRotation.x - e.relative.y * G.Sensivity * G.FixSensivity, mix_view, max_view)
			mouseRotation.y += -e.relative.x * G.Sensivity * G.FixSensivity
		
		if e is InputEventMouse:
			if e.is_action_pressed("left_mouse_button_click"):
				var temp_raycast = PlayerRayCast.get_collider()
				if temp_raycast != null: 
					actionLeftCursor(temp_raycast)
				#actionLeft()
			elif e.is_action_pressed("right_mouse_button_click"):
				actionRight()
	if showCursor:
		if e is InputEventMouse:
			if e.is_action_pressed("left_mouse_button_click"):
				mouse_click_left = true
				#mouseClick(e,"left")
			elif e.is_action_pressed("right_mouse_button_click"):
				mouse_click_right = true
				#mouseClick(e,"right")

@onready var camera_node: Camera3D = %Camera3D
@onready var player_ray_cast_3d: RayCast3D = %PlayerRayCast3D
@onready var ray_length: float = player_ray_cast_3d.target_position.y

@export var collision_masks: int = 3

func mouseClick(mouseButton : String):
	#print_debug(collision_layer)
	
	var result = getCursourPos()

	if result:
		var hit_object = result.collider
		if mouseButton == "left":
			actionLeftCursor(hit_object)

var lastMousePosition: Vector2 = Vector2.ZERO
var showCursor : bool = false
func changeMouse():
	showCursor = !showCursor
	if showCursor:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		Input.warp_mouse(lastMousePosition)
	else:
		lastMousePosition = get_viewport().get_mouse_position()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)




var canMove : bool = true
var interact_just_released
var is_mouse_down_on_viewport = false
var sprite3d
var viewport
var clickUI = false


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

func gui3dClickMouse():
	interact_just_released = Input.is_action_just_released("left_mouse_button_click")

	var hit_point_world


	if !showCursor: 
		hit_point_world = PlayerRayCast.get_collision_point()
	else:
		hit_point_world = getCursourPos()["position"]

	var hit_point_local_sprite3d = sprite3d.global_transform.affine_inverse() * hit_point_world
	var viewport_size = viewport.size
	var sprite_size = sprite3d.get_aabb().size

	var relative : Vector2 = Vector2((hit_point_local_sprite3d.x + sprite_size.x / 2.0) / sprite_size.x, 
									1.0 - (hit_point_local_sprite3d.y + sprite_size.y / 2.0) / sprite_size.y)

	
	var pixel : Vector2 = Vector2(relative.x * viewport_size.x,
								relative.y * viewport_size.y)


	if clickUI:
		var click_event = InputEventMouseButton.new()
		click_event.button_index = MOUSE_BUTTON_LEFT
		click_event.pressed = true
		click_event.position = Vector2(pixel.x, pixel.y)
		viewport.push_input(click_event)
		clickUI = false


	var move_event = InputEventMouseMotion.new()
	move_event.position = Vector2(pixel.x, pixel.y)
	viewport.push_input(move_event)

	if interact_just_released:
		is_mouse_down_on_viewport = false
		var release_event = InputEventMouseButton.new()
		release_event.button_index = MOUSE_BUTTON_LEFT
		release_event.pressed = false
		viewport.push_input(release_event)
