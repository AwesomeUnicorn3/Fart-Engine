extends DatabaseEngine
#SHOULD ONLY INCLUDE SCRIPT THAT I WANT ACCESSIBLE TO THE USER
signal save_game_data
signal save_complete
signal DbManager_loaded
signal map_loaded
signal clear_loading_screen
signal map_data_updated
signal in_game_menu_closed

@onready var EVENTS :EventEngine = EventEngine.new()
@onready var UIENGINE : UIEngine = UIEngine.new()

var actionState_dict :Dictionary = {"action_name": "", "is_pressed": false, "action_strength" : 0.0}
var CurrentInputAction_dict :Dictionary = {}

var inputMapActions :Array
var movementDirections_dict :Dictionary
var Static_Game_Dict := {}
var Dynamic_Game_Dict := {}
var Global_Options_Dict := {}

var settings_dict :Dictionary = {}
var global_data_dict :Dictionary = {}
var global_settings_profile :String = ""

var save_dict = {}
var curr_tbl_loc = ""
var DBManager_Active : bool = true
var importtext = false
var tables_list = []
var DBdict = {}

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
var operatingSystem :String


func _ready():
	operatingSystem = OS.get_name()
	Static_Game_Dict = create_dictionary_of_all_tables()
	set_var_type_dict(Static_Game_Dict)
	set_root_node()
	
	add_required_scenes_to_UI()
	set_game_state(gameState) #this should get the game state from the global data [selected profile]
	update_key_bindings()
	


func create_dictionary_of_all_tables():
	var table_list_dict = import_data("Table Data")
	tables_list = list_files_with_param(table_save_path, table_file_format, ["Table Data.json"])
	var dict := {}
	for tableName in tables_list:
		if tableName == "Options Player Data.json":
			var save_path_global = "user://OptionsData.json"
			var save_dir = list_files_with_param(save_game_path, table_file_format)
			if save_dir.has("OptionsData.json"):
				Global_Options_Dict = import_data(save_path_global)
			else:
				Global_Options_Dict = import_data("Options")
				save_global_options_data()
		else:
			var array = []
			var eventName = tableName
			array = eventName.rsplit(".")
			var tblname = array[0]
			var dictname :String

			if str_to_var(table_list_dict[tblname]["Display Name"]) != null:
				dictname = str_to_var(table_list_dict[tblname]["Display Name"])["text"]
			else:
				dictname = table_list_dict[tblname]["Display Name"]
			dict[dictname] = import_data(tblname)
	return dict


#func get_event_dict(event_name:String):
##	var table_list_dict = import_data("Table Data")
#
#	var event_list = list_files_with_param(event_folder, table_file_format)
#	var all_events_dict := {}
#	var this_event_dict:= {}
#	for eventName in event_list:
##		if tableName == "Options Player Data.json":
##			var save_path_global = "user://OptionsData.json"
##			var save_dir = list_files_with_param(save_game_path, table_file_format)
##			if save_dir.has("OptionsData.json"):
##				Global_Options_Dict = import_data(save_path_global)
##			else:
##				Global_Options_Dict = import_data("Options")
##				save_global_options_data()
##		else:
#		var array = []
##		var eventName = eventName
#		array = eventName.rsplit("_")
#		var tblname = array[0]
#		var dictname :String
#		print(array)
##
##			if str_to_var(table_list_dict[tblname]["Display Name"]) != null:
##				dictname = str_to_var(table_list_dict[tblname]["Display Name"])["text"]
##			else:
##				dictname = table_list_dict[tblname]["Display Name"]
#		all_events_dict[eventName] = import_event_data(eventName)
#
#	this_event_dict = all_events_dict[event_name]
#	return this_event_dict



func _process(delta):
	input_process()


func input_process():
	for actionKey in AU3ENGINE.Static_Game_Dict["Input Actions"]:
		var actionType :String = str(AU3ENGINE.Static_Game_Dict["Input Actions"][actionKey]["Action Type"])
		var actionName :String = AU3ENGINE.get_displayName_text(str_to_var(AU3ENGINE.Static_Game_Dict["Input Actions"][actionKey]["Display Name"]))

		if actionType == "1":
			if !CurrentInputAction_dict.has(actionKey):
				CurrentInputAction_dict[actionKey] = actionState_dict.duplicate(true)
				CurrentInputAction_dict[actionKey]["action_name"] = actionName
				
			if Input.is_action_pressed(actionName):
				CurrentInputAction_dict[actionKey]["is_pressed"] = true
				CurrentInputAction_dict[actionKey]["action_strength"] = Input.get_action_strength(actionName)
				if Input.is_action_just_pressed(actionName):
					pass
					#(actionName, "Just Pressed")
					#MAYBE EMIT A SIGNAL?
			else:
				CurrentInputAction_dict[actionKey]["action_strength"] = 0.0
				CurrentInputAction_dict[actionKey]["is_pressed"] = false


func _input(event):
		for actionKey in Static_Game_Dict["Input Actions"]:
			var actionType :String = str(Static_Game_Dict["Input Actions"][actionKey]["Action Type"])
			if actionType == "6": #Shortcut input
				if gameState == "2":
					var action :String = get_displayName_text(str_to_var(Static_Game_Dict["Input Actions"][actionKey]["Display Name"]))
					var actionStrength :float = Input.get_action_strength(action)
					var is_action_just_pressed :bool = Input.is_action_just_pressed(action)
					#MAYBE PUT A CALL V HERE ONLY IF IS ACTION JUST PRESSED IS TRUE, THAT WILL CALL
					#A METHOD SET IN THE TABLE (SIMILAR TO UI BUTTONS)
					if action == "Open Main Menu" and is_action_just_pressed:
						show_in_game_main_menu()


func show_in_game_main_menu(show :bool = true):
	root.get_node("UI/InGameMainMenu").visible = show
	if show:
		set_game_state("6")
		await in_game_menu_closed
		set_game_state("2")


func quit_game():
	pass
	#RETURN TO MAIN MENU


func get_UI_window():
	var UI = root.get_node("UI")
	return UI


func get_gui():
	var gui = get_UI_window().get_node("GUI")
	return gui


func delete_save_file(file_name : String):
	#Can include the .sav ext but is not required, it can be just save name "1"
	if file_name.get_extension() == save_format.trim_prefix("."):
		file_name = file_name.trim_suffix(save_format)
	var fileName = save_game_path + file_name + save_format
	var dir :DirAccess = DirAccess.open(save_game_path)
	dir.remove(fileName)


func set_current_map(map_node :Node, map_path:String):
	current_map_node = map_node
	current_map_name = map_node.name
	current_map_path = current_map_node.get_path()
	current_map_scene_path = map_path
	current_map_key =  await get_map_key(current_map_scene_path)
	await get_tree().create_timer(0.25).timeout


func get_map_dict() -> Dictionary:
	var map_dict : Dictionary = await import_data("Maps")
	return map_dict


func get_map_key(map_path : String):
	var map_dict : Dictionary = await get_map_dict()
	var map_key : String =""
	for map_id in map_dict:
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
	Dynamic_Game_Dict["Global Data"][await get_global_settings_profile()]["Current Map"] = map_path
	await set_current_map(map_node, map_path)
	emit_signal("map_data_updated")
	add_map_to_events(await get_map_name(map_path))
	#hide load screen
	set_game_state("2")


func add_map_to_events(map_name:String):
	if !Dynamic_Game_Dict["Event Save Data"].has(map_name):
			Dynamic_Game_Dict["Event Save Data"][map_name] = {}


func save_global_options_data():
	save_file("user://OptionsData.json", Global_Options_Dict)


func save_game():
	var return_Save_ID
	emit_signal("save_game_data")
	current_map_node.save_event_data()
	save_id = Dynamic_Game_Dict["Global Data"][await get_global_settings_profile()]["Save ID"]
	if int(save_id) == 0: #set save id when player loads game
		set_save_path()
	id = str(save_id)
	var time = Time.get_date_dict_from_system()
	Dynamic_Game_Dict["Global Data"][await get_global_settings_profile()]["Time"] = time
	var save_d :Dictionary = Dynamic_Game_Dict
	var save_path :String = save_game_path + id + save_format
	save_file(save_path, save_d)
	emit_signal("save_complete")
	return_Save_ID = id
	return return_Save_ID


func get_save_files():
	var files = list_files_with_param(save_game_path, save_format)
	return files


func set_save_path():
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
		doFileExists = directory.file_exists(save_path)
	Dynamic_Game_Dict["Global Data"][await get_global_settings_profile()]["Save ID"] = save_id

func load_game(file_name : String):
	dict_loaded = false
	Dynamic_Game_Dict = load_save_file(file_name)
	load_and_set_map(await get_current_map_path())
	var player_pos  = convert_string_to_vector(get_field_value("Global Data", await get_global_settings_profile(), "Player POS"))
	player_node.set_player_position(player_pos)
#	add_all_items_to_player_inventory()
	Dynamic_Game_Dict["Global Data"][await get_global_settings_profile()]["Is Game Active"] = true
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
	parent.remove_child(objectNode)
	current_map_node.ysort_node.add_child(objectNode)


func remove_player_from_map_node(current_map_node):
	player_node.get_parent().remove_child(player_node)
	root.add_child(player_node)


func set_player_position_in_db(new_position):
	set_save_data_value("Global Data", await get_global_settings_profile(), "Player POS", new_position)


func get_player_position_from_db():
	var player_vector_position = get_field_value("Global Data", await get_global_settings_profile(), "Player POS")
	return player_vector_position


func set_save_data_value(table_name :String, key_name :String, value_name :String, new_value):
	Dynamic_Game_Dict[table_name][key_name][value_name] = new_value


func get_field_value(table_name :String, key_name :String, value_name :String, from_save_dict :bool = true):
	var rtn_value
	if from_save_dict and Dynamic_Game_Dict.has(table_name):
		rtn_value = convert_string_to_type(str(Dynamic_Game_Dict[table_name][key_name][value_name]))
	else:
		rtn_value = convert_string_to_type(str(Static_Game_Dict[table_name][key_name][value_name]))
	return rtn_value


func new_game():
	dict_loaded = false
	var tbl_data = import_data("Table Data")
	tables_list = list_files_with_param(table_save_path, table_file_format)
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
				dict[dictname] = import_data(tblname)

	Dynamic_Game_Dict = dict
	set_var_type_dict(Dynamic_Game_Dict)
	add_all_items_to_player_inventory()
	load_and_set_map(await get_starting_map_path())
	Dynamic_Game_Dict["Global Data"][await get_global_settings_profile()]["Is Game Active"] = true
	dict_loaded = true
	emit_signal("DbManager_loaded")


func get_game_title():
	var initial_save_data : Dictionary = await import_data("Global Data")
	var game_title = str_to_var(initial_save_data[await get_global_settings_profile()]["Game Title"])["text"]
	return game_title

func get_starting_map_path():
	var current_map_key : String = var_to_str(Dynamic_Game_Dict["Global Data"][await get_global_settings_profile()]['Starting Map'])
	var current_map_path :String = Static_Game_Dict['Maps'][current_map_key]["Path"]
	return current_map_path

func get_current_map_path() -> String:
	var current_map_path : String = Dynamic_Game_Dict['Global Data'][await get_global_settings_profile()]['Current Map']
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
	var control_template :String= str(global_data_dict[await get_global_settings_profile()]["Default Controls"])
	var menu_template :String = str(global_data_dict[await get_global_settings_profile()]["Default Menu Controls"])
	for action in InputMap.get_actions():
		inputMapActions.append(action)

	clear_key_bindings()
	add_input_actions(str_to_var(control_dict[control_template]["Input List"]))
	add_input_actions(str_to_var(control_dict[menu_template]["Input List"]))


func add_input_actions(selectedControl_dict :Dictionary):
	var inputDict :Dictionary = selectedControl_dict["input_dict"]
	var actions_dict:Dictionary = import_data("Input Actions")
	for keyOption in inputDict:
		var actionName :String = inputDict[keyOption]["options_dict"]["action"]
		actionName = convert_string_to_type(actions_dict[actionName]["Display Name"])["text"]
		var keysDict :Dictionary = inputDict[keyOption]["input_dict"]
		for key in keysDict:
			var controlOption_dict :Dictionary = keysDict[key]
			var deviceClass : String = controlOption_dict["device class"]
			var keycode : int = controlOption_dict["keycode"]
			var keyname : String = controlOption_dict["keyname"]
			if !inputMapActions.has(actionName):
				InputMap.add_action(actionName)
				inputMapActions.append(actionName)
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

##########################END INVENTORY FUNCTIONS################333
func add_required_scenes_to_UI():
	var global_dict :Dictionary
	if Dynamic_Game_Dict.has("Global Data"):
		global_dict = Dynamic_Game_Dict
		Dynamic_Game_Dict["Global Data"][await get_global_settings_profile()]["Game State"] = gameState
	else:
		global_dict = Static_Game_Dict
	var menu_scenes :Dictionary = Static_Game_Dict["UI Scenes"]
	var global_data_dict :Dictionary = global_dict["Global Data"][await get_global_settings_profile()]

	var playerScene_ID :String = str(global_data_dict["Default Player Scene"])
	var playerScene_Scene :Variant = load(menu_scenes[playerScene_ID]["Path"]).instantiate()
	root.add_child(playerScene_Scene)
	playerScene_Scene.set_name("Player")

	add_map_node_to_root()
	add_UI_node_to_root()
	
	var TitleScreen_ID :String = str(global_data_dict["Title Screen"])
	var TitleScreen_Scene :Variant = load(menu_scenes[TitleScreen_ID]["Path"]).instantiate()
	root.get_node("UI").add_child(TitleScreen_Scene)
	TitleScreen_Scene.visible = true
	TitleScreen_Scene.set_name("TitleScreen")
	
	var GUI_ID :String = str(global_data_dict["Default GUI"])
	var GUI_Scene :Variant = load(menu_scenes[GUI_ID]["Path"]).instantiate()
	root.get_node("UI").add_child(GUI_Scene)
	GUI_Scene.visible = false
	GUI_Scene.set_name("GUI")
	
	var MainMenu_ID :String = str(global_data_dict["Default In-Game Menu"])
	var Menu_Scene :Variant = load(menu_scenes[MainMenu_ID]["Path"]).instantiate()
	root.get_node("UI").add_child(Menu_Scene)
	Menu_Scene.visible = false
	Menu_Scene.set_name("InGameMainMenu")

	add_loading_screen_to_UI()
	add_dialog_node_to_UI()
	add_audio_node_to_UI()


func add_map_node_to_root():
	var node :Node2D = Node2D.new()
	node.set_name("map")
	root.add_child(node)


func add_UI_node_to_root():
	var node :CanvasLayer = CanvasLayer.new()
	node.set_name("UI")
	root.add_child(node)

func add_loading_screen_to_UI():
	var node :Control = Control.new()
	node.set_anchors_preset(Control.PRESET_FULL_RECT)
	node.set_name("LoadingScreen")
	node.visible = false
	get_UI_window().add_child(node)

func add_dialog_node_to_UI():
	var node :Control = Control.new()
	node.set_anchors_preset(Control.PRESET_FULL_RECT)
	node.set_name("Dialog")
	node.visible = false
	get_UI_window().add_child(node)

func add_audio_node_to_UI():
	var node :Node = Node.new()
	node.set_name("EventAudio")
	get_UI_window().add_child(node)

func set_game_state(newGameState :String):
	gameState = newGameState
	var global_dict :Dictionary
	if Dynamic_Game_Dict.has("Global Data"):
		global_dict = Dynamic_Game_Dict
		Dynamic_Game_Dict["Global Data"][await get_global_settings_profile()]["Game State"] = gameState
	else:
		global_dict = Static_Game_Dict

	var global_data_dict :Dictionary = global_dict["Global Data"][await get_global_settings_profile()]
	var gameState_dict :Dictionary = Static_Game_Dict["Game State"]

	set_player_movement_state(convert_string_to_type(gameState_dict[str(gameState)]["Player Can Move"]))
	await add_loading_screen_to_root(convert_string_to_type(gameState_dict[str(gameState)]["Show Load Screen"]))
	show_hud(convert_string_to_type(gameState_dict[str(gameState)]["Show HUD"]))
	
func set_player_movement_state(canMove :bool):
	if player_node != null:
		player_node.set_character_movement(canMove)

func show_hud(show :bool):
	get_gui().visible = show


func add_loading_screen_to_root(load_scene:bool):
	var global_dict :Dictionary
	if Dynamic_Game_Dict.has("Global Data"):
		global_dict = Dynamic_Game_Dict
		Dynamic_Game_Dict["Global Data"][await get_global_settings_profile()]["Game State"] = gameState
	else:
		global_dict = Static_Game_Dict
	var menu_scenes :Dictionary = Static_Game_Dict["UI Scenes"]
	var global_data_dict :Dictionary = global_dict["Global Data"][await get_global_settings_profile()]


	if load_scene:
		var loadingScreenPath :String
		var loadingScene_ID :String = str(global_data_dict["Loading Screen"])
		var loadingScene_Scene :Variant = load(menu_scenes[loadingScene_ID]["Path"]).instantiate()
		get_UI_window().get_node("LoadingScreen").add_child(loadingScene_Scene)
		loadingScene_Scene.visible = true
		loadingScene_Scene.set_name("GUI")
		get_UI_window().get_node("LoadingScreen").visible = true

	else :
		if root.get_node("UI/LoadingScreen").get_children().size() > 0:
			await root.get_tree().create_timer(.5).timeout #EVENTUALLY ID LIKE TO CHANGE THE TIME TO A VARIABLE THAT THE USER CAN SET
			for child in root.get_node("UI/LoadingScreen").get_children():
				child.queue_free()
			get_UI_window().get_node("LoadingScreen").visible = false
