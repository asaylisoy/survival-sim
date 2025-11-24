extends Resource
class_name GenerationSettings

@export_category("Tiles")
@export var tiles : Array[TileMeshData]
@export var biome_weights : Array[float]
@export var tile_size : float = 1 #Scalar for different size tiles, leave at 1 if not using your own mesh

@export_category("Generation")
@export var map_seed_starting : int = 0 #starting seed for the generation of the map tiles
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
