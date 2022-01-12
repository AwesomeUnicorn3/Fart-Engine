extends Control

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
var save_game_path = "user://"
var load_game_path = ""
var save_format = ".sav"
var dbmanData_save_path : String = "res://addons/Database_Manager/Data/"
var dict_loaded = false
var op_sys : String = ""

func _ready():
	op_sys = OS.get_name()
	emit_signal("DbManager_loaded")
	var tbl_data = import_data(dbmanData_save_path + "/Table Data.json")
	tables_list = list_files_in_directory(dbmanData_save_path, json)
	var dict = {}
	for d in tables_list:
		if d == "Table Data.json":
			pass
		elif d == "Options Player Data.json":
			var save_path_global = "user://OptionsData.json"
			var save_dir = list_files_in_directory(save_game_path, json)
			if save_dir.has("OptionsData.json"):
				Global_Game_Dict = import_data(save_path_global)
				###Updates global game dict from previous saves and overwrites with "Options" table data
				#Can delete with version 0.008
				if Global_Game_Dict["BGM"].has("Active"):
					Global_Game_Dict = import_data(dbmanData_save_path + "Options.json")
					save_global_options_data()
				###########
			else:
				Global_Game_Dict = import_data(dbmanData_save_path + "Options.json")
				save_global_options_data()
		else:
			var array = []
			var name = d
			array = name.rsplit(".")
			var tblname = array[0]
			var dictname = tbl_data[tblname]["Reference Dictionary"]
			var main_dict = save_dict
			dict[dictname] = import_data(dbmanData_save_path + d)

	Static_Game_Dict = dict
	set_var_type_dict(Static_Game_Dict)
	new_game()


func import_data(table_loc):
	var curr_tbl_data = {}
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


func list_files_in_directory(sve_path, file_type):
	array_load_savefiles = []
	var files = []
	var dir = Directory.new()
	dir.open(sve_path)
	dir.list_dir_begin()
	if sve_path == save_game_path and file_type == save_format:
		while true:
			var file = dir.get_next()
			if file == "":
				break
			elif file.ends_with(save_format):
				files.append(file)
				array_load_savefiles.append(file)
		
		
	else:
		while true:
			var file = dir.get_next()
			if file == "":
				break
			elif not file.begins_with(".") and file != "Table Data.json":
				if file.ends_with(file_type):
					files.append(file)
					array_load_files.append(file)
	dir.list_dir_end()
	return files


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
	save_id = Dynamic_Game_Dict["SaveID"]["Save"]["ID"]
	if int(save_id) == 0: #set save id when player loads game
		set_save_path()
	id = String(save_id)
	var time = OS.get_datetime()

	var dict_time = Dynamic_Game_Dict["Time"]["Save"]
	dict_time["Day"] = time["day"]
	dict_time["Month"] = time["month"]
	dict_time["Year"] = time["year"]
	dict_time["Hour"] = time["hour"]
	dict_time["Minute"] = time["minute"]
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
	list_files_in_directory(save_game_path, save_format)
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
	Dynamic_Game_Dict["SaveID"]["Save"]["ID"] = save_id
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
	tables_list = list_files_in_directory(dbmanData_save_path, json)
	set_var_type_table(tbl_data)
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
			var dictname = deleteme["Reference Dictionary"]
			var dynamic = deleteme["Dynamic"]
			if dynamic == true:
				dict[dictname] = import_data(dbmanData_save_path + d)
	Dynamic_Game_Dict = dict
	set_var_type_dict(Dynamic_Game_Dict)

func to_bool(value):
	value = str(value)
	var value_lower = value.to_lower()
	match value_lower:
		"yes":
			value = true
		"no":
			value = false
		"true":
			value = true
		"false":
			value = false
	return value


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

func get_file_name(name : String, filetype : String):
	name = name.trim_suffix(filetype)
	return name

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


func edit_dict(dict, itm_nm, amt):
	if Dynamic_Game_Dict[dict].has(itm_nm):
		Dynamic_Game_Dict[dict][itm_nm]["ItemCount"] += amt
	else:
		var item = Static_Game_Dict["Items"][itm_nm]
		Dynamic_Game_Dict[dict][itm_nm] = item
		Dynamic_Game_Dict[dict][itm_nm]["ItemCount"] += amt
