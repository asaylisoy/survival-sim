extends Node3D
class_name Tile

enum biome_type {Grassland, Forest_Wood, Forest_Wild, Stone, Iron, Gold, Water_River, Water_Ocean, Mountain}
var biome : String
var mesh_data = TileMeshData
var pos_data = PositionData

var neighbors = []
var placeable = true

var debug_label : Label3D


#tile variables
var field_type #the type can be water, grasland or mountain
var ressource_type #the type can be wood, stone, iron, gold, animal
var ressource_quantity #the quantity can be small, medium or big
var peacefullness_tile #can be peacefull or dangerous discribed in either a positve, zero or negative number
