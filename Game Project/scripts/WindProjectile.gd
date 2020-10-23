extends Area2D

###############################################################################
# distance whirlwind slash skill
###############################################################################

# skill description:
# range: long
# damage: low
# mana cost:  medium
# aoe piercing: yes

const SPEED = 120
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
		var base_damage = 1
		var knockback_intensity = 5
		body.hurt(base_damage, knockback_intensity, 30, "default")
		play_explosion_sfx()
		body.show_hit_splat()

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
