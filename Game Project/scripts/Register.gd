extends Control

###############################################################################
# registration menu for users to create new accounts
###############################################################################

onready var http : HTTPRequest = $HTTPRequest
onready var username : LineEdit = $UsernameField
onready var password : LineEdit = $PasswordField
onready var confirm : LineEdit = $ConfirmField
onready var notification : Label = $Notification

# sends user information to the server to create a new profile
func _on_RegisterButton_pressed():
	# all fields must be filled in, email must be unique
	if username.text.empty() or password.text.empty() or confirm.text.empty():
		notification.text = "Please enter your username and password"
		return
	# passwords must match and be at least 6 characters long
	if password.text != confirm.text:
		notification.text = "Password does not match"
		return
	# sent request to server
	Firebase.register(username.text, password.text, http)

# redirects player to the login screen when their profile has been successfully created
func _on_HTTPRequest_request_completed(_result: int, response_code: int, _headers: PoolStringArray, body: PoolByteArray) -> void:
	var response_body := JSON.parse(body.get_string_from_ascii())
	if response_code != 200:
		notification.text = response_body.result.error.message.capitalize()
	else:
		notification.text = "Registration sucessful!"
		yield(get_tree().create_timer(2.0), "timeout")
		var _scene = get_tree().change_scene("res://scenes/ui/Login.tscn")

# redirects user to the login page
func _on_CancelButton_pressed():
	var _scene = get_tree().change_scene("res://scenes/ui/Login.tscn")
