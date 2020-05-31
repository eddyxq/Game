extends Node

###############################################################################
# autoloaded global script that is accessible from any node
###############################################################################

# user profile sstructure
var profile = {
	"player_name": {},
	"player_lv": {},
	"player_health": {},
	"player_strength": {},
	"player_defense": {},
	"player_critical": {},
	"player_exp": {}
} 

var mana = 5

# overriding default quit logic
func _ready() -> void:
	get_tree().set_auto_accept_quit(false)
	
# handles what happens when player exits game using the x button
# located  on the top right of the game window
func _notification(what):
	if (what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST):
		# logic goes here #
		get_tree().quit()

