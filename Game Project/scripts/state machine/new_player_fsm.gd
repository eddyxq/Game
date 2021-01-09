extends "res://scripts/FiniteStateMachine.gd"

const IdleState = preload("res://scripts/state machine//idle_state.gd")
const RunState = preload("res://scripts/state machine//run_state.gd")
const JumpState = preload("res://scripts/state machine//jump_state.gd")
const FallState = preload("res://scripts/state machine//fall_state.gd")
const LedgeGrabState = preload("res://scripts/state machine//ledge_grab_state.gd")
const DashState = preload("res://scripts/state machine//dash_state.gd")

const SwitchStanceState = preload("res://scripts/state machine//switch_stance_state.gd")
const AttackWaitState = preload("res://scripts/state machine//attack_wait_state.gd")

const FistAttack1State = preload("res://scripts/state machine//fist_attack1_state.gd")
const FistAttack2State = preload("res://scripts/state machine//fist_attack2_state.gd")
const FistAttack3State = preload("res://scripts/state machine//fist_attack3_state.gd")
const FistAttack4State = preload("res://scripts/state machine//fist_attack4_state.gd")

const SwordAttack1State = preload("res://scripts/state machine//sword_attack1_state.gd")
const SwordAttack2State = preload("res://scripts/state machine//sword_attack2_state.gd")
const SwordAttack3State = preload("res://scripts/state machine//sword_attack3_state.gd")

const DistanceBladeState = preload("res://scripts/state machine//distance_blade_state.gd")
const WhirlwindSlashState = preload("res://scripts/state machine//whirlwind_slash_state.gd")
const BleedSlashState = preload("res://scripts/state machine//dash_slash_state.gd")
const DashSlashState = preload("res://scripts/state machine//dash_slash_state.gd")

# user keyboard input flags
var up     # w / up arrow
var down   # s / down arrrow
var left   # a / left arrow
var right  # d / right arrow
var attack # space bar

var skills

var switch # tab

var special_movement # shift

var jump_enabled = true

# initialize possible states for the state machine
func _ready():
	# movement states
	add_state("idle", IdleState.new(body))
	add_state("run", RunState.new(body))
	add_state("jump", JumpState.new(body))
	add_state("fall", FallState.new(body))
	add_state("ledge_grab", LedgeGrabState.new(body))
	add_state("dash", DashState.new(body))
	
	# attack states
	add_state("switch_stance", SwitchStanceState.new(body))
	add_state("attack_wait", AttackWaitState.new(body, $TransitionTimer, 0.2))
	# fist attack states
	add_state("fist_attack1", FistAttack1State.new(body, $TransitionTimer))
	add_state("fist_attack2", FistAttack2State.new(body, $TransitionTimer))
	add_state("fist_attack3", FistAttack3State.new(body, $TransitionTimer))
	add_state("fist_attack4", FistAttack4State.new(body, $TransitionTimer))
	# sword attack states
	add_state("sword_attack1", SwordAttack1State.new(body, $TransitionTimer))
	add_state("sword_attack2", SwordAttack2State.new(body, $TransitionTimer))
	add_state("sword_attack3", SwordAttack3State.new(body, $TransitionTimer))
	# sword skill states
	add_state("distance_blade", DistanceBladeState.new(body, $TransitionTimer))
	add_state("whirlwind_slash", WhirlwindSlashState.new(body, $TransitionTimer))
	add_state("bleed_slash", DistanceBladeState.new(body, $TransitionTimer))
	add_state("dash_slash", WhirlwindSlashState.new(body, $TransitionTimer))
	
	call_deferred("set_state", possible_states.idle)

func _get_transition(_delta):
	update_input()
	match current_state:
		possible_states.idle:
			var new_transition = _movement_and_attack_transition_handler()
			return new_transition if new_transition != possible_states.idle else null
			
		possible_states.run:
			var new_transition = _movement_and_attack_transition_handler()
			return new_transition if new_transition != possible_states.run else null

		possible_states.jump:
			return jump_transition_handler()

		possible_states.fall:
			return fall_transition_handler()
			
		possible_states.ledge_grab:
			var current_animation = body.get_animation_state_machine().get_current_node()
			return possible_states.idle if current_animation != "ledge_grab" else null

		possible_states.dash:
			var is_dashing = body.is_dashing()
			return possible_states.idle if not is_dashing else null
			
		possible_states.attack_wait:
			if $TransitionTimer.is_paused():
				if previous_state == possible_states.fist_attack1:
					return possible_states.fist_attack2
				elif previous_state == possible_states.fist_attack2:
					return possible_states.fist_attack3
				elif previous_state == possible_states.fist_attack3:
					return possible_states.fist_attack4
				elif previous_state == possible_states.fist_attack4:
					return possible_states.fist_attack1
				elif previous_state == possible_states.sword_attack1:
					return possible_states.sword_attack2
				elif previous_state == possible_states.sword_attack2:
					return possible_states.sword_attack3
				elif previous_state == possible_states.sword_attack3:
					return possible_states.sword_attack1
			else:
				return possible_states.idle
	
		# fist attack transitions
		possible_states.fist_attack1:
			return possible_states.attack_wait
			
		possible_states.fist_attack2:
			return possible_states.attack_wait
				
		possible_states.fist_attack3:
			return possible_states.attack_wait
				
		possible_states.fist_attack4:
			return possible_states.attack_wait
			
		possible_states.switch_stance:
			if not body.is_switching_stance():
				return possible_states.idle
		
		# sword attack transitions
		possible_states.sword_attack1:
			return possible_states.attack_wait
				
		possible_states.sword_attack2:
			return possible_states.attack_wait
				
		possible_states.sword_attack3:
			return possible_states.attack_wait
		
		# skill transitions
		possible_states.distance_blade:
			return possible_states.idle
		possible_states.whirlwind_slash:
			return possible_states.idle
		possible_states.bleed_slash:
			return possible_states.idle
		possible_states.dash_slash:
			return possible_states.idle
			
	return null

func _movement_and_attack_transition_handler():
	if attack or skills.has(true):
		return _attack_transition_handler()
	else:
		return _movement_transition_handler()

func _attack_transition_handler():
	if body.is_sword_stance():
		if skills[0]:
			return possible_states.skill0
		elif skills[1] and body.mana >= body.skill_mana_cost[1]:
			return possible_states.distance_blade
		elif skills[2] and body.mana >= body.skill_mana_cost[1]:
			return possible_states.whirlwind_slash
		elif skills[3] and body.mana >= body.skill_mana_cost[1]:
			return possible_states.bleed_slash
		elif skills[4] and body.mana >= body.skill_mana_cost[1]:
			return possible_states.dash_slash
		elif skills[5]:
			return possible_states.skill5
		elif skills[6]:
			return possible_states.skill6
				
	if attack:
			# TODO implement conditional for different forms of attack
			return get_first_attack_state()

func get_first_attack_state():
	if body.is_sword_stance():
		return possible_states.sword_attack1
	elif body.is_fist_stance():
		return possible_states.fist_attack1
		
		
func _movement_transition_handler():
	if body.is_touching_ledge() and current_state != possible_states.ledge_grab:
		return possible_states.ledge_grab
		
	elif special_movement and not body.is_dashing():
		return possible_states.dash
	
	elif switch:
		return possible_states.switch_stance
		
	elif body.is_on_floor():
		if (up and jump_enabled):
			return possible_states.jump
		elif left or right:
			return possible_states.run
		else:
			return possible_states.idle
	
	elif body.velocity.y > 0:
		return possible_states.fall	

func jump_transition_handler():
	if body.is_touching_ledge() and current_state != possible_states.ledge_grab:
		return possible_states.ledge_grab
	elif special_movement and not body.is_dashing():
		return possible_states.dash
	elif body.is_on_floor():
		return possible_states.idle
	elif body.velocity.y > 0:
		return possible_states.fall
	elif attack or skills.has(true):
		return _attack_transition_handler()
	else:
		return null
	
		
func fall_transition_handler():
	if body.is_on_floor():
		return possible_states.idle
	elif body.is_touching_ledge():
		return possible_states.ledge_grab
	elif special_movement:
		return possible_states.dash
	elif attack or skills.has(true):
		return _attack_transition_handler()
	else:
		return null

	
func update_input():
	# detect keyboard input
	up = Input.is_action_pressed("ui_up")
	down = Input.is_action_pressed("ui_down")
	left = Input.is_action_pressed("ui_left")
	right = Input.is_action_pressed("ui_right")

	attack = Input.is_action_just_pressed("ui_attack")

	skills = [Input.is_action_pressed("ui_skill_slot0"),
			 Input.is_action_just_pressed("ui_skill_slot1"),
			 Input.is_action_just_pressed("ui_skill_slot2"),
			 Input.is_action_just_pressed("ui_skill_slot3"),
			 Input.is_action_just_pressed("ui_skill_slot4"),
			 Input.is_action_pressed("ui_skill_slot5"),
			 Input.is_action_pressed("ui_skill_slot6")]

	switch = Input.is_action_just_pressed("ui_switch")

	special_movement = Input.is_action_just_pressed("ui_special_movement")

func _on_TransitionTimer_timeout():
	state_objects[current_state].set_ready_to_transition_flag(true)
