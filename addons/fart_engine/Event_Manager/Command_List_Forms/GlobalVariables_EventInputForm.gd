@tool
extends CommandForm

@onready var input_container = $Control/VBoxContainer/InputContainer
@onready var input_container_dict :Dictionary

@onready var table_drop_down = $Control/VBoxContainer/TableDropdown
@onready var key_drop_down = $Control/VBoxContainer/KeyDropdown
@onready var field_drop_down = $Control/VBoxContainer/FieldDropdown

var DBENGINE:DatabaseEngine = DatabaseEngine.new()
var value_node
var global_variables_dictionary :Dictionary

var function_name :String = "change_global_variable" #must be name of valid function
var which_var :String
var which_field :String
var to_what 
var event_name :String = ""

var selected_global_variable :String
var selected_type :String
var previous_global_variable :String
var previous_selected_type :String
var id :String


func _ready():
	table_drop_down.populate_list()
	table_drop_down.select_index(table_drop_down.get_dropdown_index_from_displayName("Global Variables"))


func _on_table_dropdown_input_selection_changed():
	var selected_table_key: String = table_drop_down.selectedItemKey
	var selected_table_dict: Dictionary = DBENGINE.import_data(selected_table_key)
	var selected_table_data_dict: Dictionary = DBENGINE.import_data(selected_table_key, true)

	key_drop_down.selection_table_name = table_drop_down._get_input_value()
	var sorted_key_list: Dictionary = key_drop_down.populate_list()
	
	var field_list: Dictionary = {}
	for key in selected_table_dict[selected_table_dict.keys()[0]]:
		field_list[key] = {"Datatype": DBENGINE.get_datatype(key, selected_table_data_dict)}
	field_drop_down.selection_table = field_list
	field_drop_down.populate_list(false, true)


func set_input_values(old_function_dict :Dictionary):
#	edit_state = true
#	print("Old function dict: ", old_function_dict)
	key_drop_down.set_value_do_not_populate(old_function_dict[function_name][0])
#	print(old_function_dict[function_name][1])
	field_drop_down.set_value_do_not_populate(old_function_dict[function_name][1])
	#global_var_node.selectedItemKey = old_function_dict[function_name][0]
	#type_node.inputNode.text = old_function_dict[function_name][1]
	#type_node.selectedItemKey = old_function_dict[function_name][1]
	#selection_changed()
	#input_container_dict[selected_type].inputNode.text = old_function_dict[function_name][2]
#
#
func get_input_values():
	which_var = key_drop_down.get_input_value()
	which_field = field_drop_down.get_input_value()
	to_what = input_container.get_child(0).get_input_value()
	event_name = commandListForm.CommandInputForm.source_node.parent_node.event_name
	var return_function_dict = {function_name : [which_var, which_field, to_what, event_name]}
#	print(return_function_dict)
	return return_function_dict
#
#
func _on_accept_button_up():
	commandListForm.CommandInputForm.function_dict = get_input_values()
	get_parent()._on_close_button_up()
#

func add_input_node_for_event_condition(table_name:String, key_ID:String, field_ID: String, newParent :Node= input_container ):
	var datatype = field_drop_down.get_selection_datatype()
	for child in newParent.get_children():
		child.queue_free()
	var new_input_node = create_independant_input_node(table_name, key_ID, field_ID )
	new_input_node.label_text = "VALUE"
	new_input_node.is_label_button = false
	new_input_node.show_field= true
#	new_input_node.set_custom_minimum_size(Vector2(150,50))
#	new_input_node.set_h_size_flags(SIZE_EXPAND)
	newParent.add_child(new_input_node)


#func selection_changed(): #Called when any itemtype selection input is changed while this form is open
#	selected_global_variable = global_var_node.selectedItemKey
#	selected_type = type_node.selectedItemKey
#	if previous_global_variable != selected_global_variable:
#		previous_global_variable = selected_global_variable
##		id = global_var_node.selection_table["1"]
#
#		#id = commandListForm.DBENGINE.get_id_from_display_name(global_variables_dictionary, selected_global_variable)
##		var type_input_dict :Dictionary = global_var_node.selection_table["1"]
##		print(type_input_dict)
##		type_input_dict = remove_key_from_dict(type_input_dict, "Display Name")
##		type_node.selection_table = type_input_dict
##		type_node.selection_table_name = ""
##		type_node.populate_list(false)
##		type_node.select_index(0)
##		selected_type = type_node.selectedItemKey
#	elif previous_selected_type != selected_type:
#		type_selection_changed()
#
#
#func remove_key_from_dict(baseDict :Dictionary, keyName: String ):
#	var temp_baseDic :Dictionary = baseDict.duplicate(true)
#	for key in temp_baseDic:
#		if key == keyName:
#			baseDict.erase(key)
#	return baseDict
#
#
#func type_selection_changed():
#	print("Type selection changed")
#	hide_input_nodes()
#	input_container_dict[selected_type].visible = true
#	var inputText = str(global_variables_dictionary[id][selected_type])
#	if selected_type == "Text":
#		inputText = str_to_var(inputText)["text"]
#	input_container_dict[selected_type].inputNode.set_text(inputText)
#	previous_selected_type = selected_type
#
#
#func hide_input_nodes():
#	for child in input_container.get_children():
#		child.visible = false




func _on_field_dropdown_input_selection_changed():
	var table_name:String = table_drop_down.selectedItemKey
	var key_ID:String = key_drop_down.selectedItemKey
	var field_ID:String = field_drop_down.selectedItemKey
	add_input_node_for_event_condition(table_name, key_ID, field_ID)
