class_name LedgeGrabState
extends "res://scripts/state machine//state.gd"

func _init(body).(body):
	pass

func _state_logic(delta):
	pass

func _enter():
	body.start_ledge_grab()
	body.play_animation("ledge_grab")
	body.set_label("ledge_grab")
	print("state: ledge grab")
	
func _exit():
	pass
	
