extends RigidBody2D

# determines the drop rate
# range: 0.00 - 1.00
var drop_rate = 1


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# changes the drop
func set_drop_rate(new_drop_rate):
	drop_rate = new_drop_rate

# drops a chest in the parent of the calling node
# Return: true if chest dropped, otherwise false
func drop(calling_node):
	if (drop_rate >= randf()):
		calling_node.get_parent().add_child(self)
		position = calling_node.get_global_position()
		return true
	return false 

# opens chest when player is presses 'f' near it
# TODO: add loot, pause player movement?
func _input(_event):
	if (Input.is_action_just_pressed("ui_interact")):
		$DespawnTimer.start()
		$KeyPress.visible = false
		var bodies = $Area2D.get_overlapping_bodies()
		for body in bodies:
			if body.name == "Player":
				$AnimationPlayer.play("open")

# plays a chest opening sfx
func play_chest_sfx():
	SoundManager.play("res://audio/sfx/chest.ogg")

# removes chest from scene after it is opened
func _on_DespawnTimer_timeout():
	queue_free()
