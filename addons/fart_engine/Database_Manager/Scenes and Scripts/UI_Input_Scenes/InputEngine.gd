@tool
extends Control
class_name InputEngine

signal input_selection_changed #emitted when dropdown list selected item changes
signal input_load_complete
signal checkbox_pressed

@export var label_text := ""
@export var is_label_button := true
@export var showLabel := true
@export var show_field := false

var me = self #needed to call elements from scripts that extend this one

var DBENGINE := DatabaseEngine.new()
var labelNode
var inputNode
var itemName = ""
var default = null
var type = ""
var table_name = ""
var table_ref = ""
var parent_node :Object
var input_data 
var index :String


func _ready():
	var me = self
	itemName = name
#	add_to_group("INPUT")
	
	await get_label_node()
	await get_input_node()

	set_label_text()

	show_label(showLabel)
	connect_signals()
	parent_node = await get_main_tab(self)
	set_default_value()
	emit_signal("input_load_complete")
	if me.has_method("startup"):
		await me.startup()


func get_input_node():
	inputNode = await find_child("Input", true)
	return inputNode

func get_label_node():
	labelNode = await find_child("Label_Button", true)
	return labelNode


func show_label(show :bool = true):
	labelNode.visible = show


func set_label_text():
#	print("LABLE TEXT: ", label_text)
#	print("ITEM NAME: ", itemName)
	if !is_instance_valid(labelNode):
		get_label_node()
	if label_text == "":
		labelNode.set_text(itemName)
		label_text = itemName
	else:
		labelNode.set_text(label_text)


func set_default_value():
	var dbengine = DatabaseEngine.new()
	default = dbengine.get_default_value(type)


func label_pressed():
	var fieldName :String = labelNode.text
	print("FieldName: ", fieldName)
	print("Is Label: ", is_label_button)
	if is_label_button:
		if fieldName == "Key":
			display_edit_table_menu()
		elif fieldName == "Display Name":
			is_label_button = false
			print("Cannot Edit the settings for Display Name Node")
		else:
			display_edit_field_menu()

func display_edit_table_menu():
	var edit_table_values :Object = preload("res://addons/fart_engine/Database_Manager/Scenes and Scripts/UI_Input_Scenes/popup_edit_table_values.tscn").instantiate()
	parent_node = get_main_tab(self)
	var keyName :String = parent_node.Item_Name
	var fieldName :String = labelNode.text
	var table_data_path :String = parent_node.table_save_path + "Table Data" + parent_node.file_format
	var all_table_data_dict :Dictionary = parent_node.import_data(table_data_path)

	edit_table_values.parent_node = self
	edit_table_values.main_node = parent_node
	edit_table_values.keyName = keyName
	edit_table_values.tableName = parent_node.current_table_name
	edit_table_values.get_node("PanelContainer/VBox1/Label/HBox1/Label_Button").set_text(edit_table_values.tableName + " Options")
	parent_node.get_node("Popups").visible = true
	parent_node.get_node("Popups").add_child(edit_table_values)
	await edit_table_values.edit_table_values_closed
	if edit_table_values.update_data:
		for i in edit_table_values.DATA_CONTAINER.get_children():
			var curr_input = parent_node.get_value_from_input_node(i)
			var field_name = i.name
			all_table_data_dict[edit_table_values.tableName][field_name] = curr_input
		parent_node.save_file(table_data_path, all_table_data_dict)
		parent_node.refresh_data()
		parent_node.get_node("../..").create_tabs()
	parent_node.get_node("Popups").visible = false
	edit_table_values.queue_free()


func display_edit_field_menu():
	var edit_field_values :Object = load("res://addons/fart_engine/Database_Manager/Scenes and Scripts/UI_Input_Scenes/popup_Edit_Field_Values.tscn").instantiate()
	parent_node  = get_main_tab(self)
	var keyName :String = parent_node.Item_Name
	var fieldName :String = labelNode.text

	edit_field_values.parent_node = self
	edit_field_values.data_dict = parent_node.currentData_dict
	edit_field_values.keyName = keyName
	edit_field_values.fieldName = fieldName
	parent_node.get_node("Popups").visible = true
	parent_node.get_node("Popups").add_child(edit_field_values)
	edit_field_values.label.set_text(fieldName + " Options")
	edit_field_values.reference_table_input = self

	await edit_field_values.edit_field_values_closed
	var datatype_id = 0

	if edit_field_values.update_data:
		for i in edit_field_values.DATA_CONTAINER.get_children():
			var curr_input = parent_node.get_value_from_input_node(i)
			var field_name = i.name
			if field_name == "DataType":
				if edit_field_values.is_datatype_changed:
					curr_input = i.get_dataType_ID(i.selectedItemKey)
					datatype_id = curr_input

			if field_name == "TableRef":
				curr_input = i.selectedItemKey
				
			elif field_name == "FieldName":
				curr_input = str_to_var(curr_input)["text"]
			parent_node.currentData_dict["Column"][edit_field_values.field_index][field_name] = curr_input

	if edit_field_values.is_datatype_changed:
		var default_value = parent_node.get_default_value(datatype_id)#edit_field_values.initial_data_type)
		for key in parent_node.current_dict: #loop through all keys and set value for this file to "empty"
			parent_node.current_dict[key][fieldName] = default_value
	parent_node.refresh_data()
	parent_node._on_Save_button_up()
	parent_node.refresh_data()
	parent_node.get_node("Popups").visible = false
	edit_field_values.queue_free()


func get_main_tab(par := get_parent()):
	#Get main tab scene which should have the popup container and necessary script
	var grps := par.get_groups()
	var parent_found :bool = false
	while parent_found == false:
		var temp_par = par.get_parent()
		if temp_par == null:
			par == null
			parent_found = true
		else:
			par = temp_par
			grps = par.get_groups()
		if grps.has(&"Tab") == true:
			parent_found = true
	return par


func on_mouse_entered():
	var parent = get_main_tab(self)
	if parent != null:
		if parent.get("selected_field_name") != null:
			parent.selected_field_name = labelNode.text


func on_text_changed(new_text = "Blank"):
	var parent = get_main_tab(self)
	if parent.has_method("input_node_changed"):
		parent.input_node_changed(new_text)


func set_initial_show_value():
	var show_value := false
	var field_name_index :String = parent_node.get_data_index(labelNode.text, "Column")
	if field_name_index != "":
		show_value = parent_node.convert_string_to_type(parent_node.currentData_dict["Column"][field_name_index]["ShowValue"], "4")
		show_showHide_button()
		show_field_value(show_value)


func hide_value_button_pressed():
	var show_value :bool = !parent_node.currentData_dict["Column"][parent_node.get_data_index(labelNode.text, "Column")]["ShowValue"]
	show_field_value(show_value)


func show_showHide_button():
	labelNode.get_parent().get_node("Hide_Button").visible = true


func show_field_value(show_value :bool):
	parent_node.currentData_dict["Column"][parent_node.get_data_index(labelNode.text, "Column")]["ShowValue"] = show_value
	if show_value:
		show_field = true
		labelNode.get_parent().get_node("Hide_Button").set_text("Hide Value")
		for i in get_children():
			if !i.is_in_group("Label"):
				if i.has_method("set_visible"):
					i.visible = true
					
	else:
		show_field = false
		labelNode.get_parent().get_node("Hide_Button").set_text("Show Value")
		for i in get_children():
			if !i.is_in_group("Label"):
				if i.has_method("set_visible"):
					i.visible = false
	parent_node.save_all_db_files()


func connect_signals():
	labelNode.pressed.connect(label_pressed)
	labelNode.get_parent().get_node("Hide_Button").pressed.connect(hide_value_button_pressed)
	if inputNode.has_signal("text_changed"):
		inputNode.text_changed.connect(on_text_changed)

	if inputNode.has_signal("pressed"):
		inputNode.pressed.connect(on_text_changed.bind(inputNode.pressed))
	labelNode.mouse_entered.connect(on_mouse_entered)


func input_value_clamp(value:String, min_value = 1, max_value = 500) -> String:
	var num_value = value.to_float()
	num_value = clamp(num_value, min_value, max_value)
	return str(num_value)


func get_input_value():
	var return_value = me._get_input_value()
	return return_value


func set_input_value(node_value , key_name: String = "", current_table_name :String = ""):
	me._set_input_value(node_value)
	set_label_text()
