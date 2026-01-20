extends GoapAction

class_name GoHomeAction


func get_clazz(): return "GoHomeAction"

# This indicates if the action should be considered or not.
func is_valid() -> bool:
	return true


# Action Cost. This is a function so it handles situational costs, when the world
# state is considered when calculating the cost.
func get_cost(blackboard) -> int:
	var actor = blackboard.get("actor")
	var home_location = blackboard.get("home_location")
	
	print(str(actor) + ": home is " + str(home_location))
	return actor.get_distance(home_location)

# Action requirements.
func get_preconditions() -> Dictionary:
	return {}


# What conditions this action satisfies
func get_effects() -> Dictionary:
	return {"is_home": true}
#
# Action implementation called on every loop.
# "actor" is the NPC using the AI
# "delta" is the time in seconds since last loop.
#
# Returns true when the task is complete.
func perform(actor, _delta) -> bool:
	var home_location = actor.get_home()
	if home_location == null:
		return false
	else:
		actor.set_target_resource(home_location)
		var distance = actor.global_position.distance_to(home_location.global_position)
		if distance > 5:
			#print("Laufe nach Hause")
			return false
		else:
			print("Zuhause angekommen!")
			return true
