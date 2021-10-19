extends Node2D

###############################################################################
# detects and handles user inputs          
###############################################################################

# references to child nodes
onready var player = $Player
onready var player_movement_fsm = $Player/MovementFSM

onready var ui = $HUD/UI
onready var scene_changer = $HUD/SceneChanger/AnimationPlayer

func _ready():
	scene_changer.play_backwards("fade")

# called every delta
func _physics_process(_delta):
	if !$HUD/DialogBox.visible:
		player_movement_fsm.main(_delta)
		if Input.is_action_pressed("ui_item_slot1"):
			player.use_health_potion()
		if Input.is_action_pressed("ui_item_slot2"):
			player.use_mana_potion()
			
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
