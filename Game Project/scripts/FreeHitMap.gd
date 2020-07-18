extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# orient enemies in the right position
# set hp to infinite (kinda)
func _ready():
	$Enemy.disable_movement()
	$Enemy.max_health = 100000000
	
	$Enemy2.disable_movement()
	$Enemy2.max_health = 100000000
	$Enemy2.turn_around()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
