@tool
extends FartDatatype

@export var showDeleteButton:bool = true
@export var showListItemLabel:bool = true
@export var showDatatypeSelection:bool = true
@export var showBeginListLabel:bool = true
@export var showSelectionCheckbox:bool = false


var parent
var action_string_button
var action_control
var key_id 
#var is_new_key :bool = false
var input_dict :Dictionary = {}
var options_dict :Dictionary = {}


func _init() -> void:
	type = "17"


func startup():
	parent = get_parent()
	key_id = parent.name
#	var default = DBENGINE.get_default_value(type)
#	print("INPUT ARRAY DEFAULT DICT: ", default)



func _get_input_value():

	input_data = {}
	options_dict["action"] = $Control/ActionSelection._get_input_value()
	input_data["options_dict"] = options_dict
	var id :int = 1
	var curr_input_dict :Dictionary = {}
	for child in $Control/Scroll1/Input.get_children():
		var input_node = child
		curr_input_dict[str(id)] = input_node._get_input_value()
		id += 1
	input_data["input_dict"] = curr_input_dict

	return input_data


func _set_input_value(node_value):
	if node_value == null:
		node_value =  get_default_value(type)
#	print(node_value)
	if typeof(node_value) == 4:
		node_value = str_to_var(node_value)
	input_data = node_value
	options_dict = input_data["options_dict"]
	$Control/ActionSelection.populate_list()
	var action_name_id :int = $Control/ActionSelection.get_dropdown_index_from_key(options_dict["action"])
	$Control/ActionSelection.select_index(action_name_id)
	set_input_data()



func _on_button_press_delete_selected_key(index:String):
	input_dict.erase(index)
	await get_tree().process_frame
	for key in input_dict.size() + 1:
		var str_key = str(key + 1)
		if !input_dict.has(str_key):
			if input_dict.has(str(key + 2)):
				var next_command = input_dict[str(key + 2)]
				input_dict[str_key] = next_command
				input_dict.erase(str(key + 2))
	_set_input_value(input_data)



func add_new_key():
	_get_input_value()
	var next_index :String = str(input_dict.size() + 1)
	var action_type :String = options_dict["action"]
	var default_dict  = get_default_value(action_type)
	input_dict[next_index] = {"Input_Node": default_dict, "ChkBox": true}
	input_data["input_dict"] = input_dict
	_set_input_value(input_data)


func show_datatype_selection(show:bool):
	$Control/ActionSelection.visible = show

func show_begin_list_label(show:bool):
	$Control/HBoxContainer.visible = show

func set_input_data():
	input_dict = input_data["input_dict"]
	for child in $Control/Scroll1/Input.get_children():
		child.queue_free()
	show_datatype_selection(showDatatypeSelection)
	show_begin_list_label(showBeginListLabel)

	for index in input_dict:
		var current_input
		if typeof(input_dict) != TYPE_DICTIONARY:
			current_input = str_to_var(input_dict[index])
		else:
			if typeof(input_dict[index]) == TYPE_STRING:
				current_input = str_to_var(input_dict[index])
			else:
				current_input = input_dict[index]

		var input_type :String = options_dict["action"]
		var next_scene = get_input_type_node(input_type).instantiate()
		var node_value = input_dict[index]
		#instantiate a container with a delete button
		var input_control_node :HBoxContainer = preload("res://addons/fart_engine/Database_Manager/Scenes and Scripts/UI_Input_Scenes/InputArray_Node_Field.tscn").instantiate()
		#add new container to Scroll1/input
		input_control_node.show_delete_button(showDeleteButton)
		input_control_node.show_selection_checkbox(showSelectionCheckbox)
		$Control/Scroll1/Input.add_child(input_control_node)
		#add new input node to new_container
		var newInputNode = create_datatype_node(input_type)
		newInputNode.set_name("Input_Node")
		
		input_control_node.add_child(newInputNode)
#		DBENGINE.add_input_node(1, 1, index, current_input, input_control_node,  null, node_value, input_type)
		
		newInputNode.set_label_text(index)
		
		next_scene.set_name(index)
		input_control_node.set_name(index)
		input_control_node.array_item_delete.connect(_on_button_press_delete_selected_key)
		newInputNode.show_label(showListItemLabel)

		input_control_node._set_input_value(node_value)
		Control.new().size_flags_changed

		#be sure to emit the signal with the input_node name as the index arguement



func _on_visibility_changed():
	if Engine.is_editor_hint():
		if visible:
			show_datatype_selection(showDatatypeSelection)
			show_begin_list_label(showBeginListLabel)
