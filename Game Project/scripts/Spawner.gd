extends Area2D

var enemy = preload("res://scenes/enemy/Goblin.tscn")
export var wait_time = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	$Timer.wait_time = wait_time


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Timer_timeout():
	var enemy_instance = enemy.instance()
	enemy_instance.position = self.position
	enemy_instance.eye_reach = 10000
	enemy_instance.vision = 10000
	get_parent().add_child(enemy_instance)
