class_name AttackWaitState
extends "res://scripts/state machine//state.gd"

var transition_timer
var attack_delay

func _init(body, transition_timer, attack_delay).(body):
	self.transition_timer = transition_timer
	self.attack_delay = attack_delay
	
func _state_logic(delta):
	update_input()
	if attack:
		transition_timer.set_paused(true)
		set_ready_to_transition_flag(true)
		
func _enter():
	set_ready_to_transition_flag(false)
	transition_timer.start(attack_delay)
	
func _exit():
	transition_timer.set_paused(false)
	transition_timer.stop()
	
