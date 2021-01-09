class_name RunState
extends "res://scripts/state machine//state.gd"

func _init(body).(body):
	pass

func _state_logic(_delta):
	update_input()
	allow_horizontal_movement()
	body.update_horizontal_scale()
	body.apply_gravity()
	
func _enter():
#	if not jump_enabled:
#		$JumpCooldown.start()
	body.set_label("run")
	body.play_run_animation()
	print("state: run")	
	
func _exit():
	pass
	
