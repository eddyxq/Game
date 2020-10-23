extends RigidBody2D

###############################################################################
# a coin object that is dropped by killing enemies     
###############################################################################

const CHASE_SPEED = 256

var target = null 

func _physics_process(delta):
	if target != null:
		var direction = calculate_target_direction()
		self.position += direction * CHASE_SPEED * delta

# detects if coin touches the player
func _on_Area2D_body_entered(body):
	if "Player" in body.name:
		play_coin_sfx()
		queue_free()
		
# starts moving the coin towards the player
func start_chase(player):
	target = player

# distance between player and coin
func calculate_target_direction():
	var direction = target.transform.origin - self.transform.origin
	return direction.normalized()

# plays a coin sfx
func play_coin_sfx():
	SoundManager.play("res://audio/sfx/coin.ogg")
