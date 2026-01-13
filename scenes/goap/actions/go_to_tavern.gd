extends Node
# Action Contract
class_name GoToTavernAction

@onready var buildings = $"../../Buildings"
@onready var resource_info = $"../../Strategy_UI/Resource Info"

var nearest_tavern


func get_clazz(): return "GoToTavernAction"

#This indicates if the action should be considered or not.
func is_valid() -> bool:
	if (resource_info.get_food_amount() > 0):
		return true
	else:
		return false


# Action Cost. This is a function so it handles situational costs, when the world
# state is considered when calculating the cost.
func get_cost(actor) -> int:
	nearest_tavern = actor.loctate_nearest_tavern()
	
	return actor.get_distance(nearest_tavern)


# Action requirements.
func get_preconditions() -> Dictionary:
	return {}


# What conditions this action satisfies
func get_effects() -> Dictionary:
	return {"is_in_tavern": true}


# Action implementation called on every loop.
# "actor" is the NPC using the AI
# "delta" is the time in seconds since last loop.
#
# Returns true when the task is complete.
func perform(actor, delta) -> bool:
	if resource_info.get_food_amount() == 0:
		return false
	else:
		actor.set_target_resource(nearest_tavern)
		return false
