extends Area2D

###############################################################################
# piercing arrow bow skill
###############################################################################

# skill description:
# range: long
# damage: high
# mana cost: high
# aoe piercing: yes

const SPEED = 600
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
		var base_damage = 25
		var knockback_intensity = 25
		body.hurt(base_damage, knockback_intensity, 30, "default")
		play_explosion_sfx()

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
