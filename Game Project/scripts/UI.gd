extends Control

###############################################################################
# contains the in game UI elements
###############################################################################

onready var health_bar = $HealthBar
onready var mana_bar = $ManaBar
onready var skill_bar = $SkillBar
onready var item_Bar = $ItemBar

# called when the node enters the scene tree for the first time
func _ready():
	# set skill texture
	skill_bar.skill_slot0.set_texture_from_path("res://images/skill_icons/blank_icon.png")    # not implmented, icon0
	skill_bar.skill_slot1.set_texture_from_path("res://images/skill_icons/warrior/icon1.png")
	skill_bar.skill_slot2.set_texture_from_path("res://images/skill_icons/warrior/icon2.png")
	skill_bar.skill_slot3.set_texture_from_path("res://images/skill_icons/warrior/icon3.png")
	skill_bar.skill_slot4.set_texture_from_path("res://images/skill_icons/warrior/icon4.png")
	skill_bar.skill_slot5.set_texture_from_path("res://images/skill_icons/blank_icon.png")    # not implmented, icon5
	skill_bar.skill_slot6.set_texture_from_path("res://images/skill_icons/blank_icon.png")    # not implmented, icon6
	item_Bar.item_slot1.set_texture_from_path("res://images/items/potions/hp_pot_small.png")
	item_Bar.item_slot2.set_texture_from_path("res://images/items/potions/mp_pot_small.png")


# applies cooldown animations to skill
func start_skill0_cooldown():
	skill_bar.skill_slot0.start_cooldown()

func start_skill1_cooldown():
	skill_bar.skill_slot1.start_cooldown()
	
func start_skill2_cooldown():
	skill_bar.skill_slot2.start_cooldown()
	
func start_skill3_cooldown():
	skill_bar.skill_slot3.start_cooldown()
	
func start_skill4_cooldown():
	skill_bar.skill_slot4.start_cooldown()
	
func start_skill5_cooldown():
	skill_bar.skill_slot5.start_cooldown()
	
func start_skill6_cooldown():
	skill_bar.skill_slot6.start_cooldown()
	
func start_item1_cooldown():
	item_Bar.item_slot1.start_cooldown()
	
func start_item2_cooldown():
	item_Bar.item_slot2.start_cooldown()
	
# opens up the user profile 
func _on_TextureButton_pressed():
	var _scene = get_tree().change_scene("res://scenes/ui/UserProfile.tscn")
