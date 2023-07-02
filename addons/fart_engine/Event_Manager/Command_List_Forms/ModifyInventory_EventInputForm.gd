@tool
extends CommandForm

@onready var key_node := $Control/VBoxContainer/KeyDropdown
@onready var increase_node := $Control/VBoxContainer/TrueorFalse
@onready var how_many_node := $Control/VBoxContainer/Number_Counter

var value_node

var function_name :String = "modify_player_inventory" #must be name of valid function
var what :String
var how_many :String
var increase :bool = true
var event_name :String = ""



func _ready():
	key_node.populate_list()


func set_input_values(old_function_dict :Dictionary):
	edit_state = true
	key_node.set_input_value(old_function_dict[function_name][0])
	how_many_node.set_input_value(convert_string_to_type(old_function_dict[function_name][1]))
	var toggled_value :bool = convert_string_to_type(old_function_dict[function_name][2])
	increase_node.set_input_value(toggled_value)


func get_input_values():
	what = key_node.get_input_value()
	how_many = str(how_many_node.get_input_value())
	increase = increase_node.get_input_value()
	event_name = commandListForm.CommandInputForm.source_node.parent_node.event_name
	var return_function_dict = {function_name : [what, how_many, increase, event_name]}
	return return_function_dict



func _on_accept_button_up():
	#Get input values as dictionary
	commandListForm.CommandInputForm.function_dict = get_input_values()
	# {function Name : [which var, to_what]}
	#Send it all the way back to the command input form node and add it to main dictionary
	get_parent()._on_close_button_up()
