extends Control
tool


const UDSENGINE = preload("res://addons/Database_Manager/Scenes and Scripts/Editor_Functions.gd")

onready var btn_itemselect = preload("res://addons/Database_Manager/Scenes and Scripts/Inventory/Btn_ItemSelect.tscn")

onready var input_singleLine = preload("res://addons/Database_Manager/Scenes and Scripts/Inventory/Input_Text.tscn")
onready var input_multiLine = preload("res://addons/Database_Manager/Scenes and Scripts/Inventory/Input_Text_Multiline.tscn")
onready var input_checkBox = preload("res://addons/Database_Manager/Scenes and Scripts/Inventory/Checkbox_Template.tscn")
onready var input_intNumberCounter = preload("res://addons/Database_Manager/Scenes and Scripts/Inventory/Number_Counter.tscn")
onready var input_floatNumberCounter = preload("res://addons/Database_Manager/Scenes and Scripts/Inventory/Number_Counter_Float.tscn")
onready var input_dropDownMenu = preload("res://addons/Database_Manager/Scenes and Scripts/Inventory/DropDown_Template.tscn")
onready var input_iconDisplay = preload("res://addons/Database_Manager/Scenes and Scripts/Inventory/Icon_Template.tscn")

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
var udsEngine

var field_dict1 = {}
var field_dict2 = {}
var field_dict3 = {}
var Item_Name = ""
var tableName = ""
var table_ref = ""
var selected_field_name = ""
var first_load = true


func _ready():
	if first_load:
		udsEngine = UDSENGINE.new()
		udsEngine.current_table_name = tableName
		first_load = false
		set_ref_table()


func set_ref_table():
	var tbl_ref_dict = udsEngine.import_data(udsEngine.table_save_path + "Table Data" + udsEngine.file_format)
	table_ref = tbl_ref_dict[tableName]["Reference Dictionary"]
	udsEngine.current_table_ref = table_ref
	return table_ref

func _on_visibility_changed():
	if visible:

		udsEngine = UDSENGINE.new()
		udsEngine.current_table_name = tableName
#		_ready()
		hide_all_popups()
		udsEngine.update_dictionaries()
		reload_buttons()
		
		table_list.get_child(0)._on_TextureButton_button_up()

	else:
		udsEngine.queue_free()
		hide_all_popups()
		clear_data()
		clear_buttons()

func get_values_dict(var req = false):
	var custom_dict = {}
	var currentDict_inOrder = {}
	for i in udsEngine.currentData_dict["Column"].size():
		i = str(i + 1)
		currentDict_inOrder[i] = udsEngine.currentData_dict["Column"][i]

	for i in currentDict_inOrder:
		var value_name = udsEngine.currentData_dict["Column"][i]["FieldName"]
		var itemType = udsEngine.currentData_dict["Column"][i]["DataType"]
		var tableRef = udsEngine.currentData_dict["Column"][i]["TableRef"]
		var required  = udsEngine.convert_string_to_type(udsEngine.currentData_dict["Column"][i]["RequiredValue"])
		var showValue  = udsEngine.convert_string_to_type(udsEngine.currentData_dict["Column"][i]["ShowValue"])
		if required == req and showValue:
			custom_dict[value_name] = {"Value" : udsEngine.current_dict[Item_Name][value_name], "DataType" : itemType, "TableRef" : tableRef, "Order" : i}

	return custom_dict



func hide_all_popups():
	popup_main.visible = false
	popup_deleteConfirm.visible = false


func clear_buttons():
	#Removes all item name buttons from table_list
	for i in table_list.get_children():
		table_list.remove_child(i)
		i.queue_free()


func reload_buttons():
	clear_buttons()
	create_table_buttons()

func clear_data():

	for i in container_list1.get_children():
		if i.name != "Key":
#		var current_node = i
			i.queue_free()
		else:
			i.inputNode.set_text("")


	for i in container_list2.get_children():
		var current_node = i
		i.queue_free()

#	for i in field_dict2:
#		var current_node = container_list2.get_node(str(i))
#		clear_match(current_node, i)

	for i in container_list3.get_children():
		var current_node = i
		i.queue_free()
		
	for i in container_list4.get_children():
		var current_node = i
		i.queue_free()


func enable_all_buttons(value : bool = true):
	#Enanables user to interact with all item buttons on table_list
	for i in table_list.get_children():
		i.disabled = !value


func add_input_field(par: Node, nodeName):
	var new_node = nodeName.instance()
	par.add_child(new_node)
	return new_node


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
		var parent_container = container_list1
		if index_half < index:
			parent_container = container_list2
		var node_value =  udsEngine.convert_string_to_type(field_dict1[i]["Value"], field_dict1[i]["DataType"])
		var node_type = field_dict1[i]["DataType"]


		match node_type: #Match variant type and then determine which input field to use (check box, long text, short text, number count etc)
			"TYPE_BOOL": #Bool
				var new_field : Node = add_input_field(parent_container, input_checkBox)
				new_field.set_name(i)
				new_field.labelNode.set_text(i)
				new_field.inputNode.set_pressed(node_value)
				new_field.table_name = udsEngine.current_table_name
				new_field.table_ref = table_ref
#
			"TYPE_INT": #INT
				
				var new_field : Node = add_input_field(parent_container, input_intNumberCounter)
				new_field.set_name(i)
				new_field.labelNode.set_text(i)
				new_field.inputNode.set_text(str(node_value))
				new_field.table_name = udsEngine.current_table_name
				new_field.table_ref = table_ref
			"TYPE_REAL": #Float
				var new_field : Node = add_input_field(parent_container, input_floatNumberCounter)
				new_field.set_name(i)
				new_field.labelNode.set_text(i)
				new_field.inputNode.set_text(str(node_value))
				new_field.table_name = udsEngine.current_table_name
				new_field.table_ref = table_ref
			"TYPE_STRING": #String
				if node_value.length() <= 45:
					var new_field : Node = add_input_field(parent_container, input_singleLine)
					new_field.set_name(i)
					new_field.labelNode.set_text(i)
					new_field.inputNode.set_text(node_value)
					new_field.table_name = udsEngine.current_table_name
					new_field.table_ref = table_ref
				else:
					var new_field : Node = add_input_field(parent_container, input_multiLine)
					new_field.set_name(i)
					new_field.labelNode.set_text(i)
					new_field.inputNode.set_text(node_value)
					new_field.table_name = udsEngine.current_table_name
					new_field.table_ref = table_ref
			"TYPE_DROPDOWN":
					var new_field : Node = add_input_field(parent_container, input_dropDownMenu)
					new_field.set_name(i)
					new_field.label_text = i
					new_field.selection_table_name = field_dict1[i]["TableRef"]
					new_field.labelNode.set_text(i)
					new_field.populate_list()
					var type_id = new_field.get_id(node_value)
					new_field.inputNode.select(type_id)
					new_field.table_name = udsEngine.current_table_name
					new_field.table_ref = table_ref

			"TYPE_ICON":
				var new_field : Node = add_input_field(parent_container, input_iconDisplay)
				var texture_path = node_value
				new_field.set_name(i)
				new_field.labelNode.set_text(i)
#				new_field.inputNode.set_text(str(node_value))
				if texture_path == "empty":
					texture_path = "res://addons/Database_Manager/Data/Icons/Default.png"
				new_field.inputNode.set_normal_texture(load(str(texture_path)))
				new_field.table_name = udsEngine.current_table_name
				new_field.table_ref = table_ref
		
		index += 1
	if item_name != "Default":
		table_list.get_node(item_name).disabled = true #Sets current item button to disabled
		table_list.get_node(item_name).grab_focus() #sets focus to current item




	index = 1
	index_half = (field_dict3.size() + 1)/2
	for i in field_dict3:
		var parent_container = container_list3
		if index_half < index:
			parent_container = container_list4
		var node_value =  udsEngine.convert_string_to_type(field_dict3[i]["Value"], field_dict3[i]["DataType"])
		var node_type = field_dict3[i]["DataType"]


		match node_type: #Match variant type and then determine which input field to use (check box, long text, short text, number count etc)
			"TYPE_BOOL": #Bool
				var new_field : Node = add_input_field(parent_container, input_checkBox)
				new_field.set_name(i)
				new_field.labelNode.set_text(i)
				new_field.inputNode.set_pressed(node_value)
				new_field.table_name = udsEngine.current_table_name
				new_field.table_ref = table_ref
#
			"TYPE_INT": #INT
				
				var new_field : Node = add_input_field(parent_container, input_intNumberCounter)
				new_field.set_name(i)
				new_field.labelNode.set_text(i)
				new_field.inputNode.set_text(str(node_value))
				new_field.table_name = udsEngine.current_table_name
				new_field.table_ref = table_ref
			"TYPE_REAL": #Float
				var new_field : Node = add_input_field(parent_container, input_floatNumberCounter)
				new_field.set_name(i)
				new_field.labelNode.set_text(i)
				new_field.inputNode.set_text(str(node_value))
				new_field.table_name = udsEngine.current_table_name
				new_field.table_ref = table_ref
			"TYPE_STRING": #String
				if node_value.length() <= 45:
					var new_field : Node = add_input_field(parent_container, input_singleLine)
					new_field.set_name(i)
					new_field.labelNode.set_text(i)
					new_field.inputNode.set_text(node_value)
					new_field.table_name = udsEngine.current_table_name
					new_field.table_ref = table_ref
				else:
					var new_field : Node = add_input_field(parent_container, input_multiLine)
					new_field.set_name(i)
					new_field.labelNode.set_text(i)
					new_field.inputNode.set_text(node_value)
					new_field.table_name = udsEngine.current_table_name
					new_field.table_ref = table_ref
			"TYPE_DROPDOWN":
					var new_field : Node = add_input_field(parent_container, input_dropDownMenu)
					new_field.set_name(i)
					new_field.label_text = i
					new_field.selection_table_name = field_dict3[i]["TableRef"]
					new_field.labelNode.set_text(i)
					new_field.populate_list()
					var type_id = new_field.get_id(node_value)
					new_field.inputNode.select(type_id)
					new_field.table_name = udsEngine.current_table_name
					new_field.table_ref = table_ref
			
			"TYPE_ICON":
				var new_field : Node = add_input_field(parent_container, input_iconDisplay)
				var texture_path = node_value
				new_field.set_name(i)
				new_field.labelNode.set_text(i)
#				new_field.inputNode.set_text(str(node_value))
				if texture_path == "empty":
					texture_path = "res://addons/Database_Manager/Data/Icons/Default.png"
				new_field.texture_button.set_normal_texture(load(str(texture_path)))
				new_field.table_name = udsEngine.current_table_name
				new_field.table_ref = table_ref
		
		
		
		index += 1
	if item_name != "Default":
		table_list.get_node(item_name).disabled = true #Sets current item button to disabled
		table_list.get_node(item_name).grab_focus() #sets focus to current item


func input_match(current_node, i, dict):
	var input_type = current_node.type
	var input = dict[i]
	current_node.table_name = udsEngine.current_table_name
	current_node.table_ref = table_ref
	match input_type:
		"Text":
			if i == "Key":
				input.set_text(Item_Name)
			else:
				input.set_text(udsEngine.current_dict[Item_Name][i])
		"Dropdown List":
			current_node.populate_list()
			var type_id = current_node.get_id(udsEngine.current_dict[Item_Name][i])
			input.select(type_id)

		"Number Counter":
			input.set_text(udsEngine.current_dict[Item_Name][i])
			
		"Multiline Text":
			input.set_text(udsEngine.current_dict[Item_Name][i])
		
		"Checkbox":
			var ckbx_value = udsEngine.convert_string_to_type(udsEngine.current_dict[Item_Name][i])
			input.pressed = ckbx_value
		
		"IconDisplay":
			input.set_text(udsEngine.current_dict[Item_Name]["IconDescription"])
			var iconPath = udsEngine.current_dict[Item_Name]["IconPath"]
			if udsEngine.is_file_in_folder(udsEngine.icon_folder, iconPath):
				current_node.texture_button.set_normal_texture(load(iconPath))
			else:
				iconPath = udsEngine.current_dict["Default"]["IconPath"]
				current_node.texture_button.set_normal_texture(load(iconPath))


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
			input.set_text(udsEngine.current_dict["Default"]["IconDescription"])
			var iconPath = udsEngine.current_dict["Default"]["IconPath"]
			current_node.texture_button.set_normal_texture(load(iconPath))


func update_match(current_node, i):
	var input_type = current_node.type
	var input = current_node.inputNode

	match input_type:
		"Text":
			if i == "Key":
				update_item_name(Item_Name, input.text)
			else:
				udsEngine.current_dict[Item_Name][i] = input.text
		"Dropdown List":
#			print(current_node.selectedItemName)
			udsEngine.current_dict[Item_Name][i] = current_node.selectedItemName
	
		"Number Counter":
			udsEngine.current_dict[Item_Name][i] = input.text

		"Multiline Text":
			udsEngine.current_dict[Item_Name][i] = input.text
		
		"Checkbox":
			udsEngine.current_dict[Item_Name][i] = input.pressed
		
		"IconDisplay":
			udsEngine.current_dict[Item_Name]["IconDescription"] = input.get_normal_texture().get_path()



func create_table_buttons():
	 #Loop through the item_list dictionary and add a button for each item
	for i in udsEngine.currentData_dict["Row"].size():
		var item_number = str(i + 1) #row_dict key
		if udsEngine.currentData_dict["Row"][item_number]["FieldName"] != "Default":
			var newbtn = btn_itemselect.instance() #Create new instance of item button
			table_list.add_child(newbtn) #Add new item button to table_list
			var label = udsEngine.currentData_dict["Row"][item_number]["FieldName"] #Use the row_dict key (item_number) to set the button label as the item name
			newbtn.set_name(label) #Set the name of the new button as the item name
			newbtn.get_node("Label").set_text(label) #Sets the button label (name that the user sees)


#func import_data(table_loc):
#	#Opens .json file located at table_loc, reads it, returns the data as a dictionary
#	var curr_tbl_data : Dictionary = {}
#	var currdata_file = File.new()
#	if currdata_file.open(table_loc, File.READ) != OK:
#		print(table_loc)
#		print("Error Could not open file")
#	else:
#		currdata_file.open(table_loc, File.READ)
#		var currdata_json = JSON.parse(currdata_file.get_as_text())
#		curr_tbl_data = currdata_json.result
#		currdata_file.close()
#		return curr_tbl_data


func _on_Save_button_up():
	#Check if values are blank return error if true
	if !has_empty_fields():
		update_values()
		udsEngine.save_all_db_files(udsEngine.current_table_name)
		udsEngine.update_dictionaries()
	else:
		print("There was an error. Data has not been updated")

func update_values():
#Uses input values from Items form to update current_dict 
#	for i in field_dict1:
#		var current_node = container_list1.get_node(str(i))
#		update_match(current_node, i)
#
#	for i in field_dict2:
#		var current_node = container_list2.get_node(str(i))
#		update_match(current_node, i)
	for i in container_list1.get_children():
		var value = i.labelNode.get_text()
		update_match(i, value)
		
	for i in container_list2.get_children():
		var value = i.labelNode.get_text()
		update_match(i, value)

	for i in container_list3.get_children():
		var value = i.labelNode.get_text()
		update_match(i, value)
	
	for i in container_list4.get_children():
		var value = i.labelNode.get_text()
		update_match(i, value)
	
		#NOTE: Does NOT update the database files. That function is located in the save_data method


func save_data(sv_path, table_dict):
#Save dictionary to .json using sv_path as the file location and table_dict as the data saved to file
	var save_file = File.new()
	if save_file.open(sv_path, File.WRITE) != OK:
		print("Error Could not update file")
	else:
		var save_d = table_dict
		save_file.open(sv_path, File.WRITE)
		save_d = to_json(save_d)
		save_file.store_line(save_d)
		save_file.close()

func update_item_name(old_name : String, new_name : String = ""):
	if old_name != new_name: #if changes are made to item name
		if !does_key_exist(new_name):
			var item_name_dict = udsEngine.current_data_dict["Row"]
			for i in item_name_dict: #loop through item_row table until it finds the key number for the item
				if item_name_dict[i] == old_name:
					udsEngine.current_data_dict["Row"][i] = new_name #Replace old value with new value
					break
			
			var old_key_entry : Dictionary = udsEngine.current_dict[Item_Name].duplicate(true) #Create copy of item values
			udsEngine.current_dict.erase(Item_Name) #Erase old item entry
			udsEngine.current_dict[new_name] = old_key_entry #add new item entry
			Item_Name = new_name #Update script variable with correct item name
		else:
			print("Duplicate key exists in table DATA WAS NOT UPDATED")

func add_entry_row(entry_value):
	var item_name_dict = udsEngine.current_data_dict["Row"]
	var item_name_dict_size = item_name_dict.size()
	udsEngine.current_data_dict["Row"][str(item_name_dict_size)] = entry_value

func add_table_key(key):
	#duplicate "Default" value
	var new_entry = udsEngine.current_dict["Default"].duplicate(true)
	#Add value to item dict
	udsEngine.current_dict[key] = new_entry
	

func does_key_exist(key):
	var value = false
	#Iterate through table values and compare to key if values are the same, return error
	for i in udsEngine.current_dict:
		if i == key:
			value = true
			print("Item already exists!")
			break
	return value

func does_key_contain_invalid_characters(key : String):
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
	if !does_key_exist(Item_Name) and !does_key_contain_invalid_characters(Item_Name) and !has_empty_fields():

		#save new item to current_dict
		udsEngine.add_key(Item_Name, "TYPE_STRING", true)

		#update new dict entry with input values from item form
		update_values()
		#Save data to .json files
		udsEngine.save_all_db_files(udsEngine.current_table_name)
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
	udsEngine.data_type = "Row"
	udsEngine.Delete_Key(Item_Name)
	udsEngine.save_all_db_files(udsEngine.current_table_name)
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


func list_files_in_directory(sve_path):
	var array_load_savefiles = []
	var files = []
	var dir = Directory.new()
	dir.open(sve_path)
	dir.list_dir_begin()
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif !file.ends_with(".import"):
			files.append(file)
			array_load_savefiles.append(file)
	return array_load_savefiles


func _on_FileDialog_file_selected(path):
	var dir = Directory.new()
	var new_file_name = path.get_file()
	var new_file_path = udsEngine.icon_folder + "/" + new_file_name
	var curr_icon_path = udsEngine.current_dict[Item_Name][selected_field_name]

	if udsEngine.is_file_in_folder(udsEngine.icon_folder, new_file_name): #Check if selected folder is Icon folder and has selected file
		udsEngine.current_dict[Item_Name][selected_field_name] = new_file_path
		udsEngine.save_all_db_files(udsEngine.current_table_name)
		refresh_data(Item_Name)
	else:
#		print("Item selected is NOT in icon folder")
		dir.copy(path, new_file_path)
		if !udsEngine.is_file_in_folder(udsEngine.icon_folder, new_file_name):
			print("File Not Added")
		else:
			print("File Added")
			#THIS WORKS BUT YOU MUST trigger the import process for it to load to texture rect.  STILL TRYING TO IGURE OUT HOW TO DO THAT IN CODE
			
			udsEngine.refresh_editor()
			udsEngine.current_dict[Item_Name][selected_field_name] = new_file_path

			var tr = Timer.new()
			tr.set_one_shot(true)
			add_child(tr)
			tr.set_wait_time(.25)
			tr.start()
			yield(tr, "timeout")
			tr.queue_free()

#			udsEngine.save_all_db_files(udsEngine.current_table_name)
			refresh_data(Item_Name)



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
	udsEngine.add_field(fieldName, datatype, showField, required, tableName)
	refresh_data(Item_Name)
	


func display_options():
	var values_in_order_dict = {}
	var dlg_keySelect = $Popups/popup_deleteKey/PanelContainer/VBoxContainer/Itemlist
	dlg_keySelect.clear()
	udsEngine.data_type = "Column"
	for n in udsEngine.currentData_dict[udsEngine.data_type].size(): #Arrange row dict values by order number
		var t = n + 1
		values_in_order_dict[n + 1] =  udsEngine.currentData_dict[udsEngine.data_type][str(t)]["FieldName"]

	for n in values_in_order_dict: #Add values to options menu
		var t = values_in_order_dict[n]
		dlg_keySelect.add_item (t,null,true )

	popup_main.visible = true
	popup_deleteKey.visible = true



var delete_field_name = ""
#var delete_field_index = 0
func _on_Itemlist_item_selected(index):
	delete_field_name = udsEngine.currentData_dict[udsEngine.data_type][str(index + 1)]["FieldName"]
#	delete_field_index = str(index + 1)


func _on_DeleteField_Accept_button_up():
	udsEngine.Delete_Key(delete_field_name)
	udsEngine.save_all_db_files(udsEngine.current_table_name)
	refresh_data(Item_Name)
	_on_DeleteField_Cancel_button_up()


func _on_DeleteField_Cancel_button_up():

	popup_main.visible = false
	popup_deleteKey.visible = false
