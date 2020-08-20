extends AnimatedSprite

func show_hit_effect():
	self.play("hit_splat")

func _on_AnimatedSprite_animation_finished():
	queue_free()
