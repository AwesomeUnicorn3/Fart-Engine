@tool
extends Control
@onready var key_container = $DropPanelContainer/MainNodes/Label3


var dict_controls

#var char_name
#var lead_char_name
#var lead_char_letter
var key
var key_object
var key_select_action_string
var key_number
var key_scancode
var action_control
var main_tab 
var label_name
var control_dict: = {}
var parent_node

func _input(event):
	main_tab = get_parent()
	control_dict = main_tab.current_dict
#	$DropPanelContainer/MainNodes/Buttons/Accept.disabled = true

	#When an event happens if the event is an input event key and is pressed
	if event is InputEventKey and event.is_pressed() == true: 
#		get_tree().set_input_as_handled()
		#set the label to display the recorded keypress
		key_scancode = event.get_keycode()
		key = OS.get_keycode_string(event.get_keycode_with_modifiers())
		key_object = event
		key_container.set_text(key)
	#check to make sure key is not used elsewhere
		
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




func _on_Accept_button_up():
	main_tab.current_dict[main_tab.Item_Name][label_name] = key_scancode
	parent_node.inputNode.get_node("Keycode").set_text(str(key_scancode))
	main_tab.refresh_data(main_tab.Item_Name)
	_on_Cancel_button_up()



func _on_Cancel_button_up() -> void:
	main_tab.popup_main.visible = false
	queue_free()
