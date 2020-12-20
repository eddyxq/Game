class_name FistAttack3State
extends "res://scripts/state machine//state.gd"

var transition_timer

func _init(body, transition_timer).(body):
	self.transition_timer = transition_timer
	
func _state_logic(delta):
	if body.velocity.x != 0 and body.is_on_floor():
		body.velocity.x = 0
	body.apply_gravity()

func _enter():
	var animation = "fist_attack3"
	var animation_duration = body.get_animation_node(animation).get_length()
	
	set_ready_to_transition_flag(false)
	body.play_animation(animation)
	transition_timer.start(animation_duration)
	
	body.set_label(animation)
	print("state:", animation)
	
func _exit():
	pass
	
