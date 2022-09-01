@tool
extends CommandForm

@onready var text_node = $Control/VBoxContainer/Input_Text

var function_name :String = "print_to_console" #must be name of valid function
var text_input :String
var event_name :String = ""


func set_input_values(old_function_dict :Dictionary):
	edit_state = true
	text_node.inputNode.text = old_function_dict[function_name][0]


func get_input_values():
	text_input = text_node.inputNode.text
	event_name = commandListForm.CommandInputForm.source_node.parent_node.event_name
	var return_function_dict = {function_name : [text_input, event_name]}
	return return_function_dict

func _on_accept_button_up():
	commandListForm.CommandInputForm.function_dict = get_input_values()
	get_parent()._on_close_button_up()



