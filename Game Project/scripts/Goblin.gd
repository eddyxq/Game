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

onready var player = get_parent().get_node("Warrior")
onready var health_bar = $HealthBar

# enemy speed and state variables
var health = 100
var base_speed = 100
var velocity = Vector2(0, 0)
var is_dead = false
var gravity = 18
var despawn_timer = 1
var timer = null

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

signal loot_done

# knockback variables
# TODO: change knockback_direction to local
var knockback_frames = 0
var knockback_direction = Vector2.ZERO

# called when the node enters the scene tree for the first time
func _ready():
	health_bar.value = 100
	setup_timer() 
	setup_state_machine()
	set_process(true)

# called every delta
func _physics_process(_delta):
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
		velocity = knockback_direction.normalized() * base_speed * 3
		knockback_frames -= 1
		
	elif (anim_finished):
		# apply regular horizontal movement
		velocity.x = dir * base_speed

	# apply gravity
	velocity.y += gravity 
	velocity = move_and_slide(velocity, Vector2(0, -1))

# update health bar
func hurt(skill_multiplier, intensity):
	play_hurt_sfx()
	# damage formula: normal damage value can be up to the maximum strength
	# critical hits add additional damage equal to the strength
	# var dmg = randi() % int(Global.profile.player_strength.stringValue) + 1
	var dmg = (randi() % int(10) + 4) * skill_multiplier 
	var crit = false
	# critical when random number rolled out of 100 is within critical value
	# if randi() % 100+1 <= int(Global.profile.player_critical.stringValue):
	if randi() % 100+1 <= int(30):
		crit = true
		# dmg += int(Global.profile.player_strength.stringValue)
		dmg += int(10) * skill_multiplier
	health -= dmg
	health_bar.value = health
	$FCTMgr.show_value(dmg, crit)
	
	# check if enemy is alive
	if health < 1:
		is_dead = true
		timer.start()
		state_machine.travel("dead")
		play_death_sfx()
		$CollisionShape2D.queue_free()
		$HealthBar.queue_free()
	# apply knockback effect if any
	else:
		react_to_hit(intensity)


# sets knockback_direction relative to 'other_body_origin'
# general hit reaction

# applies a knockback scaling off intensity input
func react_to_hit(intensity):
	if (knockback_frames <= 0):
		# set some knockback_frames
		knockback_frames = intensity
		knockback_direction = transform.origin - player.transform.origin

# init timer 
func setup_timer():
	timer = Timer.new()
	timer.set_wait_time(despawn_timer)
	timer.connect("timeout", self, "on_timeout_complete")
	add_child(timer)

# despawns and removes sprite
func on_timeout_complete():
	$Sprite.visible = false
	# wait 0.5 seconds then try to spawn loot
	wait_and_execute(0.5, "drop_loot")
	# wait until loot is done then queue_free
	yield(self, "loot_done")
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

# timer use to manage attaking state, preventing animation overlap
func _on_AnimationDelay_timeout():
	anim_finished = true

# deal damage to player when attacking hitbox collides with player
func _on_HitBox_body_entered(body):
	if "Warrior" in body.name:
		body.hurt(20)

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
	SoundManager.play_sfx(load("res://audio/sfx/hit.ogg"), 0)

# spawns chest with respect to drop rate
func spawn_chest():
	# spawn chest
	var chest = preload("res://scenes/Chest.tscn").instance()
	# drop chest with respect to DROPRATE
	chest.drop(self)

# drops loot which can be a chest and/or coins
func drop_loot():
	spawn_chest()
	var coin_dropper = preload("res://scenes/CoinDropper.tscn").instance()
	var _coin_amount = coin_dropper.drop(self)
	emit_signal("loot_done")
	
# wait_time: in seconds
# function: function to execute
func wait_and_execute(wait_time, function):
	var my_timer = Timer.new()
	my_timer.set_wait_time(wait_time)
	my_timer.connect("timeout", self, function)
	add_child(my_timer)
	my_timer.start()
