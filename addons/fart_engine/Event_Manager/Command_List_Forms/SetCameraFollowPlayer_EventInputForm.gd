@tool
extends CommandForm

@onready var howMuch_inputNode = $Control/VBoxContainer/Checkbox_Template


var function_name :String = "set_camera_follow_player" #must be name of valid function
var to_what :bool
var event_name :String = ""


func set_input_values(old_function_dict :Dictionary):
	howMuch_inputNode.set_input_value(old_function_dict[function_name][0])


func get_input_values():
	to_what = howMuch_inputNode.get_input_value()
	event_name = commandListForm.CommandInputForm.source_node.parent_node.event_name
	var return_function_dict = {function_name : [to_what, event_name]}
	return return_function_dict


func _on_accept_button_up():
	commandListForm.CommandInputForm.function_dict = get_input_values()
	get_parent()._on_close_button_up()
