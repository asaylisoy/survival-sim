extends Node3D

#variables
var home_location #gives the home building of the villager or null if the villager is homeless
var job #gives the job class of the villager or null if the villager is jobless
var job_location #gives the job building of the villager or null if the villager is jobless
var rest = 100 #shows the rested state of the villager. goes from 0 to 100
var live = 100  #shows the livepoints of a villager. goes from 0 to 100
var happyness = 100 #shows the happyness of a villager. goes from 0 to 100
var food = 100 #shows the food saturation of the villager. goes from 0 to 100


func _process(delta: float) -> void:
	if food < 20:
		#
	if food < 20:
		#
