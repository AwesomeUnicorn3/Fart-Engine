extends Node
#signal interaction_ended
#signal close_menu
#signal Refresh_GUI
#signal Map_Changed
#signal Temp_Timer_timeout
### warning-ignore:unused_signal
##signal object_spawn_complete
## warning-ignore:unused_signal
#signal scene_load_complete
## warning-ignore:unused_signal
#signal load_started
##var dict_loaded = false
#var save_id = 0
#var save_path = ""
#var load_path = ""
#var new_game = true
#var load_game = false
#var game_loaded = false
#var current_scene = null
#var load_scene = "res://Maps/IndoorMaps/Fruitville_Indoor/House-Mike.tscn"
#var scene_transition = false
#var ExpDrop = 0
#var text = ""
##Player Position/Location
#var PlayerName = "Mike Hawke"
#onready var player_node = level_root().get_node("main/Player")
#var PlayerX = 0
#var PlayerY = 0
#var PlayerZ = 0
#var PlayerMap = "res://Maps/IndoorMaps/Fruitville_Indoor/House-Mike.tscn"
#var PlayerMap_Node = null
#var PlayerSubMap = ""
#var PlayerSubMap_node : Node
#var PlayerXTransfer = 0
#var PlayerYTransfer = 0
#var PlayerZTransfer = 0
#var Player_out_target = 1
#var PlayerAnim = "IdleDown"
#var PlayerDir = "Down"
#var PlayerSpriteDir = "Down"
#var PlayerCanMove = false
#var CanTalk = true
#var CanInteract = false #Change back to false when creating intro scene
#var gui = false
#var body
#var shop_name
#var buysell = ""
#var equip_menu_type = "GUI"
#var carry = false
#var object_in_hand : Object = null
#var importtext = false
#var object_id = 0
#var weapon_count = 0
##Options
#var dict_options_stats = {}
#var loot = false
#var AutoSave = false
#var touch_input_active = true
#var currency = "Chode"
#var touch_index = []
#var wind = 100.00
#var Collsion : Object = null
#var op_sys : String = ""
#
#func _ready():
#	op_sys = OS.get_name()
#	AudioServer.set_bus_mute(0, true)
#	current_scene = level_root()
# warning-ignore:return_value_discarded
#	Signal.connect("data_loaded", self, "Data_Loaded")

#func set_location(file):
#	if file != "res://UI/TitleScreen.tscn" and file != "res://UI/LoadGame.tscn":
#		if DbManager.Dynamic_Game_Dict.has("SaveID"):
#			DbManager.Dynamic_Game_Dict["SaveID"]["Player Location"]["ID"] = file
#			PlayerMap = file
#			emit_signal("Map_Changed")



#func get_current_map():
#	return PlayerMap

#func get_current_map_name():
#	var curr_map = get_current_map()
#	var map_name = DbManager.Static_Game_Dict["Locations"][curr_map]["Name"]
#	return  map_name

#func set_submap(SubMapName):
#	PlayerSubMap = SubMapName
#	DbManager.Dynamic_Game_Dict["SaveID"]["SubMap"]["ID"] = PlayerSubMap
#	if PlayerMap_Node != null:
#		for i in PlayerMap_Node.get_children():
#			if i.is_in_group("SubMap") and i.name == SubMapName:
#				PlayerSubMap_node = i
##				break
	
	


#func location_popup():
#	var root = level_root()
#	var popup_container = root.get_node("UI/Popup")
#	var location_Popup = popup_container.get_node("Location_Popup")
#	var anim_player = location_Popup.get_node("AnimationPlayer")
#	if !new_game:
#		popup_container.visible = true
#		location_Popup.visible = true
#		anim_player.queue("FadeOut")
		




#var sound
#func Data_Loaded():
#	DbManager.dict_loaded = true

#func level_root():
#	for x in get_tree().get_nodes_in_group("level_root"):
#		return x

#func sell_menu():
#	var GUI = level_root().get_node("UI/GUI")
#	var shop_menu: PackedScene = load("res://UI/ShopProcessing.tscn")
#	shop_name = "Frank's Sundries"
#	level_root().Call_Main_Menu("ui_shop", true)
#	var scene_instance = shop_menu.instance()
##	GUI.set_touchscreen_visible(false)
#	GUI.add_child(scene_instance)

#func autosave(value: bool):
#	AutoSave = value
#	if value != false:
#		level_root().get_node("UI/Auto_Save").start()
#	else:
#		level_root().get_node("UI/Auto_Save").stop()

#func can_talk(talk : bool):
#	CanTalk = talk
#
#func can_walk(walk : bool):
#	PlayerCanMove = walk


#func edit_dict(dict, itm_nm, amt):
#	if DbManager.Dynamic_Game_Dict[dict].has(itm_nm):
#		DbManager.Dynamic_Game_Dict[dict][itm_nm]["ItemCount"] += amt
#	else:
#		var item = DbManager.Static_Game_Dict["Items"][itm_nm]
#		DbManager.Dynamic_Game_Dict[dict][itm_nm] = item
#		DbManager.Dynamic_Game_Dict[dict][itm_nm]["ItemCount"] += amt



#func interaction_ended():
#	emit_signal("interaction_ended")
#
#func refresh_gui():
#	emit_signal("Refresh_GUI")
#
#func close_main_menu():
#	emit_signal("close_menu")

#func update_currency():
#	var GUI = level_root().get_node("UI/GUI")
#	GUI.update_currency()

#func clear_key_bindings():
#	for h in InputMap.get_actions():
#	#	#for each action, loop through key binds
#		for j in InputMap.get_action_list(h):
##			#remove each key bind
#			if j.get_class() == "InputEventKey":
#				InputMap.action_erase_event(h, j)

#func update_key_bindings():
#	var lead_char_name
#	#set all of the action key bindings from the options#
#	# first remove all previous keys bound to each action
#	clear_key_bindings()
#	#find the lead character
#	lead_char_name = get_player_character()
#
#	#loop through all of the actions in the action list again
#	for h in InputMap.get_actions():
#	#for each action, if keyscancode from options table == null
#	#add each key from the options table
#		var options_stats = DbManager.Dynamic_Game_Dict["Controls"]
#		if options_stats.has(h):
#			var cat = options_stats[h]["Category"]
#			match cat: 
#				"PlaceHolder":
#					var input_action = options_stats[h]["Input_Action"]
#					var char_action_string = lead_char_name + " " + input_action
#					var key1 = options_stats[char_action_string]["Key1Scancode"]
#					var key1object = InputEventKey.new()
#					key1object.set_scancode(key1)
#					InputMap.action_add_event(h, key1object)
#
#				"Controls":
#					var key1 : int = int(options_stats[h]["Key1Scancode"])
#					var key2 : int = int(options_stats[h]["Key2Scancode"])
#					var key2_text : String = options_stats[h]["Key2"]
#					var key1object = InputEventKey.new()
#					key1object.set_scancode(key1)
#					InputMap.action_add_event(h, key1object)
#					if key2_text != "":
#						var key2object = InputEventKey.new()
#						key2object.set_scancode(key2)
#						InputMap.action_add_event(h, key2object)

#
#class MyCustomSorter:
#	static func sort_ascending(a, b):
#		a = int(Global.get_file_name(a, ".sav"))
#		b = int(Global.get_file_name(b, ".sav"))
#		if a < b:
#			return true
#		return false
#
#func get_file_name(name : String, filetype : String):
#	name = name.trim_suffix(filetype)
#	return name


#var in_hand = false

#func spawn_objects(parent):
#	var dict_objects = DbManager.Dynamic_Game_Dict["Object"]
#	var obj_type = ""
#	for i in dict_objects:
#		in_hand = bool(dict_objects[i]["In_Player_Hand"])
#		if in_hand == true:
#			if load_game == true:
#				obj_type = dict_objects[i]["Item_Name"]
#				spawn_object(i, obj_type, parent)
#				print("put object in player's hand")
#
#		else:
#			if dict_objects[i]["Location"] == get_current_map_name():
#				obj_type = dict_objects[i]["Item_Name"]
#				spawn_object(i, obj_type, parent)



#func spawn_object(Name, type, par):
#	var newObject
#	var object = load("res://Interactive_Objects/" + type + "/" + type + ".tscn")
#	var stat_objects = []
#	var spawn_objects = par.get_node("../Spawn_Objects")
#
#	for i in par.get_children():
#		stat_objects.append(i.name)
#
#	if in_hand == true:
#		newObject = object.instance()
#		newObject.name = Name
#		newObject.load_object_to_hand()
#
#		var q = check_for_node(par, Name) 
#		if q:
#			if stat_objects.has(par.get_node(Name).name):
#				par.get_node(Name).queue_free()
#		in_hand = false
#
#	elif !stat_objects.has(Name):
#		newObject = object.instance()
#		newObject.name = Name
#		spawn_objects.add_child(newObject)



#func add_new_spatial_node(parent, node_name):
#	var this = Spatial.new()
#	this.name = node_name
#	parent.add_child(this)

#func check_for_node(parent, name):
#	var arr = parent.get_children()
#	var has_node = false
#	for i in arr:
#		if i.name == name:
#			has_node = true
#			break
#	return has_node

#func interacting_with_object(value: bool, interactive_object: Node):
#	var root = level_root()
#	CanInteract = !value
#	interactive_object.get_node("Mesh").get_surface_material(0).set_next_pass(null)
#	root.Call_Main_Menu("interacting", value)
#	can_talk(!value)
#	if !carry:
#		enable_player_raycast(!value)
#	can_walk(!value)
#	if value == false:
#		body = null
#	Signal.emit_signal("interaction_ended")

#func display_item_gained(item_name : String, amount : int):
#
#	var root = level_root()
#	var display = root.get_node("main/Player/Viewport/Drop_Item")
#	var anim_player = root.get_node("main/Player/Viewport/AnimationPlayer")
#	if anim_player.is_playing():
#		yield(anim_player, "animation_finished")
#	#display.get_node("VBoxContainer/HBoxContainer/Item_Name").set_text(item_name)
#	display.get_node("VBoxContainer/HBoxContainer/Item_Amount").set_text(str(amount))
#	display.get_node("VBoxContainer/HBoxContainer/TextureRect").set_texture(load("res://Icons/" + item_name + ".png"))
#	anim_player.queue("Item_gained")
#	update_currency()

#var temp_timer
#func temporary_timer(time):
#	temp_timer = Timer.new()
#	temp_timer.set_wait_time(time)
#	temp_timer.set_one_shot(true)
##	temp_timer.set_autostart(true)
#	level_root().add_child(temp_timer)
#
#	temp_timer.start()
#	yield(temp_timer, "timeout")
#	temp_timer.queue_free()
#	emit_signal("Temp_Timer_timeout")

#var new_dialog

#func dialog(dialog_name : String, par, allow_movement_at_end : bool = true):
#	var root = level_root()
#	var ui = root.get_node("UI")
#
#	root.Call_Main_Menu("dialog", true)
#	new_dialog = Dialogic.start(dialog_name)
#	new_dialog.connect("dialogic_signal", par, 'script_event')
#	ui.add_child(new_dialog)
#	var textbox = new_dialog.get_node("DialogNode/TextBubble")
#	var touchinput = instance_touch_input(textbox)
#	yield(new_dialog, "timeline_end")
#	touchinput.get_node("TextureButton").clear_input()
#	if allow_movement_at_end == true:
#		root.Call_Main_Menu("dialog", false)
#	Signal.emit_signal("message_ended")

#func instance_touch_input(par):
#	var touch_input_node = load("res://UI/Touch_Dialogue_Next.tscn")
#	var touchInput = touch_input_node.instance()
#	par.add_child(touchInput)
#
#	return touchInput

#func enable_player_raycast(value: bool):
#	var player = level_root().get_node("main/Player")
#	player.enable_interact_raycast(value)
	

#func get_player_character():
#	var dict_formation = DbManager.Dynamic_Game_Dict["Formation"]
#	var curr_char = dict_formation["1"]["CharName"]
#	return curr_char
