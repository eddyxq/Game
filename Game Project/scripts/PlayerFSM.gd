extends "res://scripts/FiniteStateMachine.gd"

onready var jump_cooldown = get_node("JumpCooldown")
var jump_enabled = true
# user keyboard input flags
var up     # w / up arrow
var down   # s / down arrrow
var left   # a / left arrow
var right  # d / right arrow
var attack # space bar

var skills

var switch # tab

var special_movement # shift

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
	
var attack_wait_is_done = false
# initialize possible states for the state machine
func _ready():
	# movement states
	add_state("idle")
	add_state("run")
	add_state("jump")
	add_state("fall")
	add_state("ledge_grab")
	add_state("dash")
	# attack states
	add_state("switch_stance")
	add_state("attack_wait")
	add_state("fist_attack1")
	add_state("fist_attack2")
	add_state("fist_attack3")
	add_state("fist_attack4")
	add_state("sword_attack1")
	add_state("sword_attack2")
	add_state("sword_attack3")
	add_state("skill0")
	add_state("skill1")
	add_state("skill2")
	add_state("skill3")
	add_state("skill4")
	add_state("skill5")
	add_state("skill6")
	# set initial state
	call_deferred("set_state", possible_states.idle)

# function that is called every tick
func _state_logic(delta):
	update_input()
	match current_state:
		possible_states.idle:
			if body.is_on_floor():
				body.apply_horizontal_deceleration()
			allow_horizontal_movement()
			body.update_horizontal_scale()
			body.apply_gravity()
			
		possible_states.run:
			allow_horizontal_movement()
			body.update_horizontal_scale()
			body.apply_gravity()

		possible_states.jump:
			allow_horizontal_movement()
			body.update_horizontal_scale()
			body.apply_gravity()

		possible_states.fall:
			allow_horizontal_movement()
			body.update_horizontal_scale()
			body.apply_gravity()

		possible_states.ledge_grab:
			pass
		
		possible_states.attack_wait:
			if body.velocity.x != 0 and body.is_on_floor():
				body.velocity.x = 0
			body.apply_gravity()
			
		possible_states.fist_attack1:
			if body.velocity.x != 0 and body.is_on_floor():
				body.velocity.x = 0
			body.apply_gravity()
		
		possible_states.fist_attack2:
			if body.velocity.x != 0 and body.is_on_floor():
				body.velocity.x = 0
			body.apply_gravity()
			
		possible_states.fist_attack3:
			if body.velocity.x != 0 and body.is_on_floor():
				body.velocity.x = 0
			body.apply_gravity()
			
		possible_states.fist_attack4:
			if body.velocity.x != 0 and body.is_on_floor():
				body.velocity.x = 0
			body.apply_gravity()
		
		possible_states.dash:
			pass

		possible_states.skill0:
			pass
		
		possible_states.skill1:
			pass
			
		possible_states.skill2:
			pass
			
		possible_states.skill3:
			pass
			
		possible_states.skill4:
			pass
			
		possible_states.skill5:
			pass
			
		possible_states.skill6:
			pass
			
		possible_states.switch_stance:
			pass
			
	body.apply_movement()

func _get_transition(delta):
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
			if attack:
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
			elif attack_wait_is_done:
				return possible_states.idle
			else:
				return null
			
		possible_states.fist_attack1:
			return possible_states.attack_wait
			
		possible_states.fist_attack2:
			return possible_states.attack_wait
				
		possible_states.fist_attack3:
			return possible_states.attack_wait
				
		possible_states.fist_attack4:
			return possible_states.attack_wait
				
		possible_states.sword_attack1:
			return possible_states.attack_wait
				
		possible_states.sword_attack2:
			return possible_states.attack_wait
				
		possible_states.sword_attack3:
			return possible_states.attack_wait
				
		possible_states.switch_stance:
			var current_animation = body.get_animation_state_machine().get_current_node()
			if body.is_switching_stance():
				return null
			else:
				return possible_states.idle

func _enter_state(new_state):
	match new_state:
		possible_states.idle:
#			body.velocity = Vector2.ZERO
			if not jump_enabled:
				$JumpCooldown.start()
			
			body.set_label("idle")
			body.play_idle_animation()
			print("state: idle")
		
		possible_states.run:
			if not jump_enabled:
				$JumpCooldown.start()
			body.set_label("run")
			body.play_run_animation()
			print("state: run")	
			
		possible_states.jump:
			body.jump()
			jump_enabled = false
			print("jump disabled")
			body.play_animation("jump")
			body.set_label("jump")
			print("state: jump")	
			
		possible_states.fall:
			body.set_label("fall")
			body.play_animation("fall")
			print("state: fall")	
		
		possible_states.ledge_grab:
			body.start_ledge_grab()
			body.play_animation("ledge_grab")
			body.set_label("ledge_grab")
			print("state: ledge grab")
			
		possible_states.dash:
			body.do_dash()
			body.set_label("dash")
			print("state: dash")
			
		possible_states.attack_wait:
			body.set_label("attack wait")
			attack_wait_is_done = false
			$NextAttackWait.start()
			
		possible_states.fist_attack1:
			pause_until_animation_finishes("fist_attack1")
			body.set_label("fist attack 1")
			print("state: fist attack1")
			
		possible_states.fist_attack2:
			pause_until_animation_finishes("fist_attack2")
			body.set_label("fist attack 2")
			print("state: fist attack2")
			
		possible_states.fist_attack3:
			pause_until_animation_finishes("fist_attack3")
			print("state: fist attack3")
			
		possible_states.fist_attack4:
			pause_until_animation_finishes("fist_attack4")
			print("state: fist attack4")
		
		possible_states.sword_attack1:
			pause_until_animation_finishes("sword_attack1")
			print("state: sword attack1")
			
		possible_states.sword_attack2:
			pause_until_animation_finishes("sword_attack2")
			print("state: sword attack2")
			
		possible_states.sword_attack3:
			pause_until_animation_finishes("sword_attack3")
			print("state: sword attack3")
			
		possible_states.skill0:
			body.skill0()
			
		possible_states.skill1:
			body.skill1()
			
		possible_states.skill2:
			body.skill2()
			
		possible_states.skill3:
			body.skill3()
			
		possible_states.skill4:
			body.skill4()
			
		possible_states.skill5:
			body.skill5()
			
		possible_states.skill6:
			body.skill6()
		
		possible_states.switch_stance:
			body.set_switch_stance_flag(true)
			body.switch_stance()
			print("state: switch stance")
			body.set_label("switching stance")
			
func _exit_state():
	match current_state:
		possible_states.dash:
			body.velocity = Vector2.ZERO

func allow_horizontal_movement():
	if right:
		body.move_right()
	
	if left:
		body.move_left()
		
func _movement_input_handler():
	if up and jump_enabled:
		jump_enabled = false
		body.jump()
			
	if right:
		body.move_right()
				
	if left:
		body.move_left()
			
	if not left and not right:
		body.velocity.x = 0
				
	body.update_horizontal_scale()
	body.apply_gravity()
	
func jump_transition_handler():
	if body.is_touching_ledge() and current_state != possible_states.ledge_grab:
		return possible_states.ledge_grab
	elif special_movement and not body.is_dashing():
		return possible_states.dash
	if attack:
		return get_first_attack_state()
	elif body.is_on_floor():
		return possible_states.idle
	elif body.velocity.y > 0:
		return possible_states.fall
	else:
		return null
		
func _attack_transition_handler():
	if not body.is_using_skill():
		if skills[0]:
			return possible_states.skill0
		elif skills[1]:
			return possible_states.skill1
		elif skills[2]:
			return possible_states.skill2
		elif skills[3]:
			return possible_states.skill3
		elif skills[4]:
			return possible_states.skill4
		elif skills[5]:
			return possible_states.skill5
		elif skills[6]:
			return possible_states.skill6
		elif attack:
			# TODO implement conditional for different forms of attack
			return get_first_attack_state()

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

func fall_transition_handler():
	if body.is_on_floor():
		return possible_states.idle
	elif body.is_touching_ledge():
		return possible_states.ledge_grab
	elif attack:
		return get_first_attack_state()
	elif special_movement:
		return possible_states.dash
	else:
		return null
	
func _movement_and_attack_transition_handler():
	if attack or skills.has(true):
		return _attack_transition_handler()
	else:
		return _movement_transition_handler()
			
func _on_JumpCooldown_timeout():
	jump_enabled = true
	print("jump enabled")
	
func get_first_attack_state():
	if body.is_sword_stance():
		return possible_states.sword_attack1
	elif body.is_fist_stance():
		return possible_states.fist_attack1


# should be called every tick
#func _get_transition(delta):
#	match current_state:
#		possible_states.idle:
#			if body.velocity.y < 0:
#				return possible_states.jump
#			elif body.velocity.y > 0:
#				return possible_states.fall
#			elif body.velocity.x != 0:
#				return possible_states.run
#			elif body.is_dashing():
#				return possible_states.dash
#
#		possible_states.run:
#			if body.velocity.y < 0:
#				return possible_states.jump
#			elif body.velocity.y > 0:
#				return possible_states.fall
#			elif body.velocity.x == 0:
#				return possible_states.idle
#			elif body.is_dashing():
#				return possible_states.dash
#
#		possible_states.jump:
#			if body.is_on_floor():
#				return possible_states.idle
#			elif body.velocity.y > 0:
#				return possible_states.fall
#			elif body.is_touching_ledge():
#				return possible_states.ledge_grab
#			elif body.is_dashing():
#				return possible_states.dash
#
#		possible_states.fall:
#			if body.is_on_floor():
#				return possible_states.idle
#			elif body.is_touching_ledge():
#				return possible_states.ledge_grab
#			elif body.is_dashing():
#				return possible_states.dash
#
#		possible_states.ledge_grab:
#			if body.get_animation_state_machine().get_current_node() != "ledge_grab":
#				return possible_states.idle
#
#		possible_states.dash:
#			if not body.is_dashing():
#				return possible_states.idle
#
#		possible_states.attack:
#			if body.is_using_skill():
#				return possible_states.skill
#			elif not body.is_attacking():
#				return possible_states.idle
#
#		possible_states.skill:
#			if not body.is_using_skill():
#				if body.is_attacking():
#					return possible_states.attack
#				else:
#					return possible_states.idle
#	return null

func _on_NextAttackWait_timeout():
	attack_wait_is_done = true

# pauses the state machine until animation length finishes
func pause_until_animation_finishes(animation):
	body.play_animation(animation)
	set_pause_flag(true)
	var animation_node = body.get_animation_node(animation)
	$PauseFlagTimer.start(animation_node.get_length())

func _on_PauseFlagTimer_timeout():
	set_pause_flag(false)
