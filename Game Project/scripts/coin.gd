extends RigidBody2D


# plays a coin sfx
func play_coin_sfx():
	SoundManager.play("res://audio/sfx/coin.ogg")
	
	
# detects if coin touches the player
# TODO: add score
func _on_Area2D_body_entered(body):
	if "Player" in body.name:
		play_coin_sfx()
		queue_free()
