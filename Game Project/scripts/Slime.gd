extends KinematicBody2D

###############################################################################
# slime enemy class
###############################################################################

const FLOOR = Vector2(0,-1)
const SPEED = 30
const GRAVITY = 14

var health = 50
var velocity = Vector2()
var is_dead = false
var timer = null
var despawn_timer = 1
var direction = 1 # left
onready var sprite = $AnimatedSprite
onready var health_bar = $HealthBar
onready var audio_player = $AudioStreamPlayer2D

# called when the node enters the scene tree for the first time
func _ready():
	health_bar.value = 100
	setup_timer() 
	
# called every delta
func _physics_process(_delta):
	# while slime is alive it moves back and forth 
	if !is_dead:
		velocity.x = SPEED * -direction
		# flip sprite when slime turns around
		if direction == 1:
			sprite.flip_h = false
		else:
			sprite.flip_h = true
		# play animation
		sprite.play("walk")
		# apply gravity
		velocity.y += GRAVITY
		velocity = move_and_slide(velocity, FLOOR)

	# reverses the direction when you reach an wall or ledge
	if is_on_wall():
		direction *= -1
		$RayCast2D.position.x *= -1
		
	if $RayCast2D.is_colliding() == false:
		direction *= -1 
		$RayCast2D.position.x *= -1

# update health bar
func apply_damage():
	# damage formula: normal damage value can be up to the maximum strength
	# critical hits add additional damage equal to the strength
	# var dmg = randi() % int(Global.profile.player_strength.stringValue) + 1
	var dmg = randi() % int(10) + 1
	var crit = false
	# critical when random number rolled out of 100 is within critical value
	# if randi() % 100+1 <= int(Global.profile.player_critical.stringValue):
	if randi() % 100+1 <= int(30):
		crit = true
		# dmg += int(Global.profile.player_strength.stringValue)
		dmg += int(10)
	health -= dmg
	health_bar.value = health
	$FCTMgr.show_value(dmg, crit)
	
	if health < 1:
		is_dead = true
		timer.start()
		sprite.play("dead")
		play_death_sfx()
		$CollisionShape2D.queue_free()
		$HealthBar.queue_free()

# init timer 
func setup_timer():
	timer = Timer.new()
	timer.set_wait_time(despawn_timer)
	timer.connect("timeout", self, "on_timeout_complete")
	add_child(timer)

# despawns and removes sprite
func on_timeout_complete():
	queue_free()

# plays a slime dying sfx
func play_death_sfx():
	audio_player.stream = load("res://audio/sfx/slime.ogg")
	audio_player.play()
	

# detects if the slime collides with player
func _on_Area2D_body_entered(body):
	if body.name == "Warrior":
		pass
		#body.hurt()
