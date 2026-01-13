extends GoapAction

class_name GoHomeAction


func get_clazz(): return "GoHomeAction"

# This indicates if the action should be considered or not.
func is_valid() -> bool:
	return true


# Action Cost. This is a function so it handles situational costs, when the world
# state is considered when calculating the cost.
func get_cost(_blackboard) -> int:
	return 1000


# Action requirements.
func get_preconditions() -> Dictionary:
	return {}


# What conditions this action satisfies
func get_effects() -> Dictionary:
	return {}
#
# Action implementation called on every loop.
# "actor" is the NPC using the AI
# "delta" is the time in seconds since last loop.
#
# Returns true when the task is complete.
func perform(_actor, _delta) -> bool:
	actor.go_home()
	return false
