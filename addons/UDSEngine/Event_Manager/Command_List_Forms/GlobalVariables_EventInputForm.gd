@tool
extends CommandForm

@onready var global_var_node = $Control/VBoxContainer/KeyDropdown
@onready var type_node = $Control/VBoxContainer/TypeDropdown
@onready var input_container = $Control/VBoxContainer/InputContainer
@onready var input_container_dict :Dictionary


var value_node
var global_variables_dictionary :Dictionary

var function_name :String = "change_global_variable" #must be name of valid function
var which_var :String
var which_type :String
var to_what :String
var event_name :String = ""

var selected_global_variable :String
var selected_type :String
var previous_global_variable :String
var previous_selected_type :String
var id

func _ready():
	global_var_node.input_selection_changed.connect(selection_changed)
	type_node.input_selection_changed.connect(selection_changed)
	for child in input_container.get_children():
		input_container_dict[child.name] = child


func set_input_values(old_function_dict :Dictionary):
	edit_state = true
	global_var_node.inputNode.text = old_function_dict[function_name][0]
	global_var_node.selectedItemName = old_function_dict[function_name][0]
	
	type_node.inputNode.text = old_function_dict[function_name][1]
	type_node.selectedItemName = old_function_dict[function_name][1]
	selection_changed()
	input_container_dict[selected_type].inputNode.text = old_function_dict[function_name][2]


func get_input_values():
	which_var = global_var_node.inputNode.text
	which_type = type_node.inputNode.text
	to_what = input_container_dict[selected_type].inputNode.text
	event_name = commandListForm.CommandInputForm.source_node.parent_node.event_name
	var return_function_dict = {function_name : [which_var, which_type, to_what, event_name]}
	return return_function_dict

func _on_accept_button_up():
	#Get input values as dictionary
#	which_var = global_var_node.inputNode.text
#	which_type = type_node.inputNode.text
#	to_what = input_container_dict[selected_type].inputNode.text
#	event_name = commandListForm.CommandInputForm.source_node.parent_node.event_name
#	var function_dict :Dictionary = {function_name : [which_var, which_type, to_what, event_name]}
	commandListForm.CommandInputForm.function_dict = get_input_values()
	# {function Name : [which var, to_what]}
	#Send it all the way back to the command input form node and add it to main dictionary
	get_parent()._on_close_button_up()


func selection_changed(): #Called when any itemtype selection input is changed while this form is open
	selected_global_variable = global_var_node.selectedItemName
	selected_type = type_node.selectedItemName

	if previous_global_variable != selected_global_variable:
		previous_global_variable = selected_global_variable
		#populate type list in type_node
		id = commandListForm.DBENGINE.get_id_from_display_name(global_variables_dictionary, selected_global_variable)
		var type_input_dict :Dictionary = global_variables_dictionary[id]
		type_node.selection_table = type_input_dict
		type_node.selection_table_name = ""
		#populate list on seelction_node 
		type_node.populate_list(false)
		#select first type in type_node
		type_node.select_index(0)
		selected_type = type_node.selectedItemName
		
	elif previous_selected_type != selected_type:
		type_selection_changed()


func type_selection_changed():
	hide_input_nodes()
	input_container_dict[selected_type].visible = true
	input_container_dict[selected_type].inputNode.set_text(str(global_variables_dictionary[id][selected_type]))
	previous_selected_type = selected_type


func hide_input_nodes():
	for child in input_container.get_children():
		child.visible = false