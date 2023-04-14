@tool
extends CommandForm

@onready var selection_node = $Control/VBoxContainer/ItemType_Selection


var function_name :String = "change_game_state" #must be name of valid function
var which_var :String
var event_name :String = ""


func _ready():
	$Control/VBoxContainer/ItemType_Selection.populate_list()

func set_input_values(old_function_dict :Dictionary):
	edit_state = true
	selection_node.inputNode.text = old_function_dict[function_name][0]



func get_input_values():
	which_var = selection_node.inputNode.text

	event_name = commandListForm.CommandInputForm.source_node.parent_node.event_name
	var return_function_dict = {function_name : [which_var, event_name]}
	return return_function_dict


func _on_accept_button_up():
	commandListForm.CommandInputForm.function_dict = get_input_values()
	get_parent()._on_close_button_up()
