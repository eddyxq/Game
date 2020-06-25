extends Node2D

const COIN = preload("res://scenes/coin.tscn")
# maximum number of coins to drop
var max_drop = 5
# some RNG functions seem to be broken
var rng = RandomNumberGenerator.new()
var max_x = 5
var max_y = 5

func _ready():
	rng.randomize()
	
# drops some coins in the parent of the calling node
# Return: number of coins dropped
func drop(calling_node):
	var coin_amount = (randi() % max_drop) + 1
	for i in range(coin_amount):
		var a_coin = COIN.instance()
		#a_coin.apply_scale(Vector2(0.5, 0.5))
		calling_node.get_parent().add_child(a_coin)
		# set coin's position near the calling node
		a_coin.position = calling_node.get_global_position() + Vector2(-30 + (randi() % 61), -20 + (randi() % 21))

	return coin_amount

