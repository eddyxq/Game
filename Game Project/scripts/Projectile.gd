extends Area2D

###############################################################################
# distance blade warrior skill
###############################################################################

const SPEED = 400
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
	
# detect collision with enemies
func _on_Projectile_body_entered(body):
	if "Enemy" in body.name:
		body.hurt(2, 10)
		play_explosion_sfx()
		$CollisionShape2D.queue_free()
		$CPUParticles2D.queue_free()
		$ProjectileSprite.visible = false

# shoots the projectile
func shoot_projectile(delta, dir):
	if dir == DIRECTION.W:
		velocity.x = -(SPEED * delta)
		$ProjectileSprite.play("shoot_left")
	elif dir == DIRECTION.E:
		velocity.x = SPEED * delta 
		$ProjectileSprite.play("shoot_right")
	translate(velocity)
	
# plays a explosion sfx
func play_explosion_sfx():
	SoundManager.play_sfx(load("res://audio/sfx/explosion.ogg"), 1)

# despawn timer
func _on_Timer_timeout():
	queue_free()
