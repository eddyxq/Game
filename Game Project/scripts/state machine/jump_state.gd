class_name JumpState
extends "res://scripts/state machine//state.gd"

func _init(body).(body):
	pass
	
func _state_logic(delta):
	update_input()
	allow_horizontal_movement()
	body.update_horizontal_scale()
	body.apply_gravity()
	
func _enter():
	body.jump()
#	jump_enabled = false
#	print("jump disabled")
	body.play_animation("jump")
	body.set_label("jump")
	print("state: jump")
	
func _exit():
	pass
	
