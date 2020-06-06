extends Control

func _physics_process(_delta):
	$FPS.text = "FPS: " + str(Performance.get_monitor(Performance.TIME_FPS))
