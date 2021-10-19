class_name DashState
extends "res://scripts/state machine//state.gd"

func _init(body).(body):
	pass
	
func _state_logic(_delta):
	pass

func _enter():
	body.do_dash()
	
	#debug label
	body.set_label("dash")
	
func _exit():
	body.velocity = Vector2.ZERO
	
