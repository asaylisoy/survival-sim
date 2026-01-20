extends GoapGoal

class_name KeepRestGoal

func get_clazz(): return "KeepRestGoal"


# This is not a valid goal when hunger is less than 50.
func is_valid(actor) -> bool:
	return actor.get_rest()  < 50


func priority(actor) -> int:
	return 1 if actor.get_rest()  < 25 else 2


func get_desired_state() -> Dictionary:
	return {
		"is_sleepy": false
	}
