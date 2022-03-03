extends DatabaseEngine
tool

onready var btn_itemselect = preload("res://addons/Database_Manager/Scenes and Scripts/UI_Input_Scenes/Btn_ItemSelect.tscn")



onready var btn_saveChanges = $VBox1/HBox1/SaveChanges
onready var btn_saveNewItem = $VBox1/HBox1/SaveNewItem
onready var btn_addNewItem = $VBox1/HBox1/AddNewItem
onready var btn_cancel = $VBox1/HBox1/Cancel
onready var btn_delete = $VBox1/HBox1/DeleteSelectedItem
onready var table_list = $VBox1/HBox2/Scroll1/Table_Buttons
onready var container_list1 = $VBox1/HBox2/Panel1/VBox1/HBox1/Scroll1/VBox1
onready var container_list2 = $VBox1/HBox2/Panel1/VBox1/HBox1/Scroll2/VBox2
onready var container_list3 = $VBox1/HBox2/Panel1/VBox1/Scroll1/Scroll1/VBox1
onready var container_list4 = $VBox1/HBox2/Panel1/VBox1/Scroll1/Scroll2/VBox2
onready var popup_main = $Popups
onready var popup_deleteConfirm = $Popups/popup_delete_confirm
onready var item_name_input = $VBox1/HBox2/Panel1/VBox1/HBox1/Scroll1/VBox1/Key/Input
onready var popup_deleteKey = $Popups/popup_deleteKey
onready var popup_fileDialog = $Popups/FileDialog
onready var popup_newField = $Popups/popup_newValue

#var udsEngine

var field_dict1 = {}
var field_dict2 = {}
var field_dict3 = {}

var tableName = ""

var selected_field_name = ""
var first_load = true
var input_changed = false

func _ready():
	if first_load:
		current_table_name = tableName
		first_load = false
		set_ref_table()
		update_dictionaries()
		reload_buttons()
		table_list.get_child(0)._on_TextureButton_button_up()

func set_ref_table():
	var tbl_ref_dict = import_data(table_save_path + "Table Data" + file_format)
	table_ref = tbl_ref_dict[tableName]["Reference Name"]
	current_table_ref = table_ref
	return table_ref

func _on_visibility_changed():
	if visible:
#		current_table_name = tableName
		_ready()
		hide_all_popups()
#		update_dictionaries()
#		reload_buttons()

#		table_list.get_child(0)._on_TextureButton_button_up()

	else:
#		queue_free()
		hide_all_popups()
#		clear_data()
#		clear_buttons()

func get_values_dict(var req = false):
	var custom_dict = {}
	var currentDict_inOrder = {}
	for i in currentData_dict["Column"].size():
		i = str(i + 1)
		currentDict_inOrder[i] = currentData_dict["Column"][i]

	for i in currentDict_inOrder:
		var value_name = currentData_dict["Column"][i]["FieldName"]
		var itemType = currentData_dict["Column"][i]["DataType"]
		var tableRef = currentData_dict["Column"][i]["TableRef"]
		var required  = convert_string_to_type(currentData_dict["Column"][i]["RequiredValue"])
		var showValue  = convert_string_to_type(currentData_dict["Column"][i]["ShowValue"])
		if required == req and showValue:
			custom_dict[value_name] = {"Value" : current_dict[Item_Name][value_name], "DataType" : itemType, "TableRef" : tableRef, "Order" : i}

	return custom_dict



func hide_all_popups():
	popup_main.visible = false
	popup_deleteConfirm.visible = false
	popup_newField.visible = false
	popup_deleteKey.visible = false
	popup_fileDialog.visible = false
#	$Popups/ListInput.visible = false

func clear_buttons():
	#Removes all item name buttons from table_list
	for i in table_list.get_children():
		table_list.remove_child(i)
		i.queue_free()


func reload_buttons():
	clear_buttons()
	create_table_buttons()

func clear_data():
	$VBox1/HBox1/Center1/Label.visible = false
	input_changed = false
	for i in container_list1.get_children():
		if i.name != "Key":
			i.queue_free()
		else:
			i.inputNode.set_text("")

	for i in container_list2.get_children():
		var current_node = i
		i.queue_free()

	for i in container_list3.get_children():
		var current_node = i
		i.queue_free()

	for i in container_list4.get_children():
		var current_node = i
		i.queue_free()


func enable_all_buttons(value : bool = true):
	#Enables user to interact with all item buttons on table_list
	for i in table_list.get_children():
		i.disabled = !value



func refresh_data(item_name : String):
#	#Pulls specific item data when button is clicked
	Item_Name = item_name #reset the script variable Item_Name
	enable_all_buttons()
	clear_data()
	
	
#	#Sets all data from item_table with values from item button that was pressed

	field_dict1 = get_values_dict(true)
	field_dict3 = get_values_dict()
	item_name_input.set_text(Item_Name) #Sets the key in the first input
	var index = 1
	var index_half = (field_dict1.size() + 1)/2
	for i in field_dict1:
		add_input_node(index,index_half, i, field_dict1, container_list1, container_list2)
		index += 1
	if item_name != "Default":
		table_list.get_node(item_name).disabled = true #Sets current item button to disabled
		table_list.get_node(item_name).grab_focus() #sets focus to current item

	index = 1
	index_half = (field_dict3.size() + 1)/2
	for i in field_dict3:
		add_input_node(index,index_half, i, field_dict3, container_list3, container_list4)
		index += 1
	if item_name != "Default":
		table_list.get_node(item_name).disabled = true #Sets current item button to disabled
		table_list.get_node(item_name).grab_focus() #sets focus to current item




func clear_match(current_node, i):
	var input_type = current_node.type
	var input = current_node.inputNode
	var default_value = current_node.default
	match input_type:
		"Text":
			if i == "Key":
				input.set_text(default_value)

		"Dropdown List":
			current_node.populate_list()

		"Number Counter":
			input.set_text(str(default_value))
			
		"Multiline Text":
			input.set_text(default_value)
		
		"Checkbox":
			input.pressed = default_value
		
		"IconDisplay":
			input.set_text(current_dict["Default"]["IconDescription"])
			var iconPath = current_dict["Default"]["IconPath"]
			current_node.texture_button.set_normal_texture(load(iconPath))

		'SpriteDisplay':
			pass
		"Vector":
			input.set_text(default_value)
		"Dictionary":
			input.set_text(str(default_value))
		
		



func create_table_buttons():
	 #Loop through the item_list dictionary and add a button for each item
	for i in currentData_dict["Row"].size():
		var item_number = str(i + 1) #row_dict key
		if currentData_dict["Row"][item_number]["FieldName"] != "Default":
			var newbtn = btn_itemselect.instance() #Create new instance of item button
			table_list.add_child(newbtn) #Add new item button to table_list
			var label = currentData_dict["Row"][item_number]["FieldName"] #Use the row_dict key (item_number) to set the button label as the item name
			newbtn.set_name(label) #Set the name of the new button as the item name
			newbtn.get_node("Label").set_text(label) #Sets the button label (name that the user sees)

func _on_Save_button_up():
	#Check if values are blank return error if true
	if !has_empty_fields():
		update_values()
		save_all_db_files(current_table_name)
		update_dictionaries()
		input_changed = true
		$VBox1/HBox1/Center1/Label.visible = false
	else:
		print("There was an error. Data has not been updated")

func update_values():
	var value
	var keyNode = null
#Uses input values from Items form to update current_dict 
	for i in container_list1.get_children():
		value = i.labelNode.get_text()
		update_match(i, value)
		if value == "Key":
			keyNode = i
		
	for i in container_list2.get_children():
		value = i.labelNode.get_text()
		update_match(i, value)

	for i in container_list3.get_children():
		value = i.labelNode.get_text()
		update_match(i, value)
	
	for i in container_list4.get_children():
		value = i.labelNode.get_text()
		update_match(i, value)
	
		#NOTE: Does NOT update the database files. That function is located in the save_data method
	if keyNode != null:
		reload_buttons()
		refresh_data(keyNode.inputNode.text)

#func save_data(sv_path, table_dict):
##Save dictionary to .json using sv_path as the file location and table_dict as the data saved to file
#	var save_file = File.new()
#	if save_file.open(sv_path, File.WRITE) != OK:
#		print("Error Could not update file")
#	else:
#		var save_d = table_dict
#		save_file.open(sv_path, File.WRITE)
#		save_d = to_json(save_d)
#		save_file.store_line(save_d)
#		save_file.close()


		

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
		add_key(Item_Name, "TYPE_STRING", true, false, false)

		#update new dict entry with input values from item form
		update_values()
		#Save data to .json files
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
		var t = Timer.new()
		t.set_wait_time(.5)
		add_child(t)
		t.start()
		yield(t, "timeout")
		t.queue_free()
		var max_v_scroll = $VBox1/HBox2/Scroll1.get_v_scrollbar().max_value
		$VBox1/HBox2/Scroll1.set_v_scroll(max_v_scroll)
	else:
		print("ERROR! No changes were made")


func delete_selected_item():
	data_type = "Row"
	Delete_Key(Item_Name)
	save_all_db_files(current_table_name)
	reload_buttons()
	table_list.get_child(0)._on_TextureButton_button_up()

func _on_DeleteSelectedItem_button_up():
	var popup_label = $Popups/popup_delete_confirm/PanelContainer/VBoxContainer/Label
	var popup_label2 = $Popups/popup_delete_confirm/PanelContainer/VBoxContainer/Label2
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


#func list_files_in_directory(sve_path):
#	var array_load_savefiles = []
#	var files = []
#	var dir = Directory.new()
#	dir.open(sve_path)
#	dir.list_dir_begin()
#	while true:
#		var file = dir.get_next()
#		if file == "":
#			break
#		elif !file.ends_with(".import"):
#			files.append(file)
#			array_load_savefiles.append(file)
#	return array_load_savefiles


func _on_FileDialog_file_selected(path):
	var dir = Directory.new()
	var new_file_name = path.get_file()
	var new_file_path = icon_folder + "/" + new_file_name
	var curr_icon_path = current_dict[Item_Name][selected_field_name]

	if is_file_in_folder(icon_folder, new_file_name): #Check if selected folder is Icon folder and has selected file
		current_dict[Item_Name][selected_field_name] = new_file_path
		save_all_db_files(current_table_name)
#		refresh_data(Item_Name)
	else:
#		print("Item selected is NOT in icon folder")
		dir.copy(path, new_file_path)
		if !is_file_in_folder(icon_folder, new_file_name):
			print("File Not Added")
		else:
			print("File Added")
			#trigger the import process for it to load to texture rect
			refresh_editor()
			current_dict[Item_Name][selected_field_name] = new_file_path

			var tr = Timer.new()
			tr.set_one_shot(true)
			add_child(tr)
			tr.set_wait_time(.25)
			tr.start()
			yield(tr, "timeout")
			tr.queue_free()

#			save_all_db_files(current_table_name)
	refresh_data(Item_Name)

func _on_FileDialog_sprite_file_selected(path: String) -> void:
	var dir = Directory.new()
	var new_file_name = path.get_file()
	var new_file_path = icon_folder + "/" + new_file_name
	var curr_icon_path = current_dict[Item_Name][selected_field_name]
	#Get frame values

	var sprite_path = curr_icon_path[0]
	var frameVector : Vector2 = convert_string_to_type(curr_icon_path[1], "TYPE_VECTOR2")



	if is_file_in_folder(icon_folder, new_file_name): #Check if selected folder is Icon folder and has selected file
		current_dict[Item_Name][selected_field_name] = [new_file_path , str(frameVector)]
		save_all_db_files(current_table_name)
#		refresh_data(Item_Name)
	else:
#		print("Item selected is NOT in icon folder")
		dir.copy(path, new_file_path)
		if !is_file_in_folder(icon_folder, new_file_name):
			print("File Not Added")
		else:
			print("File Added")
			#trigger the import process for it to load to texture rect
			refresh_editor()
			current_dict[Item_Name][selected_field_name] = [new_file_path , str(frameVector)]
			var tr = Timer.new()
			tr.set_one_shot(true)
			add_child(tr)
			tr.set_wait_time(.25)
			tr.start()
			yield(tr, "timeout")
			tr.queue_free()

#			save_all_db_files(current_table_name)
	refresh_data(Item_Name)



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
	$Popups/popup_newValue.visible = true


func _on_NewField_Accept_button_up():
	add_newField()
	_on_NewField_Cancel_button_up()


func _on_NewField_Cancel_button_up():
	popup_main.visible = false
	$Popups/popup_newValue.visible = false


func add_newField():
	var fieldName = $Popups/popup_newValue/PanelContainer/VBox1/HBox1/VBox1/LineEdit3.get_text()
	var datatype = $Popups/popup_newValue/PanelContainer/VBox1/HBox1/VBox2/ItemType_Selection.selectedItemName
	var showField = $Popups/popup_newValue/PanelContainer/VBox1/HBox1/VBox3/LineEdit3.is_pressed()
	var required = $Popups/popup_newValue/PanelContainer/VBox1/HBox1/VBox4/LineEdit3.is_pressed()
	var tableName = $Popups/popup_newValue/PanelContainer/VBox1/HBox1/Table_Selection.selectedItemName
	#Get input values and send them to the editor functions add new value script
	#NEED TO ADD ERROR CHECKING
	add_field(fieldName, datatype, showField, required, tableName)
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
	$VBox1/HBox1/Center1/Label.visible = true
	input_changed = true
