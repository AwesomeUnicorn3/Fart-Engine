@tool
extends Control

var tableName 


func _ready() -> void:
	if get_node("../..").has_method("_on_new_table_Accept_button_up"):
		var accept = $PanelContainer/MainVBox/Buttons/Accept
		var cancel = $PanelContainer/MainVBox/Buttons/Cancel
		accept.button_up.connect(get_node("../..")._on_new_table_Accept_button_up)
		cancel.button_up.connect(get_node("../..")._on_newtable_Cancel_button_up)


func _on_popup_newTable_visibility_changed():
	if visible:
		if is_instance_valid(tableName):
			tableName.grab_focus()


func reset_values():
	for child in $PanelContainer/MainVBox/UserInputScroll/UserInputVBox.get_children():
		child.queue_free()
	await get_tree().process_frame


func set_input(input_dict :Dictionary = get_default_values()):
	await reset_values()
	await get_tree().process_frame
	var DBENGINE :DatabaseManager = DatabaseManager.new()
	var input_data_dict :Dictionary = DBENGINE.import_data("Table Data", true)
	
	for key_index in input_data_dict["Column"].size():
		var keyName = input_data_dict["Column"][str(key_index + 1)]["FieldName"]
		var newNode = DBENGINE.create_input_node(keyName,"Table Data", input_dict, input_data_dict)
		if newNode.type == "5":
			newNode.selection_table_name = "Table Category"
		$PanelContainer/MainVBox/UserInputScroll/UserInputVBox.add_child(newNode)
		newNode.set_input_value(input_dict[keyName])
		newNode.is_label_button = false
		
		
	
	

func get_default_values():
	var default_dict :Dictionary = DatabaseManager.new().import_data("Table Data")["Blank"]
	return default_dict


func get_input():
	var return_dict :Dictionary = {}
	var user_input_main_node :VBoxContainer = $PanelContainer/MainVBox/UserInputScroll/UserInputVBox
	for child in user_input_main_node.get_children():
		if child.has_method("get_input_value"):
			return_dict[child.name] = child.get_input_value()
	return return_dict
