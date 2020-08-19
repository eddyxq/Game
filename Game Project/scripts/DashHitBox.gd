extends Area2D

###############################################################################
# dash slash sword skill
###############################################################################

# skill description:
# range: medium
# damage: low
# mana cost: low
# aoe piercing: yes

const SPEED = 400
var velocity = Vector2()
var stun = false
var bleed = false

# detect collision with enemies
func _on_HitBox_body_entered(body):
	if "Enemy" in body.name:
		if bleed: 
			var base_damage = 15
			var knockback_intensity = 0
			body.hurt(base_damage, knockback_intensity, 30, "default")
			body.apply_bleed()
		if stun:
			var base_damage = 15
			var knockback_intensity = 0
			body.hurt(base_damage, knockback_intensity, 30, "default")
			body.apply_stun()

# plays a explosion sfx
func play_explosion_sfx():
	SoundManager.play("res://audio/sfx/explosion.ogg")

# despawn timer
func _on_Timer_timeout():
	queue_free()

# triggers a bleeding effect
func has_bleed_effect():
	bleed = true

# trigers a stunning effect
func has_stun_effect():
	stun = true
