extends CharacterBody3D
#variables
var home_location #gives the home building of the villager or null if the villager is homeless
var job #gives the job class of the villager or null if the villager is jobless
var job_location #gives the job building of the villager or null if the villager is jobless
var rest = 100 #shows the rested state of the villager. goes from 0 to 100
var live = 100  #shows the livepoints of a villager. goes from 0 to 100
var happyness = 100 #shows the happyness of a villager. goes from 0 to 100
var hunger = 100 #shows the food saturation of the villager. goes from 0 to 100
var speed
var alive = true

var chosen = false

@onready var highlight_mat = preload("res://scenes/buildings/highlight.tres")

@onready var world = $"../World"
var current_path: PackedVector3Array = []


@onready var arm_left = $"Rig_Medium/Skeleton3D/Mannequin_ArmLeft"
@onready var arm_right = $"Rig_Medium/Skeleton3D/Mannequin_ArmRight"
@onready var body = $"Rig_Medium/Skeleton3D/Mannequin_Body"
@onready var head = $"Rig_Medium/Skeleton3D/Mannequin_Head"
@onready var leg_left = $"Rig_Medium/Skeleton3D/Mannequin_LegLeft"
@onready var leg_right = $"Rig_Medium/Skeleton3D/Mannequin_LegRight"
@onready var meshes = [arm_left, arm_right, body, head, leg_left, leg_right]

@onready var buildings = $"../../Buildings"
@onready var right_hand = $"Rig_Medium/Skeleton3D/Right Hand"

@onready var animation_tree : AnimationTree = $AnimationTree
#@onready var nav_agent = $NavigationAgent3D

@onready var villager_info = $"Villager Info"
@onready var hitpoints_label = $"Villager Info/MarginContainer/VBoxContainer/HBoxContainer/Hitpoints"
@onready var rest_label = $"Villager Info/MarginContainer/VBoxContainer/Hunger"
@onready var hunger_label = $"Villager Info/MarginContainer/VBoxContainer/Rest"
@onready var condition_label = $"Villager Info/MarginContainer/VBoxContainer/Condition"

@onready var resource_info = $"../../Strategy_UI/Resource Info"


func _ready() -> void:
	animation_tree.active = true
	villager_info.visible = false
	'''
	var agent = GoapAgent.new()
	#defines which goals are available for the villager
	agent.init(self, [
		KeepFedGoal.new()
	])
	add_child(agent)
	'''

	
func _process(delta: float) -> void:
	rest_label.text = str(int (rest))
	hunger_label.text = str(int (hunger))
	hitpoints_label.text = str(int (live))
	condition_label.text = str(animation_tree.get("parameters/Villager_A/playback").get_current_node())
	

func _physics_process(delta: float) -> void:
	if(alive):
		var current_state = animation_tree.get("parameters/Villager_A/playback").get_current_node()
		if current_state != "Villeger_Idle_A": 
			if velocity.length() < 0.1:
				animation_tree.set("parameters/Villager_A/conditions/idle", true)
		if(rest > 0):
			rest -= 5 * delta
		else:
			get_hit(5 * delta)
		
		if(hunger > 0):
			hunger -= 5 * delta
		else:
			get_hit(5 * delta)
	else:
		pass
	if(live <= 0 && alive):
		reset_all_animation_conditions()
		animation_tree.set("parameters/Villager_A/conditions/is_dead", true)
		alive = false
		resource_info.set_villager_count(resource_info.get_villager_count() - 1)
	else:
		if current_path.is_empty():
			pass
		else:
			var target_pos = current_path[0]	
			velocity = global_position.direction_to(target_pos) * speed
			
			 # Wenn wir den Punkt fast erreicht haben, lösche ihn aus der Liste
			if global_position.distance_to(target_pos) < 5:
				current_path.remove_at(0)
				if current_path.is_empty():
					velocity = Vector3.ZERO
			move_and_slide()
	
'''
func move_to(direction, delta):
	velocity = Vector3.ZERO
	nav_agent.set_target_position(job_location)
	var next_nav_point = nav_agent.get_next_path_position()
	velocity = (next_nav_point - global_transform.origin.normalized() * speed)
  # warning-ignore:return_value_discarded
	move_and_collide(direction * delta * 100)
'''	
	
func move_to_target(target_point_id: int):
	var start_id = world.astar.get_closest_point(global_position)
	current_path = world.astar.get_point_path(start_id, target_point_id)

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
	right_hand.plate_food_A2.visible = true
	reset_all_animation_conditions()
	animation_tree.set("parameters/Villager_A/conditions/use_item", true)
	right_hand.plate_food_A2.visible = false
	right_hand.plate_food_B2.visible = true
	right_hand.plate_food_B2.visible = false

func loctate_nearest_tavern():
	var taverns = buildings.find_children("Tavern*", "Area3D",false)
	var nearest_tavern = null
	
	for tavern in taverns:
		if self.origin.distance_to(nearest_tavern.origin) > self.origin.distance_to(tavern.origin) or nearest_tavern == null:
			nearest_tavern = tavern
	return nearest_tavern

func set_job(_job: String, _job_location: Area3D):
	job = _job
	job_location = _job_location
	
func set_home(_home_location: Area3D):
	home_location = _home_location

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


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_right_click"):
		for mesh in meshes:
			mesh.material_override = null
			villager_info.visible = false
		chosen = false

func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout
