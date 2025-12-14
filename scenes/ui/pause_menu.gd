extends PanelContainer



func _ready() -> void:
	visible = false


func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			if(visible == false):
				visible = true
				get_tree().paused = true
			elif(visible == true):
				visible = false
				get_tree().paused = false


func _on_main_menu_pressed() -> void:
	pass # Replace with function body.


func _on_save_game_pressed() -> void:
	pass # Replace with function body.


func _on_load_game_pressed() -> void:
	pass # Replace with function body.


func _on_options_pressed() -> void:
	pass # Replace with function body.


func _on_exit_game_pressed() -> void:
	get_tree().quit()
