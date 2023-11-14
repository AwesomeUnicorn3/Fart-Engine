@tool
extends CommandFormManager

@onready var input_container = $Control/VBoxContainer/InputContainer
@onready var input_container_dict :Dictionary
@onready var table_drop_down = $Control/VBoxContainer/TableDropdown
@onready var key_drop_down = $Control/VBoxContainer/KeyDropdown
@onready var field_drop_down = $Control/VBoxContainer/FieldDropdown


var value_node
var selected_global_variable :String
var selected_type :String
var previous_global_variable :String
var previous_selected_type :String
var id :String


func ready():
	function_name = "change_global_variable"
	table_drop_down.populate_list()
	table_drop_down.select_index(table_drop_down.get_dropdown_index_from_displayName("Global Variables"))
	_on_table_dropdown_input_selection_changed()
	

func _on_table_dropdown_input_selection_changed():
	var selected_table_key: String = table_drop_down.selectedItemKey
	var selected_table_dict: Dictionary = all_tables_merged_dict[selected_table_key]
	var selected_table_data_dict: Dictionary = all_tables_merged_data_dict[selected_table_key]
	key_drop_down.selection_table_name = table_drop_down._get_input_value()
	key_drop_down.populate_list()
	var field_list: Dictionary = {}
	var field_selected_table_data_dict: Dictionary = all_tables_merged_dict[key_drop_down.selection_table_name]
	for key in key_drop_down.selection_table[key_drop_down.selection_table.keys()[0]]:
		if key != "Display Name":
			field_list[key] = {"Datatype": await get_datatype(key, key_drop_down.selection_table_name)}
	field_drop_down.populate_list(false, true, true, field_list)

func set_input_values(old_function_dict :Dictionary):
	key_drop_down._set_input_value(old_function_dict[function_name][0], false)
	field_drop_down._set_input_value(old_function_dict[function_name][1], false)


func get_input_values():
	which_var = key_drop_down.get_input_value()
	which_field = field_drop_down.get_input_value()
	to_what = input_container.get_child(0).get_input_value()
#	event_name = parent_node.event_name
	var return_function_dict = {function_name : [which_var, which_field, to_what, event_name]}
#	print(return_function_dict)
	return return_function_dict
#
#
func _on_accept_button_up():
	function_dict = get_input_values()
	get_parent()._on_close_button_up()
#

func add_input_node_for_event_condition(table_name:String, key_ID:String, field_ID: String, newParent :Node= input_container ):
	var datatype = field_drop_down.get_selection_datatype()
	for child in newParent.get_children():
		child.queue_free()

	var new_input_node = await create_input_node(table_name, key_ID, field_ID)
	new_input_node.label_text = "VALUE"
	new_input_node.is_label_button = false
	new_input_node.show_field= true
#	new_input_node.set_custom_minimum_size(Vector2(150,50))
#	new_input_node.set_h_size_flags(SIZE_EXPAND)
	newParent.add_child(new_input_node)


func _on_field_dropdown_input_selection_changed():
	var table_name:String = table_drop_down.selectedItemKey
	var key_ID:String = key_drop_down._get_input_value()
	var field_ID:String = field_drop_down.selectedItemKey
	add_input_node_for_event_condition(table_name, key_ID, field_ID)


func _on_key_dropdown_input_selection_changed():
	pass # Replace with function body.
