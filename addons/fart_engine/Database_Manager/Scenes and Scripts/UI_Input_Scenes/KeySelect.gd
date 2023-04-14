@tool
extends Control
@onready var key_container = $DropPanelContainer/MainNodes/Label3
signal closed
var input_key_dict :Dictionary = {}
var dict_controls
var key
var key_select_action_string
var key_number
var key_scancode
var action_control
var main_tab 
var label_name
var control_dict: = {}
var Input_UserInput_scene
var is_in_input_mode :bool = false
var device_class :String = ""
var is_new_key :bool = false

func _ready():
	_on_reset_button_up()
	main_tab = get_parent()
	control_dict = main_tab.current_dict
	self.grab_focus()


func _input(event:InputEvent):
	if is_in_input_mode:
	#	#When an event happens if the event is an input event key and is pressed
		if event is InputEvent and event.is_action_type() and event.is_pressed() == true: 
			#set the label to display the recorded keypress
			device_class = event.get_class()
			key = event.as_text()
			key_container.set_text(key)
			match device_class:
				"InputEventKey":
					key_scancode = event.get_keycode()
				"InputEventMouseButton":
					key_scancode = event.button_index
			$DropPanelContainer/MainNodes/Buttons/Accept.visible = true
			$DropPanelContainer/MainNodes/Buttons/Reset.visible = true
			is_in_input_mode = false


	#check to make sure key is not used elsewhere
func check_for_duplicates():
	for i in control_dict:
		if str(control_dict[i]["Key1"]) == str(key_scancode):
			#if already used  clear key and notify player
			var label = control_dict[i]["Input_Action"]
			key_container.set_text("Key already in use by " + i + ". Please try again.")
			$DropPanelContainer/MainNodes/Buttons/Accept.disabled = true
			break
		elif str(control_dict[i]["Key2"]) == str(key_scancode):
			#if already used  clear key and notify player
			var label = control_dict[i]["Input_Action"]
			key_container.set_text("Key already in use by " + i + ". Please try again.")
			$DropPanelContainer/MainNodes/Buttons/Accept.disabled = true
			break
		else:
			#if not, enable the Accept button
			$DropPanelContainer/MainNodes/Buttons/Accept.disabled = false
			$DropPanelContainer/MainNodes/Buttons/Reset.disabled = false


func _on_Accept_button_up():
	input_key_dict = _get_values()
	emit_signal("closed")


func _on_Cancel_button_up() -> void:
	if is_new_key:
		input_key_dict = {}
	emit_signal("closed")


func _on_reset_button_up():
	$DropPanelContainer/MainNodes/Buttons/Accept.visible = false
	$DropPanelContainer/MainNodes/Buttons/Reset.visible = false
	$DropPanelContainer/MainNodes/Label3.set_text("Press Desired Mouse, Keyboard, or Joystick Button")
	is_in_input_mode = true


func _on_cancel_button_down():
	_on_Cancel_button_up()


func _set_values(button_dict :Dictionary, action_name:String):
	input_key_dict = button_dict
	$DropPanelContainer/MainNodes/Label2.set_text(action_name)

	_on_reset_button_up()

func _get_values():
	var return_value :Dictionary = {}
	input_key_dict["keycode"] = key_scancode
	input_key_dict["keyname"] = key_container.get_text()
	input_key_dict["device class"] = device_class
	return_value = input_key_dict
	return return_value
