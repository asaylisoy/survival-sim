extends Area3D

@onready var raycasts = [$RayCast3D,$RayCast3D2,$RayCast3D3,$RayCast3D4]
@export var meshes : Array[MeshInstance3D]
@onready var area = $Tavern

@onready var green_mat = preload("res://scenes/buildings/placement_green.tres")
@onready var red_mat = preload("res://scenes/buildings/placement_red.tres")


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
