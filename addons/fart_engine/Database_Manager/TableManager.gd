@tool
class_name TableManager extends DatabaseManager

var currentData_dict := {}
var current_dict := {} 
var datatype_dict := {} 
var data_type : String = "Column"
var Item_Name :String = ""
var current_table_name = ""
var current_table_ref = ""
var table_ref = ""


func update_dictionaries():
	#replaces dictionary data with data from saved files
	currentData_dict = import_data(current_table_name, true) 
	current_dict = import_data(current_table_name)


func get_data_index(value: String, dataType := data_type, data_dict :Dictionary = currentData_dict):
	var index = ""
	for i in data_dict[dataType]:
		var fieldName = data_dict[dataType][i]["FieldName"]
		if fieldName == value:
			index = i
			break
	return index


func get_table_keys():
	return current_dict.keys()



func save_all_db_files(table_name :String = current_table_name):
	save_file(table_save_path + table_name + table_file_format, current_dict)
	save_file(table_save_path + table_name + table_info_file_format, currentData_dict)
#	update_project_settings()


func delete_table(delete_tbl_name):
	###NEED TO CHECK IF TABLE CAN BE DELETED####
	
	#First delete table reference from "Table Data" file and delete the entry in the table_data main table
	current_table_name = "Table Data"
	data_type = "Row"
	update_dictionaries()
	Delete_Key(delete_tbl_name)
	save_all_db_files(current_table_name)
#	print("Table Path: ", table_save_path  + delete_tbl_name + table_file_format)
	#Then delete all of the files associated with the delted table
	var dir :DirAccess = DirAccess.open(table_save_path)
	var file_delete = table_save_path + delete_tbl_name + table_file_format
	dir.remove(file_delete)
	file_delete = table_save_path + delete_tbl_name + table_info_file_format
	dir.remove(file_delete)
	#current_table_name = ""

func delete_field(field_name, selectedDict:Dictionary = current_dict, selectedDataDict:Dictionary = currentData_dict):
#	print("DELETE field NAME: ", field_name)
	var tmp_dict = {}
	var main_tbl = {}
	data_type = "Column"
	for i in selectedDict: #loop trhough main dictionary
		selectedDict[i].erase(field_name)

	tmp_dict = selectedDataDict[data_type].duplicate(true)
	#loop through row_dict to find item
	for i in tmp_dict:
		if selectedDataDict[data_type][i]["FieldName"] == field_name:
			selectedDataDict[data_type].erase(i) #Erase entry
#			print("BREAK1")
			break
	#Loop through number 0 to row_dict size
	for j in tmp_dict.size() - 1:
		j += 1
		if !selectedDataDict[data_type].has(str(j)): #If the row_dict does not have j key
			var next_entry_value = selectedDataDict[data_type][str(j + 1)] #Get value of next entry #If ever more values are added to row table, .duplicate(true) needs to be added to this line
			selectedDataDict[data_type][str(j)] = next_entry_value #create new entry with current index and next entry
			var next_entry = str(j + 1)
			if selectedDataDict[data_type].has(next_entry):
				selectedDataDict[data_type].erase(next_entry) #Delete next entry
			else:
#				print("BREAK2")
				break
#	print("delete key complete")
	return [selectedDict, selectedDataDict]


func Delete_Key(key_name, selectedDict:Dictionary = current_dict, selectedDataDict:Dictionary = currentData_dict):
#	print("DELETE KEY NAME: ", key_name)
	var tmp_dict = {}
	var main_tbl = {}
	data_type = "Row"
	match data_type:
		"Row": #Deletes keys
			selectedDict.erase(key_name) #Remove entry from current dict
		"Column": #Deletes fields
			for i in selectedDict: #loop trhough main dictionary
				selectedDict[i].erase(key_name)

	tmp_dict = selectedDataDict[data_type].duplicate(true)
	#loop through row_dict to find item
	for i in tmp_dict:
		if selectedDataDict[data_type][i]["FieldName"] == key_name:
			selectedDataDict[data_type].erase(i) #Erase entry
#			print("BREAK1")
			break
	#Loop through number 0 to row_dict size
	for j in tmp_dict.size() - 1:
		j += 1
		if !selectedDataDict[data_type].has(str(j)): #If the row_dict does not have j key
			var next_entry_value = selectedDataDict[data_type][str(j + 1)] #Get value of next entry #If ever more values are added to row table, .duplicate(true) needs to be added to this line
			selectedDataDict[data_type][str(j)] = next_entry_value #create new entry with current index and next entry
			var next_entry = str(j + 1)
			if selectedDataDict[data_type].has(next_entry):
				selectedDataDict[data_type].erase(next_entry) #Delete next entry
			else:
#				print("BREAK2")
				break
#	print("delete key complete")
	return [selectedDict, selectedDataDict]


func add_key(keyName, datatype, showKey, requiredValue, dropdown,  newTable : bool = false, new_data := {}):
	var index = currentData_dict["Row"].size() + 1
	var CustomData_dict = import_data("Field_Pref_Values") 
	var newOptions_dict = {}
	var newValue
	#create and save new table with values from input form
	#Get custom key fields and add them to tableData dict
	for i in CustomData_dict:
		var currentKey_dict :Dictionary = str_to_var(CustomData_dict[i]["ItemID"])
		var currentKey :String = get_text(currentKey_dict)
		match currentKey:
			"DataType":
				newValue = datatype
			"FieldName":
				newValue = keyName
			"RequiredValue":
				newValue = requiredValue
			"ShowValue":
				newValue = showKey
			"TableRef":
				newValue = dropdown

		newOptions_dict[currentKey] = newValue

	currentData_dict["Row"][str(index)] =  newOptions_dict

	if newTable:
		current_dict[keyName] = "empty"

	else:
		var new_key_data = current_dict[current_dict.keys()[0]].duplicate(true)
		if new_data != {}:
			new_key_data = new_data
		current_dict[keyName] = new_key_data  #CHANGE THIS TO DEFAULT VALUE FOR DATATYPE #Set new key values based on the default (first line of table)


func get_input_type_node(input_type :String):
#	print("INPUT TYPE: ", input_type)
	var return_node : Object
	datatype_dict = import_data("DataTypes")
	return_node =  load(datatype_dict[input_type]["Default Scene"])
	return return_node


func get_input_type_id_from_name(input_type_name :String):
	datatype_dict = import_data("DataTypes")
	for key in datatype_dict:
		var displayname_dict :Dictionary = str_to_var(datatype_dict[key]["Display Name"])
		var key_name :String = get_text(displayname_dict)
#
		if key_name == input_type_name:
			return key

func add_input_node(index, index_half, key_name, table_dict := current_dict, container1 = null, container2 = null, node_value = "", node_type = "", tableName = ""):
	#Set_Input_Node
	var parent_container = container1
	var did_datatype_change = false
	if container2 != null:
		if index_half < index:
			parent_container = container2
	
	if str(node_value) == "":
		node_value =  convert_string_to_type(table_dict[key_name]["Value"], table_dict[key_name]["DataType"])

	if str(node_type) == "":
		node_type = table_dict[key_name]["DataType"]
	var new_field : Node
	datatype_dict = import_data("DataTypes")
	
	match node_type:
		"TYPE_BOOL": #Bool
			node_type = "4"
			did_datatype_change = true
		"TYPE_INT": #INT
			node_type = "2"
			did_datatype_change = true
#		"TYPE_REAL": #Float
#			node_type = "3"
#			did_datatype_change = true
		"TYPE_STRING": #String
			node_type = "1"
			did_datatype_change = true
		"TYPE_DROPDOWN":
			node_type = "5"
			did_datatype_change = true
		"TYPE_ICON":
			node_type = "6"
			did_datatype_change = true
		"TYPE_KEYSELECT":
			node_type = "11"
			did_datatype_change = true
		'TYPE_SPRITEDISPLAY':
			node_type = "8"
			did_datatype_change = true
		"TYPE_VECTOR": 
			node_type = "9"
			did_datatype_change = true
		"TYPE_MINMAX": 
			node_type = "12"
			did_datatype_change = true
		"TYPE_DICTIONARY":
			node_type = "10"
			did_datatype_change = true
		"TYPE_SCENE":
			node_type = "7"
			did_datatype_change = true
		"TYPE_SFX":
			node_type = "13"
			did_datatype_change = true

	if did_datatype_change:
		for key in currentData_dict[data_type]:
			if currentData_dict[data_type][key]["FieldName"] == key_name:
				currentData_dict[data_type][key]["DataType"] = node_type

	var input_node = load(datatype_dict[node_type]["Default Scene"])
	new_field = await add_input_field(parent_container, input_node)
	if str(node_value) == "Default":
		node_value = new_field.default

	if node_type == "5":#dropdown selection (itemtype selection)
		if tableName == "":
			new_field.selection_table_name = table_dict[key_name]["TableRef"]
		else:
			new_field.selection_table_name = tableName
	new_field.set_input_value(node_value, key_name, current_table_name)
	new_field.set_name(key_name)
	new_field.labelNode.set_text(key_name)
	new_field.table_name = current_table_name
	new_field.table_ref = table_ref
	new_field.set_initial_show_value()

	return new_field

func create_independant_input_node(table_name:String, key_ID:String, field_ID :String):
	var table_dict: Dictionary = import_data(table_name)
	var table_data_dict: Dictionary = import_data(table_name, true)
	var datatype:String = get_datatype(field_ID,table_data_dict )
	datatype_dict = import_data("DataTypes")
	var input_node = load(datatype_dict[datatype]["Default Scene"]).instantiate()
#	input_node.set_input_value(input_node.default, key_ID, table_name)

	if datatype == "5":#dropdown selection (itemtype selection)
		input_node.selection_table_name = table_name

	input_node.set_name(key_ID)
	
	input_node.table_name = table_name
#	input_node.table_ref = table_ref
#	input_node.set_initial_show_value()

	return input_node

func get_value_from_input_node(current_node, field_name := "", key_name := Item_Name):
	var input_type :String = current_node.type
	var input = current_node.inputNode
	var returnValue
	var did_datatype_change = false
	
	match input_type:
		"TYPE_BOOL": #Bool
			input_type = "4"
			did_datatype_change = true
		"TYPE_INT": #INT
			input_type = "2"
			did_datatype_change = true
#		"TYPE_REAL": #Float
#			input_type = "3"
#			did_datatype_change = true
		"TYPE_STRING": #String
			input_type = "1"
			did_datatype_change = true
		"TYPE_DROPDOWN":
			input_type = "5"
			did_datatype_change = true
		"TYPE_ICON":
			input_type = "6"
			did_datatype_change = true
		"TYPE_KEYSELECT":
			input_type = "11"
			did_datatype_change = true
		'TYPE_SPRITEDISPLAY':
			input_type = "8"
			did_datatype_change = true
		"TYPE_VECTOR": 
			input_type = "9"
			did_datatype_change = true
		"TYPE_MINMAX": 
			input_type = "12"
			did_datatype_change = true
		"TYPE_DICTIONARY":
			input_type = "10"
			did_datatype_change = true
		"TYPE_SCENE":
			input_type = "7"
			did_datatype_change = true
		"TYPE_SFX":
			input_type = "13"
			did_datatype_change = true

	if did_datatype_change:
		for key in currentData_dict[data_type]:
			if currentData_dict[data_type][key]["FieldName"] == Item_Name:
				currentData_dict[data_type][key]["DataType"] = input_type
				break

	if typeof(current_node.get_input_value()) == TYPE_STRING:
		returnValue = current_node.get_input_value()
	else:
		returnValue = var_to_str(current_node.get_input_value())



	if field_name != "" and field_name != "Key":
		current_dict[key_name][field_name] = returnValue
	elif field_name == "Key":
		update_key_name(key_name, get_text(returnValue))
	return returnValue


func update_key_name(old_name : String, new_name : String):
	var return_key = old_name
	if old_name != new_name: #if changes are made to item name
		#If is dropdown table
		var table_data_dict :Dictionary = import_data("Table Data")
		var is_dropdown_table = convert_string_to_type(table_data_dict[current_table_name]["Show in Dropdown Lists"])
		if is_dropdown_table == true:
			print("Cannot update keys in a table used as a dropdown list")

		if !does_key_exist(new_name):
			
			var item_name_dict = currentData_dict["Row"]
			for i in item_name_dict: #loop through item_row table until it finds the key number for the item
				if item_name_dict[i]["FieldName"] == old_name:
					currentData_dict["Row"][i]["FieldName"] = new_name #Replace old value with new value
					break

			var old_key_entry : Dictionary = current_dict[Item_Name].duplicate(true) #Create copy of item values
			current_dict.erase(Item_Name) #Erase old item entry
			current_dict[new_name] = old_key_entry #add new item entry
			Item_Name = new_name #Update script variable with correct item name
			return_key = new_name

		else:
			print("Duplicate key exists in table DATA WAS NOT UPDATED")

	return return_key


func does_key_exist(key):
	var value = false
	if current_dict.has(key):
		value = true
	return value


func rearrange_table_keys(new_index :String = button_focus_index, old_index:String = button_selected , selected_data_dict :Dictionary = currentData_dict):
	new_index = get_data_index(new_index, "Row")
	old_index = get_data_index(old_index, "Row")
	var key_data = currentData_dict["Row"][old_index]
	var test_dict = currentData_dict.duplicate(true)
	#remove the old index
	test_dict["Row"].erase(old_index)
	for key in test_dict["Row"].size():
		key += 1
		var key_string :String = str(key)
		if !test_dict["Row"].has(key_string):
			var next_key = str(key + 1)
			var next_key_data = test_dict["Row"][next_key]
			test_dict["Row"][key_string] = next_key_data
			test_dict["Row"].erase(next_key)
	#insert the old key data in the new key index and shift all the remaining keys down
	for key in range(test_dict["Row"].size() + 1,0,-1):
		var key_string :String = str(key)
		var previous_key = str(key - 1)
		if key_string == new_index:
			test_dict["Row"].erase(key_string)
			test_dict["Row"][key_string] = key_data
			break
		else:
			var prev_key_data = test_dict["Row"][previous_key]
			test_dict["Row"].erase(previous_key)
			test_dict["Row"][key_string] = prev_key_data

	currentData_dict["Row"] = test_dict["Row"]
	for child in $Button_Float.get_children():
		child._on_Navigation_Button_button_up()
		child.queue_free()


func get_table_values():
	var return_dict = {}
	#pulls table values in custom order
	for i in currentData_dict[data_type].size():
		var order_value = str(i + 1)
		var value = currentData_dict[data_type][order_value]
		return_dict[value] = order_value
	return return_dict


func add_new_table(newTableName, keyName, keyDatatype, keyVisible, fieldName, fieldDatatype, fieldVisible, dropdown, RefName, createTab, canDelete, isDropdown, add_toSaveFile, is_event):
	current_dict = {}
	currentData_dict["Row"] = {}
	currentData_dict["Column"] = {}
	current_table_name = newTableName
	if isDropdown:
		#THIS IS WHERE I WILL USE THE DROPDOWN TEMPLATE TO CREATE A NEW LIST STYLE TABLE (KEY IS NUMBER, ID, DISPLAY NAME)
		add_key("1", "1", keyVisible, true, dropdown, true)
		add_field("Display Name", "1", fieldVisible, true,  dropdown, true)
		current_dict["1"]["Display Name"] = var_to_str({"text" : keyName})

	else:
		add_key(keyName, keyDatatype, keyVisible, true, dropdown, true)
		add_field(fieldName, fieldDatatype, fieldVisible, true,  dropdown, true)
	save_all_db_files(newTableName)

	#save information about new table in the Table Data file
	current_table_name = "Table Data"
	data_type = "Row"
	update_dictionaries()
	add_key(newTableName, keyDatatype, keyVisible, true, dropdown)

	#Input data for table list
	if RefName == "":
		RefName = newTableName
#	else:
#		current_dict[newTableName]["Display Name"] = RefName

	current_dict[newTableName]["Display Name"] = var_to_str({"text" : RefName})
	current_dict[newTableName]["Create Tab"] = createTab
	current_dict[newTableName]["Show in Dropdown Lists"] = isDropdown
	current_dict[newTableName]["Include in Save File"] = add_toSaveFile
	current_dict[newTableName]["Can Delete"] = true
	current_dict[newTableName]["Is Event"] = is_event
	save_all_db_files(current_table_name)


func create_new_table(newTableName:String, newTable_dict: Dictionary):
	current_dict = {}
	currentData_dict["Row"] = {}
	currentData_dict["Column"] = {}
	current_table_name = newTableName
		#THIS IS WHERE I WILL USE THE DROPDOWN TEMPLATE TO CREATE A NEW LIST STYLE TABLE (KEY IS NUMBER, ID, DISPLAY NAME)
	add_key("1", "1", true, true, true, true)
	add_field("Display Name", "1", true, true,  true, true)
	save_all_db_files(newTableName)
	#save information about new table in the Table Data file
	current_table_name = "Table Data"
	data_type = "Row"
	update_dictionaries()
	add_key(newTableName, "1", true, true, true)
	current_dict[newTableName] = newTable_dict
	save_all_db_files(current_table_name)


func delete_event(delete_tbl_name):
	#First delete table reference from "Table Data" file and delete the entry in the table_data main table
	current_table_name = "Table Data"
	data_type = "Row"
	update_dictionaries()
	Delete_Key(delete_tbl_name)
	save_all_db_files(current_table_name)
#	print("Table Path: ", table_save_path + event_folder + delete_tbl_name + table_file_format)
	#Then delete all of the files associated with the delted table
	var dir :DirAccess = DirAccess.open(table_save_path)
	var file_delete = table_save_path + event_folder + delete_tbl_name + table_file_format
	dir.remove(file_delete)
	file_delete = table_save_path + event_folder + delete_tbl_name + table_info_file_format
	dir.remove(file_delete)
	#current_table_name = ""

func add_event_key(keyName, datatype, showKey, requiredValue, dropdown,  newTable : bool = false, new_data := {}):
	var index = currentData_dict["Row"].size() + 1
	var CustomData_dict = import_data("Field_Pref_Values") 
	var newOptions_dict = {}
	var newValue
	#create and save new table with values from input form
	#Get custom key fields and add them to tableData dict
	for i in CustomData_dict:
		var currentKey_dict :Dictionary = str_to_var(CustomData_dict[i]["ItemID"])
		var currentKey :String = get_text(currentKey_dict)
		match currentKey:
			"DataType":
				newValue = datatype
			"FieldName":
				newValue = keyName
			"RequiredValue":
				newValue = requiredValue
			"ShowValue":
				newValue = showKey
			"TableRef":
				newValue = dropdown

		newOptions_dict[currentKey] = newValue

	currentData_dict["Row"][str(index)] =  newOptions_dict

	if newTable:
		current_dict[keyName] = "empty"

	else:
		var new_key_data = current_dict[current_dict.keys()[0]].duplicate(true)
		if new_data != {}:
			new_key_data = new_data
		current_dict[keyName] = new_key_data  #CHANGE THIS TO DEFAULT VALUE FOR DATATYPE #Set new key values based on the default (first line of table)


func get_default_value(itemType :String):
	datatype_dict = import_data("DataTypes")
	var item_value
	for key in datatype_dict:
		if key == itemType:
			var default_dict :Dictionary =  str_to_var(datatype_dict[key]["Default Values"])
			var default_value = get_text(default_dict)
			item_value = convert_string_to_type(default_value)  #default value
			if item_value == null:
				item_value = default_value
			break
	return item_value


func add_field(fieldName, datatype, showField, required_value, tblName = "empty", newTable : bool = false ):
	#THIS IS WHERE I SHOULD LOOP THROUGH THE USER_PREF TABLE AND ADD THE VALUES TO THE COLUMN TABLE
	var index = currentData_dict["Column"].size() + 1 #Set index as next number in the order

		#Get custom value fields and add them to column_dict
	var fieldCustomData_dict = await import_data("Field_Pref_Values") 
	var newFeild_dict = {}
	var newValue

	for i in fieldCustomData_dict:
		var currentKey_dict :Dictionary = str_to_var(fieldCustomData_dict[i]["ItemID"])
		var currentKey :String = get_text(currentKey_dict)
		match currentKey:
			"DataType":
				newValue = datatype
			"FieldName":
				newValue = fieldName
			"RequiredValue":
				newValue = required_value
			"ShowValue":
				newValue = showField
			"TableRef":
				newValue = tblName


		newFeild_dict[currentKey] = newValue
	currentData_dict["Column"][index] = newFeild_dict #Add new field to the column_dict

	if newTable:
		for i in current_dict:
			var default_value = get_default_value(datatype)
			current_dict[i] = {fieldName :default_value }
	else:
		for n in current_dict: #loop through all keys and set value for this file to "empty"
			var default_value = get_default_value(datatype)

			current_dict[n][fieldName] = default_value #CHANGE THIS TO DEFAULT VALUE FOR DATATYPE
		save_all_db_files(current_table_name)
		update_dictionaries()


func add_line_to_currDataDict():
	var this_dict = import_data(current_table_name, true)
	for i in this_dict["Column"]:
		var dict = currentData_dict["Column"][i]
		if !dict.has("TableRef"):
			currentData_dict["Column"][i]["TableRef"] = "empty"
	for i in this_dict["Row"]:
		var dict = currentData_dict["Row"][i]
		if !dict.has("TableRef"):
			currentData_dict["Row"][i]["TableRef"] = "empty"


func create_datatype_node(datatype:String):
	datatype_dict = import_data("DataTypes")
#	print("CREATE DATATYPE: ", datatype)
	var input_node = load(datatype_dict[datatype]["Default Scene"]).instantiate()
	var input_default_value = get_text(datatype_dict[datatype]["Default Values"])
	return input_node


func create_input_node(key_name:String, table_name:String, table_dict:Dictionary = {}, table_data_dict: Dictionary = {}):
	var data_type:String
#	var node_input_value: Variant
	if table_dict == {}:
		table_dict = import_data(table_name)
	if table_data_dict == {}:
		table_data_dict = import_data(table_name, true)
	data_type = get_datatype(key_name, table_data_dict)
#	print("DATATYPE: ", data_type)
#	print("TABLE DICT: ", table_dict)

	var new_node = create_datatype_node(data_type)
	new_node.set_name(key_name)

	return new_node


#func update_UI_method_table():
#	var AU3_UI_method_dict:Dictionary = import_data("UI Script Methods")
#	var AU3_UI_method_data_dict: Dictionary = import_data("UI Script Methods", true)
#	var AU3_UI_method_display_name_dict:Dictionary = get_field_value_dict(AU3_UI_method_dict)
#	var method_dict:Dictionary = EditorManager.get_UI_methods()
##	print(AU3_UI_method_display_name_dict)
#
#	for method_name in method_dict:
#		if !AU3_UI_method_display_name_dict.has(method_name):
#			var NewKeyName :String = str(get_next_key_ID(AU3_UI_method_dict))
#			var displayName: Dictionary = {"text": method_name}
#			var tempArray :Array = add_key_to_table(NewKeyName, method_name.replace("_", " "), "",AU3_UI_method_dict, AU3_UI_method_data_dict )
#			AU3_UI_method_dict[NewKeyName]["Function Name"] = displayName
#	for id in AU3_UI_method_dict:
#		var functionName:String = get_text(AU3_UI_method_dict[id]["Function Name"])
#		if !method_dict.has(functionName):
#			var newDictArray :Array = Delete_Key(id, AU3_UI_method_dict,AU3_UI_method_data_dict )
#			AU3_UI_method_dict = newDictArray[0].duplicate(true)
#			AU3_UI_method_data_dict = newDictArray[1].duplicate(true)
#
#	save_file( table_save_path + "UI Script Methods" + table_file_format, AU3_UI_method_dict )
#	save_file( table_save_path + "UI Script Methods" + "_data" + table_file_format, AU3_UI_method_data_dict )
