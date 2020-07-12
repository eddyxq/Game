extends Control

var dialog = null
var dialog_index = 0
var finished = false

func _ready():
	if self.visible:
		play_dialog_sfx()

func _process(_delta):
	if Input.is_action_just_pressed("ui_accept") && self.visible == true:
		load_dialog()

# loops through the array of dialog text and sets the labels to display it
func load_dialog():
	if dialog_index < dialog.size():
		finished = false
		$TextureRect/RichTextLabel.set_bbcode(dialog[dialog_index])
		$TextureRect/RichTextLabel.percent_visible = 0
		$Tween.interpolate_property(
			$TextureRect/RichTextLabel, "percent_visible", 0, 1, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$Tween.start()
		if !$AudioStreamPlayer2D.is_playing():
			play_dialog_sfx()
		
	else:
		self.visible = false
	dialog_index += 1
	
func _on_Tween_tween_completed(_object, _key):
	finished = true
	$AudioStreamPlayer2D.stop()

# pauses the scene and displays the dialog box
func show_dialog_box():
	self.visible = true

# resumes the scene and hides the dialog box
func hide_dialog_box():
	self.visible = false

# displays the input text in a dialog box
func set_dialog(text):
	dialog = text
	dialog_index = 0
	finished = false

# plays a dialog scrolling sfx
func play_dialog_sfx():
	$AudioStreamPlayer2D.play()
	
# stops a dialog scrolling sfx
func stop_dialog_sfx():
	$AudioStreamPlayer2D.stop()
