@tool
extends CommandForm

@onready var float_node = $Control/VBoxContainer/Number_Counter_Float


var function_name :String = "wait" #must be name of valid function
var how_long :String
var event_name :String = ""


func set_input_values(old_function_dict :Dictionary):
	edit_state = true
	float_node.inputNode.text = old_function_dict[function_name][0]

func get_input_values():
	how_long = float_node.inputNode.text
	event_name = commandListForm.CommandInputForm.source_node.parent_node.event_name
	var return_function_dict = {function_name : [how_long, event_name]}
	return return_function_dict
	
func _on_accept_button_up():
	commandListForm.CommandInputForm.function_dict = get_input_values()
	get_parent()._on_close_button_up()


#func _on_cancel_button_up():
#	if edit_state
#	queue_free()
