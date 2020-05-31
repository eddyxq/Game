extends Node2D

###############################################################################
# handles the mana bar displayed in the UI
###############################################################################

func _ready():
	update()

# updates the amount of filled mana orbs to the amount of mana player has
# consider re-writting this logic with a loop
func update():
	if Global.mana == 1:
		hide_all()
		$orb1.visible = true
	elif Global.mana == 2:
		hide_all()
		$orb1.visible = true
		$orb2.visible = true
	elif Global.mana == 3:
		hide_all()
		$orb1.visible = true
		$orb2.visible = true
		$orb3.visible = true
	elif Global.mana == 4:
		hide_all()
		$orb1.visible = true
		$orb2.visible = true
		$orb3.visible = true
		$orb4.visible = true
	elif Global.mana == 5:
		$orb1.visible = true
		$orb2.visible = true
		$orb3.visible = true
		$orb4.visible = true
		$orb5.visible = true
	else:
		hide_all()

# displays a empty mana bar
func hide_all():
	$orb1.visible = false
	$orb2.visible = false
	$orb3.visible = false
	$orb4.visible = false
	$orb5.visible = false
