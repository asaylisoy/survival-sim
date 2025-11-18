extends Node3D

#world variables
var map_width #gives the dimensions for the map
var map_heigth 
var min_field_quantity #influences how big the patches of the same terrain get
var max_field_quantity
var seed_starting #starting seed for the generation of the map tiles
var seed_world #saves the map as an reusable 
var peacefullness_world #influences how many dangerous tiles and in which quantity they can be together

#tile variables
var field_type #the type can be water, grasland or mountain
var ressource_type #the type can be wood, stone, iron, gold, animal
var ressource_quantity #the quantity can be small, medium or big
var peacefullness_tile #can be peacefull or dangerous discribed in either a positve, zero or negative number

func seed_generation(seed_input: String) -> String:
	#checks if the player put an seed code in
	if seed_input == null:
		#generates an seed automatic
		for i in 7:
			#gives eauch tile values
			i.field_type
			
	return seed_starting

func world_generation():
	for i 
