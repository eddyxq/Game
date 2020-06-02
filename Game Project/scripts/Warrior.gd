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
var movement_speed = 150

const min_mp = 0
const max_mp = 5

onready var http : HTTPRequest = $HTTPRequest
onready var audio_player = $AudioStreamPlayer2D

# range attack hit box
const PROJECTILE = preload("res://scenes/Projectile.tscn")
# melee attack hit box
const HITBOX = preload("res://scenes/HitBox.tscn")
# world constants
const GRAVITY = 18

var velocity = Vector2()
var timer
var player_sprite
var state_machine

# flags for player states
var anim_finished = true # used to lock out player inputs for a short amount of time (0.3s) so prevent key spamming

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
func movement_loop(up, left, right):
	# pulls player downwards
	velocity.y += GRAVITY
	
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
	
	# translates player horizontally when left or right key is pressed
	velocity.x = (-int(left) + int(right)) * movement_speed
	# apply translations to the player
	velocity = move_and_slide(velocity, Vector2(0,-1))

func hurt():
	# If something hurts our player, we can have call the hurt function and the state_machine will 'travel' the shortest path to hurt
	state_machine.travel("hurt")
	
func die():
	# Same thing as hurt()
	state_machine.travel("die")
	set_physics_process(false) # When player dies, physics process ends and you can't move anymore

func play_animation(anim):
	state_machine.travel(anim)

# apply delay to prevents attack spamming
func apply_delay():
	$AnimationDelay.start()

# plays a sword swing sfx
func play_atk_sfx():
	audio_player.stream = load("res://audio/sfx/sword_swing.ogg")
	audio_player.play()

# creates a hit box in front of player to detect collisions
func hit_enemy():
	var hit_box = HITBOX.instance()
	get_parent().add_child(hit_box)
	if dir == DIRECTION.E:
		if sign($Position2D.position.x)  == -1:
			$Position2D.position.x *= -1
	elif dir == DIRECTION.W:
		if sign($Position2D.position.x)  == 1:
			$Position2D.position.x *= -1
	hit_box.position = $Position2D.global_position

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
