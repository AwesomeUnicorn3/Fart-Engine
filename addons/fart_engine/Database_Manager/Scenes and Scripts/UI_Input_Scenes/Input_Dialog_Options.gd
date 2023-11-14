@tool
extends FartDatatype

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
	var event_dialog_options_dict: Dictionary = all_tables_merged_dict[event_dialog_options_table.table_name]
	var selection_dict: Dictionary = event_dialog_options_dict[event_dialog_options_table.selectedItemKey]
#	print("SELECTION DICT: ", selection_dict)
#	event_dialog_variable.selection_table = selection_dict
	
	
	var field_list: Dictionary = {}
	var field_selected_table_data_dict: Dictionary = all_tables_merged_data_dict[event_dialog_options_table.selectedItemKey]
	for key in selection_dict:
		if key != "Display Name":
			field_list[key] = {"Datatype": await get_datatype(key, event_dialog_options_table.selectedItemKey)}
	event_dialog_variable.populate_list(false, true, true, field_list)
	
	
	
	
#
#	if selection_dict.has("Display Name"):
#		selection_dict.erase("Display Name")
#	event_dialog_variable.populate_list(false, true)
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
	input_data = node_value
	set_input_data()


func set_input_data():
	populate_dropdown_inputs()
	input_text._set_input_value(input_data["Button_Text"])
	event_dialog_variable._set_input_value(input_data["Dialog_Option"], false)
