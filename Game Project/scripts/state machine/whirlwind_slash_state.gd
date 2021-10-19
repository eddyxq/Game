class_name WhirlwindSlashState
extends "res://scripts/state machine//state.gd"

var transition_timer

func _init(body, tt).(body):
	self.transition_timer = tt

func _state_logic(_delta):
	if body.velocity.x != 0 and body.is_on_floor():
		body.velocity.x = 0
	body.apply_gravity()

func _enter():
	var animation = "whirlwind_slash"
	var animation_duration = body.get_animation_node(animation).get_length()
	
	set_ready_to_transition_flag(false)
	body.skill2()
	transition_timer.start(animation_duration)
	
	#debug label
	body.set_label(animation)
	
func _exit():
	pass
