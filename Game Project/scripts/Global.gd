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
