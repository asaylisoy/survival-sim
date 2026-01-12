extends Node

class_name ResourceNode

enum resource_type {
	WOOD,
	STONE
}
var amount

func harvest(damage: int):
	amount -= damage
	if amount <= 0:
		queue_free()






# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
