extends Control

###############################################################################
# UI menu displaying the user's profile details
###############################################################################

onready var http : HTTPRequest = $HTTPRequest
onready var notification : Label = $Notification

onready var player_name : Label = $PlayerName
onready var player_lv : Label = $CharacterProfile/LvLabel/LvValue
onready var player_health : Label = $CharacterProfile/HealthLabel/HealthValue
onready var player_strength : Label = $CharacterProfile/StrengthLabel/StrengthValue
onready var player_defense : Label = $CharacterProfile/DefenseLabel/DefenseValue
onready var player_critical : Label = $CharacterProfile/CriticalLabel/CriticalValue

var new_profile := false
var information_sent := false

# called when the node enters the scene tree for the first time
func _ready():
	player_name.text = Global.profile.player_name.stringValue
	player_lv.text = Global.profile.player_lv.stringValue
	player_health.text = Global.profile.player_health.stringValue
	player_strength.text = Global.profile.player_strength.stringValue
	player_defense.text = Global.profile.player_defense.stringValue
	player_critical.text = Global.profile.player_critical.stringValue

# updates new player name
func _on_ConfirmButton_pressed():
	if player_name.text.empty():
		notification.text = "Please enter new name"
		return
	Global.profile.player_name = {"stringValue": player_name.text}
	match new_profile:
		true:
			Firebase.save_document("users?documentId=%s" % Firebase.user_info.id, Global.profile, http)
		false:
			Firebase.update_document("users/%s" % Firebase.user_info.id, Global.profile, http)
			notification.text = "New Name Saved!"
	information_sent = true

# closes the user profile page
func _on_BackButton_pressed():
	var _scene = get_tree().change_scene("res://scenes/Controller.tscn")
	
