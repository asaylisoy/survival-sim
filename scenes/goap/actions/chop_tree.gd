extends GoapAction

class_name ChopTreeAction

func get_clazz(): return "ChopTreeAction"

#searches for a tree in the area around the woodcutter hut
func is_valid() -> bool:
	return WorldState.get_elements("tree").size() > 0

#calculates the way to the tree dynamic plus the time for chopping it
func get_cost(blackboard) -> int:
	if blackboard.has("position"):
		var closest_tree = WorldState.get_closest_element("tree", blackboard)
		return int(closest_tree.position.distance_to(blackboard.position) / 7)
	return 3

#the woodcutter needs no preconditions for chopping a tree
func get_preconditions() -> Dictionary:
	return {}

#cutting wood get wood
func get_effects() -> Dictionary:
	return {
		"has_wood": true
	}

lets the woodcutter chop the wood
func perform(actor, delta) -> bool:
	var _closest_tree = WorldState.get_closest_element("tree", actor)

	if _closest_tree:
		if _closest_tree.position.distance_to(actor.position) < 10:
				if actor.chop_tree(_closest_tree):
					WorldState.set_state("has_wood", true)
					return true
				return false
		else:
			actor.move_to(actor.position.direction_to(_closest_tree.position), delta)

	return false
