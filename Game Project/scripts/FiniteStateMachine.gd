class_name FiniteStateMachine
extends Node


var current_state = null setget set_state
var previous_state = null

var possible_states = {}
# possible_states[state_name] = state_object
var state_objects = {}
var pause_flag = false

onready var body = get_parent()

#func _ready():
#	body = get_parent()
	
func main(delta):
	if current_state != null:
#		print("state machine working")
		var current_state_object = state_objects[current_state]
		current_state_object._state_logic(delta)
		body.apply_movement()
		
		if current_state_object.is_ready_to_transition():
#			print("ready to transtion")
			var new_state = _get_transition(delta)
#			print("new state transition:", new_state)
			if new_state != null:
				set_state(new_state)
			
# should be called every tick
func _get_transition(delta):
	return null
	
func set_state(new_state):
	if current_state != null:
		var current_state_object = state_objects[current_state]
		current_state_object._exit()
	
	if new_state != null:
		var new_state_object = state_objects[new_state]
		new_state_object._enter()
				
	previous_state = current_state
	current_state = new_state
#	print(previous_state)
#	print(current_state)
	
func add_state(state_name, state_object):
	possible_states[state_name] = state_name
	state_objects[state_name] = state_object
