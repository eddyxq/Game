extends Node2D

###############################################################################
# detects and handles user inputs          
###############################################################################

# user keyboard input flags
var up     # w / up arrow
var down   # s / down arrrow
var left   # a / left arrow
var right  # d / right arrow
var attack # space bar

var skill0 # left/right shift 
var skill1 # 1 number key
var skill2 # 2 number key
var skill3 # 3 number key
var skill4 # 4 number key

var skill
var item

var switch # tab

# references to child nodes
onready var player = $Player
onready var ui = $HUD/UI
onready var scene_changer = $HUD/SceneChanger/AnimationPlayer

func _ready():
	scene_changer.play_backwards("fade")

# called every delta
func _physics_process(_delta):
	# detect keyboard input
	up = Input.is_action_pressed("ui_up")
	down = Input.is_action_pressed("ui_down")
	left = Input.is_action_pressed("ui_left")
	right = Input.is_action_pressed("ui_right")
	attack = Input.is_action_pressed("ui_attack")

	skill = [Input.is_action_pressed("ui_skill_slot0"),
			 Input.is_action_pressed("ui_skill_slot1"),
			 Input.is_action_pressed("ui_skill_slot2"),
			 Input.is_action_pressed("ui_skill_slot3"),
			 Input.is_action_pressed("ui_skill_slot4"),
			 Input.is_action_pressed("ui_skill_slot5"),
			 Input.is_action_pressed("ui_skill_slot6")]

	item = [Input.is_action_pressed("ui_item_slot1"),
			Input.is_action_pressed("ui_item_slot2")]

	switch = Input.is_action_pressed("ui_switch")

	if !$HUD/DialogBox.visible:
		# update player state
		player.animation_loop(attack, skill, item, switch)
		player.movement_loop(attack, up, left, right)
		if Input.is_action_just_pressed("ui_special_movement"):
			player.activate_special_movement_skill(left, right)
	else:
		if player.stance == Global.STANCE.FIST:
			player.play_animation("idle_fist")
		elif player.stance == Global.STANCE.SWORD:
			player.play_animation("idle_sword")
			
	# player dies when he falls down
	if player.get_global_position().y > 442:
		player.health = 0
	
	# disable controller when player dies
	if player.health < 1:
		player.play_death_sfx()
		player.play_animation("die")
		set_physics_process(false) 
		yield(get_tree().create_timer(2.0), "timeout")
		var _scene = get_tree().reload_current_scene()

#	# turn on light if player is underground
#	if(player.get_global_position().y > 445):
#		player.set_light_enabled(true)
#	else:
#		player.set_light_enabled(false)
