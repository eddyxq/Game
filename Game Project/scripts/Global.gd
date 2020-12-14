extends Node

###############################################################################
# autoloaded global script that is accessible from any node
###############################################################################

# overriding default quit logic
func _ready():
	get_tree().set_auto_accept_quit(false)

# handles what happens when player exits game using the x button
# located  on the top right of the game window
func _notification(what):
	if (what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST):
		# logic goes here #
		get_tree().quit()



# user profile structure
var profile = {
	"player_name": {},
	"player_lv": {},
	"player_health": {},
	"player_strength": {},
	"player_defense": {},
	"player_critical": {},
	"player_exp": {}
} 

# player direction
enum DIRECTION {
	N, # north/up
	S, # south/down
	W, # west/left
	E # east/right
}

# possible weapons and stances
enum STANCE {
	FIST, 
	SWORD, 
	BOW
}
