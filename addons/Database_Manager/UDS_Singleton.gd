extends DatabaseEngine
#SHOULD ONLY INCLUDE SCRIPT THAT I WANT ACCESSIBLE TO THE USER
signal save_complete
signal DbManager_loaded
signal refresh_UI

var uds_main_scene
var Static_Game_Dict = {}
var Dynamic_Game_Dict = {}
var Global_Game_Dict = {}
var save_dict = {}
var curr_tbl_loc = ""
var DBManager_Active : bool = true
var importtext = false
var tables_list = []
var DBdict = {}
var json = ".json"
var id
var save_id = 0
var array_load_savefiles = []
var array_load_files = []

var dict_loaded = false


func _ready():
	op_sys = OS.get_name()
	emit_signal("DbManager_loaded")
	var tbl_data = import_data(dbmanData_save_path + "/Table Data.json")
	tables_list = list_files_with_param(dbmanData_save_path, json, ["Table Data.json"])
	var dict = {}
	for d in tables_list:
		if d == "Table Data.json":
			pass
		elif d == "Options Player Data.json":
			var save_path_global = "user://OptionsData.json"
			var save_dir = list_files_with_param(save_game_path, json)
			if save_dir.has("OptionsData.json"):
				Global_Game_Dict = import_data(save_path_global)
#				###Updates global game dict from previous saves and overwrites with "Options" table data
#				#Can delete with version 0.008
#				if Global_Game_Dict["BGM"].has("Active"):
#					Global_Game_Dict = import_data(dbmanData_save_path + "Options.json")
#					save_global_options_data()
				###########
			else:
				Global_Game_Dict = import_data(dbmanData_save_path + "Options.json")
				save_global_options_data()
		else:
			var array = []
			var name = d
			array = name.rsplit(".")
			var tblname = array[0]
			var dictname = tbl_data[tblname]["Reference Name"]
			var main_dict = save_dict
			dict[dictname] = import_data(dbmanData_save_path + d)

	Static_Game_Dict = dict
	set_var_type_dict(Static_Game_Dict)
	new_game()
	update_key_bindings()
	print("Singleton Loaded and updated")


func save_global_options_data():
	var save_d = Global_Game_Dict
	var save_file = File.new()
	var save_path = "user://OptionsData.json"
	if save_file.open(save_path, File.WRITE) != OK:
		print(save_path)
		print("Error Could not update Global optionsfile")
	else:
		save_file.open(save_path, File.WRITE)
		save_d = to_json(save_d)
		save_file.store_line(save_d)
		save_file.close()

func save_game():
	save_id = Dynamic_Game_Dict["SaveData"]["Save"]["ID"]
	if int(save_id) == 0: #set save id when player loads game
		set_save_path()
	id = String(save_id)
	var time = OS.get_datetime()
	var dict_time = Dynamic_Game_Dict["SaveData"]["Time"]["ID"]

	var save_d = Dynamic_Game_Dict
	var save_file = File.new()
	var save_path = save_game_path + id + save_format
	if save_file.open(save_path, File.WRITE) != OK:
		print(save_path)
		print("Error Could not open file in Write mode")
	else:
		save_file.open(save_path, File.WRITE)
		save_d = to_json(save_d)
		save_file.store_line(save_d)
		save_file.close()
		emit_signal("save_complete")


func set_save_path():
#	list_files_in_directory(save_game_path, save_format)
	array_load_savefiles.sort_custom(MyCustomSorter, "sort_filename_ascending")
	var count = 1
	if int(save_id) == 0:
		for i in array_load_savefiles:
			var i_integer = int(get_file_name(i, ".sav"))
			if i_integer != count:
				break
			count += 1
	save_id = count
	id = String(save_id)
	var save_path = save_game_path + id + save_format
	var directory = Directory.new();
	var doFileExists = directory.file_exists(save_path)
	Dynamic_Game_Dict["SaveData"]["Save"]["ID"] = save_id
	while doFileExists:
		save_id = save_id + 1
		id = String(save_id)
		save_path = save_game_path + id + save_format
		directory = Directory.new();
		doFileExists = directory.file_exists(save_path)

func load_game():
	
	var load_path = load_game_path
	var load_file = File.new()

	if not load_file.file_exists(load_path):
		return
	load_file.open(load_path, File.READ)
	var data = {}
	Dynamic_Game_Dict = parse_json(load_file.get_as_text())
	set_var_type_dict(Dynamic_Game_Dict)
	load_file.close()
	dict_loaded = true


func new_game():
	var tbl_data = import_data("res://addons/Database_Manager/Data/Table Data.json")
	tables_list = list_files_with_param(dbmanData_save_path, json)
#	set_var_type_table(tbl_data)
	var dict = {}
	for d in tables_list:
		if d == "Table Data.json":
			pass
		else:
			var array = []
			var name = d
			array = name.rsplit(".")
			var tblname = array[0]
			var deleteme = tbl_data[tblname]
			var dictname = deleteme["Reference Name"]
			var dynamic = convert_string_to_type(deleteme["Include in Save File"])
			if dynamic == true:
				dict[dictname] = import_data(dbmanData_save_path + d)
	Dynamic_Game_Dict = dict
	
	#Set intital player inventory
	set_var_type_dict(Dynamic_Game_Dict)
	var intitial_inventory_dict = convert_string_to_type(Static_Game_Dict["Characters"][get_lead_character()]['Starting Inventory'])
#	add_newGame_inventory(intitial_inventory_dict)
	Dynamic_Game_Dict["SaveData"]["New Game"] = false


class MyCustomSorter:
	static func sort_ascending(a, b):
		if a < b:
			return true
		return false

	static func sort_filename_ascending(a, b):
		a = int(a.trim_suffix(".sav"))
		b = int(b.trim_suffix(".sav"))
		if a < b:
			return true
		return false


func edit_dict(dict, itm_nm, amt):
	if Dynamic_Game_Dict[dict].has(itm_nm):
		Dynamic_Game_Dict[dict][itm_nm]["ItemCount"] += amt
	else:
		var item = Static_Game_Dict["Items"][itm_nm]
		Dynamic_Game_Dict[dict][itm_nm] = item
		Dynamic_Game_Dict[dict][itm_nm]["ItemCount"] += amt

func get_lead_character(): #Character the player is actively controlling
	var lead_char = udsmain.Static_Game_Dict['Character Formation']["1"]["ID"]
	return lead_char

#######BEGIN CONTROL FUNCTIONS###############################33

func clear_key_bindings():
	for h in InputMap.get_actions():
	#	#for each action, loop through key binds
		for j in InputMap.get_action_list(h):
#			#remove each key bind
			if j.get_class() == "InputEventKey":
				InputMap.action_erase_event(h, j)


func update_key_bindings():
	var options_stats = Static_Game_Dict["Controls"]
#	var lead_char_name
	#set all of the action key bindings from the options#
	# first remove all previous keys bound to each action
	clear_key_bindings()
	#find the lead character
#	lead_char_name = get_player_character()

	#loop through all of the actions in the action list again
	for h in options_stats:
		if !InputMap.get_actions().has(h):
			InputMap.add_action(h)
	#for each action, if keyscancode from options table == null
	#add each key from the options table
		
		if options_stats.has(h):
			var cat = options_stats[h]["Category"]
			match cat: 
#				"PlaceHolder":
#					var input_action = options_stats[h]["Input_Action"]
#					var char_action_string = lead_char_name + " " + input_action
#					var key1 = options_stats[char_action_string]["Key1Scancode"]
#					var key1object = InputEventKey.new()
#					key1object.set_scancode(key1)
#					InputMap.action_add_event(h, key1object)
				
				"Character":
					var key1 : int = int(options_stats[h]["Key1"])
					if key1 != 0:
#						var key2_text : String = str(options_stats[h]["Key2"])
						var key1object = InputEventKey.new()
						key1object.set_scancode(key1)
						InputMap.action_add_event(h, key1object)


						var key2 : int = int(options_stats[h]["Key2"])
						if key2 != 0:
							var key2object = InputEventKey.new()
							key2object.set_scancode(key2)
							InputMap.action_add_event(h, key2object)



#BEGIN INVENTORY FUNCTIONS###############################################################################

func add_newGame_inventory(itemDict : Dictionary = {}):
	for i in itemDict:
		add_item_to_player_inventory(i, itemDict[i])
	udsmain.Dynamic_Game_Dict["Inventory"].erase("Default")

func add_item_to_player_inventory(item_name : String, count : int = 0):
	var added = false
#	var dict_inventory = udsmain.Dynamic_Game_Dict["Inventory"]
	var dict_static_items = udsmain.Static_Game_Dict["Items"]
	if dict_static_items.has(item_name):
		if!is_item_in_inventory(item_name):
			udsmain.Dynamic_Game_Dict["Inventory"][item_name] = {"ItemCount" : 0}
		var inv_count = int(udsmain.Dynamic_Game_Dict["Inventory"][item_name]["ItemCount"])
		udsmain.Dynamic_Game_Dict["Inventory"][item_name]["ItemCount"] =  inv_count + count
		print(udsmain.Dynamic_Game_Dict["Inventory"])
	else:
		print(item_name, " needs to be added to Item Table")
#	update_all_active_quests()


func remove_inventory_item(itm_name : String, count : int = 1):
	var dict_inventory = udsmain.Dynamic_Game_Dict["Inventory"]
	if is_item_in_inventory(itm_name) == true:
		var itm_count = int(dict_inventory[itm_name]["ItemCount"])
		if count > itm_count:
			count = itm_count
		dict_inventory[itm_name]["ItemCount"] =  itm_count - count
#		Global.display_item_gained(itm_name, -count)
	else:
		count = 0
	return count


func is_item_in_inventory(itm_name : String):
	var value = false
	var dict_inventory = udsmain.Dynamic_Game_Dict["Inventory"]
	if dict_inventory.has(itm_name):
		value = true
	return value
