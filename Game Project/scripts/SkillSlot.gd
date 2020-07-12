extends TextureButton

###############################################################################
# handles the skill cooldown timer and animation
###############################################################################

onready var time_label = $Value
onready var player = get_tree().get_root().get_node("/root/Controller/Player")

export var skill_slot_num = 1
export var cooldown = 1.0
var on_cooldown = false

func _ready():
	time_label.hide()
	$Sweep.value = 0
	$Sweep.texture_progress = texture_normal
	$Timer.wait_time = cooldown
	set_process(false)

func _process(_delta):
	time_label.text = "%0.0f" % $Timer.time_left
	$Sweep.value = int(($Timer.time_left / cooldown) * 100)

func _on_Timer_timeout():
	$Sweep.value = 0
	disabled = false
	time_label.hide()
	set_process(false)
	on_cooldown = false
	player.reset_skill_cooldown(skill_slot_num)

func start_cooldown():
	if !on_cooldown:
		on_cooldown = true
		disabled = true
		set_process(true)
		$Timer.start()
		time_label.show()

func set_texture_from_path(image_path):
	set_normal_texture(load(image_path))
