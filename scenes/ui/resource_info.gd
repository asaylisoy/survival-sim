extends PanelContainer


@onready var food_label = $"MarginContainer/HBoxContainer/HBoxContainer/Food"
@onready var villager_label = $"MarginContainer/HBoxContainer/HBoxContainer2/Villager"

@onready var wood_label = $"MarginContainer/HBoxContainer/HBoxContainer3/Wood"
@onready var stone_label = $"MarginContainer/HBoxContainer/HBoxContainer4/Stone"

func _process(_delta: float) -> void:
	
	# 1. food
	if food_label:
		food_label.text = str(GameManager.food)
		
	# 2. villager
	if villager_label:
		villager_label.text = str(GameManager.villager_count)
		
	# 3. wood
	if wood_label:
		wood_label.text = str(GameManager.wood)
		
	# 4. stone
	if stone_label:
		stone_label.text = str(GameManager.stone)



func get_villager_limit() -> int:
	return GameManager.villager_limit

func set_villager_limit(value: int): 
	GameManager.villager_limit = value

func get_available_home():
	return GameManager.get_available_home()

func add_home(home: Area3D):
	GameManager.homes.append(home)

func get_food_amount() -> int:
	return GameManager.food
	
func set_food_amount(value: int): 
	GameManager.food = value
	
func get_villager_count() -> int:
	return GameManager.villager_count
	
func set_villager_count(value: int): 
	GameManager.villager_count = value
