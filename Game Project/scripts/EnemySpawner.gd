extends Area2D

var enemy = preload("res://scenes/enemy/Goblin.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Timer_timeout():
	var enemy_instance = enemy.instance()
	enemy_instance.position = self.position
	get_parent().add_child(enemy_instance)
