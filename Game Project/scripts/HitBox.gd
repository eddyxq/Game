extends Area2D

###############################################################################
# hitbox instanced by the player to detect attack collisions    
###############################################################################

# detects collision with enemies
func _on_HitBox_body_entered(body):
	if "Slime" in body.name:
		body.apply_damage()
	queue_free()
