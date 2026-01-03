extends Node3D

#artik bir kare degil, merkezden yayilan bir petek yapisi var
#bu sayi, en merkezden en distaki petege kadar kac petek olacagini belirler
@export var world_radius: int = 100
#tile_size yerine hex_size kullaniyoruz
#bu, altigen modelinin merkezinden sivri tepesine kadar olan uzakligidir
@export var hex_size: float = 1.0
#yükseklik haritasi ayarlari -bunlar ayni kaliyor- 
@export var noise: FastNoiseLite
@export var height_multiplier: float = 15.0
#for the randomized placement of mountains and trees we use another noise
#determines the possibility of tree placement on a grass tile and mountain placement on a dirt tile
@export var decoration_noise: FastNoiseLite


# ---SCENE LIBRARY (PRELOADS)---

#BUILDINGS
const MAIN_CASTLE_SCENE = preload("res://scenes/buildings/castle_main.tscn")
const STOREHOUSE_SCENE = preload("res://scenes/buildings/storehouse.tscn")
const SMALL_HOUSE_SCENE = preload("res://scenes/buildings/home.tscn")
const BLACKSMITH_SCENE = preload("res://scenes/buildings/blacksmith.tscn")
#HEX TILES
const HEX_GRASS_SCENE = preload("res://scenes/hextiles/hex_grass.tscn")
const HEX_WATER_SCENE = preload("res://scenes/hextiles/hex_water.tscn")
const HEX_DIRT_SCENE = preload("res://scenes/hextiles/hex_dirt.tscn")
#ENVIRONMENT
const TREES_CUT_SCENE = preload("res://scenes/environment/trees_cut.tscn")
const TREES_LARGE_SCENE = preload("res://scenes/environment/trees_large.tscn")
const TREES_MEDIUM_SCENE = preload("res://scenes/environment/trees_medium.tscn")
const TREES_SMALL_SCENE = preload("res://scenes/environment/trees_small.tscn")
const MOUNTAINA_SCENE = preload("res://scenes/environment/mountainA.tscn")
const MOUNTAINB_SCENE = preload("res://scenes/environment/mountainB.tscn")
const MOUNTAINC_SCENE = preload("res://scenes/environment/mountainC.tscn")
#CHARACTERS
const BARBARIAN_SCENE = preload("res://scenes/characters/barbarian.tscn")
const KNIGHT_SCENE = preload("res://scenes/characters/knight.tscn")


# ---NAVIGATION (PATHFINDING) SYSTEM---

#creating a new object from AStar2D class
#this is going to be our navigation map
var astar = AStar2D.new()

func setup_navigation():
	print("Navigation network is being created...")
	astar.clear()#clear if an old map data exists
	
	#STEP 1: adding points (walkable hexes)
	#controlling every hex in height_data
	for grid_pos in height_data.keys():
		var height = height_data[grid_pos]
		
		#only heights above water surface are walkable (height >= -4)
		if height >= -4:
			
			if not occupied_hexes.has(grid_pos):
				#produce unique ID's for every single coordinate
				var point_id = get_id_from_coords(grid_pos)
			
				#calculate hex's 2D position in real world (x, z)
				#AStar wants to know the positions in real world to determine which point is closer to target
				#world_pos_3d keeps the real world position of each point
				#and navigation_pos_2d takes only the x and z values since y makes no difference in position calculations
				var world_pos_3d = hex_to_world(grid_pos)
				var navigation_pos_2d = Vector2(world_pos_3d.x, world_pos_3d.z)
			
				#add every point to the system
				#first parameter is ID and the second one is position
				astar.add_point(point_id, navigation_pos_2d)
	
	
	#get the list of IDs which was added to AStar 
	var point_ids = astar.get_point_ids()
	
	for point_id in point_ids:
		#take coordinates from IDs this time
		var grid_pos = get_coords_from_id(point_id)
		#find 6 neighbors of the current hex
		var neighbors = get_neighbors(grid_pos.x, grid_pos.y)
		
		for neighbor_pos in neighbors:
			var neighbor_id = get_id_from_coords(neighbor_pos)
			
			#checks if the neighbor is also registered in astar system (if its water)
			if astar.has_point(neighbor_id):
				
				#checks if the current hex is already connected to neighbor hexes 
				if not astar.are_points_connected(point_id, neighbor_id):
					#if not, connect them
					#astar connections are bidirectional (A->B -> B->A)
					astar.connect_points(point_id, neighbor_id)
	
	print("Navigation network is ready. Total points: ", astar.get_point_count())
	

func get_id_from_coords(point: Vector2i) -> int:
	#adding here an offset to coordinate values to get rid of the negatives
	var offset = world_radius + 1
	var q = point.x + offset
	var r = point.y + offset
	#multiplying q with 1000 here and adding r to it makes this number unique
	#uses injective encoding where one axial coordinate defines a block offset and the other defines an intra-block index
	#q is like building number and r is like apartment number
	return q * 1000 + r

func get_coords_from_id(id: int) -> Vector2i:
	var offset = world_radius + 1
	var q = id / 1000#integer division
	var r = id % 1000#remainder
	q -= offset
	r -= offset
	return Vector2i(q, r)


func hex_to_world(hex: Vector2i) -> Vector3:
	var q = hex.x
	var r = hex.y
	
	#pointy-top calculations
	var x = hex_size * (sqrt(3) * q + sqrt(3) / 2.0 * r)
	var z = hex_size * (3.0 / 2.0 * r)
	
	return Vector3(x, 0 , z)

#converts 3D world position (x, z) to axial hex coordinates (q, r)
#uses the inverse of the hex-to-pixel matrix for pointy-top hexes
func world_to_hex(world_pos: Vector3) -> Vector2i:
	#calculations for opposite of hex_to_world function by letting q and r alone
	var r = (2.0/3 * world_pos.z) / hex_size
	var q = (sqrt(3)/3 * world_pos.x - 1.0/3 * world_pos.z) / hex_size
	
	return cube_to_axial(cube_round(q, r, -q-r))

#rounds fractional cube coordinates (float) to the nearest valid integer hex
#ensures the q + r + s = 0 constraint is maintained after rounding
func cube_round(frac_q, frac_r, frac_s) -> Vector3i:
	var q = round(frac_q)
	var r = round(frac_r)
	var s = round(frac_s)
	
	var q_diff = abs(q - frac_q)
	var r_diff = abs(r - frac_r)
	var s_diff = abs(s - frac_s)
	
	#this part finds the coordinate with the largest rounding error and recalculates it
	#from the other two to guarantee the sum equals 0
	
	#lets say inputs are: q=0.51, r=0.51, s=-1.02 (Sum is 0, correct)
	#simple rounding gives: q=1, r=1, s=-1 (Sum is 1, wrong)
	#calculate errors: q_diff=0.49, r_diff=0.49, s_diff=0.02
	#largest error is in q (or r), lets say we pick q
	#discard q, recalculate from others: q = -r - s => q = -1 - (-1) = 0
	#result: q=0, r=1, s=-1 (Sum is 0, correct hex found

	if q_diff > r_diff and q_diff > s_diff:
		q = -r - s
	elif r_diff > s_diff:
		r = -q - s
	else:
		s = -q - r
	return Vector3i(q, r, s)


func get_hex_path(start_hex_coords: Vector2i, target_hex_coords: Vector2i) -> Array[Vector2i]:
	#converts coords to IDs which AStar can understand
	var start_hex_id = get_id_from_coords(start_hex_coords)
	var target_hex_id = get_id_from_coords(target_hex_coords)
	
	#checks if the path (start and target hexes) is walkable
	#if one of them is not walkable (is water) return
	if not astar.has_point(start_hex_id) or not astar.has_point(target_hex_id):
		return []
	
	#gets ID list of path from AStar like [1001, 1002, 1005, 1008...]
	var path_in_ids = astar.get_id_path(start_hex_id, target_hex_id)
	
	#we should convert ID list back into coordinate list and hold these values in this array
	#we will not use IDs but Vector2i(q, r) values
	var path_in_hex_coords: Array[Vector2i] = []
	
	for point_id in path_in_ids:
		#got the coordinates back from ID path and added them to output array
		var hex_coords = get_coords_from_id(point_id)
		path_in_hex_coords.append(hex_coords)
	
	#output example: [(0,0), (1,0), (1,-1), (2,-1)]
	return path_in_hex_coords


#bir altıgenin 6 komşusunun yönünü tutan sabit bir dizi. Bu bizim yeni offset'imiz.
const HEX_DIRECTIONS = [
	Vector2i(1, 0), Vector2i(1, -1), Vector2i(0, -1),
	Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, 1)
]


# YERLEŞTİRİLECEK ÖNEMLİ BİNALARIN LİSTESİ
const IMPORTANT_BUILDINGS = [
	MAIN_CASTLE_SCENE,
	STOREHOUSE_SCENE,
	BLACKSMITH_SCENE,
	SMALL_HOUSE_SCENE
]

#üretilen veriyi saklama -bu da ayni kaliyor- 
#sadece icindeki anahtarlar artik (x,z) degil, (q,r) olacak
var height_data = {}
#a dictionary for all of the four buildings to place
#var main_base_location: Vector2i
#var storehouse_location: Vector2i
#var home_location: Vector2i
#var blacksmith_location: Vector2i
#DICTIONARY -> KEEPS KEY-VALUE TUPLES
var building_locations = {}
#ARRAY to keep obstacles and they will be marked as unwalkable
var occupied_hexes = []

func _ready():
	randomize()
	
	noise.seed = randi()
	decoration_noise.seed = randi()
	
	noise.frequency = 0.01
	decoration_noise.frequency = 0.2
	
	generate_world_data()
	print("hexagonal world data map created")
	place_fixed_structures()#TODO
	build_the_world()#TODO
	print("hexagonal world generation completed")
	setup_navigation()
	
func generate_world_data():
	print("height data is being generated...")
	#q ve r icin, merkezden yaricap kadar her yöne giden döngüler
	for q in range(-world_radius, world_radius + 1):
		for r in range(-world_radius, world_radius + 1):
			#axial koordinatlarin bir kurali vardir: q + r + s = 0
			#haritanin altigen seklinde olmasini saglamak icin bu kurali kontrol ederiz
			var s = - q - r
			#abs() fonksiyonu bir sayinin mutlak degerini hesaplar (isaretsiz büyüklügünü)
			if abs(q) <= world_radius and abs(r) <= world_radius and abs(s) <= world_radius:
				#noise a artik q ve r adresini veriyoruz
				var noise_value = noise.get_noise_2d(q, r)
				var current_height = noise_value * height_multiplier
				#veriyi (q, r) adresiyle kaydediyoruz
				var grid_pos = Vector2i(q, r)
				height_data[grid_pos] = current_height
				

func get_distance(hexA: Vector3i, hexB: Vector3i) -> int:
	var hexA_q = hexA.x
	var hexA_r = hexA.y
	var hexA_s = hexA.z
	var hexB_q = hexB.x
	var hexB_r = hexB.y
	var hexB_s = hexB.z
	var delta_q = abs(hexA_q - hexB_q)
	var delta_r = abs(hexA_r - hexB_r)
	var delta_s = abs(hexA_s - hexB_s)
	var distance = ( (delta_q + delta_r + delta_s) / 2 )
	return distance

func axial_to_cube(axial: Vector2i) -> Vector3i:
	var q = axial.x
	var r = axial.y
	var s = - q - r
	return Vector3i(q, r, s)

func cube_to_axial(cube: Vector3i) -> Vector2i:
	return Vector2i(cube.x, cube.y)

func get_hex_area(center: Vector2i, radius) -> Array:
	var hexes_found = []
	var center_q = center.x
	var center_r = center.y
	#for loop does not include the upper bound, that is why radius + 1
	for q in range(center_q - radius, center_q + radius + 1):
		for r in range(center_r - radius, center_r + radius + 1):
			var current_hex = Vector2i(q, r)
			if get_distance(axial_to_cube(center), axial_to_cube(current_hex)) <= radius:
				hexes_found.append(current_hex)
	return hexes_found

func get_neighbors(q, r) -> Array:
	var neighbors = []
	neighbors.append(Vector2i(q + 1, r))
	neighbors.append(Vector2i(q, r + 1))
	neighbors.append(Vector2i(q - 1, r + 1))
	neighbors.append(Vector2i(q - 1, r))
	neighbors.append(Vector2i(q, r - 1))
	neighbors.append(Vector2i(q + 1, r - 1))
	return neighbors

func place_fixed_structures():	
	#1. ADIM ÜS KURMAYA UYGUN YERLERI BUL
	var suitable_locations = []
	var min_height = -3
	var max_height = 3
	
	var building_placement_radius = world_radius/2
	
	#bütün olusturulmus petek adreslerini gez
	for grid_pos in height_data.keys():
		var height = height_data[grid_pos]
		var is_height_suitable = (height >= min_height and height <= max_height)
		
		if not is_height_suitable:
			continue#if the height of the tile is not suitable, do not control further
		
		var distance_from_center = get_distance(axial_to_cube(Vector2i.ZERO), axial_to_cube(grid_pos))
		var is_location_suitable = (distance_from_center <= building_placement_radius)
		
		if is_location_suitable:
			suitable_locations.append(grid_pos)
	
	for scene_to_build in IMPORTANT_BUILDINGS:
		if suitable_locations.is_empty():
			print("Warning: There is no place for more buildings...")
			################TODO################
			#herhangi bir binadan en azindan bir tane olmali, eksik kalmamali
			break
		var random_pos = suitable_locations.pick_random()
		building_locations[scene_to_build] = random_pos
		suitable_locations.erase(random_pos)
		
		var height_at_pos = height_data[random_pos]
		#deprecated for now
		var flatten_radius = 0
		var area_to_flatten = get_hex_area(random_pos, flatten_radius)
		
		for hex_pos in area_to_flatten:
			if height_data.has(hex_pos):
				height_data[hex_pos] = height_at_pos
				#statement below is unnecessary and deprecated
				#occupied_hexes.append(hex_pos)


#param scene is the scene that will be initiated such as buildings, tiles...
#param grid_pos is the position 
func place_hex_tile(scene_to_place, grid_pos: Vector2i, custom_height = null):
	if not height_data.has(grid_pos): 
		print("Warning: The structure belonging to the scene could not be built, its location could not be found on the map")
		return

	#for logic purposes
	var map_height = height_data[grid_pos]
	#for visual purposes 
	var visual_height = map_height
	#if specific height is given(for water for example), use that
	if custom_height != null:
		visual_height = custom_height
	
	var q = grid_pos.x
	var r = grid_pos.y
	#one unit movement in q, changes X value sqrt(3) to right
	#and one unit movement in r, changes X value sqrt(3)/2 to right
	var hex_x_position_in_world = hex_size * (sqrt(3) * q + sqrt(3) / 2.0 * r)
	#one unit movement in r, changes Z value 3/2 downwards
	#moving one step in the r direction changes the Z axis value by itself
	#it makes a 60 degree angle downwards with the X axis
	#q movement does not affect the Z axis
	var hex_z_position_in_world = hex_size * (3.0 / 2.0 * r)
		
	var scene_instance = scene_to_place.instantiate()
	add_child(scene_instance)
	#Vector3 suits better, floating numbers needed for a more sensitive and smooth positioning
	scene_instance.position = Vector3(hex_x_position_in_world, visual_height, hex_z_position_in_world)


func build_the_world():
	#clear at the beginning
	occupied_hexes.clear()
	
	#a constant water level is determined, makes sense when it's equal to lowest grass' level
	const WATER_LEVEL = -4.0
	
	for scene_to_build in building_locations.keys():
		var grid_pos = building_locations[scene_to_build]
		place_hex_tile(scene_to_build, grid_pos)
		
		#append the buildings into occupied hexes
		occupied_hexes.append(grid_pos)
		
		
	for grid_pos in height_data.keys():
		#if condition below is unnecessary because when its used the tiles under the buildings remain empty 
		#if not occupied_hexes.has(grid_pos):
			var height = height_data[grid_pos]
			if height < -4:
				#now we give here constant water level as third parameter 
				#thus, water surface stays always at -4.0
				place_hex_tile(HEX_WATER_SCENE, grid_pos, WATER_LEVEL)
			elif height >= -4 and height < 4:
				place_hex_tile(HEX_GRASS_SCENE, grid_pos)
				var decoration_value = decoration_noise.get_noise_2d(grid_pos.x, grid_pos.y)
				if decoration_value > 0.2:
					var trees = [TREES_SMALL_SCENE, TREES_MEDIUM_SCENE, TREES_LARGE_SCENE]
					var random_tree = trees.pick_random()
					place_hex_tile(random_tree, grid_pos)
					#append the trees into occupied hexes
					occupied_hexes.append(grid_pos)

			else:
				place_hex_tile(HEX_DIRT_SCENE, grid_pos)
				var decoration_value = decoration_noise.get_noise_2d(grid_pos.x, grid_pos.y)
				if decoration_value > 0.3:
					var mountains = [MOUNTAINA_SCENE, MOUNTAINB_SCENE, MOUNTAINC_SCENE]
					var random_mountain = mountains.pick_random()
					place_hex_tile(random_mountain, grid_pos)
					#append the mountains into occupied hexes
					occupied_hexes.append(grid_pos)

	
	
	
