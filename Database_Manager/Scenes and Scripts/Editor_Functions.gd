tool
extends EditorPlugin

#var save_game_path = "user://"
#var load_game_path = ""
var save_format = ".sav"
var table_save_path = "res://addons/Database_Manager/Data/"
var file_format = ".json"
var table_info_file_format = "_data.json"
var icon_folder = "res://addons/Database_Manager/Data/Icons"

#var current_row_dict = {} #Currently Selected row values dictionary
#var current_column_dict = {} #Curretly seelcted column values dictionary
var currentData_dict = {}
var current_dict = {} #Currently selected table values Dictionary

var data_type : String
var current_table_name = ""
var current_table_ref = ""

func refresh_editor():
	get_editor_interface().get_resource_filesystem().scan()

func update_dictionaries():
	#replaces dictionary data with data from saved files
	currentData_dict = import_data(table_save_path + current_table_name + table_info_file_format) 
#	current_row_dict = import_data(table_save_path + current_table_name + "_Row") 
#	current_column_dict = import_data(table_save_path + current_table_name + "_Column")
	current_dict = import_data(table_save_path + current_table_name + file_format)

func get_data_index(value):
	var index
	for i in currentData_dict[data_type]:
		var fieldName = currentData_dict[data_type][i]["FieldName"]
		if fieldName == value:
			index = i
			break
	return index

#func get_row_index(value):
#	var index
#	for i in current_row_dict:
#		var fieldName = current_row_dict[i]["FieldName"]
#		if fieldName == value:
#			index = i
#			break
#
#	return index
#
#func get_column_index(value):
#	var index
#	for i in current_column_dict:
#		var fieldName = current_column_dict[i]["FieldName"]
#		if fieldName == value:
#			index = i
#			break
#
#	return index

func get_table_keys():
	return current_dict.keys()

func get_table_values():
	var return_dict = {}
	#pulls table values in custom order
	for i in currentData_dict[data_type].size():
		var order_value = str(i + 1)
		var value = currentData_dict[data_type][order_value]
		return_dict[value] = order_value
	return return_dict

func list_files_with_param(dirPath, file_type, ignore_table_array : Array = [], array_exclude_begins_with : Array = ["."]):
	var array_load_files = []
	var files = []
	var dir = Directory.new()
	dir.open(dirPath)
	dir.list_dir_begin()
	
	while true:
		var file = dir.get_next()
		var file_begings_with = file.left(0)
		if file == "":
			break
		elif !array_exclude_begins_with.has(file_begings_with):
			if !ignore_table_array.has(file):
				if file.ends_with(file_type):
					if !file.ends_with(table_info_file_format):
						files.append(file)
						array_load_files.append(file)
	dir.list_dir_end()
	return files

func remove_special_char(text : String):
	var array = [":", "/", "."]
	var result = text
	for i in array:
		result = result.replace(i, "")
	return result

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

func save_file(sv_path, tbl_data):
#Save dictionary to .json upon user confirmation
	var save_file = File.new()
	if save_file.open(sv_path, File.WRITE) != OK:
		print("Error Could not update file")
	else:
		var save_d = tbl_data
		save_file.open(sv_path, File.WRITE)
		save_d = to_json(save_d)
		save_file.store_line(save_d)
		save_file.close()

#func get_file_name(table_name, type):
#	var adj_table_name = table_name + "_" + type
#	var name = table_save_path + table_name + file_format
#	match type:
#		"Table":
#			name = table_save_path + table_name + file_format
#
#		"Row":
#			name = table_save_path + adj_table_name + table_info_file_format
#
#		"Column":
#			name = table_save_path + adj_table_name + table_info_file_format
#
#	return name


func save_all_db_files(table_name):
	save_file(table_save_path + table_name + file_format, current_dict)
	save_file(table_save_path + table_name + table_info_file_format, currentData_dict)
#	save_file(get_file_name(table_name , "Row"), current_row_dict)
#	save_file(get_file_name(table_name, "Column"), current_column_dict)


func add_new_table(newTableName, keyName, keyDatatype, keyVisible, fieldName, fieldDatatype, fieldVisible, dropdown):
	current_dict = {}
	currentData_dict["Row"] = {}
	currentData_dict["Column"] = {}
	
	add_key(keyName, keyDatatype, keyVisible, true, dropdown, true)
	add_field(fieldName, fieldDatatype, fieldVisible, true,  dropdown, true)
	save_all_db_files(newTableName)

	#save information about new table in the Table Data file
	current_table_name = "Table Data"
	data_type = "Row"
	update_dictionaries()
	add_key(newTableName, keyDatatype, keyVisible, true, dropdown)
	save_all_db_files(current_table_name)


func delete_table(delete_tbl_name):
	
	#First delete table reference from "Table Data" file and delete the entry in the table_data main table
	current_table_name = "Table Data"
	data_type = "Row"
	update_dictionaries()
	Delete_Key(delete_tbl_name)
	save_all_db_files(current_table_name)

	#Then delete all of the files associated with the delted table
	var dir = Directory.new()
	var file_delete = table_save_path + delete_tbl_name + file_format
	dir.remove(file_delete)
	file_delete = table_save_path + delete_tbl_name + table_info_file_format
	dir.remove(file_delete)
#	file_delete = table_save_path + delete_tbl_name + "_Row"
#	dir.remove(file_delete)
#	file_delete = table_save_path + delete_tbl_name + "_Column"
#	dir.remove(file_delete)

func Delete_Key(key_name):
	var tmp_dict = {}
	var main_tbl = {}
	match data_type:
		"Row": #Deletes keys
			current_dict.erase(key_name) #Remove entry from item dict
			
#			tmp_dict = current_row_dict.duplicate(true)
#			#loop through row_dict to find item
#			for i in tmp_dict:
#				if current_row_dict[i]["FieldName"] == key_name:
#					current_row_dict.erase(i) #Erase entry
#					break
#			#Loop through number 0 to row_dict size
#			for j in tmp_dict.size() - 1:
#				j += 1
#				if !current_row_dict.has(str(j)): #If the row_dict does not have j key
#					var next_entry_value = current_row_dict[str(j + 1)] #Get value of next entry #If ever more values are added to row table, .duplicate(true) needs to be added to this line
#					current_row_dict[str(j)] = next_entry_value #create new entry with current index and next entry
#					var next_entry = str(j + 1)
#					if current_row_dict.has(next_entry):
#						current_row_dict.erase(next_entry) #Delete next entry
#					else:
#						break

		"Column": #Deletes fields
#			tmp_dict = current_column_dict.duplicate(true)
#			for i in tmp_dict:
#				if current_column_dict[i]["FieldName"] == key_name:
#					current_column_dict.erase(i) #Erase entry
#					break
#			#Loop through number 0 to row_dict size
#			for j in tmp_dict.size() - 1:
#				j += 1
#				if !current_column_dict.has(str(j)): #If the row_dict does not have j key
#					var next_entry_value = current_column_dict[str(j + 1)] #Get value of next entry #If ever more values are added to row table, .duplicate(true) needs to be added to this line
#					current_column_dict[str(j)] = next_entry_value #create new entry with current index and next entry
#					var next_entry = str(j + 1)
#					if current_column_dict.has(next_entry):
#						current_column_dict.erase(next_entry) #Delete next entry
#					else:
#						break

			for i in current_dict: #loop trhough main dictionary
				current_dict[i].erase(key_name)
	tmp_dict = currentData_dict[data_type].duplicate(true)
	#loop through row_dict to find item
	for i in tmp_dict:
		if currentData_dict[data_type][i]["FieldName"] == key_name:
			currentData_dict[data_type].erase(i) #Erase entry
			break
	#Loop through number 0 to row_dict size
	for j in tmp_dict.size() - 1:
		j += 1
		if !currentData_dict[data_type].has(str(j)): #If the row_dict does not have j key
			var next_entry_value = currentData_dict[data_type][str(j + 1)] #Get value of next entry #If ever more values are added to row table, .duplicate(true) needs to be added to this line
			currentData_dict[data_type][str(j)] = next_entry_value #create new entry with current index and next entry
			var next_entry = str(j + 1)
			if currentData_dict[data_type].has(next_entry):
				currentData_dict[data_type].erase(next_entry) #Delete next entry
			else:
				break


func add_key(keyName, datatype, showKey, requiredValue, dropdown,  newTable : bool = false):
	var index = currentData_dict["Row"].size() + 1
	var CustomData_dict = import_data(table_save_path + "Field_Pref_Values.json") 
	var newOptions_dict = {}
	var newValue

	#create and save new table with values from input form

	#Get custom key fields and add them to tableData dict
	for i in CustomData_dict:
		var currentKey = CustomData_dict[i]["ItemID"]
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
		var new_key_data = current_dict[current_dict.keys()[0]]
#		for n in current_dict: #loop through all keys and set value for this field to "empty"
#			var field_name = current_column_dict[n]["FieldName"]

		current_dict[keyName] = new_key_data  #CHANGE THIS TO DEFAULT VALUE FOR DATATYPE #Set new key values based on the default (first line of table)

func add_field(fieldName, datatype, showField, required_value, tblName = "empty", newTable : bool = false ):

	#THIS IS WHERE I SHOULD LOOP THROUGH THE USER_PREF TABLE AND ADD THE VALUES TO THE COLUMN TABLE
	var index = currentData_dict["Column"].size() + 1 #Set index as next number in the order
	
		#Get custom value fields and add them to column_dict
	var fieldCustomData_dict = import_data(table_save_path + "Field_Pref_Values.json") 
	var newFeild_dict = {}
	var newValue

	for i in fieldCustomData_dict:
		var currentKey = fieldCustomData_dict[i]["ItemID"]
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
	print(newTable)
	if newTable:
		for i in current_dict:
			print(current_dict)
			current_dict[i] = {fieldName : "empty"}
	
	else:
		for n in current_dict: #loop through all keys and set value for this file to "empty"
			current_dict[n][fieldName] = "empty" #CHANGE THIS TO DEFAULT VALUE FOR DATATYPE
		save_all_db_files(current_table_name)
		update_dictionaries()


func is_file_in_folder(path : String, file_name : String):
	var value = false
	var dir = Directory.new()
	dir.open(path)
#	var dir_files = list_files_in_directory(dir)
	if dir.file_exists(file_name):
		value = true
#		print(file_name, " Exists!!!")
	else:
		print(file_name, " Does NOT Exist :(")
	
	
	return value


#_________________________-SPECIAL POSIBBLY ONE TIME USE SCRIPTS---------------------------------

func convert_keyFile_to_new_format():
	var tablenm = "Controls"
	var keyOptions_dict = {"DataType":"TYPE_BOOL","FieldName":"Dynamic","RequiredValue":false,"ShowValue":true}

	var oldRow_dict = import_data(table_save_path + tablenm + "_Row")
	var oldColumn_dict = import_data(table_save_path + tablenm + "_Column")
	var svpath = table_save_path + tablenm + "_data.json"
	var newRow_dict = {}
	var newColumn_dict = {}
	var final_dict = {"Column" : "empty", "Row" : "empty"}
	
	for i in oldColumn_dict:
		var keyoptions = keyOptions_dict.duplicate(true)
		keyoptions["FieldName"] = oldColumn_dict[i]
		newColumn_dict[i] =  keyoptions
	
	for i in oldRow_dict:
		var keyoptions = keyOptions_dict.duplicate(true)
		keyoptions["FieldName"] = oldRow_dict[i]
		newRow_dict[i] = keyoptions

	final_dict["Row"] = newRow_dict
	final_dict["Column"] = newColumn_dict
	
	print(final_dict)
			
	
	save_file(svpath, final_dict)
	

func add_line_to_currDataDict():
	var this_dict = import_data(table_save_path + current_table_name + "_data.json")
	for i in this_dict["Column"]:
		var dict = currentData_dict["Column"][i]
		if !dict.has("TableRef"):
			currentData_dict["Column"][i]["TableRef"] = "empty"
	for i in this_dict["Row"]:
		var dict = currentData_dict["Row"][i]
		if !dict.has("TableRef"):
			currentData_dict["Row"][i]["TableRef"] = "empty"


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


func convert_string_to_type(variant, datatype = ""):
	var found_match = false
	
	if datatype == "":
		variant = to_bool(variant)
		variant = str2var(variant)
		match typeof(variant):
			TYPE_INT:
				found_match = true
			TYPE_REAL:
				found_match = true
			TYPE_BOOL:
				found_match = true
			TYPE_STRING:
				found_match = true
			TYPE_VECTOR2:
				found_match = true

		if !found_match:
			print("No Match found for ", variant)

	else:
		match datatype:
			"TYPE_BOOL":
				variant = bool(variant)
			"TYPE_STRING":
				variant = str(variant)
			"TYPE_INT":
				variant = str2var(variant)
			"TYPE_REAL":
				variant = float(variant)
			"TYPE_ICON":
				variant = str(variant)
			"TYPE_VECTOR2":
				variant = convert_string_to_Vector(variant)
	return variant


func convert_string_to_Vector(value : String):
	var vector
	value = value.lstrip("(")
	value = value.rstrip(")")
	var array = value.split(",")
	var count = 1
	var x : float
	var y : float
	var z : float
	for i in array:
		match count:
			1:
				x = float(i)
			2:
				y = float(i)
			3:
				z = float(i)
		count += 1
	#count values in array to determine vec2 or vec3
	match array.size():
		2:
			vector = Vector2(x,y)
		3:
			vector = Vector3(x,y,z)

	return vector
