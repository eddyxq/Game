extends Control

###############################################################################
# displays in game frames per second
###############################################################################

func _physics_process(_delta):
	$FPS.text = "FPS: " + str(Performance.get_monitor(Performance.TIME_FPS))
