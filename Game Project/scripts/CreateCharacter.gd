extends Control

###############################################################################
# handles character creation
###############################################################################

onready var http : HTTPRequest = $HTTPRequest
onready var player_name : LineEdit = $PlayerNameField
onready var notification : Label = $Notification

# default stat values
var player_health = "100"
var player_strength = "10"
var player_defense = "10"
var player_critical = "30"
var player_crit_dmg = "200"
var player_exp = "0"
var player_lv = "1"

var profile

func _ready():
	# get profile structure
	profile = Global.profile
	# assign name and default valules
	profile.player_name = {"stringValue": player_name.text}
	profile.player_health = {"stringValue": player_health}
	profile.player_strength = {"stringValue": player_strength}
	profile.player_defense = {"stringValue": player_defense}
	profile.player_critical = {"stringValue": player_critical}
	profile.player_crit_dmg = {"stringValue": player_crit_dmg}
	profile.player_exp = {"stringValue": player_exp}
	profile.player_lv = {"stringValue": player_lv}

# submits request to the database to new profile with 
# user submitted name and default stat values
func _on_SubmitButton_pressed():
	profile.player_name = {"stringValue": player_name.text}
	Firebase.save_document("users?documentId=%s" % Firebase.user_info.id, profile, http)

# once new profile is created redirect the player into the game
func _on_HTTPRequest_request_completed(_result, response_code, _headers, _body):
	if response_code == 200:
		var _scene = get_tree().change_scene("res://scenes/Controller.tscn")
	else:
		notification.text = "Error submitting request"
