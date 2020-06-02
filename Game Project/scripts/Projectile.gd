extends Area2D

###############################################################################
# distance blade warrior skill
###############################################################################

const SPEED = 400
var audio_player 
var velocity = Vector2()
var projectile_dir

enum DIRECTION{
	N,
	S,
	W,
	E,
}

func _ready():
	audio_player = $AudioStreamPlayer2D

func set_projectile_direction(dir):
	projectile_dir = dir

func _physics_process(delta):
	shoot_projectile(delta, projectile_dir)

# remove projectile when it leaves the screen
func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
	
# detect collision with enemies
func _on_Projectile_body_entered(body):
	if "Slime" in body.name:
		# double hit
		body.apply_damage()
		body.apply_damage()
		play_explosion_sfx()
		$CollisionShape2D.queue_free()
		$ProjectileSprite.visible = false

# shoots the projectile
func shoot_projectile(delta, dir):
	if dir == DIRECTION.W:
		velocity.x = -(SPEED * delta)
		translate(velocity)
		$ProjectileSprite.play("shoot_left")
	elif dir == DIRECTION.E:
		velocity.x = SPEED * delta 
		translate(velocity)
		$ProjectileSprite.play("shoot_right")
		
# plays a explosion sfx
func play_explosion_sfx():
	audio_player.stream = load("res://audio/sfx/explosion.ogg")
	audio_player.play()
