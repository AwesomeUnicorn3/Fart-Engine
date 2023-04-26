@tool
extends DatabaseEngine
signal popup_closed
signal table_refresh_complete

@onready var btn_itemselect = load("res://addons/fart_engine/Database_Manager/Scenes and Scripts/UI_Navigation_Scenes/Navigation_Button.tscn")

@onready var btn_saveChanges = $VBox1/HBox1/SaveChanges_Button
@onready var btn_addNewItem = $VBox1/HBox1/AddNewKey_Button
@onready var btn_delete = $VBox1/HBox1/DeleteSelectedKey_Button
@onready var btn_newField = $VBox1/HBox2/AddNewField_Button
@onready var btn_deleteField = $VBox1/HBox2/DeleteField_Button

@onready var table_list = $VBox1/HBox3/Scroll1/Key_List_Vbox
@onready var scroll_table_list :ScrollContainer = $VBox1/HBox3/Scroll1
@onready var container_list1 = $VBox1/HBox3/Scroll2/Field_List_Vbox
@onready var container_list2 = $VBox1/HBox3/Scroll3/Field_List_Vbox
@onready var key_node = $VBox1/Key
@onready var item_name_input = $VBox1/Key/Input
@onready var label_changeNotification = $VBox1/HBox1/CenterContainer/Label

@onready var popup_main = $Popups
@onready var popup_deleteConfirm = $Popups/Popup_Delete_Confirm
@onready var popup_deleteKey = $Popups/popup_deleteKey
@onready var popup_listInput = $Popups/ListInput
@onready var popup_fileSelect = $Popups/FileSelect

var field_dict1 = {}
var field_dict2 = {}
@export var tableName := "Table Data"
var selected_field_name = ""
var delete_field_name = ""
var first_load = true
var input_changed = false
var error
var useDisplayName :bool = false
var selectedKeyID :String
var allow_duplicate_display_name:bool = false


func _ready():
	if first_load:
		current_table_name = tableName
		#print(current_table_name)
		first_load = false
		root = get_main_node()
		set_ref_table()
		use_display_name()
		update_dictionaries()
		reload_buttons()
		await get_tree().process_frame

		custom_table_settings()
		table_list.get_child(0)._on_Navigation_Button_button_up()


func custom_table_settings():
	var curr_table_settings_dict: Dictionary = import_data("Table Data")[tableName]
	#Disable editing the key for ALL tables
	$VBox1/Key/Input.editable = false
	$VBox1/Key.is_label_button = false
	for key in curr_table_settings_dict:
		var KeyValue = convert_string_to_type(curr_table_settings_dict[key])
		match key:
			"Show Delete Table Button":
				$VBox1/HBox1/DeleteTable_Button.visible = KeyValue
				$VBox1/HBox1/AddNewTable_Button.visible  = KeyValue

			"Enable Key Options":
				$VBox1/HBox1/AddNewKey_Button.visible = KeyValue
				$VBox1/HBox1/DeleteSelectedKey_Button.visible = KeyValue
				$VBox1/HBox1/DuplicateKey_Button.visible = KeyValue

			"Enable Field Options":
				$VBox1/HBox2.visible = KeyValue
			
			"Allow Duplicate Display Name":
				allow_duplicate_display_name = KeyValue

	if is_table_dropdown_list(current_table_name):
		$VBox1/Key/Input.editable = false


func does_key_display_name_exist(keyName:String)-> bool:
	var exists :bool = false
	for keyid in current_dict:
		if keyName == get_display_name_from_key(keyid):
			exists = true
			break
	return exists


func get_display_name_from_key(key:String)-> String:
	return str_to_var(str(current_dict[key]["Display Name"]))["text"]


func set_ref_table():
	var tbl_ref_dict = import_data("Table Data")
	table_ref = convert_string_to_type(str(tbl_ref_dict[tableName]["Display Name"]))["text"]
	current_table_ref = table_ref
	return table_ref


func use_display_name() -> bool:
	var tbl_ref_dict = import_data("Table Data" )
	useDisplayName = convert_string_to_type(str(tbl_ref_dict[tableName]["Use Display Name in Editor"]))
	return useDisplayName


func _on_visibility_changed():
	if visible:
		_ready()
		hide_all_popups()
		show_control_buttons()
		if is_data_updated():
			reload_buttons()
			reload_data_without_saving()
	else:
		hide_all_popups()


func is_data_updated():
	var is_updated := false
	var old_data_dict :Dictionary = currentData_dict.duplicate(true)
	update_dictionaries()
	for i in current_dict:
		if !old_data_dict.keys().has(i):
			is_updated = true
			break
	return is_updated


func show_control_buttons():
	if tableName == "Controls":
		btn_newField.visible = false
		btn_deleteField.visible = false
	else:
		btn_newField.visible = true
		btn_deleteField.visible = true


func get_values_dict(req = false):
	var custom_dict = {}
	var currentDict_inOrder = list_values_in_display_order(current_table_name)
	var data_dict_size = currentData_dict["Column"].size()
	for field in data_dict_size:
		field = str(field + 1)
		currentDict_inOrder[field] = currentData_dict["Column"][field]
	for i in currentDict_inOrder:
		var value_name = currentData_dict["Column"][i]["FieldName"]
		var itemType = currentData_dict["Column"][i]["DataType"]
		var tableRef = currentData_dict["Column"][i]["TableRef"]
		var required  = convert_string_to_type(currentData_dict["Column"][i]["RequiredValue"])
		var showValue  = convert_string_to_type(currentData_dict["Column"][i]["ShowValue"])
		var item_value
		if Item_Name == "Default":
			item_value = get_default_value(itemType)
		else:
			if str_to_var(value_name) == null:
				item_value = current_dict[Item_Name][value_name]
			else:
				var value_name_text :String  = str_to_var(value_name)["text"]
				item_value = current_dict[Item_Name][value_name_text]
		custom_dict[value_name] = {"Value" : item_value, "DataType" : itemType, "TableRef" : tableRef, "Order" : i}
	return custom_dict


func hide_all_popups():
	popup_main.visible = false
	popup_deleteConfirm.visible = false
	popup_deleteKey.visible = false
	var child_count := popup_listInput.get_child_count()
	while child_count > 0:
		popup_listInput.get_child(child_count - 1)._on_Close_button_up()
		child_count -= 1


func clear_buttons():
	for i in table_list.get_children():
		table_list.remove_child(i)
		i.queue_free()


func reload_buttons():
	clear_buttons()
	create_table_buttons()


func clear_data():
	label_changeNotification.visible = false
	input_changed = false
	for i in container_list1.get_children():
		if i.name != "Key":
			i.queue_free()
	for i in container_list2.get_children():
		var current_node = i
		i.queue_free()


func enable_all_buttons(value : bool = true):
	for i in table_list.get_children():
		i.disabled = !value
		i.reset_self_modulate()


func refresh_data(item_name : String = Item_Name):
	Item_Name = item_name
	get_root_node().selected_key = item_name
	enable_all_buttons()
	clear_data()
	field_dict1 = get_values_dict(true)
	item_name_input.set_text(Item_Name) #Sets the key in the first input
	var index = 1
	var index_half = (field_dict1.size() + 1)/2
	for i in field_dict1:
		var new_input = await add_input_node(index,index_half, i, field_dict1, container_list1, container_list2)
		custom_table_settings()
		index += 1
	if item_name != "Default":
		var btnNode = table_list.get_node(item_name)
		#print(table_list.get_node(item_name).name)
		#table_list.get_node(item_name)._on_TextureButton_button_up()
		btnNode.grab_focus() #sets focus to current item
		
	emit_signal("table_refresh_complete")


func create_table_buttons():
#Loop through the item_list dictionary and add a button for each item
	var sorted_current_dict :Dictionary = list_keys_in_display_order(tableName)
	for i in sorted_current_dict.size():
		var item_number = str(i + 1) #row_dict key
		var displayName :String = ""
		var label :String = currentData_dict["Row"][item_number]["FieldName"] #Use the row_dict key (item_number) to set the button label as the item name
		var key_dict :Dictionary = current_dict[label]
		if key_dict.has("Display Name"):
			if typeof(current_dict[label]["Display Name"]) == TYPE_STRING:
				displayName = str_to_var(current_dict[label]["Display Name"])["text"]
			else:
				displayName = current_dict[label]["Display Name"]["text"]
		var do_not_edit_array :Array = ["Table Data"]
		if !do_not_edit_array.has(currentData_dict["Row"][item_number]["FieldName"]):
			var newbtn :TextureButton = btn_itemselect.instantiate() #Create new instance of item button
			newbtn.set_name(label) #Set the name of the new button as the item name
			newbtn.add_to_group("Key")
			set_buttom_theme(newbtn, "Key")
			
#			print("Label: ", useDisplayName)
			#label_text: String = "", keyName: String = "", displayName :String = "", displayNameVisible :bool = true
			
			table_list.add_child(newbtn) #Add new item button to table_list
			newbtn.set_label_text(label, displayName, useDisplayName)
			newbtn.main_page = self


func set_buttom_theme(button_node: TextureButton, group: String):
#	print("BUTTON THEME: ", group)
	#SET COLOR BASED ON GROUP
	#get project table
	var project_table: Dictionary = import_data("Project Settings")
	var fart_editor_themes_table: Dictionary = import_data("Fart Editor Themes")
	
	var theme_profile: String = project_table["1"]["Fart Editor Theme"]
	var category_color: Color = str_to_var(fart_editor_themes_table[theme_profile][group + " Button"])
#	var group_name: String = group
#	for buttonName in button_dict:
#		var button_node = button_dict[buttonName]
#		button_node.root = self
	if button_node.is_in_group(group):
		button_node.set_base_color(category_color)



func _on_Save_button_up(update_Values : bool = true):
	if !has_empty_fields():
		if update_Values:
			update_values()
			await get_tree().create_timer(.5)
		save_all_db_files(current_table_name)
		update_dictionaries()
		var table_dict : Dictionary = import_data("Table Data")
		var is_dropown :bool= convert_string_to_type(table_dict[current_table_name]["Show in Dropdown Lists"])
		if is_dropown and current_table_name != "Table Data": 
			update_dropdown_tables()
		input_changed = true
		$VBox1/HBox1/CenterContainer/Label.visible = false
		match current_table_name:
			"Table Data":
				get_main_node()._ready()
		print("Save Successful")
	else:
		print("There was an error. Data has not been updated")


func update_dropdown_tables():
	for i in get_node("..").get_children():
		if i != self and i.is_in_group("Tab") and i.has_method("reload_buttons"):
			i.reload_buttons()
#			i.table_list.get_child(0)._on_Navigation_Button_button_up()


func reload_data_without_saving():
	reload_buttons()
	await get_tree().process_frame
	if table_list.has_node(Item_Name):
		var btnNode:TextureButton = table_list.get_node(Item_Name)
		btnNode._on_Navigation_Button_button_up()
	else:
		table_list.get_child(0)._on_Navigation_Button_button_up()


func update_values():
	var value
	var keyNode = null
	keyNode = key_node
	get_value_from_input_node(keyNode,"Key")
	for i in container_list1.get_children():
		value = i.labelNode.text
		get_value_from_input_node(i, value)

	for i in container_list2.get_children():
		value = i.labelNode.text
		get_value_from_input_node(i, value)
		#NOTE: Does NOT update the database files. That function is located in the save_data method
	if keyNode != null:
		reload_buttons()
		refresh_data(keyNode.inputNode.text)


func does_key_contain_invalid_characters(key):
	var value = false
	#loop through invalid characters and compare to item name, if any match, return error
	var array = [":", "/", "."]
	for i in array:
		if i in key:
			value = true
			print("'",i,"' is an invalid character. Please remove and try again")
			break
	return value


func has_empty_fields():
	#loop through input fields (need a better way to identify them and pull automatically instead of hard code)
	#if any of the fields are blank, return error
	var value = false
	#Iterate through input fields and verify that they values are not empty
	for i in field_dict1:
		#Remove blank spaces (so that you can't have an item name that is just spaces
		i = remove_special_char(i)
		if i == "":
#			value = true
			print("ERROR! One or more fields are blank")
			field_dict1[i] = "1"
	return value


func get_next_key_number(table_Name :String) -> String:
	#get table, loop through keys, find last key
	var next_key_number :int = 1
	for key in current_dict:
		print("Key number: ", key)
		var key_int: int = int(key)
		if next_key_number <= key_int:
			next_key_number = key_int + 1
	print("next Key number: ", next_key_number)
	return str(next_key_number)


func delete_selected_key():
	data_type = "Row"
	Delete_Key(Item_Name, current_dict, currentData_dict)
	save_all_db_files(current_table_name)
	reload_buttons()
	table_list.get_child(0)._on_Navigation_Button_button_up()


func _on_DeleteSelectedItem_button_up():
	var popup_label = $Popups/Popup_Delete_Confirm/PanelContainer/VBoxContainer/Label
	var popup_label2 = $Popups/Popup_Delete_Confirm/PanelContainer/VBoxContainer/Label2
	var lbl_text : String = popup_label2.get_text()
	lbl_text = lbl_text.replace("%", Item_Name.to_upper())
	popup_label.set_text(lbl_text)
	popup_main.visible = true
	popup_deleteConfirm.visible = true


func _on_deletePopup_Accept_button_up():
	delete_selected_key()
	_on__deletePopup_Cancel_button_up()


func _on__deletePopup_Cancel_button_up():
	popup_main.visible = false
	popup_deleteConfirm.visible = false


func _on_FileDialog_hide() -> void:
	hide_all_popups()

func _on_FileDialog_sprite_hide() -> void:
	hide_all_popups()


func remove_special_char(text : String):
	var array = [" "]
	var result = text
	for i in array:
		result = result.replace(i, "")
	return result


func _on_AddField_button_up():
	popup_main.visible = true
	var new_field :Control = load("res://addons/fart_engine/Database_Manager/Scenes and Scripts/UI_Input_Scenes/NewFieldPopup.tscn").instantiate()
	#add new_field to popup_main
	popup_main.add_child(new_field)
	#wait for new_field input to close
	await new_field.newfieldinput_closed
	#new_field queue free
	var new_field_dict :Dictionary = new_field.main_dict
	if !new_field_dict.is_empty():
		var field_name :String = new_field_dict["fieldName"]
		await add_field(field_name, new_field_dict["datatype"], new_field_dict["showField"], new_field_dict["required"], new_field_dict["tableName"])
		await refresh_data(Item_Name)
		await _on_Save_button_up()
	new_field.queue_free()
	popup_main.visible = false


func display_options():
	var values_in_order_dict = {}
	var dlg_keySelect = $Popups/popup_deleteKey/PanelContainer/VBoxContainer/Itemlist
	dlg_keySelect.clear()
	data_type = "Column"
	for n in currentData_dict[data_type].size(): #Arrange row dict values by order number
		var t = n + 1
		values_in_order_dict[n + 1] =  currentData_dict[data_type][str(t)]["FieldName"]
	for n in values_in_order_dict: #Add values to options menu
		var t = values_in_order_dict[n]
		dlg_keySelect.add_item (t,null,true )
	popup_main.visible = true
	popup_deleteKey.visible = true


func _on_Itemlist_item_selected(index):
	delete_field_name = currentData_dict[data_type][str(index + 1)]["FieldName"]


func _on_DeleteField_Accept_button_up():
	delete_field(delete_field_name)
	save_all_db_files(current_table_name)
	refresh_data(Item_Name)
	_on_DeleteField_Cancel_button_up()


func _on_DeleteField_Cancel_button_up():
	popup_main.visible = false
	popup_deleteKey.visible = false

func input_node_changed(value):
	label_changeNotification.visible = true
	input_changed = true


################NEW TABLE FUNCTIONS######################
func _on_add_new_table_button_button_up():
	$Popups/popup_newTable.visible = true
	$Popups/popup_newTable.set_input()
	popup_main.visible = true

func _on_new_table_Accept_button_up():
	var newTableName: String = await add_table()
	Item_Name = newTableName
	
	reload_buttons()
	refresh_data()
	#_on_Save_button_up()
	await get_tree().create_timer(0.5)
	_on_Save_button_up()

	#get_main_node()._ready()
	await get_tree().create_timer(1.5)
	#_on_Save_button_up()
	
#	var btn_node = table_list.get_node(newTableName)
#	print("Btn Node Name: ", btn_node.name)
#	btn_node._on_TextureButton_button_up()
	
	
	_on_newtable_Cancel_button_up()


func _on_newtable_Cancel_button_up():
	$Popups/popup_newTable.visible = false
	popup_main.visible = false


func add_table():
	var newTableInput := $Popups/popup_newTable
	var new_table_dict :Dictionary = newTableInput.get_input()
	var newTableName = new_table_dict["Display Name"]["text"]
	if newTableName == "":
		print("ERROR: Table Name Cannot be Blank")
	elif does_table_name_exist(newTableName):
		print("ERROR: Table Name already in use. Please try again with a different name")
	else:
		create_new_table(newTableName, new_table_dict)
	return newTableName


func does_table_name_exist(tableName:String)->bool:
	var table_dict :Dictionary = import_data("Table Data")
	return table_dict.has(tableName)


func delete_selected_table():
	var del_tbl_name = key_node.inputNode.get_text()
#	print("Table ID ", del_tbl_name)
	delete_table(del_tbl_name)
	get_main_node()._ready()
	await get_tree().process_frame


################NEW KEY FUNCTIONS######################
func _on_duplicate_key_button_button_up():
	var next_key :String = get_next_key_number(current_table_name)
	var new_entry :Dictionary = current_dict[Item_Name].duplicate(true)
	_on_SaveNewItem_button_up(next_key,new_entry )


func show_new_key_input_form():
	popup_main.visible = true
	$Popups/popup_newKey.visible = true
	await popup_closed
	$Popups/popup_newKey.reset_values()
	$Popups/popup_newKey.visible = false
	popup_main.visible = false

func _on_new_key_Accept_button_up():
	var newKeyValue :String = $Popups/popup_newKey.get_new_key_value()
	_on_SaveNewItem_button_up(newKeyValue)
	_on_new_key_Cancel_button_up()

func _on_new_key_Cancel_button_up():
	emit_signal("popup_closed")


func _on_SaveNewItem_button_up(newKeyName :String, new_key_dict :Dictionary = {}):
	var displayName :String = newKeyName
	if is_table_dropdown_list(tableName):
		newKeyName = get_next_key_number(tableName)
	if !allow_duplicate_display_name:
		if does_key_display_name_exist(displayName):
			print("ERROR: Duplicate Display Name Exists, to Allow this, change 'Allow Duplicate Display Name' in Table Options")
			return
#	print("New Key Name: ", newKeyName)
	if !does_key_exist(newKeyName):
#		print("New Key Name: ", newKeyName)
		if !does_key_contain_invalid_characters(str(newKeyName)):
#			print("New Key Name2: ", newKeyName)
			if !has_empty_fields():
#				print("New Key Name3: ", newKeyName)
				add_key(newKeyName, "1", true, false, false,false, new_key_dict)
				if current_dict[newKeyName].has("Display Name"):
					current_dict[newKeyName]["Display Name"] = {"text" : displayName}
			#update new dict entry with input values from item form
				update_values()
				save_all_db_files(current_table_name)
				reload_buttons()
				refresh_data(newKeyName)
				await get_tree().create_timer(.25).timeout
				var max_v_scroll = scroll_table_list.get_v_scroll_bar().max_value
				scroll_table_list.set_v_scroll(max_v_scroll)
	else:
		print("ERROR! No changes were made")




#_________________________________________________________________#
func set_display_name_first(): #Rearrange Fields- Not quite, but close
	#Or any time all tables need to be searched and modified
	var table_list: Dictionary = get_list_of_all_tables()
	
	for table_name in table_list:
	
		var read_dict:Dictionary = await import_data(table_name, true)["Column"].duplicate(true)
		var write_dict: Dictionary = await import_data(table_name, true)
		for order_number in read_dict:
			var field_name: String = read_dict[order_number]["FieldName"]
			if field_name == "Display Name" and order_number != str(1):
				print("Table Name: ", table_name)
				print("Order Number: ", order_number)
				print("Field Name: ", read_dict[order_number]["FieldName"])
				
				var display_dict: Dictionary = read_dict[order_number].duplicate(true)
				var index_1_dict: Dictionary = read_dict["1"].duplicate(true)
				write_dict["Column"]["1"] = display_dict
				write_dict["Column"][order_number] = index_1_dict
				print(write_dict["Column"])
				save_file(table_save_path + table_name + table_info_file_format, write_dict)
