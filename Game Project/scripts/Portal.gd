extends Node2D

export (String) var target_scene 
onready var scene_changer = get_tree().get_root().get_node("/root/Controller/HUD/SceneChanger")


func _on_Area2D_body_entered(body):
	if body.name == "Player" && target_scene != "":
		scene_changer.change_scene(target_scene)
		
