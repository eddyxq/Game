extends Area2D

###############################################################################
# distance blade sword skill
###############################################################################

# skill description:
# range: medium
# damage: low
# mana cost: low
# aoe piercing: no

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
		var base_damage = 15
		var knockback_intensity = 4
		var knockback_frames = 10
		body.hurt(base_damage, knockback_intensity, knockback_frames)
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
	SoundManager.play("res://audio/sfx/explosion.ogg")

# despawn timer
func _on_Timer_timeout():
	queue_free()
