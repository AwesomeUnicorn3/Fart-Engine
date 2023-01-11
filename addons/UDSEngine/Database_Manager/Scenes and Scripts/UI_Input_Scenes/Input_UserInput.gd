@tool
extends InputEngine

@onready var keyselect : PackedScene = load("res://addons/UDSEngine/Database_Manager/Scenes and Scripts/UI_Input_Scenes/KeySelect.tscn")

var parent
var action_string_button
var action_control
var key_id 
var is_new_key :bool = false

var input_dict :Dictionary = {}
var options_dict :Dictionary = {}


func _init() -> void:
	type = "11"


func startup():
	parent = get_parent()
	key_id = parent.name


func _on_button_up(index :String, _is_new_key :bool):
	parent_node.popup_main.visible = true
	is_new_key = _is_new_key
	var keyselect_scene = keyselect.instantiate()
	var action_key = labelNode.get_text()
	var btn_dict :Dictionary
	if typeof(input_dict[index]) != TYPE_DICTIONARY:
		btn_dict = str_to_var(input_data[index])
	else:
		btn_dict = input_dict[index]
	keyselect_scene._set_values(btn_dict, action_key)
	parent_node.add_child(keyselect_scene)
	keyselect_scene.is_new_key = is_new_key
	keyselect_scene.Input_UserInput_scene = self
#	keyselect_scene.grab
	on_text_changed(true)
	
	await keyselect_scene.closed
	parent_node.popup_main.visible = false
	if keyselect_scene.input_key_dict != {}:
		input_dict[index] = keyselect_scene.input_key_dict
	else:
		input_dict.erase(index)

	_set_input_value(input_data)
	keyselect_scene.queue_free()
#	parent_node.refresh_data(parent_node.Item_Name)


	
	
func _get_input_value():
	var return_value :Dictionary = {}
	input_data = {}
	options_dict["action"] = $ActionSelection.selectedItemName
	input_data["options_dict"] = options_dict
	input_data["input_dict"] = input_dict
	
	return_value = input_data
	return return_value


func _set_input_value(node_value):
	if typeof(node_value) == 4:
		node_value = str_to_var(node_value)
	#print(node_value)
	input_data = node_value
	options_dict = input_data["options_dict"]
	$ActionSelection.populate_list()
	var action_name_id = $ActionSelection.get_id(options_dict["action"])
	$ActionSelection.select_index(action_name_id)
	set_input_data()


func delete_selected_key(index:String):
	input_dict.erase(index)

	for key in input_dict.size():
		var str_key = str(key + 1)
		if !input_dict.has(str_key):
			if input_dict.has(str(key + 2)):
				var next_command = input_dict[str(key + 2)]
				input_dict[str_key] = next_command
				input_dict.erase(str(key + 2))
	_set_input_value(input_data)

			


func add_new_key():
	var next_index :String = str(input_dict.size() + 1)
	var default_dict :Dictionary
	if typeof(DBENGINE.get_default_value(type)) == TYPE_STRING:
		default_dict  = str_to_var(DBENGINE.get_default_value(type))
	else:
		default_dict = DBENGINE.get_default_value(type)
	#print(default_dict)
	input_dict[next_index] = default_dict["input_dict"]["1"]
#	print(input_dict)
	_set_input_value(input_data)
#	print(input_dict)
	var new_input  = $Scroll1/Input.get_node(next_index)
	new_input.index = next_index


func set_input_data():
	input_dict = input_data["input_dict"]

	for child in $Scroll1/Input.get_children():
		child.queue_free()

	for index in input_dict:
		var current_dict :Dictionary
		if typeof(input_dict) != TYPE_DICTIONARY:
			current_dict = str_to_var(input_dict[index])
		else:
			current_dict = input_dict[index]
			

		var keyname :String = current_dict["keyname"]
		var keycode :String = OS.get_keycode_string(str(current_dict["keycode"]).to_int())
		var edit_button = load("res://addons/UDSEngine/Database_Manager/Scenes and Scripts/UI_Input_Scenes/Input_UserInput_Button.tscn").instantiate()
		$Scroll1/Input.add_child(edit_button)

		edit_button.set_name(index)
		edit_button.get_node("KeySelectButton/KeyName").set_text(keyname)
		edit_button.get_node("KeyCode").set_text(str(keycode))
		edit_button.index = str(index)
		edit_button.button_clicked.connect(_on_button_up)
		edit_button.delete_key.connect(delete_selected_key)
