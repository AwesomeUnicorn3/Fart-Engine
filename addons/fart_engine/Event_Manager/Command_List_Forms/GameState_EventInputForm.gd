@tool
extends CommandFormManager

@onready var selection_node = $Control/VBoxContainer/ItemType_Selection


func _ready():
	function_name  = "change_game_state" 
	$Control/VBoxContainer/ItemType_Selection.populate_list()

func set_input_values(old_function_dict :Dictionary):
	edit_state = true
	selection_node.inputNode.text = old_function_dict[function_name][0]



func get_input_values():
	which_var = selection_node.inputNode.text

	event_name = source_node.parent_node.event_name
	var return_function_dict = {function_name : [which_var, event_name]}
	return return_function_dict


func _on_accept_button_up():
	function_dict = get_input_values()
	get_parent()._on_close_button_up()
