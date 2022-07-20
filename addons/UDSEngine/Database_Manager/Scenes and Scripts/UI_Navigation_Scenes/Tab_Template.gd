@tool
extends DatabaseEngine

@onready var btn_itemselect = load("res://addons/UDSEngine/Database_Manager/Scenes and Scripts/UI_Input_Scenes/Btn_ItemSelect.tscn")

@onready var btn_saveChanges = $VBox1/HBox1/SaveChanges_Button
@onready var btn_saveNewItem = $VBox1/HBox1/SaveNewKey_Button
@onready var btn_addNewItem = $VBox1/HBox1/AddNewKey_Button
@onready var btn_cancel = $VBox1/HBox1/CancelChanges_Button
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
@onready var popup_newField = $Popups/popup_newValue
@onready var popup_listInput = $Popups/ListInput
@onready var popup_fileSelect = $Popups/FileSelect


var field_dict1 = {}
var field_dict2 = {}
var tableName = ""
var selected_field_name = ""
var first_load = true
var input_changed = false
var error

func _ready():
	if first_load:
		current_table_name = tableName
		first_load = false
		set_ref_table()
		update_dictionaries()
		reload_buttons()
		table_list.get_child(0)._on_TextureButton_button_up()
		custom_table_settings()

func custom_table_settings():
	match tableName:
		"Table Data":
			#lock key name input
			$VBox1/Key/Input.editable = false
			$VBox1/Key.is_label_button = false
			#new table button visible
			$VBox1/HBox1/AddNewTable_Button.visible = true
			#delete table button visible
			$VBox1/HBox1/DeleteTable_Button.visible = true
			#add key not visible
			$VBox1/HBox1/AddNewKey_Button.visible = false
			#delete key not visible
			$VBox1/HBox1/DeleteSelectedKey_Button.visible = false
			#Hide add and delete field buttons
			$VBox1/HBox2.visible = false

		"Global Data":
			$VBox1/Key/Input.editable = true
	
	

func set_ref_table():
	var tbl_ref_dict = import_data(table_save_path + "Table Data" + file_format)
	table_ref = tbl_ref_dict[tableName]["Display Name"]
	current_table_ref = table_ref
	return table_ref

func _on_visibility_changed():
	if visible:
		_ready()
		hide_all_popups()
		show_control_buttons()
		if is_data_updated():
			reload_buttons()
			reload_data_without_saving()

	else:
#		queue_free()
		hide_all_popups()
#		clear_data()
#		clear_buttons()


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
	var currentDict_inOrder = {}

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
		
		
			#THIS IS WHERE ALL VALUES SHO8LD BE SET TO DATATYPE DEFAULTS
			#DOING THIS WILL ALLOW ME TO DELETE ALL OF THE "DEFAULT" TABLES
		var item_value
		if Item_Name == "Default":
			item_value = get_default_value(itemType)
		else:
			item_value = current_dict[Item_Name][value_name]

		#if required == req:# and showValue:
		custom_dict[value_name] = {"Value" : item_value, "DataType" : itemType, "TableRef" : tableRef, "Order" : i}

	return custom_dict



func hide_all_popups():
	popup_main.visible = false
	popup_deleteConfirm.visible = false
	popup_newField.visible = false
	popup_deleteKey.visible = false
	
	var child_count := popup_listInput.get_child_count()
	while child_count > 0:
		popup_listInput.get_child(child_count - 1)._on_Close_button_up()
		child_count -= 1


func clear_buttons():
	#Removes all item name buttons from table_list
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
	#Enables user to interact with all item buttons on table_list
	for i in table_list.get_children():
		i.disabled = !value


func refresh_data(item_name : String = Item_Name):
#	#Pulls specific item data when button is clicked
	Item_Name = item_name #reset the script variable Item_Name
	enable_all_buttons()
	clear_data()

#	#Sets all data from item_table with values from item button that was pressed
	field_dict1 = get_values_dict(true)
#	field_dict2 = get_values_dict(true)
	item_name_input.set_text(Item_Name) #Sets the key in the first input
	var index = 1
	var index_half = (field_dict1.size() + 1)/2
	for i in field_dict1:
		var new_input = await add_input_node(index,index_half, i, field_dict1, container_list1, container_list2)
		
		#custom settings for specific tables##
		match tableName:
			"Table Data":
				new_input.is_label_button = false
	
		index += 1
	if item_name != "Default":
		table_list.get_node(item_name).disabled = true #Sets current item button to disabled
		table_list.get_node(item_name).grab_focus() #sets focus to current item


func create_table_buttons():
#Loop through the item_list dictionary and add a button for each item
	for i in currentData_dict["Row"].size():
		var item_number = str(i + 1) #row_dict key
		var label = currentData_dict["Row"][item_number]["FieldName"] #Use the row_dict key (item_number) to set the button label as the item name
		var do_not_edit_array :Array = ["Table Data"]
		if !do_not_edit_array.has(currentData_dict["Row"][item_number]["FieldName"]):
			var newbtn :Button = btn_itemselect.instantiate() #Create new instance of item button
			table_list.add_child(newbtn) #Add new item button to table_list

			newbtn.set_name(label) #Set the name of the new button as the item name
			newbtn.get_node("Label").set_text(label) #Sets the button label (name that the user sees)


func _on_Save_button_up(update_Values : bool = true):
	#Check if values are blank return error if true
	if !has_empty_fields():
		if update_Values:
			update_values()
		save_all_db_files(current_table_name)
		update_dictionaries()
		var table_dict : Dictionary = import_data(table_save_path + "Table Data" + file_format)
		var is_dropown  = convert_string_to_type(table_dict[current_table_name]["Is Dropdown Table"])
		if is_dropown: 
			update_dropdown_tables()
		input_changed = true
		$VBox1/HBox1/CenterContainer/Label.visible = false
		match current_table_name:
			"Table Data":
				get_udsmain().create_tabs()
				
		print("Save Successful")
	else:
		print("There was an error. Data has not been updated")

func update_dropdown_tables():
	for i in get_node("..").get_children():
		if i != self and i.is_in_group("Tab") and i.has_method("reload_buttons"):
			i.reload_buttons()
			i.table_list.get_child(0)._on_TextureButton_button_up()

func reload_data_without_saving():
	reload_buttons()
	table_list.get_child(0)._on_TextureButton_button_up()

func update_values():
	var value
	var keyNode = null
	keyNode = key_node
	
	update_match(keyNode,"Key")

#Uses input values from Items form to update current_dict 
	for i in container_list1.get_children():
		value = i.labelNode.get_text()
		update_match(i, value)

		
	for i in container_list2.get_children():
		value = i.labelNode.get_text()
		update_match(i, value)

		#NOTE: Does NOT update the database files. That function is located in the save_data method
	if keyNode != null:
		reload_buttons()
		refresh_data(keyNode.inputNode.text)


func add_entry_row(entry_value):
	var item_name_dict = currentData_dict["Row"]
	var item_name_dict_size = item_name_dict.size()
	currentData_dict["Row"][str(item_name_dict_size)] = entry_value

func add_table_key(key):
	#duplicate "Default" value
	var new_entry = current_dict["Default"].duplicate(true)
	#Add value to item dict
	current_dict[key] = new_entry
	



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
			value = true
			print("ERROR! One or more fields are blank")
			break
	#return array of empty fields
	return value

func _on_AddNewItem_button_up():
	#input default item values to form


	refresh_data("Default")


	#Disable all item buttons
	enable_all_buttons(false)
	#adjust button layaout
	btn_delete.visible = false
	btn_saveNewItem.visible = true
	btn_saveChanges.visible = false
	btn_addNewItem.visible = false
	btn_cancel.visible = true


func _on_Cancel_button_up():
	#display data from the first item in the list
	table_list.get_child(0)._on_TextureButton_button_up()

	#adjust button layaout
	btn_delete.visible = true
	btn_saveNewItem.visible = false
	btn_saveChanges.visible = true
	btn_addNewItem.visible = true
	btn_cancel.visible = false


func _on_SaveNewItem_button_up():
	#NEED TO SET ITEM NAME VARIABLE HERE!!!
	Item_Name = item_name_input.text
	#THIS IS WHERE ERROR CHECKING NEEDS TO CONVERGE AND NOT RUN IF THERE IS AN ERROR
	if !does_key_exist(Item_Name) and !does_key_contain_invalid_characters(str(Item_Name)) and !has_empty_fields():

		#save new item to current_dict
		add_key(Item_Name, "1", true, false, false)

		#update new dict entry with input values from item form
		update_values()
		#Global Data to .json files
		save_all_db_files(current_table_name)
		reload_buttons()
		refresh_data(Item_Name)

		#adjust button layaout
		btn_delete.visible = true
		btn_saveNewItem.visible = false
		btn_saveChanges.visible = true
		btn_addNewItem.visible = true
		btn_cancel.visible = false
		#Set V scroll to maxvalue so user can see new entry

		await get_tree().create_timer(.25).timeout
		var max_v_scroll = scroll_table_list.get_v_scroll_bar().max_value
		scroll_table_list.set_v_scroll(max_v_scroll)
	else:
		print("ERROR! No changes were made")


func delete_selected_item():
	data_type = "Row"
	Delete_Key(Item_Name)
	save_all_db_files(current_table_name)
	reload_buttons()
	table_list.get_child(0)._on_TextureButton_button_up()

func _on_DeleteSelectedItem_button_up():
	var popup_label = $Popups/Popup_Delete_Confirm/PanelContainer/VBoxContainer/Label
	var popup_label2 = $Popups/Popup_Delete_Confirm/PanelContainer/VBoxContainer/Label2
	var lbl_text : String = popup_label2.get_text()
	lbl_text = lbl_text.replace("%", Item_Name.to_upper())
	popup_label.set_text(lbl_text)
	popup_main.visible = true
	popup_deleteConfirm.visible = true


func _on_deletePopup_Accept_button_up():
	delete_selected_item()
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
	popup_newField.visible = true


func _on_NewField_Accept_button_up():
	add_newField()
	_on_NewField_Cancel_button_up()


func _on_NewField_Cancel_button_up():
	popup_main.visible = false
	popup_newField.visible = false
	popup_newField.reset_values()


func add_newField(): 
	var datafield = $Popups/popup_newValue/PanelContainer/VBox1/HBox1/VBox2/ItemType_Selection
	var fieldName = $Popups/popup_newValue/PanelContainer/VBox1/HBox1/VBox1/Input_Text/Input.get_text()
	var selected_item_name = datafield.selectedItemName
	var datatype = datafield.get_dataType_ID(selected_item_name)
	var showField = $Popups/popup_newValue/PanelContainer/VBox1/HBox1/VBox3/LineEdit3.is_pressed()
	var required = $Popups/popup_newValue/PanelContainer/VBox1/HBox1/VBox4/LineEdit3.is_pressed()
	var tableName = $Popups/popup_newValue/PanelContainer/VBox1/HBox1/Table_Selection.selectedItemName
	#Get input values and send them to the editor functions add new value script
	#NEED TO ADD ERROR CHECKING
	
	await add_field(fieldName, datatype, showField, false, tableName)
	refresh_data(Item_Name)
	


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



var delete_field_name = ""
#var delete_field_index = 0
func _on_Itemlist_item_selected(index):
	delete_field_name = currentData_dict[data_type][str(index + 1)]["FieldName"]
#	delete_field_index = str(index + 1)


func _on_DeleteField_Accept_button_up():
	Delete_Key(delete_field_name)
	save_all_db_files(current_table_name)
	refresh_data(Item_Name)
	_on_DeleteField_Cancel_button_up()


func _on_DeleteField_Cancel_button_up():

	popup_main.visible = false
	popup_deleteKey.visible = false

func input_node_changed(value):
	label_changeNotification.visible = true
	input_changed = true

#
#func _on_RefreshData_button_up() -> void:
#	reload_data_without_saving()




func get_udsmain():
	var main_node = null
	var curr_selected_node = self
	while main_node == null:
		if curr_selected_node.get_parent().is_in_group("UDS_Root"):
			main_node = curr_selected_node.get_parent()
		else:
			curr_selected_node = curr_selected_node.get_parent()
	return main_node


func _on_add_new_table_button_button_up():
	$Popups/popup_newTable.visible = true
	popup_main.visible = true

func _on_new_table_Accept_button_up():
	await add_table()
	get_udsmain().create_tabs()
	_on_newtable_Cancel_button_up()

func _on_newtable_Cancel_button_up():
	$Popups/popup_newTable.reset_values()
	$Popups/popup_newTable.visible = false
	popup_main.visible = false


func add_table():
	#Check for errors entered in to the form
	var newTable := $Popups/popup_newTable
	var tableName = newTable.tableName.text
	var keyName = newTable.keyName.text
	var keyDataType = "1"
	var keyVisible = true
	var fieldName = newTable.fieldName.text
	var fieldDatatype = "1"
	var fieldVisible = true
	var dropdown_table = "empty"
	var isDropdown = newTable.isList.button_pressed
	var RefName = newTable.refName.text
	var createTab = newTable.createTab.button_pressed
	var canDelete = true
	var add_toSaveFile = newTable.in_saveFile.button_pressed
	var dup_check = tableName + file_format
	
	var files = await list_files_with_param(table_save_path, file_format, ["Table Data.json"])
	
	if tableName == "":
		error = 4
	if keyName == "":
		if !isDropdown:
			error = 4
	elif files.has(dup_check):
		error = 5
	else:
		error = 0
	match error: 
		0: #if there are no errors detected
			add_new_table(tableName, keyName, keyDataType, keyVisible, fieldName, fieldDatatype, fieldVisible, dropdown_table, RefName, createTab, canDelete, isDropdown, add_toSaveFile, false )

#
#		4:
#			error_display()
#		5:
#			error_display()
	error = 0


func delete_table(del_tbl_name = key_node.inputNode.get_text()):
	Delete_Table(del_tbl_name)
	get_udsmain().create_tabs()
