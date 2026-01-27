class_name ResourceNode extends StaticBody3D

@export var resource_type: String = "WOOD"#for stones do "STONES" in inspector
@export var amount: int = 50

func harvest(request_amount: int) -> int:
	var given_amount = 0
	
	if amount >= request_amount:
		given_amount = request_amount
		amount -= request_amount
	else:
		given_amount = amount
		amount = 0
	if amount <= 0:
		queue_free()
	
	return given_amount
