extends PanelContainer
@onready var buildings = $"../../Buildings"

#VBoxContainer names for hiding and showing
@onready var food_buildings = $MarginContainer/FoodBuildings
@onready var resource_buildings = $MarginContainer/ResourceBuildings
@onready var defensive_buildings = $MarginContainer/DefensiveBuildings
@onready var improvement_buildings = $MarginContainer/ImprovementBuildings
@onready var infrastructure_buildings = $MarginContainer/InfrastructureBuildings
@onready var building_types = $MarginContainer/BuildingTypes
#ItemList names for access
@onready var food_item_list = $MarginContainer/FoodBuildings/ItemList
@onready var resource_item_list = $MarginContainer/ResourceBuildings/ItemList
@onready var defensive_item_list = $MarginContainer/DefensiveBuildings/ItemList
@onready var improvement_item_list = $MarginContainer/ImprovementBuildings/ItemList
@onready var infrastructure_item_list = $MarginContainer/InfrastructureBuildings/ItemList
@onready var types_item_list = $MarginContainer/BuildingTypes/ItemList
#Building list
@onready var home =  preload("res://scenes/buildings/home.tscn")
@onready var castle =  preload("res://scenes/buildings/castle.tscn")
@onready var tavern =  preload("res://scenes/buildings/tavern.tscn")

var camera
var instance
var placing = false
var range = 1000
var can_place = false


func _ready() -> void:
	#initalizes all menus
	building_types.visible = true
	infrastructure_buildings.visible = false
	resource_buildings.visible = false
	food_buildings.visible = false
	improvement_buildings.visible = false
	defensive_buildings.visible = false
	
	camera = get_viewport().get_camera_3d()


func _process(delta: float) -> void:
	if placing:
		var mouse_pos = get_viewport().get_mouse_position() #mouseposition on the screen
		var ray_origin = camera.project_ray_origin(mouse_pos)
		var ray_end = ray_origin + camera.project_ray_normal(mouse_pos) * range
		var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
		var collision = camera.get_world_3d().direct_space_state.intersect_ray(query)
		if collision:
			instance.transform.origin = collision.position # Invalid access to property or key 'transform' on a base object of type 'previously freed'. , wenn die Kamera beim platzieren bewegt wird
			can_place = instance.check_placement()
		
	if Input.is_action_just_pressed("ui_right_click"):
		
		if(infrastructure_buildings.visible == true):
			infrastructure_buildings.visible = false
			
		elif(resource_buildings.visible == true):
			resource_buildings.visible = false
			
		elif(food_buildings.visible == true):
			food_buildings.visible = false
			
		elif(improvement_buildings.visible == true):
			improvement_buildings.visible = false
			
		elif(defensive_buildings.visible == true):
			defensive_buildings.visible = false
		
		building_types.visible = true
		

		
		
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_left_click") and can_place:
		placing = false
		can_place = false
		instance.placed()
		
	if event.is_action_pressed("ui_right_click"):
		placing = false
		can_place = false
		if(instance != null):
			instance.queue_free()

func _on_food_item_list_item_selected(index: int) -> void:
	if placing:
		instance.queue_free()
	match index:
		0:
			pass
		1:
			pass
		2:
			pass
		3:
			pass
		4:
			pass
		5:
			instance = tavern.instantiate()
	food_item_list.deselect_all()
	placing = true
	buildings.add_child(instance)


func _on_resource_item_list_item_selected(index: int) -> void:
	match index:
		0:
			pass
		1:
			pass
		2:
			pass
		3:
			pass
	resource_item_list.deselect_all()


func _on_defensive_item_list_item_selected(index: int) -> void:
	if placing:
		instance.queue_free()
	match index:
		0:
			pass
		1:
			pass
		2:
			pass
		3:
			pass
		4:
			instance = castle.instantiate()
		5:
			pass
		6:
			pass
		7:
			pass
	defensive_item_list.deselect_all()
	placing = true
	buildings.add_child(instance)


func _on_improvement_item_list_item_selected(index: int) -> void:
	match index:
		0:
			pass
		1:
			pass
		2:
			pass
	improvement_item_list.deselect_all()


func _on_infrastructure_item_list_item_selected(index: int) -> void:
	if placing:
		instance.queue_free()
	match index:
		0:
			pass
		1:
			instance = home.instantiate()
		2:
			pass
	infrastructure_item_list.deselect_all()
	placing = true
	buildings.add_child(instance)
	


func _on_type_item_list_item_selected(index: int) -> void:
	building_types.visible = false
	match index:
		0:
			infrastructure_buildings.visible = true
		1:
			resource_buildings.visible = true
		2:
			food_buildings.visible = true
		3:
			improvement_buildings.visible = true
		4:
			defensive_buildings.visible = true
	types_item_list.deselect_all()
