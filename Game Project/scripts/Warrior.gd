extends KinematicBody2D

###############################################################################
# warrior class
###############################################################################

enum DIRECTION {
	N, # north/up
	S, # south/down
	W, # west/left
	E, # east/right
}

# default player direction
var dir = DIRECTION.E

# speed stats
const jump_speed = 320
const base_speed = 100
const run_speed_modifier = 1.4
const boost_speed_modifier = 2.5
const atkmove_speed_modifier = 0.3

var movement_speed

const min_mp = 0
const max_mp = 6
const min_hp = 0
const max_hp = 100

var health = max_hp
var mana = max_mp

onready var UI = get_tree().get_root().get_node("/root/Controller/HUD/UI")

# references to child nodes
onready var http : HTTPRequest = $HTTPRequest

# skill scenes
const PROJECTILE = preload("res://scenes/Projectile.tscn")
const ROCK_STRIKE = preload("res://scenes/RockStrike.tscn")
# world constants
const GRAVITY = 18

var velocity = Vector2()
var timer
var player_sprite
var state_machine

# flags for player states
var anim_finished = true # used to lock out player inputs for a short amount of time (0.2s) so prevent key spamming
var invincible = false # true when player has invincible frames

var skill_slot1_off_cooldown = true
var skill_slot2_off_cooldown = true
var skill_slot3_off_cooldown = true
var skill_slot4_off_cooldown = true
var skill_slot5_off_cooldown = true
var item_slot1_off_cooldown = true
var item_slot2_off_cooldown = true

# called when the node enters the scene tree for the first time
func _ready():
	# Firebase.get_document("users/%s" % Firebase.user_info.id, http)
	setup_state_machine()

# animation logic
func animation_loop(attack, skill1, skill2, skill3, skill4, skill5, item1, item2):
	print(mana)
	# disable animations while player is attacking
	if anim_finished: 
		# moving state
		if velocity.x != 0 && is_on_floor():
			play_animation("sprint")
		# jumping state
		elif velocity.y < 0 && !is_on_floor():
			play_animation("jump")
		# falling state
		elif velocity.y > 0 && !is_on_floor():
			play_animation("fall")
		# idle state
		elif velocity.length() == 0: 
			play_animation("idle")

		# attacking state
		if attack && is_on_floor():
			anim_finished = false
			play_animation("attack3")
			apply_delay()
		elif skill1 && skill_slot1_off_cooldown:
			anim_finished = false
			skill_slot1_off_cooldown = false
			$Skill1Cooldown.start()
			play_animation("distance_blade")
			apply_delay()
		elif skill2 && skill_slot2_off_cooldown:
			anim_finished = false
			skill_slot2_off_cooldown = false
			$Skill2Cooldown.start()
			$Skill2Cooldown/Skill2Duration.start()
			$GhostInterval.start()
			movement_speed = base_speed * boost_speed_modifier
			play_animation("buff")
			apply_delay()
		elif skill3 && skill_slot3_off_cooldown && is_on_floor():
			anim_finished = false
			skill_slot3_off_cooldown = false
			$Skill3Cooldown.start()
			play_animation("rock_strike")
			apply_delay()
		elif skill4 && skill_slot4_off_cooldown:
			pass
		elif skill5 && skill_slot5_off_cooldown:
			pass
		elif item1 && item_slot1_off_cooldown:
			item_slot1_off_cooldown = false
			$Item1Cooldown.start()
			play_potion_sfx()
			# potion fully heals the player
			UI.health_bar.increase(health, max_hp - health)
			health = max_hp
		elif item2 && item_slot2_off_cooldown:
			item_slot2_off_cooldown = false
			$Item2Cooldown.start()
			play_potion_sfx()
			mana = max_mp
			UI.mana_bar.update_bar(mana)

# movement logic
func movement_loop(attack, up, left, right):
	# pulls player downwards
	velocity.y += GRAVITY
	update_hitbox_location()
	# update players direction 
	if right:
		dir = DIRECTION.E 
		$Sprite.flip_h = false
	elif left:
		dir = DIRECTION.W
		$Sprite.flip_h = true

	if anim_finished:
		if is_on_floor():
			velocity.y = 0
			# Jumping
			if up:
				velocity.y = -jump_speed

	# reduces movement speed during attack animation
	if skill_slot2_off_cooldown:
		if attack and is_on_floor():
			movement_speed = base_speed * atkmove_speed_modifier
		else:
			 movement_speed = base_speed * run_speed_modifier

	# translates player horizontally when left or right key is pressed
	velocity.x = (-int(left) + int(right)) * movement_speed
	# apply translations to the player
	velocity = move_and_slide(velocity, Vector2(0,-1))

# applies a blinking damage effect to the player
func hurt(dmg):
	if !invincible:
		play_hurt_sfx()
		UI.health_bar.decrease(health, dmg)
		health -= dmg
		if health > 0:
			invincible = true
			$IFrame.start()
			# blinks 4 times in 0.1 second intervals
			for i in 4:
				$Sprite.set_modulate(Color(1,1,1,0.5)) 
				yield(get_tree().create_timer(0.1), "timeout")
				$Sprite.set_modulate(Color(1,1,1,1)) 
				yield(get_tree().create_timer(0.1), "timeout")

# ensures the hitbox is always in front
func update_hitbox_location():
	if $HitBox.position.x < 0 && dir == DIRECTION.E:
		$HitBox.position.x *= -1
	elif $HitBox.position.x > 0 && dir == DIRECTION.W:
		$HitBox.position.x *= -1

# travel to input state in animation tree
func play_animation(anim):
	state_machine.travel(anim)

# apply delay to prevents attack spamming
func apply_delay():
	$AnimationDelay.start()

# plays a sword swing sfx
func play_atk_sfx():
	SoundManager.play_sfx(load("res://audio/sfx/sword_swing.ogg"), 0)
	
# plays a swoosh sfx
func play_swoosh_sfx():
	SoundManager.play_sfx(load("res://audio/sfx/swoosh.ogg"), 0)
	
# plays a rock sfx
func play_rock_sfx():
	SoundManager.play_sfx(load("res://audio/sfx/rock.ogg"), 0)
	
# plays a footstep sfx
func play_footstep_sfx():
	SoundManager.play_sfx(load("res://audio/sfx/footstep.ogg"), 0)

# plays a hurt sfx
func play_hurt_sfx():
	SoundManager.play_sfx(load("res://audio/sfx/hurt.ogg"), 0)
	
# plays a invalid sfx
func play_invalid_sfx():
	SoundManager.play_sfx(load("res://audio/sfx/invalid.ogg"), 0)
	
# plays a invalid sfx
func play_death_sfx():
	SoundManager.play_sfx(load("res://audio/sfx/death.ogg"), 0)
	
# plays a potion sfx
func play_potion_sfx():
	SoundManager.play_sfx(load("res://audio/sfx/potion.ogg"), 0)
	
# hitbox for detecting normal attack collisions with enemies
func toggle_hitbox():
	$HitBox/CollisionShape2D.disabled = not $HitBox/CollisionShape2D.disabled

# activates skill 1 shooting a ranged projectile
func distance_blade():
	var projectile = PROJECTILE.instance()
	get_parent().add_child(projectile)
	projectile.position = $PositionCenter.global_position
	projectile.set_projectile_direction(dir)

# activates skill 3 summoning rock pillars from below
func rock_strike():
	var projectile = ROCK_STRIKE.instance()
	get_parent().add_child(projectile)
	if dir == DIRECTION.E:
		projectile.position.x = $PositionCenter.global_position.x + 64
	else: 
		projectile.position.x = $PositionCenter.global_position.x - 64
	projectile.position.y = $PositionCenter.global_position.y + 36
	projectile.set_projectile_direction(dir) 

# initializes the state machine for managing animation state transitions
func setup_state_machine():
	state_machine = $AnimationTree.get("parameters/playback")

# decreases player mp by integer amount passed in as amount
func consume_mp(amount):
	mana -= amount
	if mana < min_mp:
		mana = min_mp
	UI.mana_bar.update_bar(mana)

# increases player mp by integer amount passed in as amount
func restore_mp(amount):
	mana += amount
	if mana > max_mp:
		mana = max_mp

# auto health recovery over time
func _on_HealthRecovery_timeout():
	if health < max_hp && health > -1:
		UI.health_bar.increase(health, 1)
		health += 1

# auto mana recovery over time
func _on_ManaRecovery_timeout():
	if mana < max_mp && health > -1:
		mana += 1
		UI.mana_bar.update_bar(mana)

# timer used to manage attaking state, preventing animation overlap
func _on_AnimationDelay_timeout():
	anim_finished = true

# timer used to countdown until skill1 is availiable
func _on_Skill1Cooldown_timeout():
	skill_slot1_off_cooldown = true

# timer used to countdown until skill2 is availiable
func _on_Skill2Cooldown_timeout():
	skill_slot2_off_cooldown = true

# timer used to countdown the effects of skill2 buff
func _on_Skill2Duration_timeout():
	$GhostInterval.stop()
	movement_speed = base_speed * run_speed_modifier

# timer used to countdown until skill3 is availiable
func _on_Skill3Cooldown_timeout():
	skill_slot3_off_cooldown = true

# timer used to countdown until skill4 is availiable
func _on_Skill4Cooldown_timeout():
	skill_slot4_off_cooldown = true

# timer used to countdown until skill5 is availiable
func _on_Skill5Cooldown_timeout():
	skill_slot5_off_cooldown = true

# loads player profile from database
func _on_HTTPRequest_request_completed(_result, response_code, _headers, body):
	var result_body := JSON.parse(body.get_string_from_ascii()).result as Dictionary
	match response_code:
		404:
			return
		200:
			Global.profile = result_body.fields

# player becomes invicible for a moment after getting hurt
func _on_IFrame_timeout():
	invincible = false

# applies damage when hitbox collide with enemies
func _on_HitBox_body_entered(body):
	if "Enemy" in body.name:
		body.apply_damage(1)

# time used to countdown the animation of skill2 buff
func _on_ghost_timer_timeout():
	var ghost_sprite = preload("res://scenes/PlayerGhost.tscn").instance()
	get_parent().add_child(ghost_sprite)
	ghost_sprite.position = position
	ghost_sprite.frame = $Sprite.frame
	ghost_sprite.flip_h = $Sprite.flip_h

# toggles a circular lighting effect around the player
func set_light_enabled(status):
	$Light2D.set_enabled(status)
