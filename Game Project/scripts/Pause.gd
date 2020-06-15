extends Control

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().paused = not get_tree().paused
		visible = not visible

# unpauses the game stage
func _on_ResumeButton_pressed():
	get_tree().paused = not get_tree().paused
	visible = not visible

# exits the client
func _on_MenuButton_pressed():
	get_tree().quit()

# restarts the stage
func _on_RestartButton_pressed():
	var _scene = get_tree().reload_current_scene()
	get_tree().paused = not get_tree().paused
	visible = not visible
	Global.health = 100
	Global.mana = 5
