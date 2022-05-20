extends Control
class_name InputEngine
tool

signal selected_item_changed #emitted when dropdown list selected item changes

export var label_text = ""
export var is_label_button = true
export var show_field := false

var labelNode
var inputNode
var itemName = ""
var default = null
var type = ""
var table_name = ""
var table_ref = ""
var parent_node :Object
var input_data = ""


func _ready():
	var me = self
	itemName = self.name
	labelNode = find_node("Label_Button")
	inputNode = find_node("Input")
#	for i in node_array:
#		if i.name == "Label":
#			labelNode = i.get_node("HBox/Label_Button")
#		elif i.name == "Input":
#			inputNode = i
			
	add_to_group("INPUT")
	
	if label_text == "":
		labelNode.set_text(itemName)
	else:
		labelNode.set_text(label_text)
	connect_signals()
	if me.has_method("startup"):
		me.startup()
	parent_node = get_main_tab(self)
	set_default_value()
	

#		var field_name_index :String = ""
#		field_name_index  = parent_node.get_data_index(labelNode.text, "Column")
#		if field_name_index != "":
#			var show_value :bool = parent_node.currentData_dict["Column"][field_name_index]["ShowValue"]
#			show_field_value(show_value)


func set_default_value():
	default = parent_node.get_default_value(type)

func label_pressed():
	var fieldName :String = labelNode.text
	if is_label_button:
		if fieldName == "Key":
			display_edit_table_menu()
		else:
			display_edit_field_menu()

func display_edit_table_menu():
	
	var edit_table_values :Object = load("res://addons/Database_Manager/Scenes and Scripts/UI_Input_Scenes/popup_edit_table_values.tscn").instance()
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
	yield(edit_table_values, "edit_table_values_closed")
	
	#UPDATE DATA FOR INPUT
	if edit_table_values.update_data:
		for i in edit_table_values.DATA_CONTAINER.get_children():
#
			var curr_input = parent_node.update_match(i)
			var field_name = i.name
#			if field_name == "DataType":
#				if edit_table_values.is_datatype_changed:
#
#					curr_input = i.get_dataType_ID(curr_input)
#					#print(parent_node.currentData_dict["Column"][edit_field_values.field_index], " ", field_name, " ",edit_field_values.initial_data_type)
#					parent_node.currentData_dict["Column"][edit_table_values.field_index][field_name] = edit_table_values.initial_data_type
#					#loop through all keys in currdict and set fieldName value to default for the datatype
#
#			print(edit_table_values.tableName , " ", field_name, " ", curr_input)
			all_table_data_dict[edit_table_values.tableName][field_name] = curr_input
		parent_node.save_file(table_data_path, all_table_data_dict)

#	if edit_table_values.is_datatype_changed:
#		var default_value = parent_node.get_default_value(edit_table_values.initial_data_type)
#
#		for n in parent_node.current_dict: #loop through all keys and set value for this file to "empty"
#			parent_node.current_dict[n][fieldName] = default_value
#				print(n, " ", fieldName, " ", default_value)
	
		parent_node.refresh_data()
		parent_node.get_node("../..").create_tabs()
	parent_node.get_node("Popups").visible = false
	edit_table_values.queue_free()

func display_edit_field_menu():
	var edit_field_values :Object = load("res://addons/Database_Manager/Scenes and Scripts/UI_Input_Scenes/popup_Edit_Field_Values.tscn").instance()
	parent_node  = get_main_tab(self)
	var keyName :String = parent_node.Item_Name
	var fieldName :String = labelNode.text
	
	edit_field_values.parent_node = self
	edit_field_values.main_node = parent_node
	edit_field_values.keyName = keyName
	edit_field_values.fieldName = fieldName
	parent_node.get_node("Popups").visible = true
	parent_node.get_node("Popups").add_child(edit_field_values)
	edit_field_values.label.set_text(fieldName + " Options")
	yield(edit_field_values, "edit_field_values_closed")
	
	#UPDATE DATA FOR INPUT
	if edit_field_values.update_data:
		for i in edit_field_values.DATA_CONTAINER.get_children():
			
			var curr_input = parent_node.update_match(i)

			var field_name = i.name
			if field_name == "DataType":
				if edit_field_values.is_datatype_changed:
					
					curr_input = i.get_dataType_ID(curr_input)
					#print(parent_node.currentData_dict["Column"][edit_field_values.field_index], " ", field_name, " ",edit_field_values.initial_data_type)
					parent_node.currentData_dict["Column"][edit_field_values.field_index][field_name] = edit_field_values.initial_data_type
					#loop through all keys in currdict and set fieldName value to default for the datatype
			else:
				parent_node.currentData_dict["Column"][edit_field_values.field_index][field_name] = curr_input

	if edit_field_values.is_datatype_changed:
		var default_value = parent_node.get_default_value(edit_field_values.initial_data_type)
		
		for n in parent_node.current_dict: #loop through all keys and set value for this file to "empty"
			parent_node.current_dict[n][fieldName] = default_value
#				print(n, " ", fieldName, " ", default_value)
	parent_node._on_Save_button_up(false)
	parent_node.refresh_data()

	parent_node.get_node("Popups").visible = false
	edit_field_values.queue_free()

func get_main_tab(par):
	#Get main tab scene which should have the popup container and necessary script
	while !par.get_groups().has("Tab"):
		par = par.get_parent()
	return par

func on_mouse_entered():
	var parent = get_main_tab(self)
	if parent.get("selected_field_name") != null:
		parent.selected_field_name = labelNode.text

func on_text_changed(new_text = "Blank"):
	var parent = get_main_tab(self)
#	print(parent.name)
	if parent.has_method("input_node_changed"):
		parent.input_node_changed(new_text)
#		print("Input Changed")
#	print(new_text)

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
	labelNode.connect("pressed", self, "label_pressed")
	labelNode.get_parent().get_node("Hide_Button").connect("pressed", self, "hide_value_button_pressed")
#	connect("mouse_entered", self, "on_mouse_entered")

	if inputNode.has_signal("text_changed"):
		inputNode.connect("text_changed", self, "on_text_changed")
	
	if inputNode.has_signal("pressed"):
		inputNode.connect("pressed", self, "on_text_changed", [inputNode.pressed])
	
	labelNode.connect("mouse_entered", self, "on_mouse_entered")
	self.connect("mouse_entered", self, "on_mouse_entered")
	
