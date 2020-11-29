class_name FallState
extends "res://scripts/state machine//state.gd"

func _init(body).(body):
	pass
	
func _state_logic(delta):
	update_input()
	allow_horizontal_movement()
	body.update_horizontal_scale()
	body.apply_gravity()

func _enter():
	body.set_label("fall")
	body.play_animation("fall")
	print("state: fall")
	
func _exit():
	pass
	
