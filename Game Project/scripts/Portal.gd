extends Node2D

export (String) var target_scene 

func _on_Area2D_body_entered(body):
	if body.name == "Warrior" && target_scene != "":
		var _scene = get_tree().change_scene(target_scene)
