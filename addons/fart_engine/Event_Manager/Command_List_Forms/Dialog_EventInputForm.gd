@tool
extends CommandFormManager

@onready var key_node := $Control/VBoxContainer/KeyDropdown
@onready var input_dialog_node := $Control/VBoxContainer/input_dialog

var dialog_data :Dictionary
var is_group :bool



func _ready():
	function_name = "start_dialog" 
	key_node.populate_list()
	$Control/VBoxContainer/TrueorFalse.inputNode.toggled.connect(set_group_or_single)
	$Control/VBoxContainer/TrueorFalse.inputNode.emit_signal("toggled",true )
	$Control/VBoxContainer/input_dialog/AdvancedControlsVBox.get_index_to_dialog_options()


func set_group_or_single(button_pressed):
	$Control/VBoxContainer/KeyDropdown.visible = !button_pressed
	$Control/VBoxContainer/input_dialog.visible = button_pressed
	is_group = !button_pressed


func set_input_values(old_function_dict :Dictionary):
	edit_state = true
	dialog_data = old_function_dict[function_name][0]
	input_dialog_node._set_input_value(dialog_data)


func get_input_values():
	if is_group:
		dialog_data["Group Name"] = $Control/VBoxContainer/KeyDropdown.inputNode.get_text()
	else:
		dialog_data = $Control/VBoxContainer/input_dialog._get_input_value()
	event_name = source_node.parent_node.event_name
	var return_function_dict = {function_name : [dialog_data, event_name]}
	return return_function_dict


func _on_accept_button_up():
	function_dict = get_input_values()
	get_parent()._on_close_button_up()
