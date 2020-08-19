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
var stun = false
var bleed = false

# detect collision with enemies
func _on_HitBox_body_entered(body):
	if "Enemy" in body.name:
		var base_damage = 15
		var knockback_intensity = 0
		body.hurt(base_damage, knockback_intensity)
		if bleed: 
			body.apply_bleed()
		if stun:
			body.apply_stun()

# plays a explosion sfx
func play_explosion_sfx():
	SoundManager.play("res://audio/sfx/explosion.ogg")

# despawn timer
func _on_Timer_timeout():
	queue_free()
	
func has_bleed_effect():
	bleed = true
	
func has_stun_effect():
	stun = true
