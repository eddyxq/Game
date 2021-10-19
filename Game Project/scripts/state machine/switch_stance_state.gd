class_name SwitchStanceState
extends "res://scripts/state machine//state.gd"

func _init(body).(body):
	pass

func _state_logic(_delta):
	pass

func _enter():
	body.velocity.x = 0
	body.set_switch_stance_flag(true)
	body.switch_stance()
	
	#debug label
	body.set_label("switching stance")
	
func _exit():
	pass
	
