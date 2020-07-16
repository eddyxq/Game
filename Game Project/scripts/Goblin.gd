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

onready var UI = get_tree().get_root().get_node("/root/Controller/HUD")
onready var player = get_parent().get_node("Player")
onready var health_bar = $HealthBar

export var is_boss = false

# enemy speed and state variables
export var max_health = 100.0
var health = max_health
var base_speed = 100
var strength = 10
var velocity = Vector2(0, 0)
var is_dead = false
var gravity = 18

# variables related to AI pathfinding
var react_time = 100
var dir = 0
var next_dir = 0
var next_dir_time = 0
var next_jump_time = -1
var target_player_dist = 35
var eye_reach = 90
var vision = 160
var direction_facing = DIRECTION.W # default left facing

# animation states
var state_machine = null
var anim_finished = true

# knockback variables
# TODO: change knockback_direction to local
var knockback_frames = 0
var knockback_direction = Vector2.ZERO

# called when the node enters the scene tree for the first time
func _ready():
	health = max_health
	health_bar.value = 100
	setup_state_machine()
	set_process(true)

# called every delta
func _physics_process(_delta):
	# enemies dies when it falls down
	if self.get_global_position().y > 440:
		hurt(health, 0)
		
	# aggro range increase upon getting hit
	if health < max_health:
		vision = 250

	if is_dead:
		set_physics_process(false)
	else:
		animation_loop()
		movement_loop()

# animation logic
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
	
		if velocity.x == 0 && (abs(position.x - player.get_global_position().x) < 35) && (abs(position.y - player.get_global_position().y) < 35)  && health > -1:
			state_machine.travel("attack")
			anim_finished = false
			$AnimationDelay.start()

# movement logic
func movement_loop():
	update_hitbox_location()
	
	if OS.get_ticks_msec() > next_dir_time:
		dir = next_dir

	if OS.get_ticks_msec() > next_jump_time and next_jump_time != -1 and is_on_floor():
		if player.position.y < position.y - 64 and sees_player():
			velocity.y = -500
		next_jump_time = -1

	if player.position.y < position.y - 64 and next_jump_time == -1 and sees_player():
		next_jump_time = OS.get_ticks_msec() + react_time

	if is_on_floor() and velocity.y > 0:
		velocity.y = 0

	# horizontal movement speed of enemy
	# apply knockback when knockback_frames available
	if (knockback_frames > 0):
		# apply knockback
<<<<<<< HEAD
		velocity = knockback_direction.normalized() * base_speed * 3
=======
		velocity = knockback_direction.normalized() * base_speed * knockback_intensity
		print("knockback frame:", knockback_frames, "-", velocity)
>>>>>>> parent of 68393a9... added more parameters to knockback function
		knockback_frames -= 1
		
	elif (anim_finished):
		# apply regular horizontal movement
		velocity.x = dir * base_speed

	# apply gravity
	velocity.y += gravity 
	velocity = move_and_slide(velocity, Vector2(0, -1))

# update health bar
<<<<<<< HEAD
=======
# returns boolean: true if damage was critical, false otherwise
>>>>>>> parent of 68393a9... added more parameters to knockback function
func hurt(base_damage: int, knockback_intensity: int):
	play_hurt_sfx()
	var dmg = (randi() % int(player.strength) + base_damage) 
	var crit = false
	# critical when random number rolled out of 100 is within critical value
	if randi() % 100+1 <= int(player.crit_rate):
		crit = true
		dmg *= 2 # critical hits do double damage
	health -= dmg
	var health_percent = health / max_health * 100.0
	health_bar.value = health_percent
	$FCTMgr.show_value(dmg, crit)
	
	# check if enemy is alive
	if health < 1:
		is_dead = true
		$DespawnTimer.start()
		state_machine.travel("dead")
		play_death_sfx()
		$CollisionShape2D.queue_free()
		$HealthBar.queue_free()
	# apply knockback effect if any
	else:
		react_to_hit(knockback_intensity)
<<<<<<< HEAD
=======
	
	return crit
	
	# currently not active
	#knock_back(intensity)

>>>>>>> parent of 68393a9... added more parameters to knockback function

# sets knockback_direction relative to 'other_body_origin'
# general hit reaction

# applies a knockback scaling off intensity input
func react_to_hit(intensity):
<<<<<<< HEAD
	if (knockback_frames <= 0):
		# set some knockback_frames
		knockback_frames = intensity
		knockback_direction = transform.origin - player.transform.origin
=======
	if (intensity > 0 and knockback_frames <= 0):
		# set some knockback_frames
		knockback_frames = 10
		knockback_intensity = intensity
		knockback_direction = transform.origin - player.transform.origin

# init timer 
func setup_timer():
	timer = Timer.new()
	timer.set_wait_time(despawn_timer)
	timer.connect("timeout", self, "on_timeout_complete")
	add_child(timer)
>>>>>>> parent of 68393a9... added more parameters to knockback function

# despawns and removes sprite
func _on_DespawnTimer_timeout():
	$Sprite.visible = false
	if is_boss:
		UI.stage_clear_menu.visible = true
	queue_free()

# plays a enemy dying sfx
func play_death_sfx():
	SoundManager.play("res://audio/sfx/slime.ogg")

# detects if the enemy collides with player
func _on_Area2D_body_entered(body):
	if body.name == "Player":
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
			if collision and collision.collider.name == "Player":
				return true
	return false

# initializes the state machine for managing animation state transitions
func setup_state_machine():
	state_machine = $AnimationTree.get("parameters/playback")

# timer use to manage attaking state, preventing animation overlap
func _on_AnimationDelay_timeout():
	anim_finished = true

# deal damage to player when attacking hitbox collides with player
func _on_HitBox_body_entered(body):
	if "Player" in body.name:
		var dmg = (randi() % int(strength) + 5) 
		body.hurt(dmg)

# called when attacking, toggles the hitbox on/off
func toggle_hitbox():
	$HitBox/CollisionShape2D.disabled = not $HitBox/CollisionShape2D.disabled

# ensures the hitbox is always in front and back area is behind
func update_hitbox_location():
	if $HitBox.position.x < 0 && direction_facing == DIRECTION.E:
		$HitBox.position.x *= -1
		$Area2D.position.x *= -1
	elif $HitBox.position.x > 0 && direction_facing == DIRECTION.W:
		$HitBox.position.x *= -1
		$Area2D.position.x *= -1

# turns the enemy around if move player moves behind
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

# plays a hurt sfx
func play_hurt_sfx():
	SoundManager.play("res://audio/sfx/hit.ogg")

# spawns chest with respect to drop rate
func spawn_chest():
	# spawn chest
	var chest = preload("res://scenes/item/Chest.tscn").instance()
	# drop chest with respect to DROPRATE
	chest.drop(self)

# drops loot which can be a chest and/or coins
func drop_loot():
	spawn_chest()
	var coin_dropper = preload("res://scenes/item/CoinDropper.tscn").instance()
	var _coin_amount = coin_dropper.drop(self)
