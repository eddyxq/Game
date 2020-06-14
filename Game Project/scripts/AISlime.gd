extends KinematicBody2D

onready var Warrior = get_parent().get_node("Warrior")

var vel = Vector2(0, 0)

var grav = 1800
var max_grav = 3000

var react_time = 200
var dir = 0
var next_dir = 0
var next_dir_time = 0

var next_jump_time = -1

var target_player_dist = 30

var eye_reach = 90
var vision = 90

func _ready():
	set_process(true)

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
			var collision = space_state.intersect_ray(eye, corner, [], 1) # collision mask = sum of 2^(collision layers) - e.g 2^0 + 2^3 = 9
			if collision and collision.collider.name == "Warrior":
				return true
	return false

func _process(delta):
	if Warrior.position.x < position.x - target_player_dist and sees_player():
		set_dir(-1)
	elif Warrior.position.x > position.x + target_player_dist and sees_player():
		set_dir(1)
	else:
		set_dir(0)

	if OS.get_ticks_msec() > next_dir_time:
		dir = next_dir

	if OS.get_ticks_msec() > next_jump_time and next_jump_time != -1 and is_on_floor():
		if Warrior.position.y < position.y - 64 and sees_player():
			vel.y = -550
		next_jump_time = -1
		
	# speed of enemy
	vel.x = dir * 120

	if Warrior.position.y < position.y - 64 and next_jump_time == -1 and sees_player():
		next_jump_time = OS.get_ticks_msec() + react_time

	vel.y += grav * delta;
	if vel.y > max_grav:
		vel.y = max_grav

	if is_on_floor() and vel.y > 0:
		vel.y = 0

	vel = move_and_slide(vel, Vector2(0, -1))
