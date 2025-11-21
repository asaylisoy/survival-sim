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
				
				
			
