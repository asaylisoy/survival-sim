extends Node
# Action Contract
class_name GoToTavernAction

var nearest_tavern


func get_clazz(): return "GoToTavernAction"

#This indicates if the action should be considered or not.
func is_valid() -> bool:
	var info = Engine.get_main_loop().current_scene.find_child("Resource Info", true, false)
	if (info.get_food_amount() > 0):
		return true
	else:
		return false


# Action Cost. This is a function so it handles situational costs, when the world
# state is considered when calculating the cost.
func get_cost(blackboard) -> int:
	var actor = blackboard.get("actor")
	
	nearest_tavern = actor.locate_nearest_tavern()
	print(str(actor) + ": nearest tavern is " + str(nearest_tavern))
	
	if nearest_tavern == null:
		return 1000
	
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
	if actor.resource_info.get_food_amount() == 0:
		return false
	else:
		if nearest_tavern == null:
			return false
		else:
			nearest_tavern = actor.locate_nearest_tavern()
			actor.set_target_resource(nearest_tavern)
			var distance = actor.global_position.distance_to(nearest_tavern.global_position)
			if distance < 10:
				print("Angekommen in der Taverne!")
				return true
			return true
	return false
