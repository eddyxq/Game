class_name FiniteStateMachine
extends Node

var current_state = null setget set_state
var previous_state = null

var possible_states = {}
var state_objects = {}
var pause_flag = false

onready var body = get_parent()

func main(delta):
	if current_state != null:
		var current_state_object = state_objects[current_state]
		current_state_object._state_logic(delta)
		body.apply_movement()
		
		if current_state_object.is_ready_to_transition():
			var new_state = _get_transition(delta)
			if new_state != null:
				set_state(new_state)
	
# should be called every tick
func _get_transition(_delta):
	return null
	
func set_state(new_state):
	if new_state == null:
		return
	
	# exit current state
	if current_state != null:
		var current_state_object = state_objects[current_state]
		current_state_object._exit()
	
	# enter new state
	var new_state_object = state_objects[new_state]
	new_state_object._enter()
				
	previous_state = current_state
	current_state = new_state
	
func add_state(state_name, state_object):
	possible_states[state_name] = state_name
	state_objects[state_name] = state_object
