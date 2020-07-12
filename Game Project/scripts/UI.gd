extends Control

###############################################################################
# contains the in game UI elements
###############################################################################

onready var health_bar = $HealthBar
onready var mana_bar = $ManaBar
onready var skill_slot0 = $Skill_Slot0
onready var skill_slot1 = $Skill_Slot1
onready var skill_slot2 = $Skill_Slot2
onready var skill_slot3 = $Skill_Slot3
onready var skill_slot4 = $Skill_Slot4
onready var item_slot1 = $Item_Slot1
onready var item_slot2 = $Item_Slot2

# called when the node enters the scene tree for the first time
func _ready():
	# set skill texture
	$Skill_Slot0.set_texture_from_path("res://images/skill_icons/icon0.png")
	$Skill_Slot1.set_texture_from_path("res://images/skill_icons/icon1.png")
	$Skill_Slot2.set_texture_from_path("res://images/skill_icons/icon2.png")
	$Skill_Slot3.set_texture_from_path("res://images/skill_icons/icon3.png")
	$Skill_Slot4.set_texture_from_path("res://images/skill_icons/icon4.png")
	$Item_Slot1.set_texture_from_path("res://images/items/potions/hp_pot_small.png")
	$Item_Slot2.set_texture_from_path("res://images/items/potions/mp_pot_small.png")


# applies cooldown animations to skill
func start_skill0_cooldown():
	$Skill_Slot0.start_cooldown()

func start_skill1_cooldown():
	$Skill_Slot1.start_cooldown()
	
func start_skill2_cooldown():
	$Skill_Slot2.start_cooldown()
	
func start_skill3_cooldown():
	$Skill_Slot3.start_cooldown()
	
func start_skill4_cooldown():
	$Skill_Slot4.start_cooldown()
	
func start_item1_cooldown():
	$Item_Slot1.start_cooldown()
	
func start_item2_cooldown():
	$Item_Slot2.start_cooldown()
# opens up the user profile 
func _on_TextureButton_pressed():
	var _scene = get_tree().change_scene("res://scenes/ui/UserProfile.tscn")
