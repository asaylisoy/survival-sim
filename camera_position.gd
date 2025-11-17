extends Node3D

#onready
@onready var rotation_x = $CameraRotationX
@onready var zoom_pivot = $CameraRotationX/CameraZoomPivot
@onready var camera = $CameraRotationX/CameraZoomPivot/Camera3D

#variables
var move_speed = 0.6  #defines how fast the camera moves
var move_target: Vector3 #for smooth camera movement
var rotate_keys_speed = 1.5 #defines how fast the camera rotates
var rotate_keys_target: float #defines the rotation degrees on the y-axis
var zoom_speed = 3.0 #defines how fast the camera zooms
var zoom_target: float 
var min_zoom = -20.0
var max_zoom = 20.0
var mouse_sensitivity = 0.2
var edge_size = 5.0 #size of the edgescroll border for activation around the screen as pixel value
var scroll_speed = 0.6



func _ready() -> void:
	#defines the starting position, rotation and zoom
	move_target = position
	rotate_keys_target = rotation_degrees.y
	zoom_target = camera.position.z
	
	camera.look_at(position)



func _unhandled_input(event: InputEvent) -> void:
	#rotates the camera based on the mouse movement while the middle button is pressed
	if event is InputEventMouseMotion and Input.is_action_pressed("ui_rotate"):
		rotate_keys_target -= event.relative.x * mouse_sensitivity #rotates the camera sideways based on the sideways movement of the moouse
		rotation_x.rotation_degrees.x -= event.relative.y * mouse_sensitivity #rotates the camera up and down based on the up and down movement of the moouse
		rotation_x.rotation_degrees.x = clamp(rotation_x.rotation_degrees.x, -10, 30) #clamp gives borders for the up and down rotation



func _process(delta: float) -> void:
	var mouse_pos = get_viewport().get_mouse_position() #mouseposition on the screen
	var viewport_size = get_viewport().get_visible_rect().size #size of the screen
	
	#makes the mouse invisible while the camera is rotated with the middle mous button
	if Input.is_action_just_pressed("ui_rotate"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#the mouse is visible afterwards
	if Input.is_action_just_released("ui_rotate"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	#edge scroll
	var scroll_direction = Vector3.ZERO
	if mouse_pos.x < edge_size: #mouse touches the left side of the screen
		scroll_direction.x = -1
	elif mouse_pos.x > viewport_size.x - edge_size: #mouse touches the right side of the screen
		scroll_direction.x = 1
	
	if mouse_pos.y < edge_size: #mouse touches the down side of the screen
		scroll_direction.z = -1
	elif mouse_pos.y > viewport_size.y - edge_size: #mouse touches the up side of the screen
		scroll_direction.z = 1
	move_target += transform.basis * scroll_direction * scroll_speed
	
	#get input directions
	var input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down") #builds a movement vector out of the pressed keys
	var movement_direction = (transform.basis * Vector3(input_direction.x, 0, input_direction.y)).normalized() #defines directions based on the retation of the camera
	var rotate_keys = Input.get_axis("ui_rotate_left", "ui_rotate_right") #get_axis returns either -1, 0 or 1 based on the combination on inputs currently pressed
	var zoom_dir = (int(Input.is_action_just_released("ui_camera_zoom_out")) - int(Input.is_action_just_released("ui_camera_zoom_in")))
	
	#set movement targets
	move_target += move_speed * movement_direction
	rotate_keys_target += rotate_keys * rotate_keys_speed
	zoom_target += zoom_dir * zoom_speed
	
	#lerp to movement targets
	position = lerp(position, move_target, 0.10)
	rotation_degrees.y = lerp(rotation_degrees.y, rotate_keys_target, 0.10)
	camera.position.z = lerp(camera.position.z, zoom_target, 0.10)
