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

var item
var switch # tab
var special_movement # shift

# references to child nodes
onready var player = $Player
onready var player_movement_fsm = $Player/MovementFSM

onready var ui = $HUD/UI
onready var scene_changer = $HUD/SceneChanger/AnimationPlayer

func _ready():
	scene_changer.play_backwards("fade")

# called every delta
func _physics_process(_delta):
	# updates input variables
	item = [Input.is_action_pressed("ui_item_slot1"),
			Input.is_action_pressed("ui_item_slot2")]
	
	if !$HUD/DialogBox.visible:
		player_movement_fsm.main(_delta)
		
		if item[0]:
			player.use_health_potion()
		
		if item[1]:
			player.use_mana_potion()
#	else:
#		player.play_animation("idle")
	
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
