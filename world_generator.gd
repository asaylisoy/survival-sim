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
#üretilen veriyi saklama -bu da ayni kaliyor- 
#sadece icindeki anahtarlar artik (x,z) degil, (q,r) olacak
var height_data = {}

func _ready():
	generate_world_data()
	#...diger fonksiyonlar daha eklenecek
	print("altigen dünya veri haritasi olusturuldu.")
	
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

#func get_hex_area(center, radius):#TODO

#func get_neighbors(center):
	

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
	else:
		#hic uygun yer bulunmadiysa merkezi sec ve uyari ver
		print("UYARI: Üs kurmaya uygun yer bulunamadi, base merkeze kuruldu!")
		base_grid_pos = Vector2i(0, 0)
		
	#3. ADIM DÜZLESTIRME
	if not height_data.has(base_grid_pos): return
	var height_at_base = height_data[base_grid_pos]
	var flatten_radius = 3
	var area_to_flatten = get_hex_area#TODO
	
	
