extends Control

###############################################################################
# login menu that handles player authentication
###############################################################################

onready var http : HTTPRequest = $HTTPRequest
onready var username : LineEdit = $UserNameField
onready var password : LineEdit = $PasswordField
onready var notification : Label = $Notification

# variable used to detect if user is logging in for the first time
var request_num = 1

# submits a login request to server
func _on_LoginButton_pressed():
	# validate user input
	if username.text.empty() or password.text.empty():
		notification.text = "Please enter your username and password"
		return
	Firebase.login(username.text, password.text, http)

# two http requests will be sent
# when the first request is sent, the request_num is 1, we are authenticating the user
# once the user is authenticated, the request_num is 2, we are getting their data
# if their data does not exist then it is their first time logging in
func _on_HTTPRequest_request_completed(_result: int, response_code: int, _headers: PoolStringArray, body: PoolByteArray) -> void:
	var response_body := JSON.parse(body.get_string_from_ascii())
	# request to login
	if request_num == 1:
		if response_code != 200:
			notification.text = response_body.result.error.message.capitalize()
		else:
			notification.text = "Sign in sucessful!"
			yield(get_tree().create_timer(1.0), "timeout")
			Firebase.get_document("users/%s" % Firebase.user_info.id, http)
			request_num += 1
	else:
		# new users logging in for the first time goes to character creation screen
		if response_code != 200:
			var _scene = get_tree().change_scene("res://scenes/ui/CreateCharacter.tscn")
		# existing users go straight into the game
		else:
			var _scene = get_tree().change_scene("res://scenes/environment/Map1_Frozen.tscn")

# redirects user to the registration page
func _on_RegisterButton_pressed():
	var _scene = get_tree().change_scene("res://scenes/ui/Register.tscn")

# not yet implemented
func _on_ForgotPasswordButton_pressed():
	notification.text = "This feature has not been implemented, your account is lost forever"
