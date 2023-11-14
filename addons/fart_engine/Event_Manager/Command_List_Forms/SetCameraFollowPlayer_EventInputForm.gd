@tool
extends CommandFormManager

@onready var howMuch_inputNode = $Control/VBoxContainer/Checkbox_Template


func _ready():
	function_name = "set_camera_follow_player" 


func set_input_values(old_function_dict :Dictionary):
	howMuch_inputNode.set_input_value(old_function_dict[function_name][0])


func get_input_values():
	to_what = howMuch_inputNode.get_input_value()
	event_name = source_node.parent_node.event_name
	var return_function_dict = {function_name : [to_what, event_name]}
	return return_function_dict


func _on_accept_button_up():
	function_dict = get_input_values()
	get_parent()._on_close_button_up()
