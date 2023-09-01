@tool
extends CommandForm

@onready var what_dir_inputNode = $Control/VBoxContainer/Input_Vector
@onready var how_fast_inputNode = $Control/VBoxContainer/Number_Counter
@onready var how_long_inputNode = $Control/VBoxContainer/Number_Counter2
@onready var return_to_player_inputNode = $Control/VBoxContainer/Checkbox_Template


var function_name :String = "move_camera" #must be name of valid function
var what_dir :String
var how_fast :float
var how_long :float
var return_to_player :bool

var event_name :String = ""

func _ready():
	what_dir_inputNode._on_Button_button_up()

func set_input_values(old_function_dict :Dictionary):
	what_dir_inputNode.set_input_value(old_function_dict[function_name][0])
	how_fast_inputNode.set_input_value(old_function_dict[function_name][1])
	how_long_inputNode.set_input_value(old_function_dict[function_name][2])
	return_to_player_inputNode.set_input_value(old_function_dict[function_name][3])

func get_input_values():
	print( what_dir_inputNode.get_input_value())
	what_dir = what_dir_inputNode.get_input_value()
	how_fast = how_fast_inputNode.get_input_value()
	how_long = how_long_inputNode.get_input_value()
	return_to_player = return_to_player_inputNode.get_input_value()

	event_name = commandListForm.CommandInputForm.source_node.parent_node.event_name
	var return_function_dict = {function_name : [what_dir, how_fast, how_long, return_to_player, event_name]}
	return return_function_dict


func _on_accept_button_up():
	commandListForm.CommandInputForm.function_dict = get_input_values()
	get_parent()._on_close_button_up()
