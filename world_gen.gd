extends Node3D

# Dependencies
@export var object_placer : ObjectPlacer
@onready var map = $GridMap

@export_category("Tiles")
@export var tiles : Array[TileMeshData]
@export var biome_weights : Array[float]
@export var tile_size : float = 1 #Scalar for different size tiles, leave at 1 if not using your own mesh

@export_category("Generation")
@onready var map_seed_starting : int = 0 #starting seed for the generation of the map tiles
@export var map_seed_world : int #saves the map as an reusable 
@export_range(0, 99, 1) var map_radius: int = 5 #gives the dimensions for the map
@export var resource_noise : FastNoiseLite
@export var min_field_quantity : int #influences how big the patches of the same terrain get
@export var max_field_quantity : int
@export var peacefullness_world : int #influences how many dangerous tiles and in which quantity they can be together

@export_category("Hills")
@export_range(0.1, 1.0) var hill_height = 0.5
@export_range(0.0, 1.0) var heightmap_treshold = 0.6
@export var heightmap_noise : FastNoiseLite

@export_category("Water/Ocean")
@export var ocean_tile : TileMeshData
@export var ocean_noise : FastNoiseLite
@export_range(-1.0, -0.1) var ocean_height = -0.4
@export_range(0.0, 1.0) var ocean_treshold : float




func _ready() -> void:
	#init_seed()
	generate_world()

# Randomize if no seed has been set
func init_seed():
	if map_seed_starting == 0 or map_seed_starting == null:
		var rng = RandomNumberGenerator.new()
		
		print("Randomizing seed")
		resource_noise.set_seed(rng.randi()) #New map_seed for this generation
		heightmap_noise.set_seed(rng.randi())
		ocean_noise.set_seed(rng.randi())
	else:
		
		resource_noise.set_seed(map_seed_starting)
		heightmap_noise.set_seed(map_seed_starting)
		ocean_noise.set_seed(map_seed_starting)

# creates the whole map
func generate_world():
	var starttime = Time.get_ticks_msec()
	var interval = {"Start of Generation!" : starttime}
	
	## Get all positions through the gridmapper
	var mapper = GridMapper.new()
	var positions = mapper.hex_spiral(Vector3i(0,0,0), 10) #creates a hexagonal hex_map with the middle point (0,0,0) and radius 10
	positions = mapper.hex_to_2d_map(1, positions) #converts the map from the hex grid to the normal 3d grid
	interval["Calculate Map Positions -- "] = Time.get_ticks_msec()
	
	## Create the tiles
	map.create_map(positions) #creates the map on the grid
	interval["Create Map -- "] = Time.get_ticks_msec()
	
	## Fill all gaps
	#map.modify_map(positions)
	interval["Modify Map -- "] = Time.get_ticks_msec()
	
	print_generation_results(starttime, interval)
	
# This mess of a function loops through the timing results of generate_world and prints them
func print_generation_results(start : float, dict : Dictionary):
	print("\n")
	var last_val = start
	var total = 0
	for key in dict:
		var val = dict[key]
		if val == start:
			print(key)
			continue
		var passed = val - last_val
		print(key, str(passed) + "ms")
		last_val = val
		total += passed
	var s = "ms"
	if total > 999: 
		s = "s"
		total *= 0.001
	print("Total completion time: ", total, s)
