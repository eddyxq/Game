extends Control

###############################################################################
# stage clear menu
###############################################################################

# restarts the stage
func _on_ResumeButton_pressed():
	var _scene = get_tree().change_scene("res://scenes/environment/Map1_Frozen.tscn")
