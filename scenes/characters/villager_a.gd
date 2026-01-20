extends CharacterBody3D
#variables
var home_location #gives the home building of the villager or null if the villager is homeless
var job #gives the job class of the villager or null if the villager is jobless
var job_location #gives the job building of the villager or null if the villager is jobless
var rest = 100 #shows the rested state of the villager. goes from 0 to 100
var live = 100  #shows the livepoints of a villager. goes from 0 to 100
var happyness = 100 #shows the happyness of a villager. goes from 0 to 100
var hunger = 100 #shows the food saturation of the villager. goes from 0 to 100
var speed: float = 2.0
var alive = true
var is_hungry = false
var is_sleepy = false

var chosen = false

@onready var highlight_mat = preload("res://scenes/buildings/highlight.tres")

@onready var world = $"../.."
#our path array consist of hex coordinates, means current_path should be array filled with Vector2i's ((q,r) coordinates)
var current_path: Array[Vector2i]
var current_target_world_pos: Vector3

var current_resource: Node = null

@onready var rig_medium = $"Rig_Medium"
@onready var arm_left = $"Rig_Medium/Skeleton3D/Mannequin_ArmLeft"
@onready var arm_right = $"Rig_Medium/Skeleton3D/Mannequin_ArmRight"
@onready var body = $"Rig_Medium/Skeleton3D/Mannequin_Body"
@onready var head = $"Rig_Medium/Skeleton3D/Mannequin_Head"
@onready var leg_left = $"Rig_Medium/Skeleton3D/Mannequin_LegLeft"
@onready var leg_right = $"Rig_Medium/Skeleton3D/Mannequin_LegRight"
@onready var meshes = [arm_left, arm_right, body, head, leg_left, leg_right]
@onready var plate_food_A2 = $"Rig_Medium/Skeleton3D/Right Hand/plate_food_A2"
@onready var plate_food_B2 = $"Rig_Medium/Skeleton3D/Right Hand/plate_food_B2"

@onready var buildings = $"../../Buildings"
@onready var right_hand = $"Rig_Medium/Skeleton3D/Right Hand"

@onready var animation_tree : AnimationTree = $AnimationTree
#@onready var nav_agent = $NavigationAgent3D

@onready var villager_info = $"Villager Info"
@onready var hitpoints_label = $"Villager Info/MarginContainer/VBoxContainer/HBoxContainer/Hitpoints"
@onready var rest_label = $"Villager Info/MarginContainer/VBoxContainer/Hunger"
@onready var hunger_label = $"Villager Info/MarginContainer/VBoxContainer/Rest"
@onready var home_label = $"Villager Info/MarginContainer/VBoxContainer/Home"
@onready var condition_label = $"Villager Info/MarginContainer/VBoxContainer/Condition"

@onready var resource_info = $"../../Strategy_UI/Resource Info"


func _ready() -> void:
	animation_tree.active = true
	villager_info.visible = false

	var agent = GoapAgent.new()
	#defines which goals are available for the villager
	agent.init(self, [
		KeepFedGoal.new(),
		KeepRestGoal.new()
	])
	add_child(agent)


	
func _process(delta: float) -> void:
	rest_label.text = str(int (rest))
	hunger_label.text = str(int (hunger))
	hitpoints_label.text = str(int (live))
	home_label.text = str(home_location)
	condition_label.text = str(animation_tree.get("parameters/Villager_A/playback").get_current_node())
	

func _physics_process(delta: float) -> void:
	if(alive):
		var current_state = animation_tree.get("parameters/Villager_A/playback").get_current_node()
		if current_state != "Villeger_Idle_A": 
			if velocity.length() < 0.1:
				animation_tree.set("parameters/Villager_A/conditions/idle", true)
		if(hunger > 50):
			is_hungry = true
			
		if(rest > 50):
			is_sleepy = true
		
		if(rest > 0):
			rest -= 1 * delta
		else:
			get_hit(1 * delta)
		
		if(hunger > 0):
			hunger -= 2 * delta
		else:
			get_hit(1 * delta)
	else:
		pass
	if(live <= 0 && alive):
		reset_all_animation_conditions()
		animation_tree.set("parameters/Villager_A/conditions/is_dead", true)
		alive = false
		resource_info.set_villager_count(resource_info.get_villager_count() - 1)
	else:
		#if there is no target position to walk towards
		#there is nothing to do just return
		if current_path.is_empty() and current_target_world_pos == Vector3.ZERO:
			velocity = Vector3.ZERO
			return
			
		#if the goal is reached pick up a new target
		if global_position.distance_to(current_target_world_pos) < 0.2 or current_target_world_pos == Vector3.ZERO:
			#check if the list is empty
			if current_path.is_empty():
				velocity = Vector3.ZERO
				current_target_world_pos = Vector3.ZERO
				return
			
			#if the list is not empty set up a new goal
			var next_hex = current_path.pop_front()
			var world_pos = world.hex_to_world(next_hex)
			
			if world.height_data.has(next_hex):
				world_pos.y = world.height_data[next_hex]
				
			current_target_world_pos = world_pos
			
		if current_target_world_pos != Vector3.ZERO:
			var direction = (current_target_world_pos - global_position).normalized()
			var look_target = current_target_world_pos
			look_target.y = global_position.y
			look_at(look_target, Vector3.UP)
			
			velocity = direction * speed
			move_and_slide()
		
		
		
		
		
		"""if current_path.is_empty():
			pass
		else:
			var target_pos = current_path[0]	
			velocity = global_position.direction_to(target_pos) * speed
			
			 # Wenn wir den Punkt fast erreicht haben, lösche ihn aus der Liste
			if global_position.distance_to(target_pos) < 5:
				current_path.remove_at(0)
				if current_path.is_empty():
					velocity = Vector3.ZERO
			move_and_slide()"""
	
'''
func move_to(direction, delta):
	velocity = Vector3.ZERO
	nav_agent.set_target_position(job_location)
	var next_nav_point = nav_agent.get_next_path_position()
	velocity = (next_nav_point - global_transform.origin.normalized() * speed)
  # warning-ignore:return_value_discarded
	move_and_collide(direction * delta * 100)
'''	
	
func move_to_hex(target_hex: Vector2i):
	
	var current_hex = world.world_to_hex(global_position)
	#calculate the path
	var new_path = world.get_hex_path(current_hex, target_hex)
	
	if new_path.size() > 0:
		current_path = new_path
		current_path.pop_front()
		
		current_target_world_pos = Vector3.ZERO
	else:
		print("No path!")

func set_target_resource(resource):
	var position = world.world_to_hex(resource.global_position)
	var target_hex = find_best_neighbor_hex(position)
	
	if target_hex != Vector2i.ZERO:
		current_resource = resource
		move_to_hex(target_hex)
	else:
		print("Resource is not reachable")

#helper function for determining the closest neighboring hex
#for the function set_target_resource
func find_best_neighbor_hex(resource_hex: Vector2i) -> Vector2i:
	var neighbors = world.get_neighbors(resource_hex.x, resource_hex.y)
	var best_hex = Vector2i.ZERO#we will keep the best candidate here
	var min_distance = 9999999#we give a big number at the beginning for later comparisons
	var found_valid = false
	
	for neighbor in neighbors:
		var point_id = world.get_id_from_coords(neighbor)
		
		if world.astar.has_point(point_id):
			var neighbor_world_pos = world.hex_to_world(neighbor)
			var dist = global_position.distance_to(neighbor_world_pos)
			
			if dist < min_distance:
				min_distance = dist
				best_hex = neighbor
				found_valid = true
	
	if found_valid:
		return best_hex
	else:
		print("Resource is not reachable")
		return Vector2i.ZERO

func reset_all_animation_conditions():
	for property in animation_tree.get_property_list():
		# AnimationTree parameters usually start with "parameters/conditions/"
		if property.name.begins_with("parameters/Villager_A/conditions/"):
			animation_tree.set(property.name, false)

func update_animation_parameters():
	if velocity.length() < 0.1:
		reset_all_animation_conditions()
		animation_tree.set("parameters/Villager_A/conditions/idle", true)
		
	
func get_hit(hit: float):
	reset_all_animation_conditions()
	animation_tree.set("parameters/Villager_A/conditions/is_hit", true)
	live -= hit
	wait(1.2)
	reset_all_animation_conditions()
	
func eat():
	plate_food_A2.visible = true
	reset_all_animation_conditions()
	animation_tree.set("parameters/Villager_A/conditions/use_item", true)
	plate_food_A2.visible = false
	plate_food_B2.visible = true
	plate_food_B2.visible = false
	reset_all_animation_conditions()
	hunger = 100
	is_hungry = false
	
func sleep():
	rig_medium.visible = false
	rest = 100
	is_sleepy = false
	rig_medium.visible = true

func locate_nearest_tavern():
	var taverns = get_tree().get_nodes_in_group("taverns")
	#print("Taverns:" + str(taverns))
	var nearest_tavern = null
	var path = null
	var new_path = null
	
	var current_hex = world.world_to_hex(global_position)
	var target_hex = null
	#calculate the path
	
	for tavern in taverns:
		target_hex = world.world_to_hex(tavern.global_position)
		new_path = world.get_hex_path(current_hex, target_hex)
		print("Path Size: " + str(new_path.size()))
		if path == null or path.size() > new_path.size():
			nearest_tavern = tavern
			path = new_path
			print("Nearest Tavern: " + str(nearest_tavern))
	return nearest_tavern
	
func get_distance(object):
	var current_hex = world.world_to_hex(global_position)
	var target_hex = world.world_to_hex(object.global_position)
	var path = world.get_hex_path(current_hex, target_hex)
	
	return path.size()
	

func set_job(_job: String, _job_location: Area3D):
	job = _job
	job_location = _job_location
	
func set_home(_home_location: Area3D):
	home_location = _home_location

func get_home():
	return home_location

func get_hunger():
	return hunger
	
func get_rest():
	return rest

func _on_mouse_entered() -> void:
	if !chosen:
		for mesh in meshes:
			mesh.material_override = highlight_mat
			villager_info.visible = true


func _on_mouse_exited() -> void:
	if !chosen:
		for mesh in meshes:
				mesh.material_override = null
				villager_info.visible = false


func _on_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if (event is InputEventMouseButton and event.is_pressed() and event.is_action("ui_left_click")):
		for mesh in meshes:
			mesh.material_override = highlight_mat
			villager_info.visible = true
		chosen = true


"""func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_right_click"):
		for mesh in meshes:
			mesh.material_override = null
			villager_info.visible = false

		chosen = false"""

func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout


#handles player input that has not been consumed/used by GUI elem,ents
#used for 3D world interactions like unit movement commands
func _unhandled_input(event: InputEvent) -> void:
	
	#ensure its a mouse click and trigger when pressed down and must be a left click and only allows 
	#movement when a specific villager is currently selected
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT and chosen:
		
		#---SETUP CAMERA & MOUSE
		#we need the active 3D camera from the game screen to project a ray
		var camera = get_viewport().get_camera_3d()
		#event.position is the 2D pixel coordinate on our monitor e.g., X:960, Y: 540
		var mouse_pos = event.position
		
		#---CALCULATE RAY ORIGIN & DIRECTION---
		#since the screen is 2D and the world is 3D, we must project a ray
		
		#'project_ray_origin': the starting point
		#if we shoot a laser from the camera, exactly where on the camera lens does it start?
		var ray_origin = camera.project_ray_origin(mouse_pos)
		#'project_ray_normal': the direction/angle
		#if the laser passes through this specific pixel on the screen, what angel does it fly into the 3D world?
		var ray_normal = camera.project_ray_normal(mouse_pos)
		
		#we extend the laser 1000 meters forward to ensure it reaches the ground
		var ray_end = ray_origin + (ray_normal * 1000)
		
		#we pack the start and end points into a query object to ask the physics engine
		var ray_query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
		
		#direct_space_state: the brain of the physics engine that knows where every object is
		#required to query the physics engine instantly
		var space_state = get_world_3d().direct_space_state
		
		#the physics engine checks if this line hits any CollisionObject
		#returns a dictionary with hit info (collider, position, normal) or empty if nothing hit
		var ray_result = space_state.intersect_ray(ray_query)
		
		#checks if the dictionary is not empty
		if ray_result:
			
			var collider = ray_result.collider
			if collider is ResourceNode:
				set_target_resource(collider)
			else:
				
				#position is the exact Vector3 point where the ray hit the ground
				var hit_position = ray_result.position
				
				#converts the 3D world position to our hex grid coordinates (q, r)
				var target_hex = world.world_to_hex(hit_position)
				
				#send the movement command to the villager
				move_to_hex(target_hex)
