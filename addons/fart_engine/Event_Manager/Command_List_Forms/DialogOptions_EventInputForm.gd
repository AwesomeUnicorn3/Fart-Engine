@tool
extends CommandForm

@onready var key_dropdown := $Control/VBoxContainer/KeyDropdown
@onready var field_dropdown = $Control/VBoxContainer/FieldDropdown

@onready var value_node := $Control/VBoxContainer/Checkbox_Template

var DBENGINE: DatabaseManager = DatabaseManager.new()

var function_name :String = "change_dialog_options" #must be name of valid function
var which_var :String
var to_what :String
var event_name :String = ""


func _ready():
	key_dropdown.populate_list()


func set_input_values(old_function_dict :Dictionary):
	edit_state = true
	field_dropdown._set_input_value(old_function_dict[function_name][0], false)
	var toggled_value :bool = convert_string_to_type(old_function_dict[function_name][1])
	value_node.set_input_value(toggled_value)


func get_input_values():
	which_var = field_dropdown.get_input_value()
	to_what = value_node.inputNode.text
	event_name = commandListForm.CommandInputForm.source_node.parent_node.event_name
	var return_function_dict = {function_name : [which_var, to_what, event_name]}
	return return_function_dict


func _on_accept_button_up():
	commandListForm.CommandInputForm.function_dict = get_input_values()
	get_parent()._on_close_button_up()


func _on_key_dropdown_input_selection_changed():
	var field_list: Dictionary = {}
	var field_selected_table_data_dict: Dictionary = DBENGINE.import_data(key_dropdown.selection_table_name, true)
	for key in key_dropdown.selection_table[key_dropdown.selection_table.keys()[0]]:
		if key != "Display Name":
			field_list[key] = {"Datatype": DBENGINE.get_datatype(key, field_selected_table_data_dict)}
	field_dropdown.populate_list(false, true, true, field_list)
