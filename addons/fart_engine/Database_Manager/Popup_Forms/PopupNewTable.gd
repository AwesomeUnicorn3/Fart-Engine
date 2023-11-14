@tool
extends PopupForm

var tableName 


#func _ready() -> void:
#	if get_node("../..").has_method("_on_new_table_Accept_button_up"):
#		var accept = $MainVBox/AcceptCancelButtons/Accept
#		var cancel = $MainVBox/AcceptCancelButtons/Cancel
#		accept.button_up.connect(get_node("../..")._on_new_table_Accept_button_up)
#		cancel.button_up.connect(get_node("../..")._on_newtable_Cancel_button_up)


func _on_popup_newTable_visibility_changed():
	if visible:
		if is_instance_valid(tableName):
			tableName.grab_focus()


func reset_values():
	for child in $MainVBox/UserInputScroll/UserInputVBox.get_children():
		child.queue_free()
		await get_tree().process_frame
	await get_tree().process_frame


func set_input(input_value):
	await reset_values()
	#await get_tree().process_frame
	var input_data_dict :Dictionary = all_tables_merged_data_dict["10000"]
	
	for key_index in input_data_dict[FIELD].size():
		var keyName = input_data_dict[FIELD][str(key_index + 1)]["FieldName"]
		var newNode = await create_input_node("10000", str(key_index + 1),keyName)
		newNode.set_label_text(keyName)
#		if newNode.type == "5":
#			newNode.selection_table_name = "10006"
		var input_dict :Dictionary = get_default_values()
		$MainVBox/UserInputScroll/UserInputVBox.add_child(newNode)
		input_value = input_dict[keyName]
		newNode.set_input_value(input_value)
		newNode.is_label_button = false
		
		
	
	
func set_values(arg_array:Array)-> void:
	set_input(arg_array[0])


func get_default_values():
	var default_dict :Dictionary = all_tables_merged_dict["10000"]["10003"]
	return default_dict



func set_popup_return_value():
	var return_dict :Dictionary = {}
	var user_input_main_node :VBoxContainer = $MainVBox/UserInputScroll/UserInputVBox
	for child in user_input_main_node.get_children():
		if child.has_method("get_input_value"):
			return_dict[child.name] = child.get_input_value()
	PopupManager.set_return_value(return_dict)
#	var return_dict :Dictionary = {}
#	var user_input_main_node :VBoxContainer = $MainVBox/UserInputScroll/UserInputVBox
#	for child in user_input_main_node.get_children():
#		if child.has_method("get_input_value"):
#			return_dict[child.name] = child.get_input_value()
#	return return_dict


func _on_accept_button_up():
	set_popup_return_value()
	PopupManager.hide_all_popups()


func _on_cancel_button_up():
	PopupManager.set_return_value("")
	PopupManager.hide_all_popups()
