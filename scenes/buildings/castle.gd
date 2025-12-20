extends Area3D

@onready var raycasts = [$RayCast3D,$RayCast3D2,$RayCast3D3,$RayCast3D4, $RayCast3D5,$RayCast3D6, $RayCast3D7]
@export var meshes : Array[MeshInstance3D]
@onready var area = $Castle 

@onready var villagers = $"../../Villagers"

@onready var resource_info = $"../../Strategy_UI/Resource Info"
@onready var building_info = $"Building Info"


@onready var green_mat = preload("res://scenes/buildings/placement_green.tres")
@onready var red_mat = preload("res://scenes/buildings/placement_red.tres")
@onready var highlight_mat = preload("res://scenes/buildings/highlight.tres")

@onready var villager =  preload("res://scenes/characters/villager_a.tscn")

var villager_population : Array[CharacterBody3D]

var chosen = false

var instance
var spawning = false
var can_spawn = false
var radius = 2

func check_placement() -> bool:
	for ray in raycasts:
		if !ray.is_colliding():
			placement_red()
			return false
	if self.get_overlapping_areas():
		placement_red()
		return false
	placement_green()
	return true


func placed() -> void:
	for mesh in meshes:
			mesh.material_override = null
	for ray in raycasts:
		ray.queue_free()


func placement_red() -> void:
	for mesh in meshes:
			mesh.material_override = red_mat


func placement_green() -> void:
	for mesh in meshes:
			mesh.material_override = green_mat


func _on_mouse_entered() -> void:
	if !chosen:
		for mesh in meshes:
			mesh.material_override = highlight_mat
			building_info.visible = true


func _on_mouse_exited() -> void:
	if !chosen:
		for mesh in meshes:
				mesh.material_override = null
				building_info.visible = false


func _on_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if (event is InputEventMouseButton and event.is_pressed() and event.is_action("ui_left_click")):
		for mesh in meshes:
			mesh.material_override = highlight_mat
			building_info.visible = true
		chosen = true


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_right_click"):
		for mesh in meshes:
			mesh.material_override = null
			building_info.visible = false
		chosen = false


func _on_spawn_villager_pressed() -> void:
	if resource_info.get_villager_count() < resource_info.get_villager_limit():
		var angle = randf_range(0, 2 * PI) # Get random angle (radians)
		var offset = Vector3(cos(angle) * radius, 20, sin(angle) * radius)
		
		instance = villager.instantiate()
		villagers.add_child(instance)
		instance.transform.origin = self.position + offset
		
		var space_state = get_world_3d().direct_space_state

		var origin = self.position + offset
		var end = self.position + offset - Vector3(0, 100, 0)
		var query = PhysicsRayQueryParameters3D.create(origin, end)
		query.collide_with_areas = true

		var result = space_state.intersect_ray(query)
		
		instance.transform.origin = result.position
		var available_home = resource_info.get_available_home()
		instance.set_home(available_home)
		available_home.set_inhabitant(instance)
		
		resource_info.set_villager_count(resource_info.get_villager_count() + 1)
	else:
		print("Villager limit reached")
