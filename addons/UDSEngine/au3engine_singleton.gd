extends DatabaseEngine
#SHOULD ONLY INCLUDE SCRIPT THAT I WANT ACCESSIBLE TO THE USER
signal save_game_data
signal save_complete
signal DbManager_loaded
signal map_loaded
signal clear_loading_screen
signal map_data_updated
#signal refresh_UI
@onready var EVENTS :EventEngine = EventEngine.new()

var inputMapActions :Array
var movementDirections_dict :Dictionary
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
var current_map_key :String = ""
var current_map_scene_path :String = ""

var player_node
var gameState :String = "1"


func _ready():

	op_sys = OS.get_name()
	#print(op_sys)
	var tbl_data = import_data(table_save_path + "/Table Data.json")
	#print(tbl_data)
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
			else:
				Global_Game_Dict = import_data(table_save_path + "Options.json")
				save_global_options_data()
		else:
			var array = []
			var eventName = d
			array = eventName.rsplit(".")
			var tblname = array[0]
			var dictname :String
			if str_to_var(tbl_data[tblname]["Display Name"]) != null:
				dictname = str_to_var(tbl_data[tblname]["Display Name"])["text"]
			else:
				dictname = tbl_data[tblname]["Display Name"]
			dict[dictname] = import_data(table_save_path + eventName)

	Static_Game_Dict = dict
	set_var_type_dict(Static_Game_Dict)
	set_root_node()
	
	set_game_state(gameState) #this should get the game state from the global data [selected profile]
	update_key_bindings()

	print("Singleton Loaded and updated")


func get_root_node():
	return root


	

func get_gui():
	var gui = get_root_node().get_node("UI/GUI")
	return gui


func delete_save_file(file_name : String):
	#Can include the .sav ext but is not required, it can be just save name "1"
	if file_name.get_extension() == save_format.trim_prefix("."):
		file_name = file_name.trim_suffix(save_format)

	var fileName = save_game_path + file_name + save_format

	var dir :DirAccess = DirAccess.open(save_game_path)
	#dir.open(save_game_path)
	dir.remove(fileName)


func set_current_map(map_node :Node, map_path:String):
	current_map_node = map_node
	current_map_name = map_node.name
	current_map_path = current_map_node.get_path()
	current_map_scene_path = map_path
	current_map_key =  await get_map_key(current_map_scene_path)

	await get_tree().create_timer(0.25).timeout
	
	
func get_map_dict() -> Dictionary:
	var map_dict : Dictionary = await import_data(table_save_path + "Maps" + file_format)
	return map_dict

func get_map_key(map_path : String):
	var map_dict : Dictionary = await get_map_dict()
	var map_key : String =""
	for map_id in map_dict:
		print(map_dict[map_id]["Path"])
		if map_dict[map_id]["Path"] == map_path:
			map_key = map_id
			break
	return map_key

func get_map_name(map_path : String):
	var map_dict : Dictionary = await get_map_dict()
	var map_name : String =""
	for map_id in map_dict:
		if map_dict[map_id]["Path"] == map_path:
			map_name = str_to_var(map_dict[map_id]["Display Name"])["text"]
			break
	return map_name

func load_and_set_map(map_path := ""):
	#show load screen
	#set game state to 7 (Scene transition)
	set_game_state("7")
	var map_node = load(map_path).instantiate()
	root.get_node("map").add_child(map_node)
	Dynamic_Game_Dict["Global Data"][global_settings_profile]["Current Map"] = map_path
	await set_current_map(map_node, map_path)
	emit_signal("map_data_updated")
	add_map_to_events(await get_map_name(map_path))
	#hide load screen
	set_game_state("2")


func add_map_to_events(map_name:String):
	if !Dynamic_Game_Dict["Event Save Data"].has(map_name):
			Dynamic_Game_Dict["Event Save Data"][map_name] = {}

func save_global_options_data():
	save_file("user://OptionsData.json", Global_Game_Dict)


func save_game():
	emit_signal("save_game_data")
	current_map_node.save_event_data()
	save_id = Dynamic_Game_Dict["Global Data"][global_settings_profile]["ID"]
	if int(save_id) == 0: #set save id when player loads game
		set_save_path()
	id = str(save_id)
	var time = Time.get_date_dict_from_system()
	Dynamic_Game_Dict["Global Data"][global_settings_profile]["Time"] = time
	var save_d :Dictionary = Dynamic_Game_Dict
	var save_path :String = save_game_path + id + save_format
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
	var directory :DirAccess = DirAccess.open(save_game_path)
	var doFileExists = directory.file_exists(save_path)

	while doFileExists:
		save_id = save_id + 1
		id = str(save_id)
		save_path = save_game_path + id + save_format
		#directory  = DirAccess.open(save_path);
		doFileExists = directory.file_exists(save_path)
	Dynamic_Game_Dict["Global Data"][global_settings_profile]["ID"] = save_id

func load_game(file_name : String):
	dict_loaded = false
	if file_name.get_extension() == save_format.trim_prefix("."):
		file_name = file_name.trim_suffix(save_format)

	var fileName = save_game_path + file_name + save_format
	var load_path = fileName

	Dynamic_Game_Dict = import_data(load_path)

	load_and_set_map(get_current_map_path())
	var player_pos  = convert_string_to_vector(get_data_value("Global Data", global_settings_profile, "Player POS"))
	player_node.set_player_position(player_pos)
#	add_all_items_to_player_inventory()
	Dynamic_Game_Dict["Global Data"][global_settings_profile]["Is Game Active"] = true
	dict_loaded = true
	emit_signal("DbManager_loaded")



func get_player_node():
	player_node = await root.find_child("Player", true, false)
	return player_node


func get_player_interaction_area():
	get_player_node()
	var interation_area = player_node.get_node("PlayerInteractionArea")
	return interation_area

func move_to_map_Ysort(current_map_node, objectNode :Node = player_node, parent :Node = root):
	await parent.remove_child(objectNode)
	await current_map_node.ysort_node.add_child(objectNode)


func remove_player_from_map_node(current_map_node):
	await player_node.get_parent().remove_child(player_node)
	await root.add_child(player_node)


func set_player_position_in_db(new_position):
	set_save_data_value("Global Data", global_settings_profile, "Player POS", new_position)


func get_player_position_from_db():
	var player_vector_position = get_data_value("Global Data", global_settings_profile, "Player POS")
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
			var dictname = str_to_var(deleteme["Display Name"])["text"]
			var include_in_save_file = convert_string_to_type(deleteme["Include in Save File"])
			if include_in_save_file == true:
				dict[dictname] = import_data(table_save_path + d)
				
	Dynamic_Game_Dict = dict

	set_var_type_dict(Dynamic_Game_Dict)
	add_all_items_to_player_inventory()
	load_and_set_map(get_starting_map_path())

#	Dynamic_Game_Dict["Global Data"][global_settings_profile]["NewGame"] = false
	Dynamic_Game_Dict["Global Data"][global_settings_profile].erase("Project Root Scene")
	
	
	Dynamic_Game_Dict["Global Data"][global_settings_profile]["Is Game Active"] = true
	dict_loaded = true
	emit_signal("DbManager_loaded")
	

func get_game_title():
	var initial_save_data : Dictionary = await import_data(table_save_path + "Global Data" + file_format)
	var game_title = str_to_var(initial_save_data[global_settings_profile]["Game Title"])["text"]
	return game_title

func get_starting_map_path():
	var current_map_key : String = var_to_str(Dynamic_Game_Dict["Global Data"][global_settings_profile]['Starting Map'])
	var current_map_path :String = Static_Game_Dict['Maps'][current_map_key]["Path"]
#	for i in Static_Game_Dict['Maps']:
#		if current_map_name == str_to_var(Static_Game_Dict['Maps'][i]["Display Name"])["text"]:
#			current_map_path = Static_Game_Dict['Maps'][i]["Path"]
#			Dynamic_Game_Dict["Global Data"][global_settings_profile]["Current Map"] = var_to_str({"text" : current_map_path})
#			Dynamic_Game_Dict["Global Data"][global_settings_profile].erase("Starting Map")
	return current_map_path

func get_current_map_path() -> String:
	var current_map_path : String = Dynamic_Game_Dict['Global Data'][global_settings_profile]['Current Map']
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

func get_lead_character_id(): #Character the player is actively controlling
	var lead_char_id :String = str(Static_Game_Dict['Character Formation']["1"]["ID"])
	var lead_char_name :String = str(str_to_var(Static_Game_Dict["Characters"][lead_char_id]["Display Name"])["text"])
	return lead_char_id



#######BEGIN CONTROL FUNCTIONS###############################33

func clear_key_bindings():
	for action_name in InputMap.get_actions():
	#	#for each action, loop through key binds
		for action_event in InputMap.action_get_events(action_name):
#			#remove each key bind
			if action_event.get_class() == "InputEventKey":
				InputMap.action_erase_event(action_name, action_event)

func get_displayName_text(displayName_dict :Dictionary) -> String: 
	var displayName :String = displayName_dict["text"]
	return displayName

func update_key_bindings():
	var control_dict :Dictionary = Static_Game_Dict["Controls"]
	var global_data_dict :Dictionary = Static_Game_Dict["Global Data"]
	var control_template :String= str(global_data_dict[global_settings_profile]["Default Controls"])
	for action in InputMap.get_actions():
		inputMapActions.append(action)
	clear_key_bindings()
	
	#NEED TO GET WHICH MOVEMENT TEMPLATE FROM GLOBAL DATA
#	for key in control_dict:
#		var displayName :String = str_to_var(control_dict[key]["Display Name"])["text"]
#
#		if displayName == control_template:
#			control_template = key
#			break

	
	#KEEP IN MIND CONTROL NAME WILL BE NESTED IN THE MOVEMENT TEMPLATE UNDER INPUT LIST
	var selectedControl_dict :Dictionary = str_to_var(control_dict[control_template]["Input List"])
	var inputDict :Dictionary = selectedControl_dict["input_dict"]
	for keyOption in inputDict:
		var actionName :String = inputDict[keyOption]["options_dict"]["action"]
#		if !action_array.has(control_name):
		var keysDict :Dictionary = inputDict[keyOption]["input_dict"]
		for key in keysDict:
			var controlOption_dict :Dictionary = keysDict[key]
			var deviceClass : String = controlOption_dict["device class"]
			var keycode : int = controlOption_dict["keycode"]
			var keyname : String = controlOption_dict["keyname"]
#			print(keyOption)
#			InputMap.add_action(control_name)
#
			if !inputMapActions.has(actionName):
				#print(actionName)
				InputMap.add_action(actionName)
				inputMapActions.append(actionName)
				#add key to action
			if keycode != 0:
				var keyObject = InputEventKey.new()
				keyObject.set_keycode(keycode)
				InputMap.action_add_event(actionName, keyObject)




#######################################BEGIN INVENTORY FUNCTIONS###############################################################################

func add_all_items_to_player_inventory():
	var item_dict : Dictionary = Static_Game_Dict["Items"]
	if !Dynamic_Game_Dict.has("Inventory"):
		Dynamic_Game_Dict["Inventory"] = {}
	for item_name in item_dict:
		change_player_inventory(item_name)


func change_player_inventory(item_name :String, count :int = 0, increase_value := true):
	var dict_static_items = Static_Game_Dict["Items"]
	count = int(abs(count))
	if !increase_value:
		count = int(-abs(count))
	if dict_static_items.has(item_name):
		if!is_item_in_inventory(item_name):
			Dynamic_Game_Dict["Inventory"][item_name] = {"ItemCount" : 0}
		var inv_count = int(Dynamic_Game_Dict["Inventory"][item_name]["ItemCount"])
		Dynamic_Game_Dict["Inventory"][item_name]["ItemCount"] =  inv_count + count
	else:
		print(item_name, " needs to be added to Item Table")
	return Dynamic_Game_Dict["Inventory"][item_name]["ItemCount"]


func is_item_in_inventory(item_name : String):
	var value = false
	var dict_inventory = Dynamic_Game_Dict["Inventory"]
	if dict_inventory.has(item_name):
		value = true
	return value


func set_game_state(newGameState :String):
	gameState = newGameState
	var global_dict :Dictionary
	if Dynamic_Game_Dict.has("Global Data"):
		global_dict = Dynamic_Game_Dict
		Dynamic_Game_Dict["Global Data"][global_settings_profile]["Game State"] = gameState
	else:
		global_dict = Static_Game_Dict

	var global_data_dict :Dictionary = global_dict["Global Data"][global_settings_profile]
	var gameState_dict :Dictionary = Static_Game_Dict["Game State"]
	#var gameStateDisplay :String = str_to_var(gameState_dict[str(gameState)]["Display Name"])["text"]

	set_player_movement_state(convert_string_to_type(gameState_dict[str(gameState)]["Player Can Move"]))
	show_hud(convert_string_to_type(gameState_dict[str(gameState)]["Show HUD"]))
	add_loading_screen_to_root(convert_string_to_type(gameState_dict[str(gameState)]["Show Load Screen"]))

func set_player_movement_state(canMove :bool):
	if player_node != null:
		player_node.set_character_movement(canMove)

func show_hud(show :bool):
	get_gui().get_node("HUD").visible = show


func add_loading_screen_to_root(load_scene:bool):
	if load_scene:
		var loadingScreenPath :String
		if Dynamic_Game_Dict.has("Global Data"):
			loadingScreenPath = Dynamic_Game_Dict["Global Data"][global_settings_profile]["Loading Screen"]
		else:
			var global_dict :Dictionary = import_data(table_save_path + "Global Data" + file_format)
			loadingScreenPath = global_dict[global_settings_profile]["Loading Screen"]
		var loadingScreen = load(loadingScreenPath).instantiate()
		root.get_node("UI/LoadingScreen").add_child(loadingScreen)
		root.get_node("UI/LoadingScreen").visible = true
	else :
		if root.get_node("UI/LoadingScreen").get_children().size() > 0:
			await root.get_tree().create_timer(2.0).timeout #EVENTUALLY ID LIKE TO CHANGE THE TIME TO A VARIABLE THAT THE USER CAN SET
			for child in root.get_node("UI/LoadingScreen").get_children():
				child.queue_free()
			root.get_node("UI/LoadingScreen").visible = false
	



##############################EVENT SCRIPTS#####################################3



#func change_local_variable(which_var:String, to_what:bool, event_name :String, event_node_name :String, event_node):
#	var local_variable_dict  = convert_string_to_type(Dynamic_Game_Dict["Event Save Data"][current_map_name][event_node_name]["Local Variables"])
#	for Variable in local_variable_dict:
#		if local_variable_dict[Variable]["Value 1"] == which_var:
#			local_variable_dict[Variable]["Value 2"] = to_what
#			Dynamic_Game_Dict["Event Save Data"][current_map_name][event_node_name]["Local Variables"] = local_variable_dict
#			break
#
#
#func change_global_variable(which_var:String, what_type: String,  to_what, event_name :String, event_node_name :String, event_node):
#	var global_variable_dict  = convert_string_to_type(Dynamic_Game_Dict["Global Variables"])
#	for id in global_variable_dict:
#		if global_variable_dict[id]["Display Name"] == which_var:
#			Dynamic_Game_Dict["Global Variables"][id][what_type] = to_what
#			break
#
#
#func remove_event(event_name :String, event_node_name:String, event_node):
#	event_node.update_event_data()
#	event_node.is_queued_for_delete = true
#
#
#func print_to_console(input_text :String ,event_name :String, event_node_name:String, event_node):
#	print(input_text)
#
#
#func wait(how_long: float, event_name :String, event_node_name:String, event_node):
#	await get_tree().create_timer(how_long).timeout
#
#
#func transfer_player(which_map :String, what_coordinates, event_name :String, event_node_name:String, event_node):
#	call_deferred("remove_player_from_map_node" ,current_map_node)
#	var map_path :String = get_mappath_from_displayname(which_map)
#	if current_map_name != which_map:
#		call_deferred("load_and_set_map",map_path)
#	await get_tree().create_timer(.25).timeout
#	player_node = await get_player_node()
#	player_node.set_player_position(convert_string_to_vector(what_coordinates))
#	remove_unused_maps()
#
#
#func remove_unused_maps():
#	var maps_node = root.get_node("map")
#	for child in maps_node.get_children():
#		if child != current_map_node:
#			for event in child.event_array:
#				event.is_queued_for_delete = true
#			child.queue_free()
#
#
#func modify_player_inventory(what :String, how_many , increase_value :String, event_name :String, event_node_name:String, event_node ):
#	var dict_static_items = AU3ENGINE.Static_Game_Dict["Items"]
#	var increase :bool = false
#	var modify_amount :int = int(abs(how_many))
#
#	if increase_value == "+":
#		increase = true
#
#	if !increase:
#		modify_amount = int(-abs(modify_amount))
#
#	if dict_static_items.has(what):
#		if!is_item_in_inventory(what):
#			Dynamic_Game_Dict["Inventory"][what] = {"ItemCount" : 0}
#		var inv_count = int(Dynamic_Game_Dict["Inventory"][what]["ItemCount"])
#		Dynamic_Game_Dict["Inventory"][what]["ItemCount"] =  inv_count + how_many
#	else:
#		print(what, " needs to be added to Item Table")
#
#	print(Dynamic_Game_Dict["Inventory"][what]["ItemCount"])
#	return Dynamic_Game_Dict["Inventory"][what]["ItemCount"]



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
