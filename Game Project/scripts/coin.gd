extends Area2D


const GRAVITY = 18
var velocity = Vector2(0, 0)
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# detects if player touches the coin
# TODO: add score
# TODO: add sound
func _on_Area2D_body_entered(body):
	if "Warrior" in body.name:
		queue_free()

#TODO: add gravity

# TODO: add homing functionality
