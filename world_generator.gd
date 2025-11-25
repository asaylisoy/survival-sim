extends Node3D

#artik bir kare degil, merkezden yayilan bir petek yapisi var
#bu sayi, en merkezden en distaki petege kadar kac petek olacagini belirler
@export var world_radius: int = 10
#tile_size yerine hex_size kullaniyoruz
#bu, altigen modelinin merkezinden sivri tepesine kadar olan uzakligidir
@export var hex_size: float = 1.0
#yükseklik haritasi ayarlari -bunlar ayni kaliyor- 
@export var noise: FastNoiseLite
@export var height_multiplier: float = 15.0
#üretilen veriyi saklama -bu da ayni kaliyor- 
#sadece icindeki anahtarlar artik (x,z) degil, (q,r) olacak
var height_data = {}
var main_base_location: Vector2i

func _ready():
	generate_world_data()
	#...diger fonksiyonlar daha eklenecek
	print("altigen dünya veri haritasi olusturuldu.")
	
	place_fixed_structures()#TODO
	
	build_the_world()#TODO
	
	print("Altigen dünya olusturma tamamlandi")
	
func generate_world_data():
	print("yükseklik verisi üretiliyor...")
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
				

# ---SAHNE KÜTÜPHANESI (PRELOADS)---

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

#bir altıgenin 6 komşusunun yönünü tutan sabit bir dizi. Bu bizim yeni offset'imiz.
const HEX_DIRECTIONS = [
	Vector2i(1, 0), Vector2i(1, -1), Vector2i(0, -1),
	Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, 1)
]

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
	#bu satir, her seferinde farkli rastgele sayilar üretilmesini saglar
	randomize()
	
	#1. ADIM ÜS KURMAYA UYGUN YERLERI BUL
	var suitable_locations = []
	var min_height = 3
	var max_height = 10
	
	#bütün olusturulmus petek adreslerini gez
	for grid_pos in height_data.keys():
		var height = height_data[grid_pos]
		
		#yükseklik kriterlerimize uyuyor mu
		if height >= min_height and height <= max_height:
			suitable_locations.append(grid_pos)#uyuyorsa bu adresi listeye ekle
			
	#2. ADIM UYGUN YERLERDEN BIRINI RASTGELE SEC
	var base_grid_pos: Vector2i
	if not suitable_locations.is_empty():
		#eger en az bir uygun yer bulunduysa onlardan birini rastgele sec
		base_grid_pos = suitable_locations.pick_random()
		
		##################################
		main_base_location = base_grid_pos
	else:
		#hic uygun yer bulunmadiysa merkezi sec ve uyari ver
		print("UYARI: Üs kurmaya uygun yer bulunamadi, base merkeze kuruldu!")
		base_grid_pos = Vector2i(0, 0)
		
	#3. ADIM DÜZLESTIRME
	if not height_data.has(base_grid_pos): return
	var height_at_base = height_data[base_grid_pos]
	var flatten_radius = 3
	var area_to_flatten = get_hex_area(base_grid_pos, flatten_radius)
	
	for hex_pos in area_to_flatten:
		if height_data.has(hex_pos):
			height_data[hex_pos] = height_at_base
	
	
#param scene is the scene that will be initiated such as buildings, tiles...
#param grid_pos is the position 
func place_hex_tile(scene, grid_pos: Vector2i, height: float):
	if height_data.has(grid_pos):
		var q = grid_pos.x
		var r = grid_pos.y
		height = height_data[grid_pos]


func build_the_world():
	if height_data.has(main_base_location):
		var q = main_base_location.x
		var r = main_base_location.y
		var height = height_data[main_base_location]
		#one unit movement in q, changes x value sqrt(3) to right
		#and one unit movement in r, changes x value sqrt(3)/2 to right
		var world_x = hex_size * (sqrt(3) * q + sqrt(3) / 2.0 * r)
		#one unit movement in r, changes z value 3/2 downwards
		#moving one step in the r direction changes the z axis value by itself
		#it makes a 60 degree angle downwards with the x axis
		#q movement does not affect the z axis
		var world_z = hex_size * (3.0 / 2.0 * r)
		
		
		####################################################
		var castle_instance = MAIN_CASTLE_SCENE.instantiate()
		add_child(castle_instance)
		#Vector3 suits better, floating numbers needed for a more delicate and smooth positioning
		castle_instance.position = Vector3(world_x, height, world_z)
	else:
		print("Warning: Main building could not be built, its location could not be found on the map")
	
	
	for grid_pos in height_data.keys():
		var height = height_data[grid_pos]
		if height < 0:
			var water_instance = HEX_WATER_SCENE.instantiate()
			add_child(water_instance)
		elif height >= 0 and height < 10:
			var grass_instance = HEX_GRASS_SCENE.instantiate()
			add_child(grass_instance)
		else:
			var dirt_instance = HEX_DIRT_SCENE.instantiate()
			add_child(dirt_instance)
		
	
	
	
