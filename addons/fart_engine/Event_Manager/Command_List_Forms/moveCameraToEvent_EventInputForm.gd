@tool
extends CommandFormManager

@onready var return_to_player_inputNode := $Control/VBoxContainer/Checkbox_Template2
@onready var how_long_inputNode := $Control/VBoxContainer/Number_Counter2
@onready var use_this_event_inputNode := $Control/VBoxContainer/Checkbox_Template
@onready var other_event_name_inputNode := $Control/VBoxContainer/Input_Text


#var function_name :String = "move_camera_to_event" #must be name of valid function

var return_to_player :bool
#var how_long :float
var use_this_event :bool
var other_event_name: Dictionary

#var event_name :String = ""


func _ready():
	function_name = "move_camera_to_event"
	use_this_event_inputNode.checkbox_pressed.connect(show_text_input)
	return_to_player_inputNode.checkbox_pressed.connect(show_how_long_input)
	use_this_event_inputNode.emit_signal("checkbox_pressed", use_this_event_inputNode.get_input_value())
	return_to_player_inputNode.emit_signal("checkbox_pressed", return_to_player_inputNode.get_input_value())
#player.hit.connect(_on_player_hit.bind("sword", 100))




func show_text_input(arg1):
	other_event_name_inputNode.visible = !arg1

func show_how_long_input(arg1):
	how_long_inputNode.visible = arg1


func set_input_values(old_function_dict :Dictionary):
	return_to_player_inputNode.set_input_value(old_function_dict[function_name][0])
	how_long_inputNode.set_input_value(old_function_dict[function_name][1])
	use_this_event_inputNode.set_input_value(old_function_dict[function_name][2])
	other_event_name_inputNode.set_input_value(old_function_dict[function_name][3])


func get_input_values():
	return_to_player = return_to_player_inputNode.get_input_value()
	how_long = how_long_inputNode.get_input_value()
	use_this_event = use_this_event_inputNode.get_input_value()
	other_event_name = other_event_name_inputNode.get_input_value()
#	event_name = source_node.parent_node.event_name
	var return_function_dict = {function_name : [return_to_player, how_long, use_this_event, other_event_name, event_name]}
	return return_function_dict


func _on_accept_button_up():
	function_dict = get_input_values()
	get_parent()._on_close_button_up()
