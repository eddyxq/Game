extends Area2D

###############################################################################
# rock strike sword skill
###############################################################################

# skill description:
# range: short
# damage: medium
# mana cost: medium
# aoe piercing: yes

var SPEED = 180
var velocity = Vector2()
var projectile_dir

enum DIRECTION{
	N,
	S,
	W,
	E,
}

func set_projectile_direction(dir):
	projectile_dir = dir

func _physics_process(delta):
	shoot_projectile(delta, projectile_dir)

# remove projectile when it leaves the screen
func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

# detect collision with enemies
func _on_Area2D_body_entered(body):
	if "Enemy" in body.name:
		var base_damage = 10
		var knockback_intensity = 5
		var knockback_frames = 10
		body.hurt(base_damage, knockback_intensity, knockback_frames)
		play_rock_sfx()
	
# shoots the projectile
func shoot_projectile(delta, dir):
	if dir == DIRECTION.W:
		self.scale.x = -0.4
		velocity.x = -(SPEED/18 * delta)
		velocity.y = -(SPEED * delta)
	elif dir == DIRECTION.E:
		self.scale.x = 0.4
		velocity.x = SPEED/18 * delta 
		velocity.y = -(SPEED * delta)
	translate(velocity)
	
# plays a rock sfx
func play_rock_sfx():
	SoundManager.play("res://audio/sfx/rock.ogg")

func _on_Timer_timeout():
	SPEED = 0
	$CollisionPolygon2D.queue_free()
	$DespawnTimer.start()


func _on_DespawnTimer_timeout():
	queue_free()
