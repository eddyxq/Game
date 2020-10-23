extends Label

###############################################################################
# displays damage numbers
###############################################################################

func show_value(value, travel, duration, spread, crit, text_color):
	if text_color == "green":
		modulate = Color(0, 1, 0)
	else: # text_color == "default"
		pass
		
	text = value
	# for scaling, set the pivot offset to the center
	rect_pivot_offset = rect_size / 2
	var movement = travel.rotated(rand_range(-spread/2, spread/2))
	# animate the position.
	$Tween.interpolate_property(self, "rect_position", rect_position,
			rect_position + movement, duration,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	# animate the fade-out.
	$Tween.interpolate_property(self, "modulate:a", 1.0, 0.0, duration,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	if crit:
		# set the color and animate size for criticals
		modulate = Color(1, 0, 0)
		$Tween.interpolate_property(self, "rect_scale", rect_scale*2, rect_scale,
			0.4, Tween.TRANS_BACK, Tween.EASE_IN)
	$Tween.start()
	yield($Tween, "tween_all_completed")
	queue_free()
