extends Node
class_name FiniteStateMachine

var current_state = null setget set_state
var previous_state = null
var possible_states = {}
var pause_flag = false

onready var body = get_parent()

func main(delta):
	if current_state != null and not pause_flag:
		_state_logic(delta)
		var transition = _get_transition(delta)
		if transition != null:
			set_state(transition)

# should be called every tick
func _state_logic(delta):
	pass
	
# should be called every tick
func _get_transition(delta):
	return null
	
func _enter_state(new_state):
	pass
	
func _exit_state():
	pass
	
func set_state(new_state):
	if current_state != null:
		_exit_state()
	
	if new_state != null:
		_enter_state(new_state)
		
	previous_state = current_state
	current_state = new_state
	
func add_state(state_name):
	possible_states[state_name] = possible_states.size()

func set_pause_flag(flag):
	pause_flag = flag
