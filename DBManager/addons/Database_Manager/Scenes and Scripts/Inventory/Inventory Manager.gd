extends Control
tool

var btn_itemselect = preload("res://addons/Database_Manager/Scenes and Scripts/Inventory/Btn_ItemSelect.tscn")

onready var table_list = $VBox1/HBox2/Scroll1/Table_Buttons
onready var item_name_text = $VBox1/HBox2/Panel1/HBox1/VBox1/VBox1/ItemNameText
onready var item_type_text = $VBox1/HBox2/Panel1/HBox1/VBox1/VBox1/ItemType_Selection/Hbox1/ColorRect/ItemTypeText
onready var item_description_text = $VBox1/HBox2/Panel1/HBox1/VBox2/ItemDescriptionText
onready var item_cost_text = $VBox1/HBox2/Panel1/HBox1/VBox1/VBox1/ItemCost_Counter/HBoxContainer/ItemCostText
onready var item_sellprice_text = $VBox1/HBox2/Panel1/HBox1/VBox1/VBox1/ItemSellPrice_Counter/HBoxContainer/ItemCostText
onready var item_cansell_chkbx = $VBox1/HBox2/Panel1/HBox1/VBox1/VBox1/HBox1/ItemCanSell_CheckBox

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
		update_dictionaries()
		reload_buttons()
	else:
		clear_data()
		clear_buttons()


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
	
func enable_all_buttons():
	#Enanables user to interact with all item buttons on table_list
	for i in table_list.get_children():
		i.disabled = false

func refresh_data(item_name : String):
	#Pulls specific item data when button is clicked
	Item_Name = item_name #reset the script variable Item_Name
	enable_all_buttons()
	clear_data()
	
	#Sets all data from item_table with values from item button that was pressed
	item_name_text.set_text(item_name)
	item_type_text.set_text(item_dict[item_name]["Type"])
	item_description_text.set_text(item_dict[item_name]["Description"])
	item_cost_text.set_text(item_dict[item_name]["Cost"])
	item_sellprice_text.set_text(item_dict[item_name]["Sell Value"])
	item_cansell_chkbx.pressed = to_bool(item_dict[item_name]["CanSell"])
	
	table_list.get_node(item_name).disabled = true #Sets current item button to disabled

func create_table_buttons():
	 #Loop through the item_list dictionary and add a button for each item
	for i in row_dict["Row"].size():
		var item_number = str(i + 1) #row_dict key
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
	update_values()
	save_data(row_path, row_dict)
	save_data(table_path, item_dict)
	update_dictionaries()
	reload_buttons()
	refresh_data(Item_Name)

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
		var item_name_dict = row_dict["Row"]
		for i in item_name_dict: #loop through item_row table until it finds the key number for the item
			if item_name_dict[i] == old_name:
				row_dict["Row"][i] = new_name #Replace old value with new value
				break
		
		var old_key_entry : Dictionary = item_dict[Item_Name].duplicate(true) #Create copy of item values
		item_dict.erase(Item_Name) #Erase old item entry
		item_dict[new_name] = old_key_entry #add new item entry
		Item_Name = new_name #Update script variable with correct item name



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
