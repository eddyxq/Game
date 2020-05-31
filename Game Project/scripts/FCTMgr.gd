extends Node2D

###############################################################################
# manages how the damage numbers pop up
###############################################################################

var FCT = preload("res://scenes/FCT.tscn")

export var travel = Vector2(0, -80)
export var duration = 2
export var spread = PI/2

# param value is the number that will be displayed
# crit is a flag that determines if it gets the red critical effect
func show_value(value, crit):
	var fct = FCT.instance()
	add_child(fct)
	fct.show_value(str(value), travel, duration, spread, crit)
