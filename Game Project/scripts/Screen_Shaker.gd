extends Node

const TRANS = Tween.TRANS_SINE
const EASE = Tween.EASE_IN_OUT
var amplitude = 0
onready var camera = get_parent()

# amp measured in pixels
# higher frequency = faster camera shake
# default parameters aim to give a quick shake
func start(duration=0.1, frequency=80, amp=8):
	self.amplitude = amp
		
	$Duration.wait_time = duration
	$Frequency.wait_time = 1 / float(frequency)
	
	$Duration.start()
	$Frequency.start()
	
	_new_shake()

func _new_shake():
	var rand = Vector2(0, 0)
	rand.x = rand_range(-amplitude, amplitude)
	rand.y = rand_range(-amplitude, amplitude)
	
	$Tween.interpolate_property(camera, "offset", camera.offset, rand, $Frequency.wait_time, TRANS, EASE)
	$Tween.start()
	

func _reset():
	$Tween.interpolate_property(camera, "offset", camera.offset, Vector2(), $Frequency.wait_time, TRANS, EASE)
	$Tween.start()
	


func _on_Timer_timeout():
	_new_shake()


func _on_Timer2_timeout():
	_reset()
	$Frequency.stop()
