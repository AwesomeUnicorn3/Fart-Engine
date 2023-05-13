@tool
extends InputEngine

var parent
var input_dict :Dictionary = {}
var options_dict :Dictionary = {}
@onready var event_dialog_options_table = $HBoxContainer/Event_Dialog_Options_Table
@onready var event_dialog_variable = $HBoxContainer/Event_Dialog_Variable
@onready var input_text = $HBoxContainer/Input_Text


func _init() -> void:
	type = "18"


func startup():
	populate_dropdown_inputs()


func populate_dropdown_inputs():
	event_dialog_options_table.populate_list()
#	print("SORTED TABLE: ", event_dialog_options_table.sorted_table)
	var event_dialog_options_dict: Dictionary = DBENGINE.import_data(event_dialog_options_table.selection_table_name)
	var selection_dict: Dictionary = event_dialog_options_dict[event_dialog_options_table.selectedItemKey]
#	print("SELECTION DICT: ", selection_dict)
	event_dialog_variable.selection_table = selection_dict
	if selection_dict.has("Display Name"):
		selection_dict.erase("Display Name")
	event_dialog_variable.populate_list(false, true)
#	print("SELECTION DICT: ", selection_dict)


func _get_input_value():
	input_data = {}
	input_data["Button_Text"] = input_text._get_input_value()
	input_data["Dialog_Option"] = event_dialog_variable._get_input_value()
#	print("INPUT DATA OUT: ", input_data)
	return input_data


func _set_input_value(node_value):
	if typeof(node_value) == 4:
		node_value = str_to_var(node_value)


#	print("SORTED TABLE: ", (int(key_selection) - 1))

#	print("SORTED TABLE: ", (int(key_selection) - 1))
#	$HBoxContainer/Variable_Selection.table_drop_down.select_index(int(key_selection)-1)
	

#
	input_data = node_value
#	print("INPUT DATA IN: ", input_data)
	set_input_data()


func set_input_data():
	populate_dropdown_inputs()
#	await get_tree().create_timer(0.15).timeout
#	print("BUTTON TEXT: ", input_data["Dialog_Option"])
	input_text._set_input_value(input_data["Button_Text"])
	event_dialog_variable.set_value_do_not_populate(input_data["Dialog_Option"])
#	$HBoxContainer/Variable_Selection.set_input_values(input_data["Dialog_Option"])
