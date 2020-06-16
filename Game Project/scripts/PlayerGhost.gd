extends Sprite

###############################################################################
# effects for warrior buff skill
###############################################################################

func _ready():
	$Tween.interpolate_property(self, "modulate", Color(1,1,1,1), Color(1,1,1,0), 0.6, Tween.TRANS_SINE, Tween.EASE_OUT)
	$Tween.start()


func _on_alpha_tween_tween_completed(_object, _key):
	queue_free()
