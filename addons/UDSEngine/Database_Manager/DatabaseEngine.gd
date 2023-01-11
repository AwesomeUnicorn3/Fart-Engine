@tool
extends Control
class_name DatabaseEngine
signal Editor_Refresh_Complete

var editor :EditorInterface
var op_sys : String = ""
var save_format = ".sav"
var script_format = ".gd"
var table_save_path = "res://Data/"
var file_format = ".json"
var table_info_file_format = "_data.json"
var icon_folder = "png/"
var sfx_folder =  "sfx/"
var event_folder = "events/"
var currentData_dict := {}
var current_dict := {} #Currently selected table values Dictionary
var datatype_dict := {}
var save_game_path = "user://"
var data_type : String = "Column"
var current_table_name = ""
var current_table_ref = ""
var table_ref = ""
var Item_Name = ""
var root : Node
var json_object : JSON = JSON.new()
var global_settings_profile :String = "Profile 1"

#used to rearrange keys
var button_focus_index :String = "" 
var button_movement_active := false
var button_selected :String = ""

func get_main_node(curr_selected_node = self):
	var main_node = null
	
	while main_node == null:
		if curr_selected_node.is_in_group("UDS_Root"):
			main_node = curr_selected_node
		else:
			if curr_selected_node.get_parent() == null:
				main_node = curr_selected_node
			else:
				curr_selected_node = curr_selected_node.get_parent()

	return main_node


func refresh_editor():
	var editorNew = EditorPlugin.new()
	editorNew.get_editor_interface().get_resource_filesystem().scan()
	while editorNew.get_editor_interface().get_resource_filesystem().is_scanning():
		print("Scanning...")
		await get_tree().create_timer(.1).timeout
	await get_tree().create_timer(.1).timeout
	emit_signal("Editor_Refresh_Complete")
	print("Scanning Complete")


func update_file_in_editor(file_path: String):
	var editorNew = EditorPlugin.new()
	editorNew.get_editor_interface().get_resource_filesystem().update_file(file_path)


func update_dictionaries():
	#replaces dictionary data with data from saved files
	currentData_dict = import_data(table_save_path + current_table_name + table_info_file_format) 
	current_dict = import_data(table_save_path + current_table_name + file_format)


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


func get_id_from_display_name(table_dictionary :Dictionary, display_name :String):
	#print(display_name)
	var index :String
	var id_display_name :String 
	for id in table_dictionary:
		if table_dictionary[id].has("Display Name"):
			id_display_name = str_to_var(table_dictionary[id]["Display Name"])["text"]
			if id_display_name == display_name:
				index = id
				break
	#print(index)
	return index


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
	var dir :DirAccess = DirAccess.open(dirPath)
	#dir.open(dirPath)
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


func import_data(table_loc : String):
	#Opens .json file located at table_loc, reads it, returns the data as a dictionary
	var curr_tbl_data : Dictionary = {}
	#print("Currdata dir Load begin")
	var currdata_dir :FileAccess = FileAccess.open(table_loc,FileAccess.READ_WRITE)
	#print("Currdata dir Loaded")
#	var dir :bool = currdata_dir.file_exists(table_loc)
	if currdata_dir == null :
		print("Error Could not open file at: " + table_loc)
	else:
	#currdata_dir = currdata_dir.open(table_loc, FileAccess.READ)
		var currdata_json = json_object.parse(currdata_dir.get_as_text())
		curr_tbl_data = json_object.get_data()
	#currdata_dir.close()
	#print(curr_tbl_data)
	return curr_tbl_data


func save_file(sv_path, tbl_data):
#Save dictionary to .json upon user confirmation
	var save_file :FileAccess = FileAccess.open(sv_path,FileAccess.WRITE_READ)
	if save_file == null:
		print("Error Could not update file")
	else:
		var save_d = tbl_data
		var jsonObject = JSON.new()
		#save_file.open(sv_path, File.WRITE)
		var json_string = jsonObject.stringify(save_d)
		save_file.store_string(json_string)
		#save_file.close()


func save_all_db_files(table_name :String = current_table_name):
	save_file(table_save_path + table_name + file_format, current_dict)
	save_file(table_save_path + table_name + table_info_file_format, currentData_dict)
	update_project_settings()


func update_project_settings(): #called when save_all_db_files is run
	set_game_root()


func set_game_root():
	var root_path = import_data(table_save_path + "Global Data" + file_format)[global_settings_profile]['Project Root Scene']
	var current_root_scene = ProjectSettings.get("application/run/main_scene")
	if root_path != current_root_scene:
		ProjectSettings.set("application/run/main_scene", root_path) 


func get_default_dialog_scene_path():
	var scene_path :String = import_data(table_save_path + "Global Data" + file_format)[global_settings_profile]['Default Dialog Box']
	return scene_path


func set_root_node():
	var globalDataDict :Dictionary = await import_data(table_save_path + "Global Data" + file_format)
	var rootScenePath :String = globalDataDict[global_settings_profile]["Project Root Scene"]
	var root_scene = load(rootScenePath).instantiate()
	var root_node_name :String = root_scene.get_node(".").name
	root_scene.queue_free()
	root = get_tree().get_root().get_node(root_node_name)


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
	current_dict[newTableName]["Is Dropdown Table"] = isDropdown
	current_dict[newTableName]["Include in Save File"] = add_toSaveFile
	current_dict[newTableName]["Can Delete"] = true
	current_dict[newTableName]["Is Event"] = is_event
	save_all_db_files(current_table_name)



func Delete_Table(delete_tbl_name):
	
	#First delete table reference from "Table Data" file and delete the entry in the table_data main table
	current_table_name = "Table Data"
	data_type = "Row"
	update_dictionaries()
	Delete_Key(delete_tbl_name)
	save_all_db_files(current_table_name)

	#Then delete all of the files associated with the delted table
	var dir :DirAccess = DirAccess.open(table_save_path)
	var file_delete = table_save_path + delete_tbl_name + file_format
	#dir.open(table_save_path)
	dir.remove(file_delete)
	file_delete = table_save_path + delete_tbl_name + table_info_file_format

	dir.remove(file_delete)

	current_table_name = ""



func Delete_Key(key_name):
	print(key_name)
	var tmp_dict = {}
	var main_tbl = {}
	match data_type:
		"Row": #Deletes keys
			
			current_dict.erase(key_name) #Remove entry from item dict
		
		"Column": #Deletes fields
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


func add_key(keyName, datatype, showKey, requiredValue, dropdown,  newTable : bool = false, new_line := {}):
	var index = currentData_dict["Row"].size() + 1
	var CustomData_dict = import_data(table_save_path + "Field_Pref_Values.json") 
	var newOptions_dict = {}
	var newValue

	#create and save new table with values from input form

	#Get custom key fields and add them to tableData dict
	for i in CustomData_dict:
		var currentKey_dict :Dictionary = str_to_var(CustomData_dict[i]["ItemID"])
		var currentKey :String = currentKey_dict["text"]
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
		if new_line != {}:
			new_key_data = new_line
		current_dict[keyName] = new_key_data  #CHANGE THIS TO DEFAULT VALUE FOR DATATYPE #Set new key values based on the default (first line of table)


func get_default_value(itemType :String):
	datatype_dict = import_data(table_save_path + "DataTypes" + file_format)
	var item_value
	for key in datatype_dict:
		if key == itemType:
			var default_dict :Dictionary =  str_to_var(datatype_dict[key]["Default Values"])
			var default_value = default_dict["text"]
			
			item_value = convert_string_to_type(default_value)  #default value
			
#			print(itemType, " : ", default_value, " : ", item_value)
			if item_value == null:
				item_value = default_value
				
			break
	return item_value


func get_value_type(value:String, data_dict :Dictionary):
	var value_type :String = ""
	data_dict = data_dict["Column"]
	for i in data_dict:
		if data_dict[i].has("FieldName"):
			if data_dict[i]["FieldName"] == value:
				value_type = data_dict[i]["DataType"]
				break
	return value_type

func add_field(fieldName, datatype, showField, required_value, tblName = "empty", newTable : bool = false ):

	#THIS IS WHERE I SHOULD LOOP THROUGH THE USER_PREF TABLE AND ADD THE VALUES TO THE COLUMN TABLE
	var index = currentData_dict["Column"].size() + 1 #Set index as next number in the order
	
		#Get custom value fields and add them to column_dict
	var fieldCustomData_dict = await import_data(table_save_path + "Field_Pref_Values.json") 
	var newFeild_dict = {}
	var newValue

	for i in fieldCustomData_dict:
		var currentKey_dict :Dictionary = str_to_var(fieldCustomData_dict[i]["ItemID"])
		var currentKey :String = currentKey_dict["text"]
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


func is_file_in_folder(path : String, file_name : String):
	var value = false
	print(path + file_name)
	var dir :bool = FileAccess.file_exists(path + file_name) #ClEAR WHEN DONE TESTING
	#dir.open(path)
	if dir:
		value = true
	else:
		print(file_name, " Does NOT Exist :(")
	
	return value


#_________________________-SPECIAL POSIBBLY ONE TIME USE SCRIPTS---------------------------------

func convert_keyFile_to_new_format():
	var tablenm = "Controls"
	var keyOptions_dict = {"DataType":"4","FieldName":"Dynamic","RequiredValue":false,"ShowValue":true}

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



#----------------------------------------------------------------------------- Need to sort functions below
func custom_to_bool(value):
	var found_match = false
	#changes datatype from string value to bool (Not case specific, only works with yes,no,true, and false)
	var original_value = value
	value = str(value)
	var value_lower = value.to_lower()
	match value_lower:
		"yes":
			found_match = true
			value = true
		"no":
			found_match = true
			value = false
		"true":
			found_match = true
			value = true
		"false":
			found_match = true
			value = false
	if !found_match:
		return original_value
	else:
		return value


func convert_string_to_type(variant, datatype = ""):
	var found_match = false
	if datatype == "":
		variant = custom_to_bool(variant)
		if !found_match:
			if typeof(variant) != 1:
				var new_type_value = str_to_var(str(variant))
				if new_type_value != null:
					variant = new_type_value
		match typeof(variant):
			TYPE_INT:
				found_match = true
			TYPE_FLOAT:
				found_match = true
			TYPE_BOOL:
				found_match = true
			TYPE_VECTOR2:
				found_match = true
			TYPE_DICTIONARY:
				found_match = true
			TYPE_ARRAY:
				found_match = true
			TYPE_STRING:
				found_match = true

		if !found_match:
			print("No Match found for ", variant)

	else:
		match datatype:
			"4":
				variant = custom_to_bool(variant)
			"1":
				variant = string_to_dictionary(variant)
			"2":
				variant = str_to_var(str(variant))
			"3":
				variant = str(variant).to_float()
			"6":
				variant = str(variant)
			"TYPE_VECTOR2":
				variant = convert_string_to_vector(str(variant))
			"TYPE_VECTOR3":
				variant = convert_string_to_vector(variant)
			"10":
				variant = string_to_dictionary(variant)
			"14":
				variant = string_to_dictionary(variant)
			"TYPE_ARRAY":
				variant = string_to_array(str(variant))
			"15":
				variant = string_to_dictionary(variant)
			"16":
				pass

#				variant = string_to_dictionary(variant)

			"17":
				variant = string_to_dictionary(variant)

	return variant

func string_to_array(value: String):
	var value_array = str_to_var(value)
	return value_array
	
	
	
func convert_string_to_vector(value : String):
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
				x = i.to_float()
			2:
				y = i.to_float()
			3:
				z = i.to_float()
		count += 1
	#count values in array to determine vec2 or vec3
	match array.size():
		2:
			vector = Vector2(x,y)
		3:
			vector = Vector3(x,y,z)

	return vector


func get_file_name(name : String, filetype : String):
	name = name.trim_suffix(filetype)
	return name

func set_var_type_dict(dict : Dictionary):
	var o
	for l in dict:
		for m in dict[l]:
			for n in dict[l][m]:
				o = str(dict[l][m][n])
				o = str_to_var(o)
				if typeof(o) == TYPE_STRING:
					o = custom_to_bool(o)
				match typeof(o):
					TYPE_BOOL:
						dict[l][m][n] = o
					TYPE_INT:
						dict[l][m][n] = o
					TYPE_STRING:
						pass
					TYPE_NIL:
						pass

func set_var_type_table(dict : Dictionary):
	var o
	for l in dict:
		for m in dict[l]:
			o = dict[l][m]
			o = str_to_var(o)
			if typeof(o) == TYPE_STRING:
				o = custom_to_bool(o)

			match typeof(o):
				TYPE_BOOL:
					dict[l][m] = o
				TYPE_INT:
					dict[l][m] = o
				TYPE_STRING:
					pass
				TYPE_NIL:
					pass


func string_to_dictionary(value):
	if typeof(value) == TYPE_STRING:
		value = str_to_var(value)
	return value


func add_input_field(par: Node, nodeName):
	var new_node : Node= nodeName.instantiate()
	par.add_child(new_node)
	new_node.set_owner(par)
	return new_node

func is_table_dropdown_list(tableName :String):
	var tables_dict = import_data(table_save_path + "Table Data.json")
	var table_data = import_data(table_save_path + "Table Data_data.json")
	var isTableDropdownList :bool = false
	for i in range(0, tables_dict.size()):
		var index :String = str(i + 1)
		var currTableName :String = table_data["Row"][index]["FieldName"]
		if currTableName == tableName:
			isTableDropdownList = convert_string_to_type(tables_dict[currTableName]["Is Dropdown Table"])
			#print(isTableDropdownList)
			break
	return isTableDropdownList


func get_input_type_node(input_type :String):
	var return_node : Object
	datatype_dict = import_data(table_save_path + "DataTypes" + file_format)
	return_node =  load(datatype_dict[input_type]["Default Scene"])
	return return_node


func get_input_type_id_from_name(input_type_name :String):
	datatype_dict = import_data(table_save_path + "DataTypes" + file_format)
	for key in datatype_dict:
		var displayname_dict :Dictionary = str_to_var(datatype_dict[key]["Display Name"])
		var key_name :String = displayname_dict["text"]
#
		if key_name == input_type_name:
			return key


func add_input_node(index, index_half, key_name, table_dict := current_dict, container1 = null, container2 = null, node_value = "", node_type = "", tableName = ""):

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
	datatype_dict = import_data(table_save_path + "DataTypes" + file_format)
	
	match node_type:
		"TYPE_BOOL": #Bool
			node_type = "4"
			did_datatype_change = true
		"TYPE_INT": #INT
			node_type = "2"
			did_datatype_change = true
		"TYPE_REAL": #Float
			node_type = "3"
			did_datatype_change = true
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
	match node_type: #Match variant type and then determine which input field to use (check box, long text, short text, number count etc)

		"4": #TYPE_BOOL
			new_field = await add_input_field(parent_container, input_node)
			if str(node_value) == "Default":
				node_value = new_field.default
			
			node_value = custom_to_bool(node_value)
			new_field.inputNode.set_pressed(node_value)
			new_field._on_input_toggled(node_value)


		"2": #INT
			new_field = await add_input_field(parent_container, input_node)
			if str(node_value) == "Default":
				node_value = new_field.default
			new_field.inputNode.set_text(str(node_value))

		"3": #Float
			new_field = await add_input_field(parent_container, input_node)
			if str(node_value) == "Default":
				node_value = new_field.default
			new_field.inputNode.set_text(str(node_value))

		"1": #String
			new_field = await add_input_field(parent_container, input_node)
			if str(node_value) == "Default":
				node_value = str_to_var(new_field.default)
			new_field.set_input_value(node_value, key_name, current_table_name)

		"5":
			new_field = await add_input_field(parent_container, input_node)
			if tableName == "":
				new_field.selection_table_name = table_dict[key_name]["TableRef"]
			else:
				new_field.selection_table_name = tableName
			new_field.set_input_value(node_value, key_name, current_table_name)
#			new_field.labelNode.set_text(key_name)
#			new_field.populate_list()
#			if str(node_value) == "Default":
#				node_value = new_field.default
#			var type_id = new_field.get_id(str(node_value))
#			new_field.inputNode.select(type_id)
#			var itemSelected = new_field._on_Input_item_selected(type_id)
		"6":
			new_field = await add_input_field(parent_container, input_node)
			if str(node_value) == "Default":
				node_value = new_field.default
			var texture_path = node_value
			if texture_path == "empty":
				texture_path = new_field.default
			var tempBtn :TextureButton = new_field.inputNode
			tempBtn.set_texture_normal(load(str(table_save_path + icon_folder + texture_path)))

		"11":
			new_field = await add_input_field(parent_container, input_node)
			if str(node_value) == "Default":
				node_value = new_field.default
			new_field.set_input_value(node_value, key_name, current_table_name)
#			var key = OS.get_keycode_string(str(node_value).to_int())
#			new_field.inputNode.set_text(key)
#			new_field.inputNode.get_node("Keycode").set_text(str(node_value))

		"17":
			new_field = await add_input_field(parent_container, input_node)
			if str(node_value) == "Default":
				node_value = new_field.default
			new_field.set_input_value(node_value, key_name, current_table_name)

		"8":
			new_field = await add_input_field(parent_container, input_node)
			node_value = convert_string_to_type(node_value)
			new_field.set_input_value(node_value, key_name, current_table_name)


		"9": 
			new_field = await add_input_field(parent_container, input_node)
			if str(node_value) == "Default":
				node_value = str(new_field.default)
			new_field.inputNode.set_text(node_value)
			new_field.set_user_input_value()
			new_field.set_inputNode_value()

		"12": 
			new_field = await add_input_field(parent_container, input_node)
			if str(node_value) == "Default":
				node_value = str(new_field.default)
			new_field.inputNode.set_text(node_value)
			new_field.set_user_input_value()

		"10":
			new_field = await add_input_field(parent_container, input_node)
			if str(node_value) == "Default":
				node_value = convert_string_to_type(new_field.default)
			if typeof(node_value) == TYPE_STRING:
				node_value = str_to_var(node_value)
			new_field.main_dictionary = node_value
			new_field.inputNode.set_text(str(node_value))

		"7":
			new_field  = await add_input_field(parent_container, input_node)
			if str(node_value) == "Default":
				node_value = new_field.default
			new_field.inputNode.set_text(node_value)
			new_field._on_input_text_changed(node_value)
		
		"13":
			
			new_field = await add_input_field(parent_container, input_node)
			if str(node_value) == "Default":
				node_value = new_field.default
			new_field.set_input_value(node_value, key_name, current_table_name)


		"14":
			new_field = await add_input_field(parent_container, input_node)
			if str(node_value) == "Default":
				node_value = convert_string_to_type(new_field.default)
			if typeof(node_value) == TYPE_STRING:
				node_value = str_to_var(node_value)

			new_field.main_dictionary = node_value
			new_field.inputNode.set_text(str(node_value))


		"15":
			new_field = await add_input_field(parent_container, input_node)
			if str(node_value) == "Default":
				node_value = convert_string_to_type(new_field.default)
			if typeof(node_value) == TYPE_STRING:
				node_value = str_to_var(node_value)

			new_field.main_dictionary = node_value
			new_field.inputNode.set_text(str(node_value))


		"16":
			new_field = await add_input_field(parent_container, input_node)
#			if str(node_value) == "Default":
#				node_value = convert_string_to_type(new_field.default)
			node_value = convert_string_to_type(node_value)
			new_field.set_input_value(node_value, key_name, current_table_name)

	new_field.set_name(key_name)
	new_field.labelNode.set_text(key_name)
	new_field.table_name = current_table_name
	new_field.table_ref = table_ref
	new_field.set_initial_show_value()

	return new_field


func update_match(current_node, field_name = "", key_name = Item_Name):
	
	var input_type = current_node.type
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
		"TYPE_REAL": #Float
			input_type = "3"
			did_datatype_change = true
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

	match input_type:
		"1":
			returnValue = var_to_str(current_node.get_input_value())
				
		"5":
			returnValue = var_to_str(current_node.get_input_value())
			
		"2":
			returnValue = input.text
		
		"3":
			returnValue = input.text

			
		"4":
			returnValue = input.get_text()
			
		"6":
			var filename = input.get_texture_normal().get_path().get_file()
			returnValue = filename
			
		"8":
			returnValue = var_to_str(current_node.get_input_value())

		"9":
			returnValue = input.text

		"12":
			returnValue = input.text
			
		"10":
			returnValue = var_to_str(current_node.main_dictionary)

		"7":
			returnValue = input.text
		
		"13":
			returnValue = var_to_str(current_node.get_input_value())

		"11":
			returnValue = var_to_str(current_node.get_input_value())

		"17":
			returnValue = var_to_str(current_node.get_input_value())

		"14":
			returnValue = var_to_str(current_node.main_dictionary)
		
		"15":
			returnValue = var_to_str(current_node.main_dictionary)
			
		"16": #Dialog
			returnValue = var_to_str(current_node.get_input_value())


	if field_name != "" and field_name != "Key":
		current_dict[key_name][field_name] = returnValue
	elif field_name == "Key":
		update_key_name(key_name, str_to_var(returnValue)["text"])
	return returnValue


func update_key_name(old_name : String, new_name : String):
	var return_key = old_name
	if old_name != new_name: #if changes are made to item name
		#If is dropdown table
		var table_data_dict :Dictionary = import_data(table_save_path + "Table Data" + file_format)
		var is_dropdown_table = convert_string_to_type(table_data_dict[current_table_name]["Is Dropdown Table"])
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
	#Iterate through table values and compare to key if values are the same, return error
	for i in current_dict:
		if i == key:
			value = true
			print("Item already exists!")
			break
	return value


func create_sprite_animation():
	var character_animated_sprite : AnimatedSprite2D = AnimatedSprite2D.new()
	return character_animated_sprite


func add_animation_to_animatedSprite(sprite_field_name :String, sprite_texture_data :Dictionary, create_collision :bool = true, animated_sprite : AnimatedSprite2D = AnimatedSprite2D.new(), sprite_frames :SpriteFrames = SpriteFrames.new()):
	var collision

	if sprite_frames == null:
		sprite_frames = SpriteFrames.new()

	var frame_vector :Vector2 = sprite_texture_data["atlas_dict"]["frames"]
	var frame_range :Vector2 = sprite_texture_data["advanced_dict"]["frame_range"]
	var speed :int = sprite_texture_data["advanced_dict"]["speed"]
	var frame_size :Vector2 = sprite_texture_data["advanced_dict"]["sprite_size"]

	var atlas_texture :Texture = load(table_save_path + icon_folder + sprite_texture_data["atlas_dict"]["texture_name"])

	#Size of sprite does not change in input form- only in editor and while game is running
	#DO I NEED TO SET SIZE HERE? I THINK SO
	#PERHAPS SEPERATE OUT SETTING THE SIZE AS A NEW METHOD

	frame_size = Vector2(atlas_texture.get_size().x/frame_vector.y,atlas_texture.get_size().y/frame_vector.x)
	
	
	var total_frames = frame_vector.x * frame_vector.y

	if sprite_frames.has_animation(sprite_field_name):
		sprite_frames.clear(sprite_field_name)
	sprite_frames.add_animation(sprite_field_name)
	
	var v_count = 0
	var h_count = 0
	var frame_count = 1

	animated_sprite.set_sprite_frames(sprite_frames)

	for i in range(1, total_frames + 1):
		var region_offset = Vector2(frame_size.x * h_count, (frame_size.y * v_count))
		var region := Rect2( region_offset ,  Vector2(frame_size.x , frame_size.y))
		var cropped_texture = get_cropped_texture(atlas_texture, region)

		if i >= frame_range.x and i <= frame_range.y:
			sprite_frames.add_frame(sprite_field_name, cropped_texture , frame_count)
			frame_count += 1
		h_count += 1
	
		if h_count == frame_vector.y:
			h_count = 0
			v_count += 1

	if create_collision:
		collision = get_collision_shape(sprite_field_name, sprite_texture_data)
		
	sprite_frames.set_animation_speed(sprite_field_name, speed)

	return [sprite_field_name, collision]


func add_sprite_group_to_animatedSprite(main_node , Sprite_Group_Id :String) -> Dictionary:
	var return_value_dictionary :Dictionary= {}
	var animation_dictionary :Dictionary = {}
	var new_animatedsprite2d :AnimatedSprite2D = create_sprite_animation()
	var sprite_group_dict :Dictionary = AU3ENGINE.Static_Game_Dict["Sprite Groups"]
	var spriteFrames : SpriteFrames = SpriteFrames.new()
	animation_dictionary = sprite_group_dict[Sprite_Group_Id]
#	for sprite_name in sprite_group_dict:
#		#print(sprite_group_dict[sprite_name]["Display Name"])
#		if str_to_var(sprite_group_dict[sprite_name]["Display Name"])["text"] == Sprite_Group_Id:
#			animation_dictionary = AU3ENGINE.Static_Game_Dict["Sprite Groups"][sprite_name]


	if main_node.has_method("call_commands") :
		var default_dict :Dictionary = AU3ENGINE.convert_string_to_type(main_node.event_dict[main_node.active_page]["Default Animation"])
		default_dict["Display Name"] = "Default Animation"
		animation_dictionary["Default Animation"] = default_dict

	for j in animation_dictionary:
		
		if j != "Display Name":
			var animation_name : String = j
			var anim_array :Array = AU3ENGINE.add_animation_to_animatedSprite( animation_name, AU3ENGINE.convert_string_to_type(animation_dictionary[j]), true ,new_animatedsprite2d, spriteFrames)
			main_node.add_child(anim_array[1])
	
	return_value_dictionary["animated_sprite"] = new_animatedsprite2d
	return_value_dictionary["animation_dictionary"] = animation_dictionary
	return return_value_dictionary


func set_sprite_scale(sprite_animation :AnimatedSprite2D, animation_name:String, animation_dictionary :Dictionary, additional_scaling :Vector2 = Vector2(1,1)):
	var sprite_dict :Dictionary
	if !animation_dictionary.has("animation_dictionary"):
		sprite_dict = animation_dictionary
	else:
		sprite_dict  = AU3ENGINE.convert_string_to_type(animation_dictionary["animation_dictionary"][animation_name])
	var atlas_dict :Dictionary = sprite_dict["atlas_dict"]
	var advanced_dict :Dictionary  = sprite_dict["advanced_dict"]
	var sprite_texture = load(AU3ENGINE.table_save_path + AU3ENGINE.icon_folder + atlas_dict["texture_name"])
	var sprite_frame_size = atlas_dict["frames"]
	var sprite_final_size = advanced_dict["sprite_size"]
	var sprite_cell_size := Vector2(sprite_texture.get_size().x / sprite_frame_size.y ,sprite_texture.get_size().y / sprite_frame_size.x)
	var modified_sprite_size_y = sprite_final_size.x * additional_scaling.y
	var modified_sprite_size_x = sprite_final_size.y * additional_scaling.x
	var y_scale_value = modified_sprite_size_y / sprite_cell_size.y
	var x_scale_value = modified_sprite_size_x / sprite_cell_size.x
	sprite_animation.set_scale(Vector2(x_scale_value, y_scale_value))


func get_collision_shape(sprite_field_name :String, sprite_texture_data: Dictionary):
	var collision_position := Vector2.ZERO
	var collision_shape = CollisionShape2D.new()
	var new_shape_2d : = ConvexPolygonShape2D.new()
	var sprite_advanced_dict :Dictionary = convert_string_to_type(sprite_texture_data["advanced_dict"])

#	var frameVector : Vector2 = sprite_texture_data["atlas_dict"]["frames"]
	var spriteMap = load(table_save_path + icon_folder + sprite_texture_data["atlas_dict"]["texture_name"])
	#SET COLLISION SHAPE = TO SPRITE SIZE
	var sprite_size :Vector2 = sprite_advanced_dict["sprite_size"]
	collision_shape.set_shape(new_shape_2d)

	var collision_vector_array : = []
	var height = sprite_size.y / 8
	var width = sprite_size.x / 5
	collision_vector_array.append(Vector2(-2 * width,-1 * height))
	collision_vector_array.append(Vector2(-1 * width,-2 * height))
	collision_vector_array.append(Vector2(1 * width,-2 * height))
	collision_vector_array.append(Vector2(2 * width,-1 * height))
	collision_vector_array.append(Vector2(2 * width,1 * height))
	collision_vector_array.append(Vector2(1 * width,2 * height))
	collision_vector_array.append(Vector2(-1 * width,2 * height))
	collision_vector_array.append(Vector2(-2 * width,1 * height))
	collision_shape.shape.set_points(collision_vector_array)

	collision_position.y = sprite_size.y / 4
	collision_shape.position = collision_position
	collision_shape.name = sprite_field_name + " Collision"
	collision_shape.disabled = true

	return collision_shape

func create_event_interaction_area(sprite_field_name :String, sprite_texture_data: Dictionary):
	var collision_position := Vector2.ZERO
	var area := Area2D.new()
	var collision_shape = CollisionShape2D.new()
	var new_shape_2d : = CircleShape2D.new()
	var frameVector : Vector2 = sprite_texture_data["atlas_dict"]["frames"]
	var spriteMap = load(table_save_path + icon_folder + sprite_texture_data["atlas_dict"]["texture_name"])
	var sprite_size : Vector2 = sprite_texture_data["advanced_dict"]["sprite_size"] 

	#SET COLLISION SHAPE = TO SPRITE SIZE
	collision_shape.set_shape(new_shape_2d)
	new_shape_2d.radius = sprite_size.x/2.25
	area.name = sprite_field_name + " Interation Area"
	area.set_collision_layer_value(2, true)
	area.set_collision_layer_value(1, false)
	area.set_collision_mask_value(2, true)
	area.add_child(collision_shape)
	return area



func create_event_attack_area(sprite_field_name :String, sprite_texture_data: Dictionary):
	var collision_position := Vector2.ZERO
	var area := Area2D.new()
	var collision_shape = CollisionShape2D.new()
	var new_shape_2d : = CircleShape2D.new()
	var frameVector : Vector2 = sprite_texture_data["atlas_dict"]["frames"]
	var spriteMap = load(table_save_path + icon_folder + sprite_texture_data["atlas_dict"]["texture_name"])
	var sprite_size = Vector2(spriteMap.get_size().x/frameVector.y,spriteMap.get_size().y/frameVector.x)
	
	#SET COLLISION SHAPE = TO SPRITE SIZE
	collision_shape.set_shape(new_shape_2d)
	new_shape_2d.radius = sprite_size.x * 2
	area.name = sprite_field_name + " Attack Player Area"
	area.set_collision_layer_value(2, true)
	area.set_collision_layer_value(1, false)
	area.set_collision_mask_value(2, true)
	area.add_child(collision_shape)
	
	return area


func get_cropped_texture(texture : Texture, region : Rect2) -> AtlasTexture:
	var atlas_texture = AtlasTexture.new()
	atlas_texture.set_atlas(texture)
	atlas_texture.set_region(region)
	return atlas_texture

#############################EVENT FUNCTIONS#####################################

#func  create_new_event_script(script_name : = "DefaultGDScript" ):
#	var event_dict : Dictionary = import_data(table_save_path + "events" + file_format)
#	var script_data := "extends Node \nfunc test(): \n	print('Success!!')"
#	var save_file = File.new()
#	var save_path : String = table_save_path + event_folder
#
#	if save_file.file_exists(save_path + script_name + script_format):
#		print("Error ", script_name, " already exists")
#
#	elif save_file.open(save_path + script_name + script_format, File.WRITE) != OK:
#		print("Error Could not update file")
#
#	else:
#		save_file.open(save_path + script_name + script_format, File.WRITE)
#		save_file.close()
#		event_dict[script_name] = save_path + script_name + script_format
#		print(script_name , " created at " + save_path)
#		refresh_editor()
#		add_func_to_event_script(script_name, "test", script_data)
#
#
#func add_func_to_event_script(script_name : String, function_name : String, script_line : String ):
#	var save_path : String = table_save_path + event_folder
#	var event_dict : Dictionary = import_data(table_save_path + "events" + file_format) #REPLACE THIS WITH THE TABLE REFERENCE
#	var save_file = File.new()
#	if save_file.open(save_path + script_name + script_format, File.READ_WRITE) != OK:
#		print("Error Could not update file")
#
#	elif event_has_function(script_name, function_name):
#		print("Error ", script_name, " already has a function with name ", function_name)
#	else:
#		save_file.open(save_path + script_name + script_format, File.READ_WRITE)
#		var existing_data : String = save_file.get_as_text()
#		script_line = existing_data + "\n" + script_line
#		save_file.store_string(script_line)
#
#		print(function_name + " added to " + script_name)
#		save_file.close()
#		refresh_editor()
#
#func add_line_to_function(script_name : String, function_name: String, script_line : String):
#	var save_path : String = table_save_path + event_folder
#	if event_has_function(script_name, function_name):
#		var function_script = get_function_script(script_name, function_name)
#		var script_file = File.new()
#		script_file.open(save_path + script_name + script_format, File.READ_WRITE)
#		var script_text : String = script_file.get_as_text()
#		var updated_function = function_script + "\n" + "\t" + script_line
#
#		script_text = script_text.replace(function_script, updated_function)
#
#		script_file.store_string(script_text)
#		script_file.close()
#
#
#func get_function_script(script_name : String, function_name: String):
#	var save_path : String = table_save_path + event_folder
#	var script_file = File.new()
#	var function_script :String = ""
#
#	if event_has_function(script_name, function_name):
#		script_file.open(save_path + script_name + script_format, File.READ)
#		var script_text :String = script_file.get_as_text()
#
#		if script_text.find(function_name +  "(") != -1:
#			var start_line := script_text.find(function_name +  "(")
#			var end_line := script_text.find("func", start_line)
#
#			if end_line == -1:
#				end_line = script_text.length()
#			function_script = script_text.substr(start_line - 5, end_line)
#
#		script_file.close()
#	return function_script


#func event_has_function(script_name : String, function_name: String): #DOES NOT WORK IF FILE WAS JUST CREATED BUT DOES WORK IF FILE ALREADY EXISTS
#	var save_path : String = table_save_path + event_folder
#	var has_function = false
#	var script_file = File.new()
#	script_file.open(save_path + script_name + script_format, File.READ_WRITE)
#	var script_text : String = script_file.get_as_text()
#	if script_text.find(function_name +  "(") != -1:
#		has_function = true
#	script_file.close()
#	if !has_function:
#		print(function_name, " does not exists in script ", script_name)
#	return has_function



func get_list_of_events(return_dict := false):
	#EVENT DICT NEEDS TO BE THE TABLE DATA BUT ONLY THE TABLES THAT ARE DESIGNATED AS EVENTS
	var table_dict :Dictionary = get_list_of_all_tables()
	var event_dict = {}
	for table_name in table_dict:

		var is_event = convert_string_to_type(table_dict[table_name]["Is Event"])
		if is_event:
			var name_ = table_dict[table_name]["Display Name"]
#			print(name_)
			event_dict[name_] = table_name

	var event_list :String = ""


	for displayName in event_dict:
		if event_list == "":
			event_list = displayName
		else:
			event_list = event_list + "," + displayName

	if return_dict:
		return event_dict
	else:
		return event_list

func get_list_of_all_tables():
	var table_dict : Dictionary = import_data(table_save_path + "Table Data" + file_format)
	return table_dict

func wait_timer(Wait_Time : float = 1.0):
	var t = Timer.new()
	get_main_node().add_child(t)
	t.set_wait_time(Wait_Time)
#	t.autostart = true
	t.start()
	await t.timeout
	t.queue_free()





#Convert string to dictionary testing

#	var dict = {}
#	var dict2 = {}
#	var dict3 = {}
#	var key
#
#
#	value = value.trim_prefix("{")
#	value = value.trim_suffix("}")
#	key = convert_string_to_type(value.left(value.find(":")))
#
#
#	if value.find("{") == -1:
#		dict = value.split(",")
#		if dict.size() > 1:
#			for i in dict.size():
#				dict2 = {}
#				dict2 = dict[i].split(":")
#				dict3[convert_string_to_type(dict2[0])] = convert_string_to_type(dict2[1])
#			dict_value = {key : dict3}
#		else:
#			dict2 = value.split(":")
#			dict3 = convert_string_to_type(dict2[1])
#			dict_value = {key:dict3}

#
#	else:
#		var split = value.split("{")
#		var value2 = split[1]
#		value2 = split[1].trim_prefix("{")
#		value2 = split[1].trim_prefix(" ")
#		value2 = split[1].trim_suffix("}")
#		value2 = convert_string_to_type(value2, "10")
#		dict_value[key] = value2[value2.keys()[0]]

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
	#_on_Save_button_up()

	for child in $Button_Float.get_children():
		child._on_TextureButton_button_up()
		child.queue_free()


func get_events_tab(curr_selected_node):
	var events_tab = get_main_node().get_node("HBox_1/VBox_1/ScrollContainer/Hbox_1/Event_Manager")
	return events_tab


func open_scene_in_editor(scene_path :String):
	editor = EditorPlugin.new().get_editor_interface()
	var open_scenes = editor.get_open_scenes()
	if open_scenes.has(scene_path):
		editor.reload_scene_from_path(scene_path)
	else:
		editor.open_scene_from_path(scene_path)

func get_mappath_from_displayname(map_name :String):
	#print(map_name)
	var maps_dict = import_data(table_save_path + "Maps" + file_format)
	#print(maps_dict)
	var new_map_path :String = ""
	for map_id in maps_dict:
		if str_to_var(maps_dict[map_id]["Display Name"])["text"] == map_name:
			new_map_path = maps_dict[map_id]["Path"]
			break
	#print(new_map_path)
	return new_map_path


func add_starting_position_node_to_map(selectedItemName,previous_selection, parent_node):
	editor = EditorPlugin.new().get_editor_interface()
	var new_map_path :String
	var previous_map_path :String

	new_map_path = get_mappath_from_displayname(selectedItemName)
	previous_map_path = get_mappath_from_displayname(previous_selection)

	var starting_position_node = Sprite2D.new()
	var new_map_scene  = load(new_map_path).instantiate()

	new_map_scene.add_child(starting_position_node)
	starting_position_node.set_owner(new_map_scene)
	starting_position_node.set_name("StartingPositionNode")
	starting_position_node.set_script(load("res://addons/UDSEngine/Database_Manager/StartingPositionNode.gd"))
	var starting_position_icon :Texture = load("res://Data/png/StartingPosition.png")
	starting_position_node.set_texture(starting_position_icon)

	var new_packed_scene = PackedScene.new()
	new_packed_scene.pack(new_map_scene)
	var dir :DirAccess = DirAccess.open(new_map_path.get_base_dir())
	#dir.open(new_map_path.get_base_dir())
	dir.remove(selectedItemName)
	ResourceSaver.save(new_packed_scene, new_map_path,)
	new_map_scene.queue_free()

	parent_node._on_Save_button_up()

	open_scene_in_editor(new_map_path)

	var tabbar :TabBar = get_editor_tabbar()
	var tabbar_dict :Dictionary = get_open_scenes_in_editor()
	var previous_scene_name :String = previous_map_path.get_file().get_basename()
	var scene_name :String = new_map_path.get_file().get_basename()
	var scene_index :int = 0

	for index in tabbar_dict:
		if tabbar_dict[index] == scene_name:
			scene_index = index
			break

	tabbar.set_current_tab(scene_index)
	close_scene_in_editor(previous_scene_name)
	select_node_in_editor("StartingPositionNode")

func close_scene_in_editor(scene_name :String):
	var scene_index :int = 0
	var tabbar = get_editor_tabbar()
	var tabbar_dict :Dictionary = get_open_scenes_in_editor()
	for index in tabbar_dict:
		if tabbar_dict[index] == scene_name:
			scene_index = index
			break
	tabbar.emit_signal("tab_close_pressed", scene_index)


func select_node_in_editor(node_name : String):
	editor.get_selection().clear()
	editor.edit_node(editor.get_edited_scene_root().get_node(node_name))


func get_editor_tabbar() -> TabBar:
	var tabbar :TabBar
	tabbar = editor.get_editor_main_screen().get_parent().get_parent().get_node("@@717/@@718/@@719")
#	print(tabbar.name)
	
#	for child in editor.get_editor_main_screen().get_parent().get_parent().get_children():
#		print(child.name, " ", child.get_class())
#		print(child.get_children())
#		if child.name == "@@717":
#			print("Found")
#			print(child.get_node("@@718").get_children())
			

			
#	for child in editor.get_editor_main_screen().get_parent().get_parent().get_children():
#
#		if child.get_class() == "HBoxContainer":
#			for child2 in child.get_children():
#				if child2.get_class() == "TabBar":
#					tabbar = child2
	return tabbar

func return_to_AU3Engine():
	var editor := EditorPlugin.new()
	editor.get_editor_interface().set_main_screen_editor("AU3 Engine")


func get_open_scenes_in_editor() -> Dictionary:
	var tabbar :TabBar = get_editor_tabbar()
	var tabbar_dict :Dictionary = {}
	for tab in tabbar.get_tab_count():
		tabbar_dict[tab] = tabbar.get_tab_title(tab)
	return tabbar_dict
	

func delete_starting_position_from_old_map(previous_selection, node_name:String = "StartingPositionNode" ):
	editor = EditorPlugin.new().get_editor_interface()
	var maps_dict = import_data(table_save_path + "Maps" + file_format)
	var new_map_path
	for map_id in maps_dict:
		if str_to_var(maps_dict[map_id]["Display Name"])["text"] == previous_selection:
			new_map_path = maps_dict[map_id]["Path"]
			break
	if !new_map_path == null:
		var new_map_scene :Node = load(new_map_path).instantiate()
		new_map_scene.set_name(previous_selection)

		var start_pos_node :Sprite2D = new_map_scene.get_node(node_name)
		if start_pos_node != null:
			new_map_scene.remove_child(start_pos_node)
			start_pos_node.queue_free()
			
			var new_packed_scene = PackedScene.new()
			new_packed_scene.pack(new_map_scene)
			
			var dir :DirAccess = DirAccess.open(new_map_path.get_base_dir())
			#dir.open(new_map_path.get_base_dir())
			dir.remove(previous_selection)
			ResourceSaver.save(new_packed_scene, new_map_path)
		
		new_map_scene.queue_free()

		var open_scenes = editor.get_open_scenes()
		open_scene_in_editor(new_map_path)
		editor.save_scene()


