extends Control
class_name DatabaseEngine
tool


onready var input_singleLine = preload("res://addons/Database_Manager/Scenes and Scripts/UI_Input_Scenes/Input_Text.tscn")
onready var input_multiLine = preload("res://addons/Database_Manager/Scenes and Scripts/UI_Input_Scenes/Input_Text_Multiline.tscn")
onready var input_checkBox = preload("res://addons/Database_Manager/Scenes and Scripts/UI_Input_Scenes/Checkbox_Template.tscn")
onready var input_intNumberCounter = preload("res://addons/Database_Manager/Scenes and Scripts/UI_Input_Scenes/Number_Counter.tscn")
onready var input_floatNumberCounter = preload("res://addons/Database_Manager/Scenes and Scripts/UI_Input_Scenes/Number_Counter_Float.tscn")
onready var input_dropDownMenu = preload("res://addons/Database_Manager/Scenes and Scripts/UI_Input_Scenes/DropDown_Template.tscn")
onready var input_iconDisplay = preload("res://addons/Database_Manager/Scenes and Scripts/UI_Input_Scenes/Icon_Template.tscn")
onready var input_keySelection = preload("res://addons/Database_Manager/Scenes and Scripts/UI_Input_Scenes/KeySelect_Template.tscn")
onready var input_spriteDisplay = preload("res://addons/Database_Manager/Scenes and Scripts/UI_Input_Scenes/Sprite_Template.tscn")
onready var input_vector = preload("res://addons/Database_Manager/Scenes and Scripts/UI_Input_Scenes/Input_Vector.tscn")
onready var input_dictionary = preload("res://addons/Database_Manager/Scenes and Scripts/UI_Input_Scenes/Input_Dictionary.tscn")
onready var input_scenePath = preload("res://addons/Database_Manager/Scenes and Scripts/UI_Input_Scenes/ScenePath_Template.tscn")
onready var input_minmax = preload("res://addons/Database_Manager/Scenes and Scripts/UI_Input_Scenes/Input_MinMax.tscn")
onready var input_sfx = preload("res://addons/Database_Manager/Scenes and Scripts/UI_Input_Scenes/Input_sfx.tscn")

#var dbmanData_save_path : String = "res://addons/Database_Manager/Data/"
var op_sys : String = ""
var save_format = ".sav"
var table_save_path = "res://Data/"
var file_format = ".json"
var table_info_file_format = "_data.json"
var icon_folder = "png/"
var sfx_folder =  "sfx/"
var currentData_dict = {}
var current_dict = {} #Currently selected table values Dictionary
var save_game_path = "user://"
var data_type : String
var current_table_name = ""
var current_table_ref = ""
var table_ref = ""
var Item_Name = ""

func refresh_editor():
	var editorNew = EditorPlugin.new()
	editorNew.get_editor_interface().get_resource_filesystem().scan()

func update_dictionaries():
	#replaces dictionary data with data from saved files
	currentData_dict = import_data(table_save_path + current_table_name + table_info_file_format) 
	current_dict = import_data(table_save_path + current_table_name + file_format)

func get_data_index(value):
	var index
	for i in currentData_dict[data_type]:
		var fieldName = currentData_dict[data_type][i]["FieldName"]
		if fieldName == value:
			index = i
			break
	return index


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


func save_all_db_files(table_name):
	save_file(table_save_path + table_name + file_format, current_dict)
	save_file(table_save_path + table_name + table_info_file_format, currentData_dict)
	update_project_settings()

func update_project_settings(): #called when save_all_db_files is run
	set_game_root()

func set_game_root():
	var root_path = import_data(table_save_path + "Global Data" + file_format)["Global Data"]['Project Root Scene']
	var current_root_scene = ProjectSettings.get("application/run/main_scene")
	if root_path != current_root_scene:
		ProjectSettings.set("application/run/main_scene", root_path) 


func add_new_table(newTableName, keyName, keyDatatype, keyVisible, fieldName, fieldDatatype, fieldVisible, dropdown, RefName, createTab, canDelete, isDropdown, add_toSaveFile):
	current_dict = {}
	currentData_dict["Row"] = {}
	currentData_dict["Column"] = {}
	current_table_name = newTableName
	if isDropdown:
		#THIS IS WHERE I WILL USE THE DROPDOWN TEMPLATE TO CREATE A NEW LIST STYLE TABLE (KEY IS NUMBER, ID, DISPLAY NAME)
		add_key("1", "TYPE_STRING", keyVisible, true, dropdown, true)
		add_field("ID", "TYPE_STRING", fieldVisible, true,  dropdown, true)
		add_field("Display Name", "TYPE_STRING", fieldVisible, true,  dropdown)
		current_dict["1"]["ID"] = keyName
		current_dict["1"]["Display Name"] = keyName

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
	else:
		current_dict[newTableName]["Reference Name"] = RefName

	current_dict[newTableName]["Reference Name"] = RefName
	current_dict[newTableName]["Create Tab"] = createTab
	current_dict[newTableName]["Is Dropdown Table"] = isDropdown
	current_dict[newTableName]["Include in Save File"] = add_toSaveFile
	current_dict[newTableName]["Can Delete"] = true
	save_all_db_files(current_table_name)



func Delete_Table(delete_tbl_name):
	
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
	current_table_name = ""



func Delete_Key(key_name):
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
		var new_key_data = current_dict[current_dict.keys()[0]].duplicate(true)
#		print(keyName)
		current_dict[keyName] = new_key_data  #CHANGE THIS TO DEFAULT VALUE FOR DATATYPE #Set new key values based on the default (first line of table)


#func get_default_value():
#	var datatype_dictionary : Dictionary = parent_node.import_data(parent_node.table_save_path + "DataTypes" + parent_node.file_format)
#	for i in datatype_dictionary:
#		if datatype_dictionary[i]["Display Name"] == type:
#			return  datatype_dictionary[i]["Default Values"]
#			print(type, " ", default)
#			break

func get_default_value(itemType):
	var data_default_dict :Dictionary = import_data(table_save_path + "DataTypes" + file_format)
	var item_value
	for j in data_default_dict:
		if data_default_dict[j]["ID"] == itemType:
			var default_value =  data_default_dict[j]["Default Values"]
			item_value = default_value #default value
			break
	return item_value

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
#	print(newTable)
	if newTable:
		for i in current_dict:
			current_dict[i] = {fieldName : get_default_value(datatype)}
	
	else:
		for n in current_dict: #loop through all keys and set value for this file to "empty"
			current_dict[n][fieldName] = get_default_value(datatype) #CHANGE THIS TO DEFAULT VALUE FOR DATATYPE
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
	
#	print(final_dict)
			
	
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
			TYPE_DICTIONARY:
				found_match = true
			TYPE_ARRAY:
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
				variant = convert_string_to_Vector(str(variant))
			"TYPE_VECTOR3":
				variant = convert_string_to_Vector(variant)
			"TYPE_DICTIONARY":
				variant = string_to_dictionary(str(variant))
			"TYPE_ARRAY":
				variant = string_to_array(str(variant))
#				print(variant)
	return variant

func string_to_array(value: String):
#	value = value.replace("[", "")
#	value = value.replace("]", "")
#	var value_array = value.split(",")
	var value_array = str2var(value)
	return value_array
	
	
	
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


func get_file_name(name : String, filetype : String):
	name = name.trim_suffix(filetype)
	return name

func set_var_type_dict(dict : Dictionary):
	var o
	for l in dict:
		for m in dict[l]:
			for n in dict[l][m]:
				o = str(dict[l][m][n])
				o = str2var(o)
				if typeof(o) == TYPE_STRING:
					o = to_bool(o)
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
			o = str2var(o)
			if typeof(o) == TYPE_STRING:
				o = to_bool(o)

			match typeof(o):
				TYPE_BOOL:
					dict[l][m] = o
				TYPE_INT:
					dict[l][m] = o
				TYPE_STRING:
					pass
				TYPE_NIL:
					pass


func string_to_dictionary(value : String):
#	print(value)
#	print(typeof(value))

#	print(str2var(value))
#	print(typeof(str2var(value)))
	var dict_value : Dictionary = {}
#	if typeof(str2var(value)) == 4:
#		print(value)
#		var dict = "{"+ value + "}"
#		dict = str2var(dict)
##		print(dict.result)
##		var dict_temp = to_json(dict.result)
#		dict_value = dict
##		print(dict_value)
#	else:
#	print(value)
	dict_value = str2var(value)
#		print(dict_value)
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
##			print(dict_value)
#		else:
#			dict2 = value.split(":")
#			dict3 = convert_string_to_type(dict2[1])
#			dict_value = {key:dict3}
##			print(dict_value)
#
#	else:
#		var split = value.split("{")
#		var value2 = split[1]
#		value2 = split[1].trim_prefix("{")
#		value2 = split[1].trim_prefix(" ")
#		value2 = split[1].trim_suffix("}")
#		value2 = convert_string_to_type(value2, "TYPE_DICTIONARY")
#		dict_value[key] = value2[value2.keys()[0]]
#	print(dict_value)
	return dict_value


func add_input_field(par: Node, nodeName):
	var new_node = nodeName.instance()
	par.add_child(new_node)
	return new_node

func add_input_node(index, index_half, i, dict, container1, container2 = null, node_value = "", node_type = "", tableName = ""):
	var parent_container = container1
	if container2 != null:
		if index_half < index:
			parent_container = container2
	if str(node_value) == "":
		node_value =  convert_string_to_type(dict[i]["Value"], dict[i]["DataType"])
	if str(node_type) == "":
		node_type = dict[i]["DataType"]
	var new_field : Node

	match node_type: #Match variant type and then determine which input field to use (check box, long text, short text, number count etc)
		"TYPE_BOOL": #Bool
			new_field = add_input_field(parent_container, input_checkBox)
			if str(node_value) == "Default":
				node_value = new_field.default
			new_field.inputNode.set_pressed(node_value)
			#REPLACE WITH new_field.set_input_data()

		"TYPE_INT": #INT
			new_field = add_input_field(parent_container, input_intNumberCounter)
			if str(node_value) == "Default":
				node_value = new_field.default
			new_field.inputNode.set_text(str(node_value))

		"TYPE_REAL": #Float
			new_field = add_input_field(parent_container, input_floatNumberCounter)
			if str(node_value) == "Default":
				node_value = new_field.default
			new_field.inputNode.set_text(str(node_value))

		"TYPE_STRING": #String
			if node_value.length() <= 45:
				new_field  = add_input_field(parent_container, input_singleLine)
				if str(node_value) == "Default":
					node_value = new_field.default
				new_field.inputNode.set_text(node_value)
			else:
				new_field  = add_input_field(parent_container, input_multiLine)
				if str(node_value) == "Default":
					node_value = new_field.default
				new_field.inputNode.set_text(node_value)

		"TYPE_DROPDOWN":
			new_field = add_input_field(parent_container, input_dropDownMenu)
			if tableName == "":
				new_field.selection_table_name = dict[i]["TableRef"]
			else:
				new_field.selection_table_name = tableName
			new_field.labelNode.set_text(i)
			new_field.populate_list()
			if str(node_value) == "Default":
				node_value = new_field.default
			var type_id = new_field.get_id(str(node_value))
			new_field.inputNode.select(type_id)
			var itemSelected = new_field._on_Input_item_selected(type_id)

		"TYPE_ICON":
			new_field = add_input_field(parent_container, input_iconDisplay)
			if str(node_value) == "Default":
				node_value = new_field.default
			var texture_path = node_value
			if texture_path == "empty":
				texture_path = new_field.default
			new_field.inputNode.set_normal_texture(load(str(table_save_path + icon_folder + texture_path)))

		"TYPE_KEYSELECT":
			new_field = add_input_field(parent_container, input_keySelection)
			if str(node_value) == "Default":
				node_value = new_field.default
			var key = OS.get_scancode_string(int(node_value))
			new_field.inputNode.set_text(key)
			new_field.inputNode.get_node("Keycode").set_text(str(node_value))

		'TYPE_SPRITEDISPLAY':
			new_field = add_input_field(parent_container, input_spriteDisplay)
			var sprite_data :Array = []
			if str(node_value) == "Default":
				node_value = new_field.default[0]
				sprite_data = new_field.default
			var texture_path = node_value
			var frameVector : Vector2
			if sprite_data == []:
				if typeof(texture_path) == 4:
					texture_path = str2var(texture_path)
				sprite_data = texture_path
			frameVector = convert_string_to_type(sprite_data[1], "TYPE_VECTOR2")
			var sprite_path = table_save_path + icon_folder + sprite_data[0]
			new_field.get_node("HBox1/VBox1/VBox1/VInput").set_text(str(frameVector.x))
			new_field.get_node("HBox1/VBox1/VBox1/HInput").set_text(str(frameVector.y))
			new_field.inputNode.set_normal_texture(load(str(sprite_path)))
			new_field.input_data = sprite_data

		"TYPE_VECTOR": 
			new_field = add_input_field(parent_container, input_vector)
			if str(node_value) == "Default":
				node_value = str(new_field.default)
			new_field.inputNode.set_text(node_value)
			new_field.set_user_input_value()

		"TYPE_MINMAX": 
			new_field = add_input_field(parent_container, input_minmax)
			if str(node_value) == "Default":
				node_value = str(new_field.default)
			new_field.inputNode.set_text(node_value)
			new_field.set_user_input_value()

		"TYPE_DICTIONARY":
			new_field = add_input_field(parent_container, input_dictionary)
			if str(node_value) == "Default":
				node_value = convert_string_to_type(new_field.default)
			if typeof(node_value) == TYPE_STRING:
				node_value = str2var(node_value)
			new_field.main_dictionary = node_value
			new_field.inputNode.set_text(str(node_value))

		"TYPE_SCENE":
			new_field  = add_input_field(parent_container, input_scenePath)
			if str(node_value) == "Default":
				node_value = new_field.default
			new_field.inputNode.set_text(node_value)
		
		"TYPE_SFX":
			new_field  = add_input_field(parent_container, input_sfx)
			if str(node_value) == "Default":
				node_value = new_field.default
			if typeof(node_value) == TYPE_STRING:
				node_value = str2var(node_value)
			var stream = table_save_path + sfx_folder + node_value[0]
			var volume = float(node_value[1])
			var pitch = float(node_value[2])
			
			new_field.inputNode.set_stream(load(stream))
			new_field.inputNode.set_volume_db(volume)
			new_field.inputNode.set_pitch_scale(pitch)
			
			new_field.sfx_name.set_text(stream.get_file())
			new_field.volumne_slider.set_value(volume)
			new_field.pitch_slider.set_value(pitch)


#			print(stream, " ", volume, " ", pitch)


	new_field.set_name(i)
	new_field.labelNode.set_text(i)
	new_field.table_name = current_table_name
	new_field.table_ref = table_ref

	return new_field


func update_match(current_node, i = ""):
	var input_type = current_node.type
	var input = current_node.inputNode
	var returnValue
	match input_type:
		"TYPE_STRING":
			if i == "Key":
				update_item_name(Item_Name, input.text)
			else:
				returnValue = input.text
				
		"TYPE_DROPDOWN":
			returnValue = current_node.selectedItemName
			
		"TYPE_INT":
			returnValue = input.text
		
		"TYPE_REAL":
			returnValue = input.text
			
		"Multiline Text":
			returnValue = input.text
			
		"TYPE_BOOL":
				returnValue = input.pressed
			
		"TYPE_ICON":
			var filename = input.get_normal_texture().get_path().get_file()
			returnValue = filename
			
		'TYPE_SPRITEDISPLAY':
			var vframe = current_node.get_node("HBox1/VBox1/VBox1/VInput").get_text()
			var hframe = current_node.get_node("HBox1/VBox1/VBox1/HInput").get_text()
			var frames = Vector2(vframe,hframe)
			var sprite_data : Array = [input.get_normal_texture().get_path().get_file() , str(frames)]
			returnValue = var2str(sprite_data)
			
		"TYPE_VECTOR":
			returnValue = input.text

		"TYPE_MINMAX":
			returnValue = input.text
			
		"TYPE_DICTIONARY":
			returnValue = var2str(current_node.main_dictionary)

		"TYPE_SCENE":
			returnValue = input.text
		
		"TYPE_SFX":
			var stream : String = input.get_stream().get_path().get_file()
			var volume : String = str(input.get_volume_db())
			var pitch : String = str(input.get_pitch_scale())
			var sfx_array := [stream, volume, pitch]
			returnValue = var2str(sfx_array)

		"TYPE_KEYSELECT":
			returnValue = input.get_node("Keycode").text
#			var key = OS.get_scancode_string(int(node_value))
#			new_field.inputNode.set_text(key)


	if i != "" and i != "Key":
		current_dict[Item_Name][i] = returnValue
		
	return returnValue

func update_item_name(old_name : String, new_name : String = ""):
	if old_name != new_name: #if changes are made to item name
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

#			reload_buttons()
#			refresh_data(new_name)
		else:
			print("Duplicate key exists in table DATA WAS NOT UPDATED")

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
#	var sprite_texture_info = udsmain.Static_Game_Dict['Characters'][character_name][sprite_field_name]
#	var character_sprite_array : Array
	var character_animated_sprite : AnimatedSprite = AnimatedSprite.new()
#	var spriteFrame = SpriteFrames.new()
#	character_animated_sprite.name = sprite_field_name
#	if character_sprite_array != sprite_texture_info:
##		print(characterSprite, " ", sprite_field_name)
#		character_sprite_array = udsmain.Static_Game_Dict['Characters'][character_name][sprite_field_name] #udsmain.Static_Game_Dict['Characters'][activeCharacterName]['Walk Sprite']
#		var frameVector : Vector2 = udsmain.convert_string_to_Vector(character_sprite_array[1])
#		var spriteMap = load(character_sprite_array[0])
#
#			#SET COLLISION SHAPE = TO SPRITE SIZE
#		var sprite_size = Vector2(spriteMap.get_size().x/frameVector.y,spriteMap.get_size().y/frameVector.x)
#
#
#		#CREATE ANIMATION BASED ON THE NUMBER OF FRAMES
#		var total_frames = frameVector.x * frameVector.y
#		if spriteFrame.has_animation(sprite_field_name):
#			spriteFrame.clear(sprite_field_name)
#		spriteFrame.add_animation(sprite_field_name)
#
#		for i in range(0, total_frames):
#			character_animated_sprite.set_sprite_frames(spriteFrame)
#			var region_offset = sprite_size * i
#			var region := Rect2( region_offset.x ,  0, sprite_size.x , sprite_size.y)
#			var cropped_texture = get_cropped_texture(spriteMap, region)
#			spriteFrame.add_frame(sprite_field_name, cropped_texture , i)

	return character_animated_sprite


func add_animation_to_animatedSprite(sprite_field_name := "Idle Sprite", sprite_texture_data : Array = [], animated_sprite : AnimatedSprite = AnimatedSprite.new(), sprite_frames :SpriteFrames = SpriteFrames.new()):
#	var sprite_texture_info = udsmain.Static_Game_Dict['Characters'][character_name][sprite_field_name]
	var sprite_array : Array

	if sprite_frames == null:
		sprite_frames = SpriteFrames.new()
#	var spriteFrame = SpriteFrames.new()

#	if character_sprite_array != sprite_texture_data:
#		print(characterSprite, " ", sprite_field_name)
#	character_sprite_array = udsmain.Static_Game_Dict['Characters'][character_name][sprite_field_name] #udsmain.Static_Game_Dict['Characters'][activeCharacterName]['Walk Sprite']
	var frameVector : Vector2 = convert_string_to_Vector(sprite_texture_data[1])
	var spriteMap = load(table_save_path + icon_folder + sprite_texture_data[0])

		#SET COLLISION SHAPE = TO SPRITE SIZE
	var sprite_size = Vector2(spriteMap.get_size().x/frameVector.y,spriteMap.get_size().y/frameVector.x)

	#CREATE ANIMATION BASED ON THE NUMBER OF FRAMES
	var total_frames = frameVector.x * frameVector.y

	if sprite_frames.has_animation(sprite_field_name):
		sprite_frames.clear(sprite_field_name)
	sprite_frames.add_animation(sprite_field_name)
	
	
	var v_count = 0
	var h_count = 0
	var frame_count = 1
	for i in range(0, total_frames):
		animated_sprite.set_sprite_frames(sprite_frames)
		
		var region_offset = Vector2(sprite_size.x * h_count, (sprite_size.y * v_count))
#		print(i, " ", sprite_size, " ", region_offset)
		var region := Rect2( region_offset ,  Vector2(sprite_size.x , sprite_size.y))
		var cropped_texture = get_cropped_texture(spriteMap, region)
		sprite_frames.add_frame(sprite_field_name, cropped_texture , i)
#		print(frame_count, ' ', v_count, " ", h_count)

#		print(frame_count, " ", h_count, " " , v_count, " ", region_offset)
		frame_count += 1
		h_count += 1

		if h_count == frameVector.y:
			h_count = 0
			v_count += 1


	return sprite_field_name


func get_cropped_texture(texture : Texture, region : Rect2) -> AtlasTexture:
	var atlas_texture = AtlasTexture.new()
	atlas_texture.set_atlas(texture)
	atlas_texture.set_region(region)
	return atlas_texture

