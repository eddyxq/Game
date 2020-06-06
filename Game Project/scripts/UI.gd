extends Control

###############################################################################
# contains the in game UI elements
###############################################################################

onready var health_bar = $HealthBar
onready var mana_bar = $ManaBar
onready var exp_bar = $ExpBar

# called when the node enters the scene tree for the first time
func _ready():
	health_bar.value = Global.health
	exp_bar.value = 50
	# set skill texture
	$Skill_Slot1.set_texture_from_path("res://images/skill_icons/icon1.png")

func _process(_delta):
	health_bar.value = Global.health

# applies cooldown animations to skill
func start_skill1_cooldown():
	$Skill_Slot1.start_cooldown()

# opens up the user profile 
func _on_TextureButton_pressed():
	var _scene = get_tree().change_scene("res://scenes/UserProfile.tscn")
