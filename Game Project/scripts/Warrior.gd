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
var movement_speed

const min_mp = 0
const max_mp = 5

# references to child nodes
onready var http : HTTPRequest = $HTTPRequest
onready var audio_player = $AudioStreamPlayer2D
#donready var iframe_timer = $IFrame

# range attack hit box
const PROJECTILE = preload("res://scenes/Projectile.tscn")
# world constants
const GRAVITY = 18

var velocity = Vector2()
var timer
var player_sprite
var state_machine

# flags for player states
var anim_finished = true # used to lock out player inputs for a short amount of time (0.3s) so prevent key spamming
var invincible = false # true when player has invincible frames

var skill_slot1_off_cooldown = true

# called when the node enters the scene tree for the first time
func _ready():
	# Firebase.get_document("users/%s" % Firebase.user_info.id, http)
	setup_state_machine()

# animation logic
func animation_loop(down, attack, skill1):
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
		elif !down && velocity.length() == 0: 
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
	if attack and is_on_floor():
		movement_speed = base_speed * 0.5
	else:
		 movement_speed = base_speed * 1.5

	# translates player horizontally when left or right key is pressed
	velocity.x = (-int(left) + int(right)) * movement_speed
	# apply translations to the player
	velocity = move_and_slide(velocity, Vector2(0,-1))

# applies a blinking damage effect to the player
func hurt():
	if !invincible:
		Global.health -= 25
		if Global.health > 0:
			invincible = true
			$IFrame.start()
			# blinks 4 times in 0.1 second intervals
			for i in 4:
				$Sprite.set_modulate(Color(1,1,1,0.5)) 
				yield(get_tree().create_timer(0.1), "timeout")
				$Sprite.set_modulate(Color(1,1,1,1)) 
				yield(get_tree().create_timer(0.1), "timeout")

func update_hitbox_location():
	if $HitBox.position.x < 0 && dir == DIRECTION.E:
		$HitBox.position.x *= -1
	elif $HitBox.position.x > 0 && dir == DIRECTION.W:
		$HitBox.position.x *= -1

func play_animation(anim):
	state_machine.travel(anim)

# apply delay to prevents attack spamming
func apply_delay():
	$AnimationDelay.start()

# plays a sword swing sfx
func play_atk_sfx():
	audio_player.stream = load("res://audio/sfx/sword_swing.ogg")
	audio_player.play()


func toggle_hitbox():
	$HitBox/CollisionShape2D.disabled = not $HitBox/CollisionShape2D.disabled


# activates skill 1 shooting a ranged projectile
func distance_blade():
	var projectile = PROJECTILE.instance()
	get_parent().add_child(projectile)
	projectile.position = $PositionCenter.global_position
	projectile.set_projectile_direction(dir)

# initializes the state machine for managing animation state changes
func setup_state_machine():
	state_machine = $AnimationTree.get("parameters/playback")

# decreases player mp by integer amount passed in as amount
func consume_mp(amount):
	Global.mana -= amount
	if Global.mana < min_mp:
		Global.mana = min_mp

# increases player mp by integer amount passed in as amount
func restore_mp(amount):
	Global.mana += amount
	if Global.mana > max_mp:
		Global.mana = max_mp

# auto mana recovery over time
func _on_ManaRecovery_timeout():
	if Global.mana < max_mp:
		Global.mana += 1

func _on_Skill1Cooldown_timeout():
	skill_slot1_off_cooldown = true

func _on_AnimationDelay_timeout():
	anim_finished = true



func _on_HTTPRequest_request_completed(_result, response_code, _headers, body):
	var result_body := JSON.parse(body.get_string_from_ascii()).result as Dictionary
	match response_code:
		404:
			return
		200:
			Global.profile = result_body.fields


func _on_IFrame_timeout():
	invincible = false



func _on_HitBox_body_entered(body):
	if "Slime" in body.name:
		body.apply_damage()
	#queue_free()

