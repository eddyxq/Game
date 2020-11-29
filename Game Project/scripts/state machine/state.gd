class_name NodeState
extends Node

var ready_to_transition
var body

# user keyboard input flags
var up     # w / up arrow
var down   # s / down arrrow
var left   # a / left arrow
var right  # d / right arrow
var attack # space bar

var skills

var switch # tab

var special_movement # shift


func _init(body):
	self.body = body
	ready_to_transition = true

func is_ready_to_transition():
	return ready_to_transition

func set_ready_to_transition_flag(flag):
	ready_to_transition = flag

# ** virtual functions **
# continuously executed while state is active
func _state_logic(delta):
	pass
	
# exected once when state is entered
func _enter():
	pass

# executed after state transition to another state (could be itself)
func _exit():
	pass

func allow_horizontal_movement():
	if right:
		body.move_right()
	
	if left:
		body.move_left()

func update_input():
	# detect keyboard input
	up = Input.is_action_pressed("ui_up")
	down = Input.is_action_pressed("ui_down")
	left = Input.is_action_pressed("ui_left")
	right = Input.is_action_pressed("ui_right")

	attack = Input.is_action_just_pressed("ui_attack")

	skills = [Input.is_action_pressed("ui_skill_slot0"),
			 Input.is_action_pressed("ui_skill_slot1"),
			 Input.is_action_pressed("ui_skill_slot2"),
			 Input.is_action_pressed("ui_skill_slot3"),
			 Input.is_action_pressed("ui_skill_slot4"),
			 Input.is_action_pressed("ui_skill_slot5"),
			 Input.is_action_pressed("ui_skill_slot6")]

	switch = Input.is_action_just_pressed("ui_switch")

	special_movement = Input.is_action_just_pressed("ui_special_movement")
