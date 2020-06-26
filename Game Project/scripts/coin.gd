extends RigidBody2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# detects if coin touches the player
# TODO: add score
# TODO: add sound
func _on_Area2D_body_entered(body):
	if "Warrior" in body.name:
		queue_free()


