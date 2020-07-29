extends RigidBody2D

const CHASE_SPEED = 256

var target = null 
var is_chasing = false
		

func _physics_process(delta):
	# homes in on the target
	if is_chasing:
		var direction = calculate_target_direction()
		#print("translating coin:", velocity*delta)
		self.position += direction * CHASE_SPEED * delta
	
# plays a coin sfx
func play_coin_sfx():
	SoundManager.play("res://audio/sfx/coin.ogg")


# detects if coin touches the player
# TODO: add score
func _on_Area2D_body_entered(body):
	if "Player" in body.name:
		play_coin_sfx()
		queue_free()
		
func start_chase(a_target):
	if a_target != null:
		target = a_target
		is_chasing = true
		# allows the coin to move through objects/platforms
		phase_through(true)
		# allows us to move the coin manually
		self.mode = RigidBody2D.MODE_KINEMATIC
		
		
# allows coins to phase through environment
func phase_through(flag):
	if flag == true:
		set_collision_mask_bit(2, false)
		set_collision_mask_bit(0, false)
	else:
		set_collision_mask_bit(2, true)
		set_collision_mask_bit(0, true)


func calculate_target_direction():
	var direction = target.transform.origin - self.transform.origin
	return direction.normalized()
