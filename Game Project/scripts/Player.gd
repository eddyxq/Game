extends KinematicBody2D

###############################################################################
# player class
###############################################################################

onready var UI = get_tree().get_root().get_node("/root/Controller/HUD/UI")
onready var http : HTTPRequest = $HTTPRequest
onready var tree_state = $AnimationTree.get("parameters/playback")

# player direction
enum DIRECTION {
	N, # north/up
	S, # south/down
	W, # west/left
	E, # east/right
}

# possible weapons and stances
enum STANCE {
	FIST, 
	SWORD, 
	BOW
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

# player orientation
var stance = STANCE.FIST # default fist stance

# world constants
const GRAVITY = 18

# flags for player states
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

# velocity vector
var velocity = Vector2()

# animation tree
var state_machine

# variables used for ledge climbing
var isTouchingLedge = false
var highRayCast = null  # not used at the moment, likely remove in the future
var lowRayCast = null   # not used at the moment, likely remove in the future

# flag use to signal that the player hit an enemy
var recentHit = false

var movement_enabled = true
var dash_enabled = false
var dash_velocity = 0
var canDash = true

# called when the node enters the scene tree for the first time
func _ready():
	# Firebase.get_document("users/%s" % Firebase.user_info.id, http)
	$AnimationTree.active = true
	setup_state_machine()

# animation logic
func animation_loop(attack,skill0, skill1, skill2, skill3, skill4, item1, item2, switch):
	# DEBUG: used to display current animation state, uncomment line below to use
	# print(tree_state.get_current_node())
	
	# disable animations while player is attacking
	move() # moving state
	jump() # jumping state
	fall() # falling state
	idle() # idle state
	attack(attack) # attacking state
	detect_skill_activation(skill0, skill1, skill2, skill3, skill4) # pass input
	item(item1, item2) # item activation
	grab_ledge()
	animate_dash()
	stance_update(switch) # stance change

# movement logic
# TODO refactor movement loop to reduce condition checks
func movement_loop(attack, up, left, right, skill3, dash):
	
	if movement_enabled:
		horizontal_movement(right, left) # horizontal translation
		update_hitbox_location() # update hitbox
		enable_dash(dash)
		detect_ledge()
		if not isTouchingLedge:
			if not dash_enabled:
				apply_gravity() # pull player downwards
				vertical_movement(up) # vertical translation
				update_speed_modifier(attack) # restricts movement during certain actions
				apply_accel_decel(left, right) # acceleration effect
				
			apply_translation(left, right, attack, skill3)

func animate_dash():
	if dash_enabled:
		play_animation("dash_placeholder")

func enable_dash(dash):
	if not canDash and is_on_floor():
		canDash = true
	
	if canDash and dash:
		if not dash_enabled and velocity.y != 0:
			#print("dash enabled")
			canDash = false
			dash_enabled = true
			dash_velocity = DASH_SPEED
			if dir == DIRECTION.W:
				dash_velocity *= -1
			# freezes the player midair in the y axis
			velocity.y = 0
			$DashTimer.start()
			

# applies a blinking damage effect to the player
func hurt(dmg):
	if !invincible:
		play_hurt_sfx()
		UI.health_bar.decrease(health, dmg)
		health -= dmg
		if health > 0:
			invincible = true
			blinking_damage_effect()

# ensures the hitbox is always in front
func update_hitbox_location():
	if $HitBox.position.x < 0 && dir == DIRECTION.E:
		$HitBox.position.x *= -1
	elif $HitBox.position.x > 0 && dir == DIRECTION.W:
		$HitBox.position.x *= -1

# update player's direction and sprite orientation
func horizontal_movement(right, left):
	if right:
		dir = DIRECTION.E 
		$Sprite.flip_h = false
	elif left:
		dir = DIRECTION.W
		$Sprite.flip_h = true

# update player's y velocity
func vertical_movement(up):
	if is_on_floor():
		velocity.y = 0
		if up: # jump
			emit_foot_dust()
			velocity.y = -jump_speed
			play_footstep_sfx()

# travel to input state in animation tree
func play_animation(anim):
	state_machine.travel(anim)

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
# calls screen shaker whenever damage was critical
func _on_HitBox_body_entered(body):
	if "Enemy" in body.name:
		recentHit = true
		var is_crit = body.hurt(5, 0)
		if is_crit:
			#pass
			$Camera2D/ScreenShaker.start()

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
	if body.get_filename() == "res://scenes/item/Coin.tscn":
		#$Area2D.set_space_override_mode(3)
		#$Area2D.set_gravity_is_point(true)
		#$Area2D.set_gravity_vector(Vector2(0, 0))
		#play_coin_sfx()
		body.start_chase(self)
		
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

# toggles the player's stance between fist and sword
func toggle_stance():
	if stance == STANCE.FIST:
		draw_sword()
	elif stance == STANCE.SWORD:
		sheath_sword()

# draws sword weapon
func draw_sword():
	stance = STANCE.SWORD
	play_animation("idle_sword")

# put away sword
func sheath_sword():
	stance = STANCE.FIST
	play_animation("idle_fist")

# left and right movement
func move():
	if velocity.x != 0 && is_on_floor():
		if !skill_slot0_off_cooldown:
			play_animation("sprint")
			emit_foot_dust()
		else:
			if stance == STANCE.FIST:
				play_animation("run")
			elif stance == STANCE.SWORD:
				play_animation("sword_run")

# player jumps in air 
func jump():
	if velocity.y < 0 && !is_on_floor():
		play_animation("jump")

# player enters fall state while mid air
func fall():
	if velocity.y > 0 && !is_on_floor():
		play_animation("fall")

# player is in idle state when they are not moving
func idle():
	if velocity.length() == 0: 
		if stance == STANCE.FIST:
			play_animation("idle_fist")
		elif stance == STANCE.SWORD:
			play_animation("idle_sword")

# regular attacking skills
func attack(attack):
	if !attack:
		toggle_hitbox_off()
	if attack && is_on_floor():
		if stance == STANCE.FIST:
			play_animation("fist_attack4")
		elif stance == STANCE.SWORD:
			play_animation("sword_attack3")

# sends skill input 
func detect_skill_activation(skill0, skill1, skill2, skill3, skill4):
	skill0(skill0)
	skill3(skill3)
	if stance == STANCE.SWORD:
		skill1(skill1)
		skill2(skill2)
		skill4(skill4)

# sprint buff
func skill0(skill0):
	if skill0 && skill_slot0_off_cooldown:
		if mana >= skill0_mana_cost:
			UI.skill_slot0.start_cooldown()
			skill_slot0_off_cooldown = false
			$GhostInterval.start()
			movement_speed = max_speed * boost_speed_modifier
			play_animation("buff")
		else:
			play_invalid_sfx()
			invalid_sfx = false

# distance blade
func skill1(skill1):
	if skill1 && skill_slot1_off_cooldown:
		if mana >= skill1_mana_cost:
			UI.skill_slot1.start_cooldown()
			skill_slot1_off_cooldown = false
			play_animation("distance_blade")
		else:
			play_invalid_sfx()
			invalid_sfx = false
	
# rock strike
func skill2(skill2):
	if skill2 && skill_slot2_off_cooldown:
		if mana >= skill2_mana_cost && is_on_floor():
			UI.skill_slot2.start_cooldown()
			skill_slot2_off_cooldown = false
			play_animation("rock_strike")
		else:
			play_invalid_sfx()
			invalid_sfx = false

# piercing arrow
func skill3(skill3):
	if skill3 && skill_slot3_off_cooldown:
		if mana >= skill3_mana_cost:
			#UI.skill_slot3.start_cooldown()
			play_animation("bow_attack")
		else:
			play_invalid_sfx()
			invalid_sfx = false

# not yet implemented
func skill4(skill4):
	if skill4 && skill_slot4_off_cooldown:
		if mana >= skill4_mana_cost:
			pass
		else:
			pass

# item consumables for status recovery
func item(item1, item2):
	if item1 && item_slot1_off_cooldown:
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

# changes the stance and weapon of the player
func stance_update(switch):
	if switch:
		if stance == STANCE.FIST:
			play_animation("sword_draw")
		elif stance == STANCE.SWORD:
			play_animation("sword_sheath")

# translates the player downwards every frame at the rate of gravity
func apply_gravity():
	velocity.y += GRAVITY

# applies a acceleration and deceeleration effect
func apply_accel_decel(left, right):
	if !left && !right:
		base_speed -= acceleration_rate *2
		if base_speed < min_speed:
			base_speed = min_speed
	else:
		base_speed += acceleration_rate
		if base_speed > max_speed:
			base_speed = max_speed

const DASH_SPEED = 50 * 12
# restricts the movement ability of the player depending on actions
func update_speed_modifier(attack):
	if skill_slot0_off_cooldown:
		if attack and is_on_floor():
			movement_speed = base_speed * atkmove_speed_modifier
		else:
			movement_speed = base_speed * run_speed_modifier

# update velocity and vectors
# TODO refactor function so it does not need to know about dash
func apply_translation(left, right, attack, skill3):
	
	# translates player horizontally when left or right key is pressed
	if not dash_enabled:
		velocity.x = (-int(left) + int(right)) * movement_speed
		# restrict movement during certain attack/skill
		if attack or skill3:
			velocity.x = 0
	else:
		velocity.x = dash_velocity
		
	# apply translations to the player
	velocity = move_and_slide(velocity, Vector2(0,-1))

# upon receiving damage player sprite blinks
func blinking_damage_effect():
	$IFrame.start()
	# blinks 4 times in 0.1 second intervals
	for i in 4:
		$Sprite.set_modulate(Color(1,1,1,0.5)) 
		yield(get_tree().create_timer(0.1), "timeout")
		$Sprite.set_modulate(Color(1,1,1,1)) 
		yield(get_tree().create_timer(0.1), "timeout")

###############################################################################
# sound effects
###############################################################################

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
func play_death_sfx():
	SoundManager.play("res://audio/sfx/death.ogg")
	
# plays a potion sfx
func play_potion_sfx():
	SoundManager.play("res://audio/sfx/potion.ogg")
	
# plays a coin sfx
func play_coin_sfx():
	SoundManager.play("res://audio/sfx/coin.ogg")
	
# plays a punch sfx
func play_punch_sfx():
	SoundManager.play("res://audio/sfx/punch.ogg")
	
# plays a buff sfx
func play_buff_sfx():
	SoundManager.play("res://audio/sfx/buff.ogg")
	
# plays a invalid sfx
func play_invalid_sfx():
	if invalid_sfx:
		SoundManager.play("res://audio/sfx/invalid.ogg")
		$InvalidSFX.start()
	

func update_ledge_grab_direction():
	# flip raycast if it does not correspond to player direction
	var lowRayCastDirection = $LowerEdgeDetect.get_cast_to()
	# only checks one ray cast since both raycast should have the same direction
	if (dir == DIRECTION.E and lowRayCastDirection.x < 0) or (dir == DIRECTION.W and lowRayCastDirection.x > 0):
		lowRayCastDirection.x *= -1
		$LowerEdgeDetect.set_cast_to(lowRayCastDirection)
		
		var highRayCastDirection = $HigherEdgeDetect.get_cast_to()
		highRayCastDirection.x *= -1
		$HigherEdgeDetect.set_cast_to(highRayCastDirection)
		#print("raycast direction flipped")

# TODO: needs a better way to identify blocks in the stage
# detects whether an player is close to an edge
# an edge is detected when lower raycast intersects with a block while upper ray cast does not
func is_ledge_detected():
	var lowerCollision = $LowerEdgeDetect.get_collider()
	var higherCollision = $HigherEdgeDetect.get_collider()
	
	if lowerCollision != null and higherCollision == null:
		#print(lowerCollision.get_name())
		if lowerCollision.get_name() == "Blocks":
			highRayCast = $LowerEdgeDetect.get_collision_point()
			var absolute_y = abs(int(highRayCast.y))
			var new_y = absolute_y + (16 - (absolute_y % 16))
			if (highRayCast.y < 0):
				new_y *= -1
				new_y += 16
			highRayCast.y = new_y - 32
			self.position = highRayCast 
			#print("new position:", highRayCast)
			return true
	return false

func detect_ledge():
	update_ledge_grab_direction()
	isTouchingLedge = is_ledge_detected()
	# if player is touching ledge then movement is disabled
	# hence opposite boolean values
	movement_enabled = not isTouchingLedge
	
	
func move_forward_after_climb():
	if dir == DIRECTION.E:
		self.position.x += 8
	else:
		self.position.x -= 8
	
	isTouchingLedge = false
	movement_enabled = true

func grab_ledge():
	if isTouchingLedge:
		play_animation("ledge_grab_placeholder")
		
# freezes the frame if the player hit something
# freezes frame for 100 milliseconds
func freeze_hit_frame():
	if recentHit:
		OS.delay_msec(50)
		recentHit = false

# creates dust particles after player movements
func emit_foot_dust():
	var dust_particles = preload("res://scenes/player/DustParticle.tscn").instance()
	dust_particles.set_as_toplevel(true)
	if dir == DIRECTION.E:
		dust_particles.scale.x = 1
	elif dir == DIRECTION.W:
		dust_particles.scale.x = -1
	dust_particles.global_position = $FeetPosition.global_position
	add_child(dust_particles)


func _on_DashTimer_timeout():
	dash_enabled = false
	velocity = Vector2.ZERO
