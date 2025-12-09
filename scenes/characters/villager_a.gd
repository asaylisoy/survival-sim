extends CharacterBody3D
#variables
var home_location #gives the home building of the villager or null if the villager is homeless
var job #gives the job class of the villager or null if the villager is jobless
var job_location #gives the job building of the villager or null if the villager is jobless
var rest = 100 #shows the rested state of the villager. goes from 0 to 100
var live = 100  #shows the livepoints of a villager. goes from 0 to 100
var happyness = 100 #shows the happyness of a villager. goes from 0 to 100
var hunger = 100 #shows the food saturation of the villager. goes from 0 to 100
var speed

@onready var animation_tree : AnimationTree = $AnimationTree
@onready var nav_agent = $NavigationAgent3D

'''
func _ready() -> void:
	var agent = GoapAgent.new()
	#defines which goals are available for the villager
	agent.init(self, [
		KeepFedGoal.new()
	])
	add_child(agent)
'''
func _physics_process(delta: float) -> void:
	pass
	
	
func move_to(direction, delta):
	velocity = Vector3.ZERO
	nav_agent.set_target_position(job_location)
	var next_nav_point = nav_agent.get_next_path_position()
	velocity = (next_nav_point - global_transform.origin.normalized() * speed)
  # warning-ignore:return_value_discarded
	move_and_collide(direction * delta * 100)


func update_animation_parameters():
	if(velocity == Vector3.ZERO):
		animation_tree["parameters/Villager_A/conditions/idle"] = true
		
	
func get_hit():
	pass



func loctate_nearest_tavern():
	pass
