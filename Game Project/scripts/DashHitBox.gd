extends Area2D

###############################################################################
# dash slash sword skill
###############################################################################

# skill description:
# range: low
# damage: low
# mana cost: low
# aoe piercing: yes

const SPEED = 400
var velocity = Vector2()

# detect collision with enemies
func _on_HitBox_body_entered(body):
	if "Enemy" in body.name:
		var base_damage = 15
		var knockback_intensity = 0
		body.hurt(base_damage, knockback_intensity)
		#queue_free()
#		play_explosion_sfx()
#		$CollisionShape2D.queue_free()
#		$CPUParticles2D.queue_free()
#		$ProjectileSprite.visible = false

# plays a explosion sfx
func play_explosion_sfx():
	SoundManager.play("res://audio/sfx/explosion.ogg")

# despawn timer
func _on_Timer_timeout():
	queue_free()
	pass
