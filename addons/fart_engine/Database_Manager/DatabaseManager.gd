@tool
class_name DatabaseManager extends Control

signal Editor_Refresh_Complete
signal get_datatype_complete

signal save_file_complete
#signal table_save_complete




#Static var
static var KEY = "KEY"
static var FIELD = "FIELD"
#Dictionaries
static var project_settings_dict :Dictionary = {}
static var global_data_dict :Dictionary = {}
static var do_not_delete_dict: Dictionary = {}
static var button_dict :Dictionary = {}
static var display_form_dict :Dictionary = {}
static var category_settings_dict: Dictionary = {}


static var datatype_dict:Dictionary = {}
static var all_events_dict: Dictionary = {}
static var all_tables_merged_dict: Dictionary = {}
static var all_tables_merged_data_dict: Dictionary = {}
static var all_tables_dict_sorted: Dictionary = {}
static var all_popups_dict:Dictionary = {}
static var all_fields_dict: Dictionary = {}
static var all_tables_settings_dict: Dictionary = {}
static var all_tables_settings_data_dict: Dictionary = {}
#static var categories_dict: Dictionary = {}
static var categories_data_dict: Dictionary = {}


static var selected_tab_name :String= ""
static var selected_category :String = "1"
static var is_uds_main_updating: bool = false
static var is_editor_saving:bool = false
static var all_tables_loaded:bool = false
static var fart_root : Node
static var op_sys : String = ""


static var global_settings_profile :String = ""

static var starting_position_node:Sprite2D

#NEED TO SET THESE WHEN DATABASE IS LOADED FROM PROJECT SETTINGS TABLE
static var save_format = ".sav"
static var table_save_path = "res://fart_data/"
static var table_file_format = ".json"
static var table_info_file_format = "_data.json"
static var save_game_path = "user://"
static var icon_folder = "png/"
static var sfx_folder =  "sfx/"
static var event_folder = "events/"
#NEED TO SET THESE WHEN DATABASE IS LOADED FROM PROJECT SETTINGS TABLE

static var BTN_focus_index :String 



static func update_all_event_list(update_data :bool = false): #POSSIBLY NEED TO MOVE TO EVENT MANAGER
	if update_data or all_events_dict == {}:
		all_events_dict = await get_list_of_events()
		print("EVENT DICT UPDATED")


static func get_global_settings_profile(is_temp:bool = false) -> String: #CONFIG FILE
	if !Engine.is_editor_hint() and !is_temp:
		if global_settings_profile == "":
			await set_global_settings_profile()

		return global_settings_profile
	else:
		var settings_dict =  import_data("10038")
		var profile_index :String = settings_dict["1"]["Game Profile"]
		return profile_index

func set_project_settings_dict():
	#CALLED BEFORE SETTING ALL TABLES MERGED DICT
	project_settings_dict = import_data("10038")


func set_global_data_dict():
	#CALLED BEFORE SETTING ALL TABLES MERGED DICT
	global_data_dict = import_data("10002")

#func set_categories_dict():
#	#CALLED BEFORE SETTING ALL TABLES MERGED DICT
#	categories_dict = await import_data("10006")
#	categories_data_dict = await import_data("10006", true)

static func set_global_settings_profile():
	var profile_index :String =  await import_data("10038")["1"]["Game Profile"]
	global_settings_profile = profile_index
	return global_settings_profile


func get_id_from_display_name(table_dictionary :Dictionary, display_name :String):
	var index :String
	var id_display_name :String 
	for id in table_dictionary:
		if table_dictionary[id].has("Display Name"):
			id_display_name = get_value_as_text(table_dictionary[id]["Display Name"])
			if id_display_name == display_name:
				index = id
				break
	return index


static func list_files_with_param(dirPath, file_type, ignore_table_array : Array = [], array_exclude_begins_with : Array = []) -> Array:
	var array_load_files :Array= []
	var files :Array = []
	var dir :DirAccess = DirAccess.open(dirPath)
#	if deep_search:
#		var dir_folder: DirAccess = DirAccess.open(dirPath)
#		dir_folder


	dir.list_dir_begin()
	array_exclude_begins_with.append(".")
	while true:
		var file = dir.get_next()
		#print("FILE NAME: ", file)
		var file_begings_with = file.left(0)
		if file == "":
			break
		elif !array_exclude_begins_with.has(file_begings_with):
			if !ignore_table_array.has(file):
				if file.ends_with(file_type):
					if !file.ends_with(table_info_file_format):
						files.append(file)
						array_load_files.append(file)
		else:
			print("An Error Has occured trying to access: ", dirPath)
			break
	dir.list_dir_end()
	return files


func list_all_files_in_folder(dir: DirAccess, file_type,  ignore_table_array : Array = [], array_exclude_begins_with : Array = []):
	var array_load_files = []
	var files = []
	dir.list_dir_begin()
	array_exclude_begins_with.append(".")
	while true:
		var file = dir.get_next()
		#print("FILE NAME: ", file)
		var file_begings_with = file.left(0)
		if file == "":
			break
		elif !array_exclude_begins_with.has(file_begings_with):
			if !ignore_table_array.has(file):
				if file.ends_with(file_type):
					if !file.ends_with(table_info_file_format):
						files.append(file)
						array_load_files.append(file)
		else:
			print("An Error Has occured trying to access file: ")
			break
	dir.list_dir_end()


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
		print("Error Could not open file at: " + table_path)
	else:
		var currdata_json = json_object.parse(currdata_dir.get_as_text())
		curr_tbl_data = json_object.get_data()
	return curr_tbl_data



static func get_list_of_events(for_dropdown:bool = false) -> Dictionary:
	var return_dict:Dictionary = {}
	var event_array :Array = list_files_with_param(table_save_path + event_folder,table_file_format)
	var index:= 1
	var return_value

	for eventPath in event_array:
		var name_array:Array = eventPath.rsplit(".")
		var eventID: String = name_array[0]
		var curr_event_dict:Dictionary = await import_event_data(eventID)
		var eventName:String = get_value_as_text(curr_event_dict["0"]["Display Name"])

		if for_dropdown:
			return_dict[str(index)] = [eventName, eventID,  "0"]
			index += 1
			return_value = return_dict
		else:
#			print("Event ID: ", eventID)
			return_dict[eventID] = curr_event_dict
	return return_dict



	#IMPORTING THE TABLE DATA INFORATION ONLY LOADS THE TABLE DATA INFORMATION
	#WHY!!!!?????
static func import_event_data(event_name:String, get_event_data:bool = false):
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
#	emit_signal("import_complete")
#	print(curr_event_data)
	return curr_event_data


static func import_data(table_name : String, get_table_data :bool = false):
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

	return curr_tbl_data


func set_background_theme(background_node: ColorRect):
#	print("BUTTON THEME: ", group)
	#SET COLOR BASED ON GROUP
	#get project table
	var project_table: Dictionary = import_data("10038")
	var fart_editor_themes_table: Dictionary = import_data("10025")
	
	var theme_profile: String = project_table["1"]["Fart Editor Theme"]
	var category_color: Color = str_to_var(fart_editor_themes_table[theme_profile]["Background"])
	background_node.set_base_color(category_color)



static func save_file(sv_path, tbl_data:Dictionary):
#Save dictionary to .json upon user confirmation
	print("SAVE FILE BEGIN")
	var save_file :FileAccess = FileAccess.open(sv_path,FileAccess.WRITE)
	if save_file == null:
		print("Error Could not update file")
	else:
		print("SAVE FILE FUNC BEGIN: ", sv_path)
		var save_d = tbl_data
		var jsonObject = JSON.new()
		#save_file.open(sv_path, File.WRITE)
		var json_string = jsonObject.stringify(save_d)
		#print("JSON STRING: ", json_string)
		save_file.store_string(json_string)
		print("save completed successfully")

	print("SAVE FILE END")


func list_values_in_display_order(data_dict: Dictionary):
	var sorted_dict: Dictionary = {}
	for keyID in data_dict[FIELD].size():
		#print("KEY ID: LIST VALUES IN: ", keyID)
		var item_number:String = str(keyID + 1)
		#print("LIST VALUES IN: ITEM NUMBER: ", item_number)
		var label :String = data_dict[FIELD][item_number]["FieldName"] #Use the row_dict key (item_number) to set the button label as the item name
		sorted_dict[item_number] = label
	return sorted_dict


func update_project_settings(): #called when save_all_db_files is run
	if project_settings_dict == {}:
		set_project_settings_dict()
	set_target_screen_size()
	set_game_root()


func set_target_screen_size():
	#var project_settings_dict: Dictionary = project_settings_dict
	#print("TARGET SCREEN SIZE: ",convert_string_to_type(all_tables_merged_dict["1"]["Target Screen Size"],"9") )
#	while !all_tables_merged_dict.has("10038"):
#		print("ERROR TABLE NOT IN DICTIOANRY")
#		await get_tree().process_frame
	all_tables_merged_dict["10038"] = await import_data("10038")
#	if !all_tables_loaded:
#		print("TABLES STILL LOADING")
#		await get_tree().process_frame
	print("TARGET SCREEN SIZE DICT: ", all_tables_merged_dict["10038"]["1"])
	var screen_size:Vector3 = convert_string_to_vector(all_tables_merged_dict["10038"]["1"]["Target Screen Size"])
	var target_screen_size_x: int = screen_size.x
	var target_screen_size_y: int = screen_size.y

	print("TARGET SCREEN SIZE : ", screen_size)
	var current_screen_size_x = ProjectSettings.get("display/window/size/viewport_width")
	var current_screen_size_y = ProjectSettings.get("display/window/size/viewport_height")
	
	if target_screen_size_x != current_screen_size_x:
		ProjectSettings.set("display/window/size/viewport_width", target_screen_size_x) 
		ProjectSettings.set("display/window/size/viewport_height", target_screen_size_y) 

func set_game_root():
	var settings_profile :String = await get_global_settings_profile()
	var root_ID : String = all_tables_merged_dict["10002"][settings_profile]["Project Root Scene"]
	var root_path = all_tables_merged_dict["10044"][root_ID]["Path"]
	var current_root_scene = ProjectSettings.get("application/run/main_scene")
	if root_path != current_root_scene:
		ProjectSettings.set("application/run/main_scene", root_path) 


func get_default_dialog_scene_path() ->String:
	var root_ID : String =all_tables_merged_dict["10002"][await get_global_settings_profile()]['Default Dialog Box']
	var scene_path :String = all_tables_merged_dict["10044"][root_ID]["Path"]

	return scene_path

#
#func set_root_node():
#	fart_root = DatabaseManager.fart_root


func get_root_node():
	return fart_root


func is_file_in_folder(path : String, file_name : String):
	var value = false
	var dir :bool = FileAccess.file_exists(path + file_name) #ClEAR WHEN DONE TESTING
	if dir:
		value = true
	else:
		print(file_name, " Does NOT Exist :(")

	return value


#_________________________-SPECIAL POSIBBLY ONE TIME USE SCRIPTS---------------------------------




#----------------------------------------------------------------------------- Need to sort functions below
static func custom_to_bool(value):
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


static func convert_string_to_type(variant, datatype = ""):
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

static func string_to_array(value: String):
	var value_array = str_to_var(value)
	return value_array



static func convert_string_to_vector(value : String):
	
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
	#print("VECTOR: ", vector)
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


static func string_to_dictionary(value):
	if typeof(value) == TYPE_STRING:
		value = str_to_var(value)
	return value


#func add_input_field(par, node_path:String):
##	print("PARENT NODE: ", par)
##	print("NODE PATH: ", node_path)
#	var node = load(node_path)
#	if node != null:
#		var new_node = node.instantiate()
##		print("NODE NAME: ", new_node.name)
#		par.add_child(new_node)
##		new_node.set_owner(par)
#		return new_node
#	else:
#		print("UNABLE TO ADD A NULL NODE")


func is_table_dropdown_list(tableName :String):
	var tables_dict = all_tables_merged_dict["10000"]
	var table_data = all_tables_merged_data_dict["10000"]
	var isTableDropdownList :bool = false
	for i in range(0, tables_dict.size()):
		var index :String = str(i + 1)
		var currTableName :String = table_data[KEY][index]["FieldName"]
		if currTableName == tableName:
			isTableDropdownList = convert_string_to_type(tables_dict[currTableName]["Show in Dropdown Lists"])
			break
	#return

static func set_datatype_dict()-> void:
	if datatype_dict == {}:
		datatype_dict = import_data("10017")


static func get_datatype(field_name:String, table_name:String)-> String:
	set_datatype_dict()
	var data_type: String = "1"
#	print("TABLE DATA DICT: ", table_data_dict)
#	print("FIELD ID: ", field_ID)
	var data_dict_column :Dictionary
	if all_tables_merged_data_dict[table_name].has(FIELD):
		data_dict_column = all_tables_merged_data_dict[table_name][FIELD]
		for datakey in data_dict_column:
			#print("DATAKEY: ", datakey)
			#print("FIELD NAME: ", field_name)
			var currFieldName:String = data_dict_column[datakey]["FieldName"]
			if currFieldName == field_name:
				data_type = data_dict_column[datakey]["DataType"]
				break
	#if data_type == "":
#		print(table_data_dict)
		#print("NO DATATYPE FOUND FOR: ", field_name)
#	print("GET DATATYPE RETURN VALUE: ", data_type)
	return data_type

#
#static func get_datatype(field_ID:String, table_data_dict :Dictionary) ->String:
#	var data_type: String = "1"
#
#	data_type = table_data_dict[FIELD][field_ID]["DataType"]
#	print("RETURN DATATYPE: ", data_type)
#	return data_type


func get_reference_table_name(tableID:String, keyID:String, fieldID:String) -> String:
	var table_ref_name: String = ""
	var data_dict_column :Dictionary = all_tables_merged_data_dict[tableID][FIELD]
	for datakey in data_dict_column:
		var currFieldName:String = data_dict_column[datakey]["FieldName"]
		if currFieldName == fieldID:
			table_ref_name = str(data_dict_column[datakey]["TableRef"])
			break
	return table_ref_name


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
	var sprite_group_dict :Dictionary = FART.Static_Game_Dict["10040"]
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
	return all_tables_merged_dict["10000"]


#MAP FUNCTIONS------
func get_mappath_from_displayname(map_name :String):
	var maps_dict = all_tables_merged_dict["10034"]
	var new_map_path :String = ""
	for map_id in maps_dict:
		if get_value_as_text(maps_dict[map_id]["Display Name"]) == map_name:
			new_map_path = maps_dict[map_id]["Path"]
			break
	return new_map_path


func get_mappath_from_key(key :String) -> String:
	var maps_dict = all_tables_merged_dict["10034"]
	var new_map_path :String = ""
	new_map_path = maps_dict[key]["Path"]
	return new_map_path


func add_items_to_inventory_table():
	#Needs to use import
	var items_dict:Dictionary = import_data("Items")
	var items_dict_data_dict: Dictionary = import_data("Items", true)
	var current_inventory_dict: Dictionary = import_data("Inventory")
	var current_inventory_data_dict: Dictionary = import_data("Inventory", true)
	var input_actions_display_name_dict:Dictionary = get_display_name(items_dict)

	var new_inventory_dict: Dictionary
	var new_inventory_data_dict: Dictionary = current_inventory_data_dict.duplicate(true)
	var item_index : int = 1
	new_inventory_data_dict[KEY] = {}
	for item_id in items_dict:
		new_inventory_dict[item_id] = {"Display Name" : items_dict[item_id]["Display Name"], "ItemCount" : 0}
		var new_line:Dictionary = {"DataType":"1","FieldName":"","RequiredValue":true,"ShowValue":true,"TableRef":true}
		new_line["FieldName"] = item_id
		new_inventory_data_dict[KEY][item_index] =  new_line
		item_index += 1

	save_file( table_save_path + "Inventory" + table_file_format, new_inventory_dict )
	save_file( table_save_path + "Inventory" + "_data" + table_file_format, new_inventory_data_dict)



func get_display_name(inputDict: Dictionary)->Dictionary:
	var display_name_dict :Dictionary = {}
	for key in inputDict:
		var display_name :String = get_value_as_text(inputDict[key]["Display Name"])
		display_name_dict[display_name] = key
	return display_name_dict


func get_field_value_dict(inputDict: Dictionary, fieldName:String ="Function Name"):
	var display_name_dict :Dictionary = {}
	for key in inputDict:
		var display_name :String = get_value_as_text(inputDict[key][fieldName])
		display_name_dict[display_name] = key
	return display_name_dict


func add_key_to_table(NewKeyName :String, NewDisplayName: String, TableName:String, target_dict:Dictionary = {}, target_data_dict:Dictionary = {}):
	if target_dict == {}:
		target_dict = all_tables_merged_dict[TableName]
	if target_data_dict == {}:
		target_data_dict = all_tables_merged_data_dict[TableName]
	var index = target_data_dict[KEY].size() + 1
	var CustomData_dict = all_tables_merged_dict["10026"]
	var newOptions_dict = {}
	var newValue

	for ID in CustomData_dict:
		var currentKey :String = get_value_as_text(CustomData_dict[ID]["ItemID"])
		newValue = target_data_dict[KEY][target_data_dict[KEY].keys()[0]][currentKey]
		newOptions_dict[currentKey] = newValue

	newOptions_dict["FieldName"] = NewKeyName
	target_data_dict[KEY][str(index)] =  newOptions_dict


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


static func get_value_as_text(text_value)-> String:
	var return_string:String
	var typed_value = convert_string_to_type(text_value)
	if typeof(typed_value) == TYPE_DICTIONARY:
		return_string = convert_string_to_type(text_value)["text"]
	else:
		return_string = str(text_value)
	return return_string


func get_default_value(datatype :String):
	var item_value
	for key in datatype_dict:
		if key == datatype:
			var default_dict :Dictionary =  str_to_var(datatype_dict[key]["Default Values"])
			var default_value = get_value_as_text(default_dict)
			item_value = convert_string_to_type(default_value)  #default value
			if item_value == null:
				item_value = default_value
			break
	return item_value


static func get_input_type_node(input_type :String):
	var return_node =  load(datatype_dict[input_type]["Default Scene"])
	return return_node


static func create_datatype_node(datatype:String):
#	print("CREATE DATATYPE: ", datatype)
	var input_node = load(datatype_dict[datatype]["Default Scene"]).instantiate()
	var input_default_value = get_value_as_text(datatype_dict[datatype]["Default Values"])
	return input_node
