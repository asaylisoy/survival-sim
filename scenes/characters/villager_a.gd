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
var alive = true

@onready var buildings = $"../../Buildings"

@onready var animation_tree : AnimationTree = $AnimationTree
@onready var nav_agent = $NavigationAgent3D


#func _ready() -> void:
'''
	var agent = GoapAgent.new()
	#defines which goals are available for the villager
	agent.init(self, [
		KeepFedGoal.new()
	])
	add_child(agent)
'''
	


func _physics_process(delta: float) -> void:
	update_animation_parameters()

	if(alive):
		if(rest > 0):
			rest -= 1
		else:
			get_hit(1)
		
		if(hunger > 0):
			hunger -= 1
		else:
			get_hit(1)
		
	if(live > 0):
		animation_tree["parameters/Villager_A/conditions/is_dead"] = true
		alive = false
	
	
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
		
	
func get_hit(hit: int):
	animation_tree["parameters/Villager_A/conditions/is_hit"] = true
	live -= hit

func loctate_nearest_tavern():
	var taverns = buildings.find_children("Tavern*", "Area3D",false)
	var nearest_tavern = null
	
	for tavern in taverns:
		if self.origin.distance_to(nearest_tavern.origin) > self.origin.distance_to(tavern.origin) or nearest_tavern == null:
			nearest_tavern = tavern
	return nearest_tavern

func set_job(_job: String, _job_location: Area3D):
	job = _job
	job_location = _job_location
	
func set_home(_home_location: Area3D):
	home_location = _home_location

func get_hunger():
	return hunger
	
func get_rest():
	return rest
