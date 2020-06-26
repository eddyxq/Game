extends Control

###############################################################################
# handles the health bar displayed in the UI
###############################################################################

const FLASH_RATE = 0.05
const N_FLASHES = 4
const TRANS = Tween.TRANS_SINE
const EASE = Tween.EASE_IN_OUT

onready var health_over = $health_over
onready var health_under = $health_under
onready var update_tween = $update_tween
onready var flash_tween = $flash_tween

export(Color) var flash_color = Color.darkgreen

func _ready():
	health_over.value = 100

# decreases the health bar by amount
func decrease(health, amount):
	health_under.value = health
	health -= amount
	flash_effect()
	health_over.value = health
	update_tween.interpolate_property(health_under, "value", health_under.value, health, 0.4, TRANS, EASE, 0.4)
	update_tween.start()

# increases the health bar by amount
func increase(health, amount):
	update_tween.interpolate_property(health_over, "value", health, (health+amount), 0.4, TRANS, EASE)
	update_tween.start()

func flash_effect():
	for i in range(N_FLASHES * 2):
		var color = health_over.tint_progress if i % 2 == 1 else flash_color
		var time = FLASH_RATE * i + FLASH_RATE
		flash_tween.interpolate_callback(health_over, time, "set", "tint_progress", color)
	flash_tween.start()
