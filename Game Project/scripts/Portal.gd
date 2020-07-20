extends Node2D

export (String) var target_scene 
onready var scene_changer = get_tree().get_root().get_node("/root/Controller/HUD/SceneChanger")

# go through portal when player is presses 'f' near it
func _input(_event):
	if (Input.is_action_just_pressed("ui_interact")):
		var bodies = $Area2D.get_overlapping_bodies()
		for body in bodies:
			if target_scene != "" and body.name == "Player":
				scene_changer.change_scene(target_scene)
				break
