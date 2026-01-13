extends GoapGoal

class_name KeepFedGoal

func get_clazz(): return "KeepFedGoal"


# This is not a valid goal when hunger is less than 50.
func is_valid(actor) -> bool:
	return actor.get_hunger()  > 50 and actor.resource_info.get_food_amount() > 0


func priority(actor) -> int:
	return 1 if actor.get_hunger()  < 75 else 2


func get_desired_state() -> Dictionary:
	return {
		"is_hungry": false
	}
