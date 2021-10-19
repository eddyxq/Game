class_name IdleState
extends "res://scripts/state machine//state.gd"

func _init(body).(body):
	pass
	
func _state_logic(_delta):
	update_input()
	if body.is_on_floor():
		body.apply_horizontal_deceleration()
	body.update_horizontal_scale()
	body.apply_gravity()
	
func _enter():
	body.velocity = Vector2.ZERO
	body.play_idle_animation()
	#debug label
	body.set_label("idle")
	
	
func _exit():
	pass
	
