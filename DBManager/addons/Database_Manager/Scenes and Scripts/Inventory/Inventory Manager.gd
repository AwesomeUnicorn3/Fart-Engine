extends Control
tool

var btn_itemselect = preload("res://addons/Database_Manager/Scenes and Scripts/Inventory/Btn_ItemSelect.tscn")

onready var btn_saveChanges = $VBox1/HBox1/SaveChanges
onready var btn_saveNewItem = $VBox1/HBox1/SaveNewItem
onready var btn_addNewItem = $VBox1/HBox1/AddNewItem
onready var btn_cancel = $VBox1/HBox1/Cancel
onready var btn_delete = $VBox1/HBox1/DeleteSelectedItem

onready var table_list = $VBox1/HBox2/Scroll1/Table_Buttons
onready var item_name_text = $VBox1/HBox2/Panel1/HBox1/VBox1/VBox1/ItemNameText
onready var item_type_text = $VBox1/HBox2/Panel1/HBox1/VBox1/VBox1/ItemType_Selection/Hbox1/ColorRect/OptionButton
onready var item_description_text = $VBox1/HBox2/Panel1/HBox1/VBox2/ItemDescriptionText
onready var item_cost_text = $VBox1/HBox2/Panel1/HBox1/VBox1/VBox1/ItemCost_Counter/HBoxContainer/ItemCostText
onready var item_sellprice_text = $VBox1/HBox2/Panel1/HBox1/VBox1/VBox1/ItemSellPrice_Counter/HBoxContainer/ItemCostText
onready var item_cansell_chkbx = $VBox1/HBox2/Panel1/HBox1/VBox1/VBox1/ItemCanSell_Checkbox/ItemCanSell_CheckBox
onready var popup_main = $Popups
onready var popup_deleteConfirm = $Popups/popup_delete_confirm


var save_path = "res://addons/Database_Manager/Data/"
var table_path = "res://addons/Database_Manager/Data/Items.json"
var row_path = "res://addons/Database_Manager/Data/Items_Row"
var column_path = "res://addons/Database_Manager/Data/Items_Column"

var row_dict = {}
var column_dict = {}
var item_dict = {}
var Item_Name = ""

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
	#Clears all input data from item user form
		#(Would like to make this more efficient Not currently sure best way to do so)
	item_name_text.set_text("")
	item_type_text.set_text("")
	item_description_text.set_text("")
	item_cost_text.set_text("")
	item_sellprice_text.set_text("")
	item_cansell_chkbx.pressed = false
	
func enable_all_buttons(value : bool = true):
	#Enanables user to interact with all item buttons on table_list
	for i in table_list.get_children():
		i.disabled = !value

func refresh_data(item_name : String):
	#Pulls specific item data when button is clicked
	Item_Name = item_name #reset the script variable Item_Name
	enable_all_buttons()
	clear_data()
	
	#Sets all data from item_table with values from item button that was pressed
	item_name_text.set_text(item_name)
	
	item_type_text.get_node("../../..").populate_list()
	var type_id = item_type_text.get_node("../../..").get_item_id(item_dict[item_name]["Type"])
	item_type_text.select(type_id)
	
	item_description_text.set_text(item_dict[item_name]["Description"])
	item_cost_text.set_text(item_dict[item_name]["Cost"])
	item_sellprice_text.set_text(item_dict[item_name]["Sell Value"])
	item_cansell_chkbx.pressed = to_bool(item_dict[item_name]["CanSell"])
	if item_name != "Default":
		table_list.get_node(item_name).disabled = true #Sets current item button to disabled
		table_list.get_node(item_name).grab_focus()
		

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
		#NOTE: Does NOT update the database files. That function is located in the save_data method
	#insert code here to only run if values have changed (Not currently sure the best way to indicate changed values)
	
	##Would like to improve this area with less hard code data (Not currently sure the best way to do this)
	update_item_name(Item_Name, item_name_text.text)
	item_dict[Item_Name]["Type"] = item_type_text.text
	item_dict[Item_Name]["Description"] = item_description_text.text
	item_dict[Item_Name]["Cost"] = item_cost_text.text
	item_dict[Item_Name]["Sell Value"] = item_sellprice_text.text
	item_dict[Item_Name]["CanSell"] = item_cansell_chkbx.pressed
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
	var field_array = [item_name_text.text, item_description_text.text]
	#Iterate through input fields and verify that they values are not empty
	for i in field_array:
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
	Item_Name = item_name_text.text
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

func remove_special_char(text : String):
	var array = [" "]
	var result = text
	for i in array:
		result = result.replace(i, "")
	return result

func to_bool(value):
	#changes datatype from string value to bool (Not case specific, only works with yes,no,true, and false)
	value = str(value)
	var value_lower = value.to_lower()
	match value_lower:
		"yes":
			value = true
		"no":
			value = false
		"true":
			value = true
		"false":
			value = false
	return value





