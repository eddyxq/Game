class_name FallState
extends "res://scripts/state machine//state.gd"

func _init(body).(body):
	pass
	
func _state_logic(_delta):
	update_input()
	allow_horizontal_movement()
	body.update_horizontal_scale()
	body.apply_gravity()

func _enter():
	body.play_animation("fall")
	
	#debug label
	body.set_label("fall")
	
func _exit():
	pass
	
