extends KinematicBody2D

###############################################################################
# goblin enemy class
###############################################################################

enum DIRECTION {
	N, # north/up
	S, # south/down
	W, # west/left
	E, # east/right
}

const base_speed = 135
var gravity = 18

var health = 100
var velocity = Vector2(0, 0)
var is_dead = false
var timer = null
var despawn_timer = 1
var direction = 1 # left
onready var health_bar = $HealthBar
onready var audio_player = $AudioStreamPlayer2D

onready var player = get_parent().get_node("Warrior")
var react_time = 100
var dir = 0
var next_dir = 0
var next_dir_time = 0
var next_jump_time = -1
var target_player_dist = 35
var eye_reach = 90
var vision = 160

var state_machine
var anim_finished = true

var direction_facing = DIRECTION.W

# called when the node enters the scene tree for the first time
func _ready():
	health_bar.value = 100
	setup_timer() 
	set_process(true)
	setup_state_machine()

# called every delta
func _physics_process(_delta):
	if is_dead:
		set_physics_process(false)
	else:
		animation_loop()
		movement_loop()
func animation_loop():
	if anim_finished:
		if player.get_global_position().x < $Position2D.get_global_position().x - target_player_dist and sees_player():
			set_dir(-1)
			$Sprite.flip_h = false
			$Sprite.position.x = -17.5
			direction_facing = DIRECTION.W
			state_machine.travel("run")
		elif player.get_global_position().x > $Position2D.get_global_position().x + target_player_dist and sees_player():
			set_dir(1)
			$Sprite.flip_h = true
			$Sprite.position.x = 17.5
			direction_facing = DIRECTION.E
			state_machine.travel("run")
		else:
			set_dir(0)
			state_machine.travel("idle")
	
		if velocity.x == 0 && (abs(position.x - player.get_global_position().x) < 35):
#			if (abs($HitBox.get_global_position().x - player.get_global_position().x) > 17.5):
#				turn_around()
			state_machine.travel("attack")
			anim_finished = false
			$AnimationDelay.start()



func movement_loop():
	update_hitbox_location()
	
	if OS.get_ticks_msec() > next_dir_time:
		dir = next_dir

	if OS.get_ticks_msec() > next_jump_time and next_jump_time != -1 and is_on_floor():
		if player.position.y < position.y - 64 and sees_player():
			velocity.y = -550
		next_jump_time = -1

	if player.position.y < position.y - 64 and next_jump_time == -1 and sees_player():
		next_jump_time = OS.get_ticks_msec() + react_time

	if is_on_floor() and velocity.y > 0:
		velocity.y = 0
		
	# horizontal movement speed of enemy
	if anim_finished:
		velocity.x = dir * base_speed
	# apply gravity
	velocity.y += gravity 

	velocity = move_and_slide(velocity, Vector2(0, -1))

# update health bar
func apply_damage():
	# damage formula: normal damage value can be up to the maximum strength
	# critical hits add additional damage equal to the strength
	# var dmg = randi() % int(Global.profile.player_strength.stringValue) + 1
	var dmg = randi() % int(10) + 1
	var crit = false
	# critical when random number rolled out of 100 is within critical value
	# if randi() % 100+1 <= int(Global.profile.player_critical.stringValue):
	if randi() % 100+1 <= int(30):
		crit = true
		# dmg += int(Global.profile.player_strength.stringValue)
		dmg += int(10)
	health -= dmg
	health_bar.value = health
	$FCTMgr.show_value(dmg, crit)
	
	if health < 1:
		is_dead = true
		timer.start()
		#sprite.play("dead")
		state_machine.travel("dead")
		play_death_sfx()
		$CollisionShape2D.queue_free()
		$HealthBar.queue_free()

# init timer 
func setup_timer():
	timer = Timer.new()
	timer.set_wait_time(despawn_timer)
	timer.connect("timeout", self, "on_timeout_complete")
	add_child(timer)

# despawns and removes sprite
func on_timeout_complete():
	queue_free()

# plays a enemy dying sfx
func play_death_sfx():
	SoundManager.play_sfx(load("res://audio/sfx/slime.ogg"), 1)

# detects if the enemy collides with player
func _on_Area2D_body_entered(body):
	if body.name == "Warrior":
		turn_around()

# set direction for enemy to move to horizontally
func set_dir(target_dir):
	if next_dir != target_dir:
		next_dir = target_dir
		next_dir_time = OS.get_ticks_msec() + react_time

# intersects rays between collision bodies of the enemy to the corners of the player
func sees_player():
	# eye in middle of enemy, and on top
	var eye_center = get_global_position()
	var eye_top = eye_center + Vector2(0, -eye_reach)
	
	var player_pos = player.get_global_position()
	var player_extents = player.get_node("CollisionShape2D").shape.extents - Vector2(1, 1)
	# corners of the player
	var top_left = player_pos + Vector2(-player_extents.x, -player_extents.y)
	var top_right = player_pos + Vector2(player_extents.x, -player_extents.y)
	var bottom_left = player_pos + Vector2(-player_extents.x, player_extents.y)
	var bottom_right = player_pos + Vector2(player_extents.x, player_extents.y)

	var space_state = get_world_2d().direct_space_state

	# check each eye until one see the player, else false
	for eye in [eye_center, eye_top]:
		for corner in [top_left, top_right, bottom_left, bottom_right]:
			if (corner - eye).length() > vision:
				continue
			# collision mask = sum of 2^(collision layers) - e.g 2^0 + 2^3 = 9
			var collision = space_state.intersect_ray(eye, corner, [], 1) 
			if collision and collision.collider.name == "Warrior":
				return true
	return false

# initializes the state machine for managing animation state transitions
func setup_state_machine():
	state_machine = $AnimationTree.get("parameters/playback")


func _on_AnimationDelay_timeout():
	anim_finished = true


func _on_HitBox_body_entered(body):
	if "Warrior" in body.name:
		body.hurt()

func toggle_hitbox():
	$HitBox/CollisionShape2D.disabled = not $HitBox/CollisionShape2D.disabled

func update_hitbox_location():
	if $HitBox.position.x < 0 && direction_facing == DIRECTION.E:
		$HitBox.position.x *= -1
		$Area2D.position.x *= -1
	elif $HitBox.position.x > 0 && direction_facing == DIRECTION.W:
		$HitBox.position.x *= -1
		$Area2D.position.x *= -1

func turn_around():
	$Sprite.flip_h = not $Sprite.flip_h
	$Sprite.position.x *= -1
	if direction_facing == DIRECTION.W:
		direction_facing = DIRECTION.E
		$HitBox.position.x *= -1
		$Area2D.position.x *= -1
	elif direction_facing == DIRECTION.E:
		direction_facing = DIRECTION.W
		$HitBox.position.x *= -1
		$Area2D.position.x *= -1

