extends Node

class_name GoapAgent
# This script integrates the actor (NPC) with goap.
# In your implementation you could have this logic
# inside your NPC script.
var _goals
var _current_goal = null
var _current_plan : Array
var _current_plan_step = 0
var _actor


func _process(delta):
	var goal = _get_best_goal()
	#checks if current goal is still highest priority. 
	if _current_goal == null or goal != _current_goal:
	# You can set in the blackboard any relevant information you want to use
	# when calculating action costs and status. I'm not sure here is the best
	# place to leave it, but I kept here to keep things simple.
		var blackboard = {
			"position": _actor.position,
			"actor": _actor,
			"is_hungry": _actor.is_hungry,
			"is_sleepy": _actor.is_sleepy,
			"home_location": _actor.home_location
			}
		# if not, requests the action planner a plan for new high priority goal
		_current_goal = goal
		_current_plan = Goap.get_action_planner().get_plan(_current_goal, blackboard)
		_current_plan_step = 0
	else:
		_follow_plan(_current_plan, delta)


# initializes the actor and its goals
func init(actor, goals: Array):
	_actor = actor
	_goals = goals


# Returns the highest priority goal available.
func _get_best_goal():
	var highest_priority

	for goal in _goals:
		if goal.is_valid(_actor) and (highest_priority == null or goal.priority(_actor) > highest_priority.priority(_actor)):
			highest_priority = goal
	return highest_priority


# Executes plan (the current list of actions) and delta is the time since last loop
func _follow_plan(plan, delta):
	if plan.size() == 0: #cancels for an empty plan
		return

	var is_step_complete = plan[_current_plan_step].perform(_actor, delta) # Every action has perform function, which returns true when complete
	if is_step_complete and _current_plan_step < plan.size() - 1: #if done agent can jump to the next action in the list.
		_current_plan_step += 1
