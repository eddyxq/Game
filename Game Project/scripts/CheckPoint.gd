extends Area2D

export var check_point_id = 0

onready var dialog_box = get_tree().get_root().get_node("/root/Controller/HUD/DialogBox")


var dialog = null

var dialog1 = [
	'You wake up in an odd but somewhat familiar land.',
	'Perhaps you should explore the area.'
]
var dialog2= [
	'Watch out! There is a ledge in front of you.',
	'Consider jumping over it.',
	'Those who fall will lose all their memories and be sent to the beginning.'
]
var dialog3 = [
	'Press Shift to activate your speed skill.',
	'That should help you get over this river.'
]
var dialog4 = [
	'Watch out! There is a dangerous monster ahead.',
	'You must overcome this enemy with your sword!',
	'Hold Tab to draw your sword. Equipping a weapon will grant you access to new skills.', 
	'Activate sword skills with the number keys.',
	'The effects of your shift key speed skill changes based on your weapon.',
	'Skills require mana, use them wisely!'
]
var dialog5 = [
	'Your health and mana had depleted from battle and skill usage.',
	'But you do not need to worry, you can replenish them by using potions.',
	'Be sure to recover and stay safe throughout your adventures!.'
]
var dialog6 = [
	'At the end of each stage you will find portals that will take you to other areas.',
	'From here on out you are on your own.',
	'Good luck adventurer!'
]
var dialog7 = [
	'Prepare yourself, you have angered the goblin cheif.'
]


func _on_CheckPoint_area_entered(_area):
	if check_point_id == 1:
		dialog_box.set_dialog(dialog1)
	elif check_point_id == 2:
		dialog_box.set_dialog(dialog2)
	elif check_point_id == 3:
		dialog_box.set_dialog(dialog3)
	elif check_point_id == 4:
		dialog_box.set_dialog(dialog4)
	elif check_point_id == 5:
		dialog_box.set_dialog(dialog5)
	elif check_point_id == 6:
		dialog_box.set_dialog(dialog6)
	elif check_point_id == 7:
		dialog_box.set_dialog(dialog7)
		
	dialog_box.load_dialog()
	dialog_box.show_dialog_box()
	queue_free()
