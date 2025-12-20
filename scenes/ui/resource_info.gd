extends PanelContainer

var food_amount = 10
var villager_count = 0
var villager_limit = 0

var homes : Array[Area3D]

@onready var food_amount_label = $"MarginContainer/HBoxContainer/FoodAmount"
@onready var villager_label = $"MarginContainer/HBoxContainer/Villager"

func _process(delta: float) -> void:
	food_amount_label.text = str(food_amount)
	villager_label.text = str(villager_count) + " / " + str(villager_limit)

func get_food_amount() -> int:
	return food_amount
	
func set_food_amount(_food_amount): 
	food_amount = _food_amount
	
func get_villager_count() -> int:
	return villager_count
	
func set_villager_count(_villager_count): 
	villager_count = _villager_count

func get_villager_limit() -> int:
	return villager_limit
	
func set_villager_limit(_villager_limit): 
	villager_limit = _villager_limit


func get_available_home():
	for home in homes:
		if home.get_free_space() != null:
			return home
		

func add_home(home: Area3D):
	homes.append(home)
