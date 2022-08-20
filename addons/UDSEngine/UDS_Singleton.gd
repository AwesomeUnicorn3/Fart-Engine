extends DatabaseEngine
#SHOULD ONLY INCLUDE SCRIPT THAT I WANT ACCESSIBLE TO THE USER
signal save_game_data
signal save_complete
signal DbManager_loaded
signal map_loaded
#signal refresh_UI


var Static_Game_Dict = {}
var Dynamic_Game_Dict := {}
var Global_Game_Dict = {}
var save_dict = {}
var curr_tbl_loc = ""
var DBManager_Active : bool = true
var importtext = false
var tables_list = []
var DBdict = {}
#var json = ".json"
var id
var save_id = 0
var array_load_savefiles = []
var array_load_files = []

var dict_loaded = false

var current_map_path := ""
var current_map_name := ""
var current_map_node

var player_node

func _ready():
	op_sys = OS.get_name()
#	emit_signal("DbManager_loaded")
	var tbl_data = import_data(table_save_path + "/Table Data.json")
	tables_list = list_files_with_param(table_save_path, file_format, ["Table Data.json"])
	var dict = {}
	for d in tables_list:
		if d == "Table Data.json":
			pass
		elif d == "Options Player Data.json":
			var save_path_global = "user://OptionsData.json"
			var save_dir = list_files_with_param(save_game_path, file_format)
			if save_dir.has("OptionsData.json"):
				Global_Game_Dict = import_data(save_path_global)
#				###Updates global game dict from previous saves and overwrites with "Options" table data
#				#Can delete with version 0.008
#				if Global_Game_Dict["BGM"].has("Active"):
#					Global_Game_Dict = import_data(table_save_path + "Options.json")
#					save_global_options_data()
				###########
			else:
				Global_Game_Dict = import_data(table_save_path + "Options.json")
				save_global_options_data()
		else:
			var array = []
			var name = d
			array = name.rsplit(".")
			var tblname = array[0]
			var dictname = tbl_data[tblname]["Display Name"]
			dict[dictname] = import_data(table_save_path + d)

	Static_Game_Dict = dict
	set_var_type_dict(Static_Game_Dict)
	set_root_node()
#	new_game()

	update_key_bindings()
	print("Singleton Loaded and updated")



func get_root_node():
	return root

func delete_save_file(file_name : String):
	#Can include the .sav ext but is not required, it can be just save name "1"
	if file_name.get_extension() == save_format.trim_prefix("."):
		file_name = file_name.trim_suffix(save_format)

	var fileName = save_game_path + file_name + save_format

	var dir = Directory.new()
	dir.open(save_game_path)
	dir.remove(fileName)


func set_current_map(map_node):
	current_map_node = map_node
	current_map_name = map_node.name
	current_map_path = current_map_node.get_path()


func get_map_name(map_path : String):
	var map_dict : Dictionary = await import_data(table_save_path + "Maps" + file_format)
	var map_name : String =""
	for map_id in map_dict:
		if map_dict[map_id]["Path"] == map_path:
			map_name = map_dict[map_id]["Display Name"]
			break
	return map_name

func load_and_set_map(map_path := ""):
	var map_node = load(map_path).instantiate()
	root.get_node("map").add_child(map_node)
	Dynamic_Game_Dict["Global Data"][global_settings]["Current Map"] = map_path
	set_current_map(map_node)
	add_map_to_events(await get_map_name(map_path))


func add_map_to_events(map_name:String):
	if !Dynamic_Game_Dict["Event Save Data"].has(map_name):
			Dynamic_Game_Dict["Event Save Data"][map_name] = {}

func save_global_options_data():
	save_file("user://OptionsData.json", Global_Game_Dict)


func save_game():
	emit_signal("save_game_data")
	current_map_node.save_event_data()
	save_id = Dynamic_Game_Dict["Global Data"][global_settings]["ID"]
	if int(save_id) == 0: #set save id when player loads game
		set_save_path()
	id = str(save_id)
	var time = Time.get_date_dict_from_system()
	Dynamic_Game_Dict["Global Data"][global_settings]["Time"] = time
	
	var save_d = Dynamic_Game_Dict
	var save_file = File.new()
	var save_path = save_game_path + id + save_format
	save_file(save_path, save_d)
	emit_signal("save_complete")


func get_save_files():
	var files = list_files_with_param(save_game_path, save_format)
	return files

func set_save_path():
#	list_files_in_directory(save_game_path, save_format)
	array_load_savefiles.sort_custom(sort_filename_ascending)
	var count = 1
	if int(save_id) == 0:
		for i in array_load_savefiles:

			var i_integer : int = get_file_name(i, ".sav").to_int()
			if i_integer != count:
				break
			count += 1
	save_id = count
	id = str(save_id)
	var save_path = save_game_path + id + save_format
	var directory = Directory.new();
	var doFileExists = directory.file_exists(save_path)

	while doFileExists:
		save_id = save_id + 1
		id = str(save_id)
		save_path = save_game_path + id + save_format
		directory = Directory.new();
		doFileExists = directory.file_exists(save_path)
	Dynamic_Game_Dict["Global Data"][global_settings]["ID"] = save_id

func load_game(file_name : String):
	dict_loaded = false
	if file_name.get_extension() == save_format.trim_prefix("."):
		file_name = file_name.trim_suffix(save_format)

	var fileName = save_game_path + file_name + save_format
	var load_path = fileName

	Dynamic_Game_Dict = import_data(load_path)

	load_and_set_map(get_current_map_path())
	var player_pos  = convert_string_to_vector(get_data_value("Global Data", global_settings, "Player POS"))
	player_node.set_player_position(player_pos)
#	add_all_items_to_player_inventory()
	Dynamic_Game_Dict["Global Data"][global_settings]["Is Game Active"] = true
	dict_loaded = true
	emit_signal("DbManager_loaded")


func get_player_node():
	player_node = await root.find_child("Player", true, false)
	return player_node


func get_player_interaction_area():
	get_player_node()
	var interation_area = player_node.get_node("PlayerInteractionArea")
	return interation_area

func move_player_to_map_node(current_map_node):
	await root.remove_child(player_node)
	await current_map_node.ysort_node.add_child(player_node)


func remove_player_from_map_node(current_map_node):
	await player_node.get_parent().remove_child(player_node)
	await root.add_child(player_node)


func set_player_position_in_db(new_position):
	set_save_data_value("Global Data", global_settings, "Player POS", new_position)


func get_player_position_from_db():
	var player_vector_position = get_data_value("Global Data", global_settings, "Player POS")
	return player_vector_position


func set_save_data_value(table_name :String, key_name :String, value_name :String, new_value):
	Dynamic_Game_Dict[table_name][key_name][value_name] = new_value


func get_data_value(table_name :String, key_name :String, value_name :String, from_save_dict :bool = true):
	var rtn_value
	if from_save_dict:
#		var value :String = str(Dynamic_Game_Dict[table_name][key_name][value_name])
		
		rtn_value = convert_string_to_type(str(Dynamic_Game_Dict[table_name][key_name][value_name]))
	else:
		rtn_value = convert_string_to_type(str(Static_Game_Dict[table_name][key_name][value_name]))
	return rtn_value


func new_game():
	dict_loaded = false
	var tbl_data = import_data( table_save_path + "Table Data.json")
	tables_list = list_files_with_param(table_save_path, file_format)
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
			var dictname = deleteme["Display Name"]
			var include_in_save_file = convert_string_to_type(deleteme["Include in Save File"])
			if include_in_save_file == true:
				dict[dictname] = import_data(table_save_path + d)
				
	Dynamic_Game_Dict = dict

	set_var_type_dict(Dynamic_Game_Dict)
	add_all_items_to_player_inventory()
	load_and_set_map(get_starting_map_path())
	
#	Dynamic_Game_Dict["Global Data"][global_settings]["NewGame"] = false
	Dynamic_Game_Dict["Global Data"][global_settings].erase("Project Root Scene")
	
	
	Dynamic_Game_Dict["Global Data"][global_settings]["Is Game Active"] = true
	dict_loaded = true
	emit_signal("DbManager_loaded")
	

func get_game_title():
	var initial_save_data : Dictionary = await import_data(table_save_path + "Global Data" + file_format)
	var game_title = initial_save_data[global_settings]["Game Title"]
	return game_title

func get_starting_map_path():
	var current_map_name : String = Dynamic_Game_Dict['Global Data'][global_settings]['Starting Map']
	var current_map_path := ""
	for i in Static_Game_Dict['Maps']:
		if current_map_name == Static_Game_Dict['Maps'][i]["Display Name"]:
			current_map_path = Static_Game_Dict['Maps'][i]["Path"]
			Dynamic_Game_Dict["Global Data"][global_settings]["Current Map"] = current_map_path
			Dynamic_Game_Dict["Global Data"][global_settings].erase("Starting Map")
			break
	return current_map_path

func get_current_map_path() -> String:
	var current_map_path : String = Dynamic_Game_Dict['Global Data'][global_settings]['Current Map']
	return current_map_path

func sort_ascending(a, b):
	if a < b:
		return true
	return false

func sort_filename_ascending(a, b):
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
		for j in InputMap.action_get_events(h):
#			#remove each key bind
			if j.get_class() == "InputEventKey":
				InputMap.action_erase_event(h, j)


func update_key_bindings():
	var options_stats = Static_Game_Dict["Controls"]
#	var lead_char_name
	#set all of the action key bindings from the options#
	# first remove all previous keys bound to each action
	clear_key_bindings()
#	await get_tree().create_timer(.5)
	#find the lead character
#	lead_char_name = get_player_character()

	#loop through all of the actions in the action list again
	for h in options_stats:
		if !InputMap.get_actions().has(h):
			InputMap.add_action(h)
	#for each action, if keyscancode from options table == null
	#add each key from the options table
		
		if options_stats.has(h):
			var cat :String = options_stats[h]["Category"]
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
						key1object.set_keycode(key1)
						InputMap.action_add_event(h, key1object)


						var key2 : int = int(options_stats[h]["Key2"])
						if key2 != 0:
							var key2object = InputEventKey.new()
							key2object.set_keycode(key2)
							InputMap.action_add_event(h, key2object)



#######################################BEGIN INVENTORY FUNCTIONS###############################################################################

func add_all_items_to_player_inventory():
	var item_dict : Dictionary = Static_Game_Dict["Items"]
	if !Dynamic_Game_Dict.has("Inventory"):
		Dynamic_Game_Dict["Inventory"] = {}
	for item_name in item_dict:
		change_player_inventory(item_name)


func change_player_inventory(item_name :String, count :int = 0, increase_value := true):
	var dict_static_items = udsmain.Static_Game_Dict["Items"]
	count = int(abs(count))
	if !increase_value:
		count = int(-abs(count))
	if dict_static_items.has(item_name):
		if!is_item_in_inventory(item_name):
			udsmain.Dynamic_Game_Dict["Inventory"][item_name] = {"ItemCount" : 0}
		var inv_count = int(udsmain.Dynamic_Game_Dict["Inventory"][item_name]["ItemCount"])
		udsmain.Dynamic_Game_Dict["Inventory"][item_name]["ItemCount"] =  inv_count + count
	else:
		print(item_name, " needs to be added to Item Table")
	return udsmain.Dynamic_Game_Dict["Inventory"][item_name]["ItemCount"]


func is_item_in_inventory(item_name : String):
	var value = false
	var dict_inventory = udsmain.Dynamic_Game_Dict["Inventory"]
	if dict_inventory.has(item_name):
		value = true
	return value


##############################EVENT SCRIPTS#####################################3



func change_local_variable(which_var:String, to_what:bool, event_name :String, event_node_name :String, event_node):
	var local_variable_dict  = convert_string_to_type(Dynamic_Game_Dict["Event Save Data"][current_map_name][event_node_name]["Local Variables"])
	for Variable in local_variable_dict:
		if local_variable_dict[Variable]["Value 1"] == which_var:
			local_variable_dict[Variable]["Value 2"] = to_what
			Dynamic_Game_Dict["Event Save Data"][current_map_name][event_node_name]["Local Variables"] = local_variable_dict
			break


func change_global_variable(which_var:String, what_type: String,  to_what, event_name :String, event_node_name :String, event_node):
	var global_variable_dict  = convert_string_to_type(Dynamic_Game_Dict["Global Variables"])
	for id in global_variable_dict:
		if global_variable_dict[id]["Display Name"] == which_var:
			Dynamic_Game_Dict["Global Variables"][id][what_type] = to_what
			break


func remove_event(event_name :String, event_node_name:String, event_node):
	event_node.is_queued_for_delete = true


func print_to_console(input_text :String ,event_name :String, event_node_name:String, event_node):
	print(input_text)


func wait(how_long: float, event_name :String, event_node_name:String, event_node):
	await get_tree().create_timer(how_long).timeout


func transfer_player(which_map :String, what_coordinates, event_name :String, event_node_name:String, event_node):
	call_deferred("remove_player_from_map_node" ,current_map_node)
	var map_path :String = get_mappath_from_displayname(which_map)
	if current_map_name != which_map:
		call_deferred("load_and_set_map",map_path)
	await get_tree().create_timer(.25).timeout
	player_node = await get_player_node()
	player_node.set_player_position(convert_string_to_vector(what_coordinates))
	remove_unused_maps()


func remove_unused_maps():
	var maps_node = root.get_node("map")
	for child in maps_node.get_children():
		if child != current_map_node:
			for event in child.event_array:
				event.is_queued_for_delete = true
			child.queue_free()


func modify_player_inventory(what :String, how_many , increase_value :String, event_name :String, event_node_name:String, event_node ):
	var dict_static_items = udsmain.Static_Game_Dict["Items"]
	var increase :bool = false
	var modify_amount :int = int(abs(how_many))

	if increase_value == "+":
		increase = true
		
	if !increase:
		modify_amount = int(-abs(modify_amount))

	if dict_static_items.has(what):
		if!is_item_in_inventory(what):
			Dynamic_Game_Dict["Inventory"][what] = {"ItemCount" : 0}
		var inv_count = int(Dynamic_Game_Dict["Inventory"][what]["ItemCount"])
		Dynamic_Game_Dict["Inventory"][what]["ItemCount"] =  inv_count + how_many
	else:
		print(what, " needs to be added to Item Table")
	
	print(Dynamic_Game_Dict["Inventory"][what]["ItemCount"])
	return Dynamic_Game_Dict["Inventory"][what]["ItemCount"]



#####################################UNUSED BUT POSSIBLY USEFUL AT SOME POINT#########################33


#func get_event_from_script(event_name : String, function_name : String):
#	var event_script = load(Static_Game_Dict['events']['DefaultGDScript']['Script Path'])
#	var events_node : Node = root.get_node("events")
#	events_node.set_script(event_script)
#
#	if events_node.has_method(function_name):
#		events_node.call(function_name)
#	else:
#		print("Function ", function_name, " not found in ", event_name)
#	return events_node
