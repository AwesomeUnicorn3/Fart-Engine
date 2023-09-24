@tool
class_name DatabaseManager extends Control

signal Editor_Refresh_Complete
signal get_datatype_complete
signal import_complete
signal save_file_complete
signal table_save_complete


#Static var

#Dictionaries
static var settings_dict :Dictionary = {}
static var global_data_dict :Dictionary = {}
static var do_not_delete_dict: Dictionary = {}
static var button_dict :Dictionary = {}
static var display_form_dict :Dictionary = {}
static var category_settings_dict: Dictionary = {}
static var all_events_dict: Dictionary = {}


static var selected_tab_name :String= ""
static var selected_category :String = "Game Settings"
static var is_uds_main_updating: bool = false
static var is_editor_saving:bool = false
static var fart_root : Node
static var op_sys : String = ""


static var global_settings_profile :String = ""

static var starting_position_node:Sprite2D
#NEED TO SET THESE WHEN DATABASE IS LOADED FROM PROJECT SETTINGS TABLE
var save_format = ".sav"
var table_save_path = "res://fart_data/"
var table_file_format = ".json"
var table_info_file_format = "_data.json"
var save_game_path = "user://"
var icon_folder = "png/"
var sfx_folder =  "sfx/"
var event_folder = "events/"
#NEED TO SET THESE WHEN DATABASE IS LOADED FROM PROJECT SETTINGS TABLE


#NEED TO REMOVE THIS VARIABLE AND ONLY USE IN THE TAB TEMPLATE


#NEED TO REMOVE THIS VARIABLE AND ONLY USE IN THE TAB TEMPLATE



####used to rearrange keys #LIKELY NEEDS TO BE MOVED TO TAB TEMPLATE
var button_focus_index :String = "" 
var button_movement_active := false
var button_selected :String = ""
####used to rearrange keys #LIKELY NEEDS TO BE MOVED TO TAB TEMPLATE




func _init():
	update_all_event_list()


func update_all_event_list(update_data :bool = false): #POSSIBLY NEED TO MOVE TO EVENT MANAGER
	if update_data or all_events_dict == {}:
		all_events_dict = get_list_of_events()
		print(all_events_dict)


func get_global_settings_profile(is_temp:bool = false) -> String: #CONFIG FILE
	if !Engine.is_editor_hint() and !is_temp:
#		var project_root = FART
		if global_settings_profile == "":
			set_global_settings_profile()

#			if settings_dict == {}:
#				settings_dict = import_data("Project Settings")
#			if global_data_dict == {}:
#				global_data_dict = import_data("Global Data")
#			var profile_index :String = settings_dict["1"]["Game Profile"]
#			global_settings_profile = profile_index
			await get_tree().create_timer(0.1)
		return global_settings_profile
	else:
		var settings_dict = import_data("Project Settings")
		var profile_index :String = settings_dict["1"]["Game Profile"]
		return profile_index

func set_global_settings_profile():
	if settings_dict == {}:
		settings_dict = await import_data("Project Settings")
	if global_data_dict == {}:
		global_data_dict = await import_data("Global Data")
	var profile_index :String = settings_dict["1"]["Game Profile"]
	global_settings_profile = profile_index
	return global_settings_profile
#func update_dictionaries():
#	#replaces dictionary data with data from saved files
#	currentData_dict = import_data(current_table_name, true) 
#	current_dict = import_data(current_table_name)
#
#
#func get_data_index(value: String, dataType := data_type, data_dict :Dictionary = currentData_dict):
#	var index = ""
#	for i in data_dict[dataType]:
#		var fieldName = data_dict[dataType][i]["FieldName"]
#		if fieldName == value:
#			index = i
#			break
#	return index
#
#
#func get_table_keys():
#	return current_dict.keys()




func get_id_from_display_name(table_dictionary :Dictionary, display_name :String):
	var index :String
	var id_display_name :String 
	for id in table_dictionary:
		if table_dictionary[id].has("Display Name"):
			id_display_name = get_text(table_dictionary[id]["Display Name"])
			if id_display_name == display_name:
				index = id
				break
	return index


#func get_table_values():
#	var return_dict = {}
#	#pulls table values in custom order
#	for i in currentData_dict[data_type].size():
#		var order_value = str(i + 1)
#		var value = currentData_dict[data_type][order_value]
#		return_dict[value] = order_value
#	return return_dict


func list_files_with_param(dirPath, file_type, ignore_table_array : Array = [], array_exclude_begins_with : Array = ["."]):
	var array_load_files = []
	var files = []
	var dir :DirAccess = DirAccess.open(dirPath)
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


func load_save_file(table_name :String):
	var json_object : JSON = JSON.new()
	var curr_tbl_data : Dictionary = {}
	var file_extension: String = table_file_format
	var table_path :String = save_game_path + table_name
	var currdata_dir :FileAccess = FileAccess.open(table_path,FileAccess.READ_WRITE)
	if currdata_dir == null :
		pass
#		print("Error Could not open file at: " + table_path)
	else:
		var currdata_json = json_object.parse(currdata_dir.get_as_text())
		curr_tbl_data = json_object.get_data()
	return curr_tbl_data




func get_list_of_events(for_dropdown:bool = false) -> Dictionary:
	var return_dict:Dictionary = {}
	var event_array :Array = list_files_with_param(table_save_path + event_folder,table_file_format)
	var index:= 1
	var return_value

	for eventPath in event_array:
		var name_array:Array = eventPath.rsplit(".")
		var eventID: String = name_array[0]
		var curr_event_dict:Dictionary = import_event_data(eventID)
		var eventName:String = get_text(curr_event_dict["0"]["Display Name"])

		if for_dropdown:
			return_dict[str(index)] = [eventName, eventID,  "0"]
			index += 1
			return_value = return_dict
		else:
			print("Event ID: ", eventID)
			return_dict[eventID] = curr_event_dict


	return return_dict




func import_event_data(event_name:String, get_event_data:bool = false):
	var json_object : JSON = JSON.new()
	var curr_event_data : Dictionary = {}
	var file_extension: String = table_file_format
	if get_event_data:
		file_extension =  table_info_file_format
	var table_path :String = table_save_path + event_folder + event_name + file_extension
	var currdata_dir :FileAccess = FileAccess.open(table_path,FileAccess.READ_WRITE)
	if currdata_dir == null :
		pass
#		print("Error Could not open file at: " + table_path)
	else:
		var currdata_json = json_object.parse(currdata_dir.get_as_text())
		curr_event_data = json_object.get_data()
	emit_signal("import_complete")
	return curr_event_data


func import_data(table_name : String, get_table_data :bool = false):
	var json_object : JSON = JSON.new()
	var curr_tbl_data : Dictionary = {}
	var file_extension: String = table_file_format
	if get_table_data:
		file_extension = table_info_file_format
	var table_path :String = table_save_path + table_name + file_extension
	var currdata_dir :FileAccess = FileAccess.open(table_path,FileAccess.READ_WRITE)
	if currdata_dir == null :
		print("Error Could not open file at: " + table_path)
	else:
		var currdata_json = json_object.parse(currdata_dir.get_as_text())
		curr_tbl_data = json_object.get_data()
	emit_signal("import_complete")
	return curr_tbl_data


func set_background_theme(background_node: ColorRect):
#	print("BUTTON THEME: ", group)
	#SET COLOR BASED ON GROUP
	#get project table
	var project_table: Dictionary = import_data("Project Settings")
	var fart_editor_themes_table: Dictionary = import_data("Fart Editor Themes")
	
	var theme_profile: String = project_table["1"]["Fart Editor Theme"]
	var category_color: Color = str_to_var(fart_editor_themes_table[theme_profile]["Background"])
	background_node.set_base_color(category_color)



func save_file(sv_path, tbl_data:Dictionary):
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
#		print("save completed successfully")
		#print(tbl_data)
		#save_file.close()
	save_file_complete.emit()
#	emit_signal("save_file_complete")


func list_keys_in_display_order(table_name:String):
	var table_dict:Dictionary = import_data(table_name)
	var data_dict:Dictionary = import_data(table_name, true)
	var sorted_dict: Dictionary = {}

	for keyID in data_dict["Row"].size():
		var item_number = str(keyID + 1) #row_dict key
		var displayName :String = ""
		var datatype :String = data_dict["Row"][item_number]["DataType"]
		var key_name :String = data_dict["Row"][item_number]["FieldName"] #Use the row_dict key (item_number) to set the button label as the item name
		var key_dict :Dictionary = table_dict[key_name]
		if key_dict.has("Display Name"):
			displayName = get_text(table_dict[key_name]["Display Name"])
		sorted_dict[item_number] = [displayName, key_name, datatype]
	return sorted_dict


func list_custom_dict_keys_in_display_order(table_dict:Dictionary, table_name:String):
#	print("TABLE NAME FOR LIST CUSTOM DICT IN DISPLAY ORDER: ", table_name)
	var data_dict:Dictionary = import_data(table_name, true)
	
	var sorted_dict: Dictionary = {}
	var index := 1
	for keyID in data_dict["Row"].size():

		var item_number = str(keyID + 1) #row_dict key
		var displayName :String = ""
		var datatype :String = data_dict["Row"][item_number]["DataType"]
		var key_name :String = data_dict["Row"][item_number]["FieldName"] #Use the row_dict key (item_number) to set the button label as the item name
#		print(table_dict)
		if table_dict.has(key_name):
			
			var key_dict :Dictionary = table_dict[key_name]
#			print("KEY DICT: ", key_dict)
			if key_dict.has("Display Name"):
#
#				print("HAS DISPLAY NAME")
#				print(table_dict)
				displayName = get_text(table_dict[key_name]["Display Name"])
#				print(displayName)
			else:
#				print("NO DISPLAY NAME")
				displayName = key_name
			sorted_dict[str(index)] = [displayName, key_name, datatype]
			index += 1
	return sorted_dict


func list_values_in_display_order(table_name:String):
	var table_dict:Dictionary = import_data(table_name)
	var data_dict:Dictionary = import_data(table_name, true)
	var sorted_dict: Dictionary = {}

	for keyID in data_dict["Column"].size():
		var item_number = str(keyID + 1)
		var label :String = data_dict["Column"][item_number]["FieldName"] #Use the row_dict key (item_number) to set the button label as the item name
		sorted_dict[item_number] = label
		#print(sorted_dict)
	return sorted_dict


#func save_all_db_files(table_name :String = current_table_name):
#	save_file(table_save_path + table_name + table_file_format, current_dict)
#	save_file(table_save_path + table_name + table_info_file_format, currentData_dict)
#	update_project_settings()


func update_project_settings(): #called when save_all_db_files is run
	set_target_screen_size()
	set_game_root()


func set_target_screen_size():
	var project_settings_dict: Dictionary = import_data("Project Settings")
	var target_screen_size_x: int = convert_string_to_type(project_settings_dict["1"]["Target Screen Size"],"9").x
	var target_screen_size_y: int = convert_string_to_type(project_settings_dict["1"]["Target Screen Size"],"9").y

	
	var current_screen_size_x = ProjectSettings.get("display/window/size/viewport_width")
	var current_screen_size_y = ProjectSettings.get("display/window/size/viewport_height")
	
	if target_screen_size_x != current_screen_size_x:
		ProjectSettings.set("display/window/size/viewport_width", target_screen_size_x) 
		ProjectSettings.set("display/window/size/viewport_height", target_screen_size_y) 

func set_game_root():
	var settings_profile :String = await get_global_settings_profile()
	var root_ID : String = import_data("Global Data")[settings_profile]["Project Root Scene"]
	var root_path = import_data("UI Scenes")[root_ID]["Path"]
	var current_root_scene = ProjectSettings.get("application/run/main_scene")
	if root_path != current_root_scene:
		ProjectSettings.set("application/run/main_scene", root_path) 


func get_default_dialog_scene_path() ->String:
	var root_ID : String = import_data("Global Data")[await get_global_settings_profile()]['Default Dialog Box']
	var scene_path :String = import_data("UI Scenes")[root_ID]["Path"]

	return scene_path


func set_root_node():
	var root_ID : String = import_data("Global Data")[await get_global_settings_profile()]["Project Root Scene"]
	var root_path = import_data("UI Scenes")[root_ID]["Path"]
	var root_scene = load(root_path).instantiate()
	var root_node_name :String = root_scene.get_node(".").name
	await get_tree().create_timer(0.1).timeout
	fart_root = get_tree().get_root().get_node(root_node_name)
	root_scene.call_deferred("queue_free")


func get_root_node():
	return fart_root


#func add_new_table(newTableName, keyName, keyDatatype, keyVisible, fieldName, fieldDatatype, fieldVisible, dropdown, RefName, createTab, canDelete, isDropdown, add_toSaveFile, is_event):
#	current_dict = {}
#	currentData_dict["Row"] = {}
#	currentData_dict["Column"] = {}
#	current_table_name = newTableName
#	if isDropdown:
#		#THIS IS WHERE I WILL USE THE DROPDOWN TEMPLATE TO CREATE A NEW LIST STYLE TABLE (KEY IS NUMBER, ID, DISPLAY NAME)
#		add_key("1", "1", keyVisible, true, dropdown, true)
#		add_field("Display Name", "1", fieldVisible, true,  dropdown, true)
#		current_dict["1"]["Display Name"] = var_to_str({"text" : keyName})
#
#	else:
#		add_key(keyName, keyDatatype, keyVisible, true, dropdown, true)
#		add_field(fieldName, fieldDatatype, fieldVisible, true,  dropdown, true)
#	save_all_db_files(newTableName)
#
#	#save information about new table in the Table Data file
#	current_table_name = "Table Data"
#	data_type = "Row"
#	update_dictionaries()
#	add_key(newTableName, keyDatatype, keyVisible, true, dropdown)
#
#	#Input data for table list
#	if RefName == "":
#		RefName = newTableName
##	else:
##		current_dict[newTableName]["Display Name"] = RefName
#
#	current_dict[newTableName]["Display Name"] = var_to_str({"text" : RefName})
#	current_dict[newTableName]["Create Tab"] = createTab
#	current_dict[newTableName]["Show in Dropdown Lists"] = isDropdown
#	current_dict[newTableName]["Include in Save File"] = add_toSaveFile
#	current_dict[newTableName]["Can Delete"] = true
#	current_dict[newTableName]["Is Event"] = is_event
#	save_all_db_files(current_table_name)
#
#
#func create_new_table(newTableName:String, newTable_dict: Dictionary):
#	current_dict = {}
#	currentData_dict["Row"] = {}
#	currentData_dict["Column"] = {}
#	current_table_name = newTableName
#		#THIS IS WHERE I WILL USE THE DROPDOWN TEMPLATE TO CREATE A NEW LIST STYLE TABLE (KEY IS NUMBER, ID, DISPLAY NAME)
#	add_key("1", "1", true, true, true, true)
#	add_field("Display Name", "1", true, true,  true, true)
#	save_all_db_files(newTableName)
#	#save information about new table in the Table Data file
#	current_table_name = "Table Data"
#	data_type = "Row"
#	update_dictionaries()
#	add_key(newTableName, "1", true, true, true)
#	current_dict[newTableName] = newTable_dict
#	save_all_db_files(current_table_name)
#
#
#func delete_event(delete_tbl_name):
#	#First delete table reference from "Table Data" file and delete the entry in the table_data main table
#	current_table_name = "Table Data"
#	data_type = "Row"
#	update_dictionaries()
#	Delete_Key(delete_tbl_name)
#	save_all_db_files(current_table_name)
##	print("Table Path: ", table_save_path + event_folder + delete_tbl_name + table_file_format)
#	#Then delete all of the files associated with the delted table
#	var dir :DirAccess = DirAccess.open(table_save_path)
#	var file_delete = table_save_path + event_folder + delete_tbl_name + table_file_format
#	dir.remove(file_delete)
#	file_delete = table_save_path + event_folder + delete_tbl_name + table_info_file_format
#	dir.remove(file_delete)
#	#current_table_name = ""

#func delete_table(delete_tbl_name):
#	###NEED TO CHECK IF TABLE CAN BE DELETED####
#
#	#First delete table reference from "Table Data" file and delete the entry in the table_data main table
#	current_table_name = "Table Data"
#	data_type = "Row"
#	update_dictionaries()
#	Delete_Key(delete_tbl_name)
#	save_all_db_files(current_table_name)
##	print("Table Path: ", table_save_path  + delete_tbl_name + table_file_format)
#	#Then delete all of the files associated with the delted table
#	var dir :DirAccess = DirAccess.open(table_save_path)
#	var file_delete = table_save_path + delete_tbl_name + table_file_format
#	dir.remove(file_delete)
#	file_delete = table_save_path + delete_tbl_name + table_info_file_format
#	dir.remove(file_delete)
#	#current_table_name = ""


#func delete_field(field_name, selectedDict:Dictionary = current_dict, selectedDataDict:Dictionary = currentData_dict):
##	print("DELETE field NAME: ", field_name)
#	var tmp_dict = {}
#	var main_tbl = {}
#	data_type = "Column"
#	for i in selectedDict: #loop trhough main dictionary
#		selectedDict[i].erase(field_name)
#
#	tmp_dict = selectedDataDict[data_type].duplicate(true)
#	#loop through row_dict to find item
#	for i in tmp_dict:
#		if selectedDataDict[data_type][i]["FieldName"] == field_name:
#			selectedDataDict[data_type].erase(i) #Erase entry
##			print("BREAK1")
#			break
#	#Loop through number 0 to row_dict size
#	for j in tmp_dict.size() - 1:
#		j += 1
#		if !selectedDataDict[data_type].has(str(j)): #If the row_dict does not have j key
#			var next_entry_value = selectedDataDict[data_type][str(j + 1)] #Get value of next entry #If ever more values are added to row table, .duplicate(true) needs to be added to this line
#			selectedDataDict[data_type][str(j)] = next_entry_value #create new entry with current index and next entry
#			var next_entry = str(j + 1)
#			if selectedDataDict[data_type].has(next_entry):
#				selectedDataDict[data_type].erase(next_entry) #Delete next entry
#			else:
##				print("BREAK2")
#				break
##	print("delete key complete")
#	return [selectedDict, selectedDataDict]
#
#
#func Delete_Key(key_name, selectedDict:Dictionary = current_dict, selectedDataDict:Dictionary = currentData_dict):
##	print("DELETE KEY NAME: ", key_name)
#	var tmp_dict = {}
#	var main_tbl = {}
#	data_type = "Row"
#	match data_type:
#		"Row": #Deletes keys
#			selectedDict.erase(key_name) #Remove entry from current dict
#		"Column": #Deletes fields
#			for i in selectedDict: #loop trhough main dictionary
#				selectedDict[i].erase(key_name)
#
#	tmp_dict = selectedDataDict[data_type].duplicate(true)
#	#loop through row_dict to find item
#	for i in tmp_dict:
#		if selectedDataDict[data_type][i]["FieldName"] == key_name:
#			selectedDataDict[data_type].erase(i) #Erase entry
##			print("BREAK1")
#			break
#	#Loop through number 0 to row_dict size
#	for j in tmp_dict.size() - 1:
#		j += 1
#		if !selectedDataDict[data_type].has(str(j)): #If the row_dict does not have j key
#			var next_entry_value = selectedDataDict[data_type][str(j + 1)] #Get value of next entry #If ever more values are added to row table, .duplicate(true) needs to be added to this line
#			selectedDataDict[data_type][str(j)] = next_entry_value #create new entry with current index and next entry
#			var next_entry = str(j + 1)
#			if selectedDataDict[data_type].has(next_entry):
#				selectedDataDict[data_type].erase(next_entry) #Delete next entry
#			else:
##				print("BREAK2")
#				break
##	print("delete key complete")
#	return [selectedDict, selectedDataDict]
#
#
#func add_key(keyName, datatype, showKey, requiredValue, dropdown,  newTable : bool = false, new_data := {}):
#	var index = currentData_dict["Row"].size() + 1
#	var CustomData_dict = import_data("Field_Pref_Values") 
#	var newOptions_dict = {}
#	var newValue
#	#create and save new table with values from input form
#	#Get custom key fields and add them to tableData dict
#	for i in CustomData_dict:
#		var currentKey_dict :Dictionary = str_to_var(CustomData_dict[i]["ItemID"])
#		var currentKey :String = get_text(currentKey_dict)
#		match currentKey:
#			"DataType":
#				newValue = datatype
#			"FieldName":
#				newValue = keyName
#			"RequiredValue":
#				newValue = requiredValue
#			"ShowValue":
#				newValue = showKey
#			"TableRef":
#				newValue = dropdown
#
#		newOptions_dict[currentKey] = newValue
#
#	currentData_dict["Row"][str(index)] =  newOptions_dict
#
#	if newTable:
#		current_dict[keyName] = "empty"
#
#	else:
#		var new_key_data = current_dict[current_dict.keys()[0]].duplicate(true)
#		if new_data != {}:
#			new_key_data = new_data
#		current_dict[keyName] = new_key_data  #CHANGE THIS TO DEFAULT VALUE FOR DATATYPE #Set new key values based on the default (first line of table)
#

#func add_event_key(keyName, datatype, showKey, requiredValue, dropdown,  newTable : bool = false, new_data := {}):
#	var index = currentData_dict["Row"].size() + 1
#	var CustomData_dict = import_data("Field_Pref_Values") 
#	var newOptions_dict = {}
#	var newValue
#	#create and save new table with values from input form
#	#Get custom key fields and add them to tableData dict
#	for i in CustomData_dict:
#		var currentKey_dict :Dictionary = str_to_var(CustomData_dict[i]["ItemID"])
#		var currentKey :String = get_text(currentKey_dict)
#		match currentKey:
#			"DataType":
#				newValue = datatype
#			"FieldName":
#				newValue = keyName
#			"RequiredValue":
#				newValue = requiredValue
#			"ShowValue":
#				newValue = showKey
#			"TableRef":
#				newValue = dropdown
#
#		newOptions_dict[currentKey] = newValue
#
#	currentData_dict["Row"][str(index)] =  newOptions_dict
#
#	if newTable:
#		current_dict[keyName] = "empty"
#
#	else:
#		var new_key_data = current_dict[current_dict.keys()[0]].duplicate(true)
#		if new_data != {}:
#			new_key_data = new_data
#		current_dict[keyName] = new_key_data  #CHANGE THIS TO DEFAULT VALUE FOR DATATYPE #Set new key values based on the default (first line of table)
#
#
#func get_default_value(itemType :String):
#	datatype_dict = import_data("DataTypes")
#	var item_value
#	for key in datatype_dict:
#		if key == itemType:
#			var default_dict :Dictionary =  str_to_var(datatype_dict[key]["Default Values"])
#			var default_value = get_text(default_dict)
#			item_value = convert_string_to_type(default_value)  #default value
#			if item_value == null:
#				item_value = default_value
#			break
#	return item_value
#
#
#func add_field(fieldName, datatype, showField, required_value, tblName = "empty", newTable : bool = false ):
#	#THIS IS WHERE I SHOULD LOOP THROUGH THE USER_PREF TABLE AND ADD THE VALUES TO THE COLUMN TABLE
#	var index = currentData_dict["Column"].size() + 1 #Set index as next number in the order
#
#		#Get custom value fields and add them to column_dict
#	var fieldCustomData_dict = await import_data("Field_Pref_Values") 
#	var newFeild_dict = {}
#	var newValue
#
#	for i in fieldCustomData_dict:
#		var currentKey_dict :Dictionary = str_to_var(fieldCustomData_dict[i]["ItemID"])
#		var currentKey :String = get_text(currentKey_dict)
#		match currentKey:
#			"DataType":
#				newValue = datatype
#			"FieldName":
#				newValue = fieldName
#			"RequiredValue":
#				newValue = required_value
#			"ShowValue":
#				newValue = showField
#			"TableRef":
#				newValue = tblName
#
#
#		newFeild_dict[currentKey] = newValue
#	currentData_dict["Column"][index] = newFeild_dict #Add new field to the column_dict
#
#	if newTable:
#		for i in current_dict:
#			var default_value = get_default_value(datatype)
#			current_dict[i] = {fieldName :default_value }
#	else:
#		for n in current_dict: #loop through all keys and set value for this file to "empty"
#			var default_value = get_default_value(datatype)
#
#			current_dict[n][fieldName] = default_value #CHANGE THIS TO DEFAULT VALUE FOR DATATYPE
#		save_all_db_files(current_table_name)
#		update_dictionaries()


func is_file_in_folder(path : String, file_name : String):
	var value = false
	var dir :bool = FileAccess.file_exists(path + file_name) #ClEAR WHEN DONE TESTING
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


#func add_line_to_currDataDict():
#	var this_dict = import_data(current_table_name, true)
#	for i in this_dict["Column"]:
#		var dict = currentData_dict["Column"][i]
#		if !dict.has("TableRef"):
#			currentData_dict["Column"][i]["TableRef"] = "empty"
#	for i in this_dict["Row"]:
#		var dict = currentData_dict["Row"][i]
#		if !dict.has("TableRef"):
#			currentData_dict["Row"][i]["TableRef"] = "empty"



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
			TYPE_VECTOR3:
				found_match = true
			TYPE_VECTOR2:
				found_match = true
			TYPE_DICTIONARY:
				found_match = true
			TYPE_ARRAY:
				found_match = true
			TYPE_STRING:
				found_match = true

#		if !found_match:
#			print("No Match found for ", variant)

	else:
		match datatype:
			"5":
				variant = str(variant)
			"4":
				variant = custom_to_bool(variant)
			"1":
				variant = string_to_dictionary(variant)
			"2":
				variant = str_to_var(str(variant))
			"3":
				variant = str_to_var(variant)

			"6":
				variant = str(variant)
				
			"9":
				variant = convert_string_to_vector(str(variant))
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
			"12":
				variant = convert_string_to_vector(variant)

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
	var x : float = 0.0
	var y : float = 0.0
	var z : float = 0.0
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
	var tables_dict = import_data("Table Data")
	var table_data = import_data("Table Data", true)
	var isTableDropdownList :bool = false
	for i in range(0, tables_dict.size()):
		var index :String = str(i + 1)
		var currTableName :String = table_data["Row"][index]["FieldName"]
		if currTableName == tableName:
			isTableDropdownList = convert_string_to_type(tables_dict[currTableName]["Show in Dropdown Lists"])
			break
	return isTableDropdownList

#
#func get_input_type_node(input_type :String):
##	print("INPUT TYPE: ", input_type)
#	var return_node : Object
#	datatype_dict = import_data("DataTypes")
#	return_node =  load(datatype_dict[input_type]["Default Scene"])
#	return return_node
#
#
#func get_input_type_id_from_name(input_type_name :String):
#	datatype_dict = import_data("DataTypes")
#	for key in datatype_dict:
#		var displayname_dict :Dictionary = str_to_var(datatype_dict[key]["Display Name"])
#		var key_name :String = get_text(displayname_dict)
##
#		if key_name == input_type_name:
#			return key


#func create_independant_input_node(table_name:String, key_ID:String, field_ID :String):
#	var table_dict: Dictionary = import_data(table_name)
#	var table_data_dict: Dictionary = import_data(table_name, true)
#	var datatype:String = get_datatype(field_ID,table_data_dict )
#	datatype_dict = import_data("DataTypes")
#	var input_node = load(datatype_dict[datatype]["Default Scene"]).instantiate()
##	input_node.set_input_value(input_node.default, key_ID, table_name)
#
#	if datatype == "5":#dropdown selection (itemtype selection)
#		input_node.selection_table_name = table_name
#
#	input_node.set_name(key_ID)
#
#	input_node.table_name = table_name
##	input_node.table_ref = table_ref
##	input_node.set_initial_show_value()
#
#	return input_node

#func add_input_node(index, index_half, key_name, table_dict := current_dict, container1 = null, container2 = null, node_value = "", node_type = "", tableName = ""):
#	#Set_Input_Node
#	var parent_container = container1
#	var did_datatype_change = false
#	if container2 != null:
#		if index_half < index:
#			parent_container = container2
#
#	if str(node_value) == "":
#		node_value =  convert_string_to_type(table_dict[key_name]["Value"], table_dict[key_name]["DataType"])
#
#	if str(node_type) == "":
#		node_type = table_dict[key_name]["DataType"]
#	var new_field : Node
#	datatype_dict = import_data("DataTypes")
#
#	match node_type:
#		"TYPE_BOOL": #Bool
#			node_type = "4"
#			did_datatype_change = true
#		"TYPE_INT": #INT
#			node_type = "2"
#			did_datatype_change = true
##		"TYPE_REAL": #Float
##			node_type = "3"
##			did_datatype_change = true
#		"TYPE_STRING": #String
#			node_type = "1"
#			did_datatype_change = true
#		"TYPE_DROPDOWN":
#			node_type = "5"
#			did_datatype_change = true
#		"TYPE_ICON":
#			node_type = "6"
#			did_datatype_change = true
#		"TYPE_KEYSELECT":
#			node_type = "11"
#			did_datatype_change = true
#		'TYPE_SPRITEDISPLAY':
#			node_type = "8"
#			did_datatype_change = true
#		"TYPE_VECTOR": 
#			node_type = "9"
#			did_datatype_change = true
#		"TYPE_MINMAX": 
#			node_type = "12"
#			did_datatype_change = true
#		"TYPE_DICTIONARY":
#			node_type = "10"
#			did_datatype_change = true
#		"TYPE_SCENE":
#			node_type = "7"
#			did_datatype_change = true
#		"TYPE_SFX":
#			node_type = "13"
#			did_datatype_change = true
#
#	if did_datatype_change:
#		for key in currentData_dict[data_type]:
#			if currentData_dict[data_type][key]["FieldName"] == key_name:
#				currentData_dict[data_type][key]["DataType"] = node_type
#
#	var input_node = load(datatype_dict[node_type]["Default Scene"])
#	new_field = await add_input_field(parent_container, input_node)
#	if str(node_value) == "Default":
#		node_value = new_field.default
#
#	if node_type == "5":#dropdown selection (itemtype selection)
#		if tableName == "":
#			new_field.selection_table_name = table_dict[key_name]["TableRef"]
#		else:
#			new_field.selection_table_name = tableName
#	new_field.set_input_value(node_value, key_name, current_table_name)
#	new_field.set_name(key_name)
#	new_field.labelNode.set_text(key_name)
#	new_field.table_name = current_table_name
#	new_field.table_ref = table_ref
#	new_field.set_initial_show_value()
#
#	return new_field


#func create_input_node(key_name:String, table_name:String, table_dict:Dictionary = {}, table_data_dict: Dictionary = {}):
#	var data_type:String
##	var node_input_value: Variant
#	if table_dict == {}:
#		table_dict = import_data(table_name)
#	if table_data_dict == {}:
#		table_data_dict = import_data(table_name, true)
#	data_type = get_datatype(key_name, table_data_dict)
##	print("DATATYPE: ", data_type)
##	print("TABLE DICT: ", table_dict)
#
#	var new_node = create_datatype_node(data_type)
#	new_node.set_name(key_name)
#
#	return new_node


#func create_datatype_node(datatype:String):
#	datatype_dict = import_data("DataTypes")
##	print("CREATE DATATYPE: ", datatype)
#	var input_node = load(datatype_dict[datatype]["Default Scene"]).instantiate()
#	var input_default_value = get_text(datatype_dict[datatype]["Default Values"])
#	return input_node


func get_datatype(field_ID:String, table_data_dict :Dictionary):
	var data_type: String = ""
#	print("TABLE DATA DICT: ", table_data_dict)
#	print("FIELD ID: ", field_ID)
	var data_dict_column :Dictionary
	if table_data_dict.has("Column"):
		data_dict_column = table_data_dict["Column"]
		for datakey in data_dict_column:
#			print("DATAKEY: ", datakey)
			var currFieldName:String = data_dict_column[datakey]["FieldName"]
			if currFieldName == field_ID:
				data_type = data_dict_column[datakey]["DataType"]
				break
#	if data_type == "":
##		print(table_data_dict)
#		print("NO DATATYPE FOUND FOR: ", field_ID)
#	print("GET DATATYPE RETURN VALUE: ", data_type)
	return data_type
	

func get_reference_table(tableID:String, keyID:String, fieldID:String):
	var data_type: String = ""
	var data_dict_column :Dictionary = import_data(tableID, true)["Column"]
	for datakey in data_dict_column:
		var currFieldName:String = data_dict_column[datakey]["FieldName"]
		if currFieldName == fieldID:
			data_type = data_dict_column[datakey]["TableRef"]
			break
	return data_type


#func get_value_from_input_node(current_node, field_name := "", key_name := Item_Name):
#	var input_type :String = current_node.type
#	var input = current_node.inputNode
#	var returnValue
#	var did_datatype_change = false
#
#	match input_type:
#		"TYPE_BOOL": #Bool
#			input_type = "4"
#			did_datatype_change = true
#		"TYPE_INT": #INT
#			input_type = "2"
#			did_datatype_change = true
##		"TYPE_REAL": #Float
##			input_type = "3"
##			did_datatype_change = true
#		"TYPE_STRING": #String
#			input_type = "1"
#			did_datatype_change = true
#		"TYPE_DROPDOWN":
#			input_type = "5"
#			did_datatype_change = true
#		"TYPE_ICON":
#			input_type = "6"
#			did_datatype_change = true
#		"TYPE_KEYSELECT":
#			input_type = "11"
#			did_datatype_change = true
#		'TYPE_SPRITEDISPLAY':
#			input_type = "8"
#			did_datatype_change = true
#		"TYPE_VECTOR": 
#			input_type = "9"
#			did_datatype_change = true
#		"TYPE_MINMAX": 
#			input_type = "12"
#			did_datatype_change = true
#		"TYPE_DICTIONARY":
#			input_type = "10"
#			did_datatype_change = true
#		"TYPE_SCENE":
#			input_type = "7"
#			did_datatype_change = true
#		"TYPE_SFX":
#			input_type = "13"
#			did_datatype_change = true
#
#	if did_datatype_change:
#		for key in currentData_dict[data_type]:
#			if currentData_dict[data_type][key]["FieldName"] == Item_Name:
#				currentData_dict[data_type][key]["DataType"] = input_type
#				break
#
#	if typeof(current_node.get_input_value()) == TYPE_STRING:
#		returnValue = current_node.get_input_value()
#	else:
#		returnValue = var_to_str(current_node.get_input_value())
#
#
#
#	if field_name != "" and field_name != "Key":
#		current_dict[key_name][field_name] = returnValue
#	elif field_name == "Key":
#		update_key_name(key_name, get_text(returnValue))
#	return returnValue
#
#
#func update_key_name(old_name : String, new_name : String):
#	var return_key = old_name
#	if old_name != new_name: #if changes are made to item name
#		#If is dropdown table
#		var table_data_dict :Dictionary = import_data("Table Data")
#		var is_dropdown_table = convert_string_to_type(table_data_dict[current_table_name]["Show in Dropdown Lists"])
#		if is_dropdown_table == true:
#			print("Cannot update keys in a table used as a dropdown list")
#
#		if !does_key_exist(new_name):
#
#			var item_name_dict = currentData_dict["Row"]
#			for i in item_name_dict: #loop through item_row table until it finds the key number for the item
#				if item_name_dict[i]["FieldName"] == old_name:
#					currentData_dict["Row"][i]["FieldName"] = new_name #Replace old value with new value
#					break
#
#			var old_key_entry : Dictionary = current_dict[Item_Name].duplicate(true) #Create copy of item values
#			current_dict.erase(Item_Name) #Erase old item entry
#			current_dict[new_name] = old_key_entry #add new item entry
#			Item_Name = new_name #Update script variable with correct item name
#			return_key = new_name
#
#		else:
#			print("Duplicate key exists in table DATA WAS NOT UPDATED")
#
#	return return_key
#
#
#func does_key_exist(key):
#	var value = false
#	if current_dict.has(key):
#		value = true
#	return value


func create_sprite_animation():
	var character_animated_sprite : AnimatedSprite2D = AnimatedSprite2D.new()
	return character_animated_sprite


func add_animation_to_animatedSprite(sprite_field_name :String, sprite_texture_data :Dictionary,animated_sprite : AnimatedSprite2D , create_collision :bool = true,  sprite_frames :SpriteFrames = SpriteFrames.new()):
	var collision

#	if sprite_frames == null:
#		sprite_frames = SpriteFrames.new()

	var frame_vector :Vector2 = convert_string_to_vector(str(sprite_texture_data["atlas_dict"]["frames"]))
	var frame_range :Vector2 = convert_string_to_vector(str(sprite_texture_data["advanced_dict"]["frame_range"]))
	var speed :int = sprite_texture_data["advanced_dict"]["speed"]
	var frame_size :Vector2 = convert_string_to_vector(str(sprite_texture_data["advanced_dict"]["sprite_size"]))

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
#	sprite_frames.queue_free()

	return [sprite_field_name, collision]


func add_sprite_group_to_animatedSprite(main_node , Sprite_Group_Id :String) -> Dictionary:
	var return_value_dictionary :Dictionary= {}
	var animation_dictionary :Dictionary = {}
	var new_animatedsprite2d :AnimatedSprite2D = create_sprite_animation()
	var sprite_group_dict :Dictionary = FART.Static_Game_Dict["Sprite Groups"]
	var spriteFrames : SpriteFrames = SpriteFrames.new()
	animation_dictionary = sprite_group_dict[Sprite_Group_Id]

	if main_node.has_method("call_commands") :
		var default_dict :Dictionary = FART.convert_string_to_type(main_node.event_dict[main_node.active_page]["Default Animation"])
		default_dict["Display Name"] = "Default Animation"
		animation_dictionary["Default Animation"] = default_dict

	for j in animation_dictionary:

		if j != "Display Name":
			var animation_name : String = j
			var anim_array :Array = FART.add_animation_to_animatedSprite( animation_name, FART.convert_string_to_type(animation_dictionary[j]),new_animatedsprite2d, true , spriteFrames)
			main_node.add_child(anim_array[1])

	return_value_dictionary["animated_sprite"] = new_animatedsprite2d
	return_value_dictionary["animation_dictionary"] = animation_dictionary
	return return_value_dictionary


func set_sprite_scale(sprite_animation :AnimatedSprite2D, animation_name:String, animation_dictionary :Dictionary, additional_scaling :Vector2 = Vector2(1,1)):
	var sprite_dict :Dictionary
	if !animation_dictionary.has("animation_dictionary"):
		sprite_dict = animation_dictionary
	else:
		sprite_dict  = FART.convert_string_to_type(animation_dictionary["animation_dictionary"][animation_name])
	var atlas_dict :Dictionary = sprite_dict["atlas_dict"]
	var advanced_dict :Dictionary  = sprite_dict["advanced_dict"]
	var sprite_texture = load(FART.table_save_path + FART.icon_folder + atlas_dict["texture_name"])
	var sprite_frame_size:Vector2 = FART.convert_string_to_vector(str(atlas_dict["frames"]))
	var sprite_final_size:Vector2 = FART.convert_string_to_vector(str(advanced_dict["sprite_size"]))
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
	var sprite_size :Vector2 = convert_string_to_vector(str(sprite_advanced_dict["sprite_size"]))
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
	var frameVector : Vector2 = convert_string_to_vector(str(sprite_texture_data["atlas_dict"]["frames"]))
	var spriteMap = load(table_save_path + icon_folder + sprite_texture_data["atlas_dict"]["texture_name"])
	var sprite_size : Vector2 = convert_string_to_vector(str(sprite_texture_data["advanced_dict"]["sprite_size"]))

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


func get_list_of_all_tables():
	var table_dict : Dictionary = import_data("Table Data")
	return table_dict



#func rearrange_table_keys(new_index :String = button_focus_index, old_index:String = button_selected , selected_data_dict :Dictionary = currentData_dict):
#	new_index = get_data_index(new_index, "Row")
#	old_index = get_data_index(old_index, "Row")
#	var key_data = currentData_dict["Row"][old_index]
#	var test_dict = currentData_dict.duplicate(true)
#	#remove the old index
#	test_dict["Row"].erase(old_index)
#	for key in test_dict["Row"].size():
#		key += 1
#		var key_string :String = str(key)
#		if !test_dict["Row"].has(key_string):
#			var next_key = str(key + 1)
#			var next_key_data = test_dict["Row"][next_key]
#			test_dict["Row"][key_string] = next_key_data
#			test_dict["Row"].erase(next_key)
#	#insert the old key data in the new key index and shift all the remaining keys down
#	for key in range(test_dict["Row"].size() + 1,0,-1):
#		var key_string :String = str(key)
#		var previous_key = str(key - 1)
#		if key_string == new_index:
#			test_dict["Row"].erase(key_string)
#			test_dict["Row"][key_string] = key_data
#			break
#		else:
#			var prev_key_data = test_dict["Row"][previous_key]
#			test_dict["Row"].erase(previous_key)
#			test_dict["Row"][key_string] = prev_key_data
#
#	currentData_dict["Row"] = test_dict["Row"]
#	for child in $Button_Float.get_children():
#		child._on_Navigation_Button_button_up()
#		child.queue_free()



#MAP FUNCTIONS------
func get_mappath_from_displayname(map_name :String):
	var maps_dict = import_data("Maps")
	var new_map_path :String = ""
	for map_id in maps_dict:
		if get_text(maps_dict[map_id]["Display Name"]) == map_name:
			new_map_path = maps_dict[map_id]["Path"]
			break
	return new_map_path


func get_mappath_from_key(key :String) -> String:
	var maps_dict = import_data("Maps")
	var new_map_path :String = ""
	new_map_path = maps_dict[key]["Path"]
	return new_map_path


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



func add_items_to_inventory_table():
	var items_dict:Dictionary = import_data("Items")
	var items_dict_data_dict: Dictionary = import_data("Items", true)
	var current_inventory_dict: Dictionary = import_data("Inventory")
	var current_inventory_data_dict: Dictionary = import_data("Inventory", true)
	var input_actions_display_name_dict:Dictionary = get_display_name(items_dict)

	var new_inventory_dict: Dictionary
	var new_inventory_data_dict: Dictionary = current_inventory_data_dict.duplicate(true)
	var item_index : int = 1
	new_inventory_data_dict["Row"] = {}
	for item_id in items_dict:
		new_inventory_dict[item_id] = {"Display Name" : items_dict[item_id]["Display Name"], "ItemCount" : 0}
		var new_line:Dictionary = {"DataType":"1","FieldName":"","RequiredValue":true,"ShowValue":true,"TableRef":true}
		new_line["FieldName"] = item_id
		new_inventory_data_dict["Row"][item_index] =  new_line
		item_index += 1

	save_file( table_save_path + "Inventory" + table_file_format, new_inventory_dict )
	save_file( table_save_path + "Inventory" + "_data" + table_file_format, new_inventory_data_dict)



func get_display_name(inputDict: Dictionary):
	var display_name_dict :Dictionary = {}
	for key in inputDict:
		var display_name :String = get_text(inputDict[key]["Display Name"])
		display_name_dict[display_name] = key
	return display_name_dict


func get_field_value_dict(inputDict: Dictionary, fieldName:String ="Function Name"):
	var display_name_dict :Dictionary = {}
	for key in inputDict:
		var display_name :String = get_text(inputDict[key][fieldName])
		display_name_dict[display_name] = key
	return display_name_dict


func add_key_to_table(NewKeyName :String, NewDisplayName: String, TableName:String, target_dict:Dictionary = {}, target_data_dict:Dictionary = {}):
	if target_dict == {}:
		target_dict = import_data(TableName)
	if target_data_dict == {}:
		target_data_dict = import_data(TableName, true)
	var index = target_data_dict["Row"].size() + 1
	var CustomData_dict = import_data("Field_Pref_Values") 
	var newOptions_dict = {}
	var newValue

	for ID in CustomData_dict:
		var currentKey :String = get_text(CustomData_dict[ID]["ItemID"])
		newValue = target_data_dict["Row"][target_data_dict["Row"].keys()[0]][currentKey]
		newOptions_dict[currentKey] = newValue

	newOptions_dict["FieldName"] = NewKeyName
	target_data_dict["Row"][str(index)] =  newOptions_dict


	var new_key_data = target_dict[target_dict.keys()[0]].duplicate(true)
	new_key_data["Display Name"] = {"text": NewDisplayName}
	target_dict[NewKeyName] = new_key_data  #CHANGE THIS TO DEFAULT VALUE FOR DATATYPE #Set new key values based on the default (first line of table)
	
	return [target_dict, target_data_dict]
	#Save target_data_dict and target_dict



func get_next_key_ID(target_dict:Dictionary):
	var next_key_number: int
	next_key_number = target_dict.size()
	while target_dict.has(str(next_key_number)):
		next_key_number += 1
	return next_key_number


func get_text(text_value)-> String:
	var return_string:String
	var typed_value = convert_string_to_type(text_value)
	if typeof(typed_value) == TYPE_DICTIONARY:
		return_string = convert_string_to_type(text_value)["text"]
	else:
		return_string = str(text_value)
	return return_string
