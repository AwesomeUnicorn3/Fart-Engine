extends Control
tool


const EDITSCRIPT = preload("res://addons/Database_Manager/Scenes and Scripts/Editor_Functions.gd")

onready var btn_itemselect = preload("res://addons/Database_Manager/Scenes and Scripts/Inventory/Btn_ItemSelect.tscn")

onready var input_singleLine = preload("res://addons/Database_Manager/Scenes and Scripts/Inventory/Input_Text.tscn")
onready var input_multiLine = preload("res://addons/Database_Manager/Scenes and Scripts/Inventory/Input_Text_Multiline.tscn")
onready var input_checkBox = preload("res://addons/Database_Manager/Scenes and Scripts/Inventory/Checkbox_Template.tscn")
onready var input_intNumberCounter = preload("res://addons/Database_Manager/Scenes and Scripts/Inventory/Number_Counter.tscn")
onready var input_floatNumberCounter = preload("res://addons/Database_Manager/Scenes and Scripts/Inventory/Number_Counter_Float.tscn")




onready var btn_saveChanges = $VBox1/HBox1/SaveChanges
onready var btn_saveNewItem = $VBox1/HBox1/SaveNewItem
onready var btn_addNewItem = $VBox1/HBox1/AddNewItem
onready var btn_cancel = $VBox1/HBox1/Cancel
onready var btn_delete = $VBox1/HBox1/DeleteSelectedItem
onready var table_list = $VBox1/HBox2/Scroll1/Table_Buttons
onready var container_list1 = $VBox1/HBox2/Panel1/VBoxContainer2/HBox1/VBox1
onready var container_list2 = $VBox1/HBox2/Panel1/VBoxContainer2/HBox1/VBox2
onready var container_list3 = $VBox1/HBox2/Panel1/VBoxContainer2/Scroll1/HBox1/VBox1
onready var container_list4 = $VBox1/HBox2/Panel1/VBoxContainer2/Scroll1/HBox1/VBox2
onready var popup_main = $Popups
onready var popup_deleteConfirm = $Popups/popup_delete_confirm


var icon_folder = "res://addons/Database_Manager/Data/Icons"
var save_path = "res://addons/Database_Manager/Data/"
var table_path = "res://addons/Database_Manager/Data/Items.json"
var row_path = "res://addons/Database_Manager/Data/Items_Row"
var column_path = "res://addons/Database_Manager/Data/Items_Column"

var row_dict = {}
var column_dict = {}
var item_dict = {}
var field_dict1 = {}
var field_dict2 = {}
var field_dict3 = {}
var Item_Name = ""


func _ready():
	var input_data
	var label_name
	var field_name
	for i in container_list1.get_children():
		if i.get("labelNode") != null and i.get("inputNode") != null:
			field_name = i.name
			label_name = i.itemName
			input_data = i.inputNode
			field_dict1[label_name] = input_data
		else:
			print(i.name, " Does not have labelNode")
	
	for i in container_list2.get_children():
		if i.get("labelNode") != null and i.get("inputNode") != null:
			field_name = i.name
			label_name = i.itemName
			input_data = i.inputNode
			field_dict2[label_name] = input_data
		else:
			print(i.name, " Does not have labelNode")
	


func _on_Inventory_Manager_visibility_changed():
	if visible:
		hide_all_popups()
		update_dictionaries()
		reload_buttons()

		table_list.get_child(0)._on_TextureButton_button_up()
	else:
		hide_all_popups()
		clear_data()
		clear_buttons()



func custom_values_dict():
	var custom_dict = {}

	for i in column_dict["Column"]:
		var value_name = column_dict["Column"][i]
		custom_dict[value_name] = i

	for i in field_dict1:
		if custom_dict.has(i):
			custom_dict.erase(i)
	for i in field_dict2:
		if custom_dict.has(i):
			custom_dict.erase(i)

	
	for i in custom_dict:
		var value = item_dict[Item_Name][i]
		value = convert_string_to_type(value)
		custom_dict[i] = value

#	print(custom_dict)
	return custom_dict
	



func hide_all_popups():
	popup_main.visible = false
	popup_deleteConfirm.visible = false

func update_dictionaries():
	#replaces dictionary data with data from saved files
	row_dict = import_data(row_path) 
	column_dict = import_data(column_path)
	item_dict = import_data(table_path)


func clear_buttons():
	#Removes all item name buttons from table_list
	for i in table_list.get_children():
		table_list.remove_child(i)
		i.queue_free()


func reload_buttons():
	clear_buttons()
	create_table_buttons()

func clear_data():
	for i in field_dict1:
		var current_node = container_list1.get_node(str(i))
		clear_match(current_node, i)

	for i in field_dict2:
		var current_node = container_list2.get_node(str(i))
		clear_match(current_node, i)

	for i in container_list3.get_children():
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
	for i in field_dict1:
		var current_node = container_list1.get_node(str(i))
		input_match(current_node, i, field_dict1)

	for i in field_dict2:
		var current_node = container_list2.get_node(str(i))
		input_match(current_node, i, field_dict2)

	field_dict3 = custom_values_dict()
	for i in field_dict3:
		var node_type = typeof(field_dict3[i])
		var node_value = field_dict3[i]
		match node_type: #Match variant type and then determine which input field to use (check box, long text, short text, number count etc)
			1: #Bool
				var new_field : Node = add_input_field(container_list3, input_checkBox)
				new_field.set_name(i)
				new_field.labelNode.set_text(i)
				new_field.inputNode.set_pressed(field_dict3[i])

			2: #INT
				var new_field : Node = add_input_field(container_list3, input_intNumberCounter)
				new_field.set_name(i)
				new_field.labelNode.set_text(i)
				new_field.inputNode.set_text(str(field_dict3[i]))
			3: #Float
				var new_field : Node = add_input_field(container_list3, input_floatNumberCounter)
				new_field.set_name(i)
				new_field.labelNode.set_text(i)
				new_field.inputNode.set_text(str(field_dict3[i]))
			4: #String
				if node_value.length() <= 45:
					var new_field : Node = add_input_field(container_list3, input_singleLine)
					new_field.set_name(i)
					new_field.labelNode.set_text(i)
					new_field.inputNode.set_text(field_dict3[i])
				else:
					var new_field : Node = add_input_field(container_list3, input_multiLine)
					new_field.set_name(i)
					new_field.labelNode.set_text(i)
					new_field.inputNode.set_text(field_dict3[i])

	if item_name != "Default":
		table_list.get_node(item_name).disabled = true #Sets current item button to disabled
		table_list.get_node(item_name).grab_focus() #sets focus to current item



func input_match(current_node, i, dict):
	var input_type = current_node.type
	var input = dict[i]
	match input_type:
		"Text":
			if i == "Key":
				input.set_text(Item_Name)
			else:
				input.set_text(item_dict[Item_Name][i])
		"Dropdown":
			current_node.populate_list()
			var type_id = current_node.get_item_id(item_dict[Item_Name]["Type"])
			input.select(type_id)
		"Number Counter":
			input.set_text(item_dict[Item_Name][i])
			
		"Multiline Text":
			input.set_text(item_dict[Item_Name][i])
		
		"Checkbox":
			var ckbx_value = convert_string_to_type(item_dict[Item_Name][i])
			input.pressed = ckbx_value
		
		"Icon":
			input.set_text(item_dict[Item_Name]["IconDescription"])
			var iconPath = item_dict[Item_Name]["IconPath"]
			if is_file_in_folder(icon_folder, iconPath):
				current_node.texture_button.set_normal_texture(load(iconPath))
			else:
				iconPath = item_dict["Default"]["IconPath"]
				current_node.texture_button.set_normal_texture(load(iconPath))

func clear_match(current_node, i):
	var input_type = current_node.type
	var input = current_node.inputNode
	var default_value = current_node.default
	match input_type:
		"Text":
			if i == "Key":
				input.set_text(default_value)


		"Dropdown":
			current_node.populate_list()
			var type_id = current_node.get_item_id(str(default_value))
			input.select(type_id)
		"Number Counter":
			input.set_text(str(default_value))
			
		"Multiline Text":
			input.set_text(default_value)
		
		"Checkbox":
			input.pressed = default_value
		
		"Icon":
			input.set_text(item_dict["Default"]["IconDescription"])
			var iconPath = item_dict["Default"]["IconPath"]
			current_node.texture_button.set_normal_texture(load(iconPath))

func update_match(current_node, i):
	var input_type = current_node.type
	var input = current_node.inputNode
	match input_type:
		"Text":
			if i == "Key":
				update_item_name(Item_Name, input.text)
			else:
				item_dict[Item_Name][i] = input.text
		"Dropdown":
			item_dict[Item_Name][i] = input.text

		"Number Counter":
			item_dict[Item_Name][i] = input.text
			
		"Multiline Text":
			item_dict[Item_Name][i] = input.text
		
		"Checkbox":
			item_dict[Item_Name][i] = input.pressed
		
		"Icon":
			item_dict[Item_Name]["IconDescription"] = input.text



func create_table_buttons():
	 #Loop through the item_list dictionary and add a button for each item
	for i in row_dict["Row"].size():
		var item_number = str(i + 1) #row_dict key
		if row_dict["Row"][item_number] != "Default":
			var newbtn = btn_itemselect.instance() #Create new instance of item button
			table_list.add_child(newbtn) #Add new item button to table_list
			var label = row_dict["Row"][item_number] #Use the row_dict key (item_number) to set the button label as the item name
			newbtn.set_name(label) #Set the name of the new button as the item name
			newbtn.get_node("Label").set_text(label) #Sets the button label (name that the user sees)



func import_data(table_loc):
	#Opens .json file located at table_loc, reads it, returns the data as a dictionary
	var curr_tbl_data : Dictionary = {}
	var currdata_file = File.new()
	if currdata_file.open(table_loc, File.READ) != OK:
		print(table_loc)
		print("Error Could not open file")
	else:
		currdata_file.open(table_loc, File.READ)
		var currdata_json = JSON.parse(currdata_file.get_as_text())
		curr_tbl_data = currdata_json.result
		currdata_file.close()
		return curr_tbl_data


func _on_Save_button_up():
	#Check if values are blank return error if true
	if !has_empty_fields():
		update_values()
		save_data(row_path, row_dict)
		save_data(table_path, item_dict)
		update_dictionaries()
		reload_buttons()
		refresh_data(Item_Name)
	else:
		print("There was an error. Data has not been updated")

func update_values():
#Uses input values from Items form to update item_dict 
	for i in field_dict1:
		var current_node = container_list1.get_node(str(i))
		update_match(current_node, i)

	for i in field_dict2:
		var current_node = container_list2.get_node(str(i))
		update_match(current_node, i)
	
	for i in container_list3.get_children():
		var value = i.labelNode.get_text()
		update_match(i, value)
	
		#NOTE: Does NOT update the database files. That function is located in the save_data method
	#insert code here to only run if values have changed (Not currently sure the best way to indicate changed values)
	
	##Would like to improve this area with less hard code data (Not currently sure the best way to do this)
#	update_item_name(Item_Name, item_name_text.text)
#	for i in field_dict:
#		if i == "Key":
#			pass
#		else:
#			item_dict[Item_Name][i] = i.inputNode.text
#	item_dict[Item_Name]["Type"] = item_type_text.text
#	item_dict[Item_Name]["Description"] = item_description_text.text
#	item_dict[Item_Name]["Cost"] = item_cost_text.text
#	item_dict[Item_Name]["Sell Value"] = item_sellprice_text.text
#	item_dict[Item_Name]["IconDescription"] = icon_description.text
#	item_dict[Item_Name]["CanSell"] = item_cansell_chkbx.pressed
	print("Value Update Complete")

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
			var item_name_dict = row_dict["Row"]
			for i in item_name_dict: #loop through item_row table until it finds the key number for the item
				if item_name_dict[i] == old_name:
					row_dict["Row"][i] = new_name #Replace old value with new value
					break
			
			var old_key_entry : Dictionary = item_dict[Item_Name].duplicate(true) #Create copy of item values
			item_dict.erase(Item_Name) #Erase old item entry
			item_dict[new_name] = old_key_entry #add new item entry
			Item_Name = new_name #Update script variable with correct item name
		else:
			print("Duplicate key exists in table DATA WAS NOT UPDATED")

func add_entry_row(entry_value):
	var item_name_dict = row_dict["Row"]
	var item_name_dict_size = item_name_dict.size()
	row_dict["Row"][str(item_name_dict_size)] = entry_value

func add_table_key(key):
	#duplicate "Default" value
	var new_entry = item_dict["Default"].duplicate(true)
	#Add value to item dict
	item_dict[key] = new_entry
	

func does_key_exist(key):
	var value = false
	#Iterate through table values and compare to key if values are the same, return error
	for i in item_dict:
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
#	field_dict = [item_name_text.text, item_description_text.text]
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
	#THIS IS WHERE ERROR CHECKING NEEDS TO CONVERGE AND NOT RUN IF THERE IS AN ERROR
	if !does_key_exist(Item_Name) and !does_key_contain_invalid_characters(Item_Name) and !has_empty_fields():
	#NEED TO ADD ERROR NOTICE IF NAME IS DEFAULT
#	if item_name_text.text != "Default":
#		Item_Name = item_name_text.text
		#save new item to item_dict
		add_table_key(Item_Name)
		#Update row file
		add_entry_row(Item_Name)
		#update new dict entry with input values from item form
		update_values()
		#Save data to .json files
		save_data(row_path, row_dict)
		save_data(table_path, item_dict)
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
	item_dict.erase(Item_Name) #Remove entry from item dict
	#loop through row_dict to find item
	for i in row_dict["Row"]:
		if row_dict["Row"][i] == Item_Name:
			row_dict["Row"].erase(i) #Erase entry
	#Loop through number 0 to row_dict size

	var row_size = row_dict["Row"].size()
	for j in range(0, row_size):
		j += 1
		if !row_dict["Row"].has(str(j)): #If the row_dict does not have j key
			var next_entry_value = row_dict["Row"][str(j + 1)] #Get value of next entry #If ever more values are added to row table, .duplicate(true) needs to be added to this line
#			row_dict["Row"].erase(str(j))
			row_dict["Row"][str(j)] = next_entry_value #create new entry with current index and next entry
			var next_entry = str(j + 1)
			row_dict["Row"].erase(next_entry) #Delete next entry

	#row_dict["Row"].erase(str(row_dict["Row"].size())) #Delete last row because it should be a duplicate by this point
	save_data(row_path, row_dict)
	save_data(table_path, item_dict)
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

func is_file_in_folder(path : String, file_name : String):
	var value = false
	var dir = Directory.new()
	dir.open(path)
#	var dir_files = list_files_in_directory(dir)
	if dir.file_exists(file_name):
		value = true
		print(file_name, " Exists!!!")
	else:
		print(file_name, " Does NOT Exist :(")
	
	
	return value
		




func _on_FileDialog_file_selected(path):
	var dir = Directory.new()
	var new_file_name = path.get_file()
	var new_file_path = icon_folder + "/" + new_file_name
	var curr_icon_path = item_dict[Item_Name]["IconPath"]

	if is_file_in_folder(icon_folder, new_file_name): #Check if selected folder is Icon folder and has selected file
		item_dict[Item_Name]["IconPath"] = new_file_path
		save_data(table_path, item_dict)
		refresh_data(Item_Name)
	else:
		print("Item selected is NOT in icon folder")
		dir.copy(path, new_file_path)
		if !is_file_in_folder(icon_folder, new_file_name):
			print("File Not Added")
		else:
			print("File Added")
			#THIS WORKS BUT YOU MUST trigger the import process for it to load to texture rect.  STILL TRYING TO IGURE OUT HOW TO DO THAT IN CODE
			
			var es = EDITSCRIPT.new()
			es.refresh_data()
			item_dict[Item_Name]["IconPath"] = new_file_path

			var tr = Timer.new()
			tr.set_one_shot(true)
			add_child(tr)
			tr.set_wait_time(.25)
			tr.start()
			yield(tr, "timeout")
			tr.queue_free()

			save_data(table_path, item_dict)
			refresh_data(Item_Name)


func remove_special_char(text : String):
	var array = [" "]
	var result = text
	for i in array:
		result = result.replace(i, "")
	return result

func to_bool(value):
	var found_match = false
	#changes datatype from string value to bool (Not case specific, only works with yes,no,true, and false)
	var original_value = value
	value = str(value)
	var value_lower = value.to_lower()
	match value_lower:
		"yes":
			found_match = true
			value = "true"
		"no":
			found_match = true
			value = "false"
		"true":
			found_match = true
			value = "true"
		"false":
			found_match = true
			value = "false"
	if !found_match:
		return original_value
	else:
		return value


func convert_string_to_type(variant):
	var found_match = false
	variant = to_bool(variant)
	variant = str2var(variant)
	match typeof(variant):
		TYPE_INT:
			found_match = true
#			print(variant, " is INTEGER")
		TYPE_REAL:
			found_match = true
#			print(variant, " is FLOAT")
		TYPE_BOOL:
			found_match = true
#			print(variant, " is BOOL")
		TYPE_STRING:
			found_match = true
#			print(variant, " is STRING")
		
	if !found_match:
		print("No Match found for ", variant)
	else:
		return variant

