extends Node2D

###############################################################################
# handles the health bar displayed in the UI
###############################################################################

func _ready():
	update()

# updates the amount of filled health orbs to the amount of health player has
# consider re-writting this logic with a loop
func update():
	if Global.health == 1:
		hide_all()
		$orb1.visible = true
	elif Global.health == 2:
		hide_all()
		$orb1.visible = true
		$orb2.visible = true
	elif Global.health == 3:
		hide_all()
		$orb1.visible = true
		$orb2.visible = true
		$orb3.visible = true
	elif Global.health == 4:
		hide_all()
		$orb1.visible = true
		$orb2.visible = true
		$orb3.visible = true
		$orb4.visible = true
	elif Global.health == 5:
		$orb1.visible = true
		$orb2.visible = true
		$orb3.visible = true
		$orb4.visible = true
		$orb5.visible = true
	elif Global.health == 6:
		$orb1.visible = true
		$orb2.visible = true
		$orb3.visible = true
		$orb4.visible = true
		$orb5.visible = true
		$orb6.visible = true
	else:
		hide_all()

# displays a empty health bar
func hide_all():
	$orb1.visible = false
	$orb2.visible = false
	$orb3.visible = false
	$orb4.visible = false
	$orb5.visible = false
	$orb6.visible = false
