extends Control

###############################################################################
# creates a screen wide fading effect for scene transitions
###############################################################################

onready var animation_player = $AnimationPlayer
onready var black = $ColorRect

# plays a black fading effect
func change_scene(path):
	yield(get_tree().create_timer(0.75), "timeout")
	animation_player.play("fade")
	yield(animation_player, "animation_finished")
	assert(get_tree().change_scene(path) == OK)
