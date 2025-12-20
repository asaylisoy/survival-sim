extends Area3D

@onready var raycasts = [$RayCast3D,$RayCast3D2,$RayCast3D3,$RayCast3D4]
@export var meshes : Array[MeshInstance3D]
@onready var area = $Home 

@onready var resource_info = $"../../Strategy_UI/Resource Info"

@onready var green_mat = preload("res://scenes/buildings/placement_green.tres")
@onready var red_mat = preload("res://scenes/buildings/placement_red.tres")
@onready var highlight_mat = preload("res://scenes/buildings/highlight.tres")

var inhabitants : Array[CharacterBody3D] #the house should contain 4 villagers at max

var chosen = false

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
	inhabitants.resize(4)
	resource_info.set_villager_limit(resource_info.get_villager_limit() + inhabitants.size())
	resource_info.add_home(self)


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


func _on_mouse_exited() -> void:
	if !chosen:
		for mesh in meshes:
				mesh.material_override = null


func _on_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if (event is InputEventMouseButton and event.is_pressed() and event.is_action("ui_left_click")):
		for mesh in meshes:
			mesh.material_override = highlight_mat
		chosen = true

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_right_click"):
		for mesh in meshes:
			mesh.material_override = null
		chosen = false
		
		
func get_free_space():
	for slot in inhabitants.size():
		if inhabitants[slot] == null:
			return slot
			
func set_inhabitant(_inhabitant):
	var free_space = get_free_space()
	if free_space != null:
		inhabitants[free_space] = _inhabitant
	else:
		print("Fehler bei der Wohnungssuche")
