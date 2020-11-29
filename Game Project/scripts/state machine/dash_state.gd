class_name DashState
extends "res://scripts/state machine//state.gd"

func _init(body).(body):
	pass
	
func _state_logic(delta):
	pass

func _enter():
	body.do_dash()
	body.set_label("dash")
	print("state: dash")
	
func _exit():
	body.velocity = Vector2.ZERO
	
