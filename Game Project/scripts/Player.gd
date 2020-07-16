extends KinematicBody2D

###############################################################################
# warrior class
###############################################################################

onready var UI = get_tree().get_root().get_node("/root/Controller/HUD/UI")
onready var http : HTTPRequest = $HTTPRequest

enum DIRECTION {
	N, # north/up
	S, # south/down
	W, # west/left
	E, # east/right
}

# user profile sstructure
var profile = {
	"player_name": {},
	"player_lv": {},
	"player_health": {},
	"player_strength": {},
	"player_defense": {},
	"player_critical": {},
	"player_exp": {}
} 

# combat stats
const max_hp = 100
const min_hp = 0
const max_mp = 6
const min_mp = 0
var health = max_hp
var mana = max_mp
var strength = 10
var crit_rate = 30

# speed stats
const jump_speed = 330
const run_speed_modifier = 1.3
const boost_speed_modifier = 2.3
const atkmove_speed_modifier = 0
var base_speed = 50
var max_speed = 100
var min_speed = 0
var acceleration_rate = 14
var movement_speed # final actual speed after calculations

# player orientation
var dir = DIRECTION.E # default right facing 

# world constants
const GRAVITY = 18

var velocity = Vector2()
var state_machine

# flags for player states
var anim_finished = true # used to lock out player inputs for a short amount of time (0.2s) so prevent key spamming
var invincible = false # true when player has invincible frames

# flags that restrict usage of skills and items
var skill_slot0_off_cooldown = true
var skill_slot1_off_cooldown = true
var skill_slot2_off_cooldown = true
var skill_slot3_off_cooldown = true
var skill_slot4_off_cooldown = true

var item_slot1_off_cooldown = true
var item_slot2_off_cooldown = true

# mana cost of each skill
var skill0_mana_cost = 1
var skill1_mana_cost = 1
var skill2_mana_cost = 1
var skill3_mana_cost = 1
var skill4_mana_cost = 1

# flag to prevent spamming of invalid skill use sfx
var invalid_sfx = true

# called when the node enters the scene tree for the first time
func _ready():
	# Firebase.get_document("users/%s" % Firebase.user_info.id, http)
	setup_state_machine()

# animation logic
func animation_loop(attack,skill0, skill1, skill2, skill3, skill4, item1, item2):
	# disable animations while player is attacking
	if anim_finished: 
		# moving state
		if velocity.x != 0 && is_on_floor():
			if !skill_slot0_off_cooldown:
				play_animation("sprint")
			else:
				play_animation("run")
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
		if !attack:
			toggle_hitbox_off()
		if attack && is_on_floor():
			anim_finished = false
			play_animation("attack3")
			apply_delay()
		elif skill0 && skill_slot0_off_cooldown:
			if mana >= skill0_mana_cost:
				UI.skill_slot0.start_cooldown()
				anim_finished = false
				skill_slot0_off_cooldown = false
				$GhostInterval.start()
				movement_speed = max_speed * boost_speed_modifier
				play_animation("buff")
				apply_delay()
			else:
				play_invalid_sfx()
				invalid_sfx = false
		elif skill1 && skill_slot1_off_cooldown:
			if mana >= skill1_mana_cost:
				UI.skill_slot1.start_cooldown()
				anim_finished = false
				skill_slot1_off_cooldown = false
				play_animation("distance_blade")
				apply_delay()
			else:
				play_invalid_sfx()
				invalid_sfx = false
		elif skill2 && skill_slot2_off_cooldown:
			if mana >= skill2_mana_cost && is_on_floor():
				UI.skill_slot2.start_cooldown()
				anim_finished = false
				skill_slot2_off_cooldown = false
				play_animation("rock_strike")
				apply_delay()
			else:
				play_invalid_sfx()
				invalid_sfx = false
		elif skill3 && skill_slot3_off_cooldown:
			if mana >= skill3_mana_cost:
				#UI.skill_slot3.start_cooldown()
				anim_finished = false
				play_animation("bow_attack")
				apply_delay()
			else:
				play_invalid_sfx()
				invalid_sfx = false
		# not yet implemented
		elif skill4 && skill_slot4_off_cooldown:
			if mana >= skill4_mana_cost:
				pass
			else:
				pass
		elif item1 && item_slot1_off_cooldown:
			UI.item_slot1.start_cooldown()
			item_slot1_off_cooldown = false
			play_potion_sfx()
			# potion fully heals the player's health
			UI.health_bar.increase(health, max_hp - health)
			health = max_hp
		elif item2 && item_slot2_off_cooldown:
			UI.item_slot2.start_cooldown()
			item_slot2_off_cooldown = false
			play_potion_sfx()
			# potion fully heals the player's mana
			mana = max_mp
		UI.mana_bar.update_bar(mana)

# movement logic
func movement_loop(attack, up, left, right, skill3):
	# apply gravity
	velocity.y += GRAVITY
	
	# update players direction 
	update_hitbox_location()
	if right:
		dir = DIRECTION.E 
		$Sprite.flip_h = false
	elif left:
		dir = DIRECTION.W
		$Sprite.flip_h = true

	# air state
	if anim_finished:
		if is_on_floor():
			velocity.y = 0
			if up: # jump
				velocity.y = -jump_speed
				play_footstep_sfx()

	# reduces movement speed during attack animation
	if skill_slot0_off_cooldown:
		if attack and is_on_floor():
			movement_speed = base_speed * atkmove_speed_modifier
		else:
			 movement_speed = base_speed * run_speed_modifier
			
	# acceleration effect
	if !left && !right:
		base_speed -= acceleration_rate *2
		if base_speed < min_speed:
			base_speed = min_speed
	else:
		base_speed += acceleration_rate
		if base_speed > max_speed:
			base_speed = max_speed

	# translates player horizontally when left or right key is pressed
	velocity.x = (-int(left) + int(right)) * movement_speed
	
	# restrict movement during certain attack/skill
	if attack or skill3:
		velocity.x = 0
	
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
	SoundManager.play("res://audio/sfx/sword_swing.ogg")
	
# plays a swoosh sfx
func play_swoosh_sfx():
	SoundManager.play("res://audio/sfx/swoosh.ogg")
	
# plays a rock sfx
func play_rock_sfx():
	SoundManager.play("res://audio/sfx/rock.ogg")
	
# plays a footstep sfx
func play_footstep_sfx():
	SoundManager.play("res://audio/sfx/footstep.ogg")

# plays a hurt sfx
func play_hurt_sfx():
	SoundManager.play("res://audio/sfx/hurt.ogg")
	
# plays a invalid sfx
func play_invalid_sfx():
	if invalid_sfx:
		SoundManager.play("res://audio/sfx/invalid.ogg")
		$InvalidSFX.start()
	
# plays a invalid sfx
func play_death_sfx():
	SoundManager.play("res://audio/sfx/death.ogg")
	
# plays a potion sfx
func play_potion_sfx():
	SoundManager.play("res://audio/sfx/potion.ogg")
	
# plays a coin sfx
func play_coin_sfx():
	SoundManager.play("res://audio/sfx/coin.ogg")
	
# plays a buff sfx
func play_buff_sfx():
	SoundManager.play("res://audio/sfx/buff.ogg")
	
# enables normal attack hitbox
func toggle_hitbox_on():
	$HitBox/CollisionShape2D.disabled = false

# disables normal attack hitbox
func toggle_hitbox_off():
	$HitBox/CollisionShape2D.disabled = true

# activates skill 1 shooting a ranged projectile
func distance_blade():
	var projectile = preload("res://scenes/player/BladeProjectile.tscn").instance()
	get_parent().add_child(projectile)
	projectile.position = $PositionCenter.global_position
	projectile.set_projectile_direction(dir)

# activates skill 2 summoning rock pillars from below
func rock_strike():
	var projectile = preload("res://scenes/player/RockStrike.tscn").instance()
	get_parent().add_child(projectile)
	if dir == DIRECTION.E:
		projectile.position.x = $PositionCenter.global_position.x + 64
	else: 
		projectile.position.x = $PositionCenter.global_position.x - 64
	projectile.position.y = $PositionCenter.global_position.y + 36
	projectile.set_projectile_direction(dir) 
	
# activates skill 3 shooting a ranged projectile
func piercing_arrow():
	var projectile = preload("res://scenes/player/ArrowProjectile.tscn").instance()
	get_parent().add_child(projectile)
	projectile.position = $PositionCenter.global_position
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

# ***temporarily disabled: might be adjusted or removed for game balance***
# to enable to go HealthRecovery node and check off Autostart
# auto health recovery over time
func _on_HealthRecovery_timeout():
	if health < max_hp && health > -1:
		UI.health_bar.increase(health, 1)
		health += 1

# ***temporarily disabled: might be adjusted or removed for game balance***
# to enable to go ManaRecovery node and check off Autostart
# auto mana recovery over time
func _on_ManaRecovery_timeout():
	if mana < max_mp && health > -1:
		mana += 1
		UI.mana_bar.update_bar(mana)

# timer used to manage attaking state, preventing animation overlap
func _on_AnimationDelay_timeout():
	anim_finished = true

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
	
# allows another invalid sfx to be played
func _on_InvalidSFX_timeout():
	invalid_sfx = true

# applies damage when hitbox collide with enemies
func _on_HitBox_body_entered(body):
	if "Enemy" in body.name:
		body.hurt(5, 0)

# time used to countdown the animation of skill0 buff
func _on_ghost_timer_timeout():
	var ghost_sprite = preload("res://scenes/player/PlayerGhost.tscn").instance()
	get_parent().add_child(ghost_sprite)
	ghost_sprite.position = position
	ghost_sprite.frame = $Sprite.frame
	ghost_sprite.flip_h = $Sprite.flip_h

# toggles a circular lighting effect around the player
func set_light_enabled(status):
	$Light2D.set_enabled(status)

# changes center of gravity to player so coins will be attracted to it
func _on_Area2D_body_entered(body):
	if body.name == "Coin":
		$Area2D.set_space_override_mode(3)
		$Area2D.set_gravity_is_point(true)
		$Area2D.set_gravity_vector(Vector2(0, 0))
		play_coin_sfx()

# resets the cooldown of slot utilized allowing reuse
func reset_skill_cooldown(skill_slot_num):
	# skill num 0 thruough 4 are skill slots
	# skill num 5 and 6 are item slots
	if skill_slot_num == 0:
		skill_slot0_off_cooldown = true
		$GhostInterval.stop()
		movement_speed = max_speed * run_speed_modifier
	elif skill_slot_num == 1:
		skill_slot1_off_cooldown = true
	elif skill_slot_num == 2:
		skill_slot2_off_cooldown = true
	elif skill_slot_num == 3:
		skill_slot3_off_cooldown = true
	elif skill_slot_num == 4:
		skill_slot4_off_cooldown = true
	elif skill_slot_num == 5:
		item_slot1_off_cooldown = true
	elif skill_slot_num == 6:
		item_slot2_off_cooldown = true
