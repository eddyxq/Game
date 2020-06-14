extends KinematicBody2D

###############################################################################
# slime enemy class
###############################################################################

const FLOOR = Vector2(0,-1)
const SPEED = 30
var GRAVITY = 18

var health = 50
var velocity = Vector2(0, 0)
var is_dead = false
var timer = null
var despawn_timer = 1
var direction = 1 # left
onready var sprite = $AnimatedSprite
onready var health_bar = $HealthBar
onready var audio_player = $AudioStreamPlayer2D

onready var Warrior = get_parent().get_node("Warrior")
var react_time = 200
var dir = 0
var next_dir = 0
var next_dir_time = 0
var next_jump_time = -1
var target_player_dist = 50
var eye_reach = 90
var vision = 90


# called when the node enters the scene tree for the first time
func _ready():
	health_bar.value = 100
	setup_timer() 
	set_process(true)
	
# called every delta
func _physics_process(_delta):
	if is_dead:
		set_physics_process(false)
	else:
		animation_loop()
		movement_loop()

func animation_loop():
	if Warrior.position.x < position.x - target_player_dist and sees_player():
		set_dir(-1)
		sprite.flip_h = false
		sprite.play("walk")
	elif Warrior.position.x > position.x + target_player_dist and sees_player():
		set_dir(1)
		sprite.flip_h = true
		sprite.play("walk")
	else:
		set_dir(0)
		sprite.play("idle")

func movement_loop():
	if OS.get_ticks_msec() > next_dir_time:
		dir = next_dir

	if OS.get_ticks_msec() > next_jump_time and next_jump_time != -1 and is_on_floor():
		if Warrior.position.y < position.y - 64 and sees_player():
			velocity.y = -550
		next_jump_time = -1

	if Warrior.position.y < position.y - 64 and next_jump_time == -1 and sees_player():
		next_jump_time = OS.get_ticks_msec() + react_time

	if is_on_floor() and velocity.y > 0:
		velocity.y = 0
		
	# horizontal movement speed of enemy
	velocity.x = dir * 135
	# apply gravity
	velocity.y += GRAVITY 

	velocity = move_and_slide(velocity, Vector2(0, -1))

	# reverses the direction when you reach an wall or ledge
#	if is_on_wall():
#		direction *= -1
#		$RayCast2D.position.x *= -1
#
#	if $RayCast2D.is_colliding() == false:
#		direction *= -1 
#		$RayCast2D.position.x *= -1

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
		sprite.play("dead")
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

# plays a slime dying sfx
func play_death_sfx():
	audio_player.stream = load("res://audio/sfx/slime.ogg")
	audio_player.play()
	

# detects if the slime collides with player
func _on_Area2D_body_entered(body):
	if body.name == "Warrior":
		pass
		#body.hurt()

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
	
	var player_pos = Warrior.get_global_position()
	var player_extents = Warrior.get_node("CollisionShape2D").shape.extents - Vector2(1, 1)
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
