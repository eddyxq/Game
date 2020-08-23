extends "res://scripts/FiniteStateMachine.gd"

onready var jump_cooldown = get_node("JumpCooldown")
var jumpEnabled = true

# initialize possible states for the state machine
func _ready():
	add_state("idle")
	add_state("run")
	add_state("jump")
	add_state("fall")
	add_state("ledge_grab")
	add_state("dash")
	# set initial state
	call_deferred("set_state", possible_states.idle)


func update(up, down, left, right, dash, delta):
	if current_state != possible_states.ledge_grab and current_state != possible_states.dash:
		if dash and body.mana > 0:
			body.consume_mp(1)
			body.do_dash()
		else:
			if up and jumpEnabled:
				jumpEnabled = false
				body.jump()
			
			if right:
				body.move_right()
				
			if left:
				body.move_left()
			
			if not left and not right:
				body.velocity.x = 0
				
			body.update_horizontal_scale()
			body.apply_gravity()
		
	body.apply_movement()

	main(delta)


	
# function that is called every tick
func _state_logic(delta):
	pass
#	body.update_horizontal_scale()
#	body.apply_gravity()
#	body.apply_movement()


# should be called every tick
func _get_transition(delta):
	match current_state:
		possible_states.idle:
			if body.velocity.y < 0:
				return possible_states.jump
			elif body.velocity.y > 0:
				return possible_states.fall
			elif body.velocity.x != 0:
				return possible_states.run
			elif body.is_dashing():
				return possible_states.dash
				
		possible_states.run:
			if body.velocity.y < 0:
				return possible_states.jump
			elif body.velocity.y > 0:
				return possible_states.fall
			elif body.velocity.x == 0:
				return possible_states.idle
			elif body.is_dashing():
				return possible_states.dash
				
		possible_states.jump:
			if body.is_on_floor():
				return possible_states.idle
			elif body.velocity.y > 0:
				return possible_states.fall
			elif body.is_touching_ledge():
				return possible_states.ledge_grab
			elif body.is_dashing():
				return possible_states.dash
			
		possible_states.fall:
			if body.is_on_floor():
				return possible_states.idle
			elif body.is_touching_ledge():
				return possible_states.ledge_grab
			elif body.is_dashing():
				return possible_states.dash
				
		possible_states.ledge_grab:
			if body.get_animation_state_machine().get_current_node() != "ledge_grab":
				return possible_states.idle
		
		possible_states.dash:
			if not body.is_dashing():
				return possible_states.idle
		
	return null
	
func _enter_state(new_state):
	match new_state:
		possible_states.idle:
			body.set_label("idle")
			body.velocity = Vector2.ZERO
			if jump_cooldown.is_stopped():
				jumpEnabled = false
				print("jump disabled")
				jump_cooldown.start()
				
			body.play_idle_animation()
			
		possible_states.run:
			body.set_label("run")
			body.play_run_animation()
			
		possible_states.jump:
			body.set_label("jump")
			body.play_animation("jump")
			
		possible_states.fall:
			body.set_label("fall")
			body.play_animation("fall")
		
		possible_states.ledge_grab:
			body.set_label("ledge_grab")
			body.start_ledge_grab()
			body.play_animation("ledge_grab")
			
		possible_states.dash:
			body.set_label("dash")
			
		
	
	
func _exit_state():
	match current_state:
		possible_states.dash:
			body.velocity = Vector2.ZERO

func _on_JumpCooldown_timeout():
	jumpEnabled = true
	print("jump enabled")
