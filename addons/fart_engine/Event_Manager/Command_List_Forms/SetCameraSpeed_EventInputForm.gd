@tool
extends CommandFormManager

@onready var float_node = $Control/VBoxContainer/Number_Counter_Float


func _ready():
	function_name = "set_camera_speed" 


func set_input_values(old_function_dict :Dictionary):
	edit_state = true
	float_node.inputNode.text = old_function_dict[function_name][0]


func get_input_values():
	how_long = float_node.inputNode.text
	event_name = source_node.parent_node.event_name
	var return_function_dict = {function_name : [how_long, event_name]}
	return return_function_dict


func _on_accept_button_up():
	function_dict = get_input_values()
	get_parent()._on_close_button_up()
