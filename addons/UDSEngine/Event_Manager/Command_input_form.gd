@tool
extends DatabaseEngine

signal save_complete
signal rearrange_commands
signal edit_command

@onready var CommandLineItem = preload("res://addons/UDSEngine/Event_Manager/Command_line_item.tscn")
@onready var inputContainer = $VBox1/Scroll1/VBox1
var mainDictionary : Dictionary = {}
#var local_variable_dictionary : Dictionary 

var condition_types_dict : Dictionary = {"Inventory Item": "", "Event Variable": "", "Global Variable": ""}
var parent_node
var source_node

var function_dict :Dictionary = {}


func startup(main_dictionary:Dictionary, label_text:String, source_scene):
#	local_variable_dictionary = local_variables
	mainDictionary = main_dictionary
	source_node = source_scene
	$VBox1/HBox1/Label.set_text(label_text)
	rearrange_commands.connect(change_command_order)
	edit_command.connect(edit_selected_command)
	create_input_fields()


func edit_selected_command(key:String):
#	print("edit selected command")
	var selected_command_dict :Dictionary = mainDictionary[key]
	var function_name = selected_command_dict.keys()[0]
	open_selected_form_for_editing(function_name, selected_command_dict,key )


func open_selected_form_for_editing(function_name :String ,old_command_dict:Dictionary, key_value :String) -> void:
	#show Command List Form
	var CommandListForm = load("res://addons/UDSEngine/Event_Manager/Command_List_Forms/Command_List_Form.tscn").instantiate()
	#send key value to command list form so it can append the main dictionary with the new command dict
	await add_child(CommandListForm)
	CommandListForm.CommandInputForm = self
#	CommandListForm.local_variable_dictionary = local_variable_dictionary
	CommandListForm._open_selected_form(function_name)
	CommandListForm.emit_signal("set_input", old_command_dict)
	await CommandListForm.closed
	if function_dict != {}:
		mainDictionary[str(key_value)] = function_dict
	refresh_form()
	_on_SaveChanges_button_up()


func change_command_order(current_index:String, move_amount :int):
	var new_index :String = str(current_index.to_int() + move_amount)
	var temp_dict = mainDictionary.duplicate(true)
	var key_data = mainDictionary[current_index]
	var mainDictionary_size :int = mainDictionary.size()
	temp_dict.erase(current_index)
	if new_index.to_int() > 0 and new_index.to_int() <= mainDictionary_size: 
		var current_key_value = mainDictionary[current_index]
		var new_key_value = mainDictionary[new_index]
		mainDictionary[current_index] = new_key_value
		mainDictionary[new_index] = current_key_value
		refresh_form()


func _on_Close_button_up() -> void:
	emit_signal("save_complete")
	_on_SaveChanges_button_up()
	self.call_deferred("close_form")


func close_form():
	call_deferred("delete_me")


func delete_me():
	self.queue_free()


func _on_SaveChanges_button_up() -> void:
	updateMainDict()


func updateMainDict():
	mainDictionary = {}
	for node in inputContainer.get_children():
		mainDictionary[node.Key_field.inputNode.get_text()] = node.line_item_dictionary
	source_node.inputNode.set_text(var_to_str(mainDictionary))
	source_node.main_dictionary = mainDictionary


func clear_input_fields():
	for i in inputContainer.get_children():
		i.queue_free()


func _delete_selected_list_item(itemKey := ""):
	mainDictionary.erase(itemKey)
	for key in mainDictionary.size():
		var str_key = str(key + 1)
		if !mainDictionary.has(str_key):
			if mainDictionary.has(str(key + 2)):
				var next_command = mainDictionary[str(key + 2)]
				mainDictionary[str_key] = next_command
				mainDictionary.erase(str(key + 2))
	refresh_form()


func create_input_fields():
	for command_line in mainDictionary.size():
		command_line += 1
		var command_line_string = str(command_line)
		var command_line_node = CommandLineItem.instantiate()
		inputContainer.add_child(command_line_node)
		command_line_node.CommandInputForm = self
		command_line_node.Key_field.inputNode.set_text(str(command_line_string))
		command_line_node.parent_node = self
		command_line_node.line_item_dictionary = mainDictionary[command_line_string]
		command_line_node.get_node("ScriptInput/Input").set_text(str(command_line_node.line_item_dictionary))


func _on_AddItem_button_up() -> void:
	#show Command List Form
	var CommandListForm = load("res://addons/UDSEngine/Event_Manager/Command_List_Forms/Command_List_Form.tscn").instantiate()
	#send key value to command list form so it can append the main dictionary with the new command dict
	var key_value = get_next_key()
	await add_child(CommandListForm)
	CommandListForm.CommandInputForm = self
#	CommandListForm.local_variable_dictionary = local_variable_dictionary
	await CommandListForm.closed
	if function_dict != {}:
		mainDictionary[str(key_value)] = function_dict
	refresh_form()
	_on_SaveChanges_button_up()


func get_next_key() -> int:
	var nextKeyValue :int
	if mainDictionary.size() == 0:
		nextKeyValue = 1
	else:
		nextKeyValue = (mainDictionary.keys().max()).to_int() + 1
	return nextKeyValue


func _add_input_field() ->String:
	_on_SaveChanges_button_up()
	var nextKeyValue :int = get_next_key()
	var default_dictionary :Dictionary = get_default_value("15")
	mainDictionary[str(nextKeyValue)] = default_dictionary["1"]
	_on_SaveChanges_button_up()
	return str(nextKeyValue)


func refresh_form():
	clear_input_fields()
	create_input_fields()
