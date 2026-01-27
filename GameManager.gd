extends Node

var wood: int = 0
var stone: int = 0
var food: int = 10
var villager_count: int = 0 #lets say there is 0 villager at the beginning
var villager_limit: int = 0
var homes: Array[Area3D] = []

func add_resource(type: String, amount: int):
	if type == "WOOD":
		wood += amount
	elif type == "STONE":
		stone += amount
	elif type == "FOOD":
		food += amount

func get_available_home():
	for home in homes:
		if home.has_method("get_free_space") and home.get_free_space() != null:
			return home
	return null
