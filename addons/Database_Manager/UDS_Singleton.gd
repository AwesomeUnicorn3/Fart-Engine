extends DatabaseEngine
#SHOULD ONLY INCLUDE SCRIPT THAT I WANT ACCESSIBLE TO THE USER
signal save_complete
signal DbManager_loaded
signal refresh_UI

var root : Node
var Static_Game_Dict = {}
var Dynamic_Game_Dict := {}
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
	var tbl_data = import_data(table_save_path + "/Table Data.json")
	tables_list = list_files_with_param(table_save_path, json, ["Table Data.json"])
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
			var dictname = tbl_data[tblname]["Reference Name"]
			var main_dict = save_dict
			dict[dictname] = import_data(table_save_path + d)

	Static_Game_Dict = dict
	set_var_type_dict(Static_Game_Dict)
#	set_root_node()
#	new_game()
	update_key_bindings()

	print("Singleton Loaded and updated")

func set_root_node():
	var root_scene = load(import_data(table_save_path + "Global Data" + file_format)["Global Data"]["Project Root Scene"]).instance()
	var root_node_name = root_scene.get_node(".").name
	root_scene.queue_free()
	root = get_tree().root.get_node(root_node_name)

func get_root_node():
	return root

func delete_save_file(file_name : String):
	#Can include the .sav ext but is not required, it can be just save name "1"
	if file_name.get_extension() == save_format.trim_prefix("."):
		file_name = file_name.trim_suffix(save_format)

	var fileName = save_game_path + file_name + save_format

	var dir = Directory.new()
	dir.remove(fileName)


func get_map_name(map_path : String):
	var map_dict : Dictionary = import_data(table_save_path + "Maps" + file_format)
	var map_name : String
	for i in map_dict:
		if map_dict[i]["Path"] == map_path:
			map_name = map_dict[i]["Display Name"]
			return map_name
		else:
			print("Error " + map_path + " not found")

func load_map(map_path := ""):
	root.get_node("map").add_child(load(map_path).instance())
	Dynamic_Game_Dict["Global Data"]["Global Data"]["Current Map"] = map_path

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
	save_id = Dynamic_Game_Dict["Global Data"]["Global Data"]["ID"]
	if int(save_id) == 0: #set save id when player loads game
		set_save_path()
	id = String(save_id)
	var time = OS.get_datetime()
	Dynamic_Game_Dict["Global Data"]["Global Data"]["Time"] = time

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


func get_save_files():
	var files = list_files_with_param(save_game_path, save_format)
	return files

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

	while doFileExists:
		save_id = save_id + 1
		id = String(save_id)
		save_path = save_game_path + id + save_format
		directory = Directory.new();
		doFileExists = directory.file_exists(save_path)
	Dynamic_Game_Dict["Global Data"]["Global Data"]["ID"] = save_id

func load_game(file_name : String):
	#Can include the .sav ext but is not required, it can be just save name "1"
	if file_name.get_extension() == save_format.trim_prefix("."):
		file_name = file_name.trim_suffix(save_format)

	var fileName = save_game_path + file_name + save_format
	var load_path = fileName
	var load_file = File.new()

	if not load_file.file_exists(load_path):
		return
	load_file.open(load_path, File.READ)
	var data = {}
	Dynamic_Game_Dict = parse_json(load_file.get_as_text())
	set_var_type_dict(Dynamic_Game_Dict)
	load_file.close()
	load_map(get_current_map_path())
	dict_loaded = true

func get_player_node():
	return root.get_node("YSort/Player")


func set_player_position():
	var player = get_player_node()
	print(udsmain.Dynamic_Game_Dict['Global Data']["Global Data"]["Player POS"])
	var player_position = convert_string_to_Vector(Dynamic_Game_Dict['Global Data']["Global Data"]["Player POS"])
	player.set_global_position(player_position)





func new_game():
	var tbl_data = import_data( table_save_path + "Table Data.json")
	tables_list = list_files_with_param(table_save_path, json)
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
				dict[dictname] = import_data(table_save_path + d)
				
	Dynamic_Game_Dict = dict
	
	#Set intital player inventory
	set_var_type_dict(Dynamic_Game_Dict)
#	var intitial_inventory_dict = convert_string_to_type(Static_Game_Dict["Characters"][get_lead_character()]['Starting Inventory'])
#	add_newGame_inventory(intitial_inventory_dict)
	Dynamic_Game_Dict["Global Data"]["Global Data"]["NewGame"] = false
	Dynamic_Game_Dict["Global Data"]["Global Data"].erase("Project Root Scene")
	Dynamic_Game_Dict["Global Data"]["Global Data"].erase("Project Root Scene")
	#Add new map to root/map
	load_map(get_starting_map_path())


func get_game_title():
	var initial_save_data : Dictionary = import_data(table_save_path + "Global Data" + file_format)
	var game_title = initial_save_data["Global Data"]["Game Title"]
	return game_title

func get_starting_map_path():
	var current_map_name : String = Dynamic_Game_Dict['Global Data']["Global Data"]['Starting Map']
	var current_map_path := ""
	for i in Static_Game_Dict['Maps']:
		if current_map_name == Static_Game_Dict['Maps'][i]["Display Name"]:
			current_map_path = Static_Game_Dict['Maps'][i]["Path"]
			Dynamic_Game_Dict["Global Data"]["Global Data"]["Current Map"] = current_map_path
			Dynamic_Game_Dict["Global Data"]["Global Data"].erase("Starting Map")
			break
	return current_map_path

func get_current_map_path():
	var current_map_path : String = Dynamic_Game_Dict['Global Data']["Global Data"]['Current Map']
#	var current_map_path := ""
#	for i in Static_Game_Dict['Maps']:
#		if current_map_name == Static_Game_Dict['Maps'][i]["Display Name"]:
#			current_map_path = Static_Game_Dict['Maps'][i]["Path"]
#			Dynamic_Game_Dict["Global Data"]["Global Data"]["Current Map"] = current_map_path
#			Dynamic_Game_Dict["Global Data"]["Global Data"].erase("Starting Map")
#			break
	return current_map_path

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


func get_collision_shape(sprite_field_name := "Idle Sprite", character_name :String = get_lead_character()):
#func get_character_sprite_animation(sprite_field_name := "Idle Sprite", character_name :String = get_lead_character()):
	var sprite_texture_info = udsmain.Static_Game_Dict['Characters'][character_name][sprite_field_name]
	var character_sprite_array : Array
	var character_animated_sprite : AnimatedSprite = AnimatedSprite.new()
	var collision_shape = CollisionShape2D.new()
#	character_animated_sprite.name = sprite_field_name
	if character_sprite_array != sprite_texture_info:
#		print(characterSprite, " ", sprite_field_name)
		character_sprite_array = udsmain.Static_Game_Dict['Characters'][character_name][sprite_field_name] #udsmain.Static_Game_Dict['Characters'][activeCharacterName]['Walk Sprite']
		var frameVector : Vector2 = udsmain.convert_string_to_Vector(character_sprite_array[1])
		var spriteMap = load(table_save_path + icon_folder + character_sprite_array[0])
		#SET COLLISION SHAPE = TO SPRITE SIZE
		var sprite_size = Vector2(spriteMap.get_size().x/frameVector.y,spriteMap.get_size().y/frameVector.x)
		var new_rectangle_2d : = RectangleShape2D.new()
		collision_shape.set_shape(new_rectangle_2d)
		collision_shape.shape.set_extents(Vector2(sprite_size.x / 2, sprite_size.y / 2))
		collision_shape.name = "Collision_Shape"
		#CREATE ANIMATION BASED ON THE NUMBER OF FRAMES
#		var total_frames = frameVector.x * frameVector.y
#		var spriteFrame = SpriteFrames.new()
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
	return collision_shape
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
