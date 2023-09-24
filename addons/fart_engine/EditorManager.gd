@tool
class_name EditorManager extends DatabaseManager
#signal Editor_Refresh_Complete

signal refresh_all_data
signal save_complete
signal begin_save

static var toolbar
static var selected_fart_node  = null
static var editor_interface :EditorInterface


func when_editor_saved(arg1):
	print("Editor Saved ", arg1)
	if !DatabaseManager.is_editor_saving:
		DatabaseManager.is_editor_saving = true
		if !DatabaseManager.is_uds_main_updating:
			print("FART MAIN: WHEN EDITOR SAVED  - START")
			for table_name in DatabaseManager.display_form_dict:
				var table_node = DatabaseManager.display_form_dict[table_name]["Node"]
				if table_node != null:
					if !table_node.is_in_group("Database"):
						DatabaseManager.display_form_dict[table_name]["Node"]._on_Save_button_up()
						print(table_name, " SAVE COMPLETE")
			update_input_actions_table()
			update_UI_method_table()
			add_items_to_inventory_table()
			update_project_settings()
			await get_tree().create_timer(0.5).timeout
		is_editor_saving = false
		print("FART MAIN - WHEN EDITOR SAVED - END")
	save_complete.emit()


func update_UI_method_table():
	var AU3_UI_method_dict:Dictionary = import_data("UI Script Methods")
	var AU3_UI_method_data_dict: Dictionary = import_data("UI Script Methods", true)
	var AU3_UI_method_display_name_dict:Dictionary = get_field_value_dict(AU3_UI_method_dict)
	var method_dict:Dictionary = EditorManager.get_UI_methods()
#	print(AU3_UI_method_display_name_dict)

	for method_name in method_dict:
		if !AU3_UI_method_display_name_dict.has(method_name):
			var NewKeyName :String = str(get_next_key_ID(AU3_UI_method_dict))
			var displayName: Dictionary = {"text": method_name}
			var tempArray :Array = add_key_to_table(NewKeyName, method_name.replace("_", " "), "",AU3_UI_method_dict, AU3_UI_method_data_dict )
			AU3_UI_method_dict[NewKeyName]["Function Name"] = displayName
	for id in AU3_UI_method_dict:
		var functionName:String = get_text(AU3_UI_method_dict[id]["Function Name"])
		if !method_dict.has(functionName):
			var newDictArray :Array = TableManager.new().Delete_Key(id, AU3_UI_method_dict,AU3_UI_method_data_dict )
			AU3_UI_method_dict = newDictArray[0].duplicate(true)
			AU3_UI_method_data_dict = newDictArray[1].duplicate(true)

	save_file( table_save_path + "UI Script Methods" + table_file_format, AU3_UI_method_dict )
	save_file( table_save_path + "UI Script Methods" + "_data" + table_file_format, AU3_UI_method_data_dict )


func connect_signals():
	pass

func refresh_editor(parent):
	editor_interface.get_resource_filesystem().scan()
	while editor_interface.get_resource_filesystem().is_scanning():
		print("Scanning...")
		await parent.get_tree().process_frame
	await parent.get_tree().create_timer(.1).timeout
	emit_signal("Editor_Refresh_Complete")
	print("Scanning Complete")


static func save_godot_current_scene():
	print("SAVED SCENE ", editor_interface.save_scene())


func update_input_actions_table():
#	print("UPDATE INPUT ACTIONS TABLE BEGIN")
	var AU3_input_map_dict:Dictionary = import_data("AU3 InputMap")
	var AU3_input_map_data_dict: Dictionary = import_data("AU3 InputMap", true)
	var input_actions_display_name_dict:Dictionary = get_display_name(AU3_input_map_dict)
	InputMap.load_from_project_settings()
	var inputMap = InputMap.get_actions()
	

	for action_name in inputMap:
		if !action_name.left(3) == "ui_":
			if !input_actions_display_name_dict.has(action_name):
				var NewKeyName :String = str(get_next_key_ID(AU3_input_map_dict))
				var tempArray :Array = add_key_to_table(NewKeyName, action_name, "",AU3_input_map_dict, AU3_input_map_data_dict )


	for id in AU3_input_map_dict:
#		print(id)
		var displayName:String = get_text(AU3_input_map_dict[id]["Display Name"])

		if !inputMap.has(displayName):# or displayName.left(3) == "ui_":
			var newDictArray :Array = TableManager.new().Delete_Key(id, AU3_input_map_dict.duplicate(true),AU3_input_map_data_dict.duplicate(true) )
			AU3_input_map_dict = newDictArray[0].duplicate(true)
			AU3_input_map_data_dict = newDictArray[1].duplicate(true)
	
		if displayName.left(3) == "ui_":
#			print(displayName)
			var newDictArray :Array = TableManager.new().Delete_Key(id, AU3_input_map_dict.duplicate(true),AU3_input_map_data_dict.duplicate(true) )
			AU3_input_map_dict = newDictArray[0].duplicate(true)
			AU3_input_map_data_dict = newDictArray[1].duplicate(true)

	save_file( table_save_path + "AU3 InputMap" + table_file_format, AU3_input_map_dict )
	save_file( table_save_path + "AU3 InputMap" + "_data" + table_file_format, AU3_input_map_data_dict )



func _process(delta: float) -> void:

	var selected_nodes :Array = editor_interface.get_selection().get_selected_nodes()
	if selected_nodes.size() == 1:
		var current_selection :Node = selected_nodes[0]
		if !is_instance_valid(selected_fart_node):
			selected_fart_node = current_selection
		if selected_fart_node != current_selection:
			selected_fart_node = current_selection
			if current_selection.has_method("show_event_toolbar_in_editor"):
				current_selection.show_event_toolbar_in_editor(current_selection.name)
				toolbar.event_Node = current_selection
				toolbar.visible = true
				toolbar.get_node("HBoxContainer/Edit_Event_Button").visible = true
				toolbar.get_node("HBoxContainer/Assign_Function").visible = false
				toolbar.get_node("HBoxContainer/Edit_Data_Display").visible = false
				
			elif current_selection.has_method("show_UIMethod_selection_in_editor"):
				toolbar.visible = true
				toolbar.get_node("HBoxContainer/Assign_Function").visible = true
				toolbar.get_node("HBoxContainer/Edit_Event_Button").visible = false
				toolbar.get_node("HBoxContainer/Edit_Data_Display").visible = false
				
			elif current_selection.has_method("data_display"):
				toolbar.visible = true
				toolbar.get_node("HBoxContainer/Edit_Data_Display").visible = true
				toolbar.get_node("HBoxContainer/Edit_Event_Button").visible = false
				toolbar.get_node("HBoxContainer/Assign_Function").visible = false
			else:
				toolbar.get_node("HBoxContainer/Edit_Event_Button").visible = false
				toolbar.get_node("HBoxContainer/Assign_Function").visible = false
				toolbar.get_node("HBoxContainer/Edit_Data_Display").visible = false

				toolbar.visible = false
	else:
		toolbar.visible = false
		toolbar.get_node("HBoxContainer/Edit_Event_Button").visible = false
		toolbar.get_node("HBoxContainer/Assign_Function").visible = false
		toolbar.get_node("HBoxContainer/Edit_Data_Display").visible = false
		selected_fart_node = null


func get_fart_root() -> Node:
	return fart_root

func set_fart_root(new_root_node:Node):
	fart_root = new_root_node


func close_scene_in_editor(scene_name :String):
	var scene_index :int = -1
	var tabbar = get_editor_tabbar()
	var tabbar_dict :Dictionary = get_open_scenes_in_editor()
	for index in tabbar_dict:
		if tabbar_dict[index] == scene_name:
			scene_index = index
			break
	if scene_index != -1:
		tabbar.emit_signal("tab_close_pressed", scene_index)

func open_scene_in_editor(scene_path :String):
	var open_scenes = editor_interface.get_open_scenes()
	if open_scenes.has(scene_path):
		close_scene_in_editor(scene_path.get_file().get_basename())
		await get_tree().process_frame
	editor_interface.open_scene_from_path(scene_path)


func get_open_scenes_in_editor() -> Dictionary:
	var tabbar :TabBar = get_editor_tabbar()
	var tabbar_dict :Dictionary = {}
	for tab in tabbar.get_tab_count():
		tabbar_dict[tab] = tabbar.get_tab_title(tab)
	return tabbar_dict


func replace_scene(scene:Node, path:String):
	var new_packed_scene = PackedScene.new()
	new_packed_scene.pack(scene)
	var dir :DirAccess = DirAccess.open(path.get_base_dir())
	dir.remove(path)
	ResourceSaver.save(new_packed_scene, path)
	scene.queue_free()


func set_editor_scene(map_path:String) :
	print("SET EDITOR SCENE BEGIN:")
	var scene_name :String = map_path.get_file().get_basename()
	open_scene_in_editor(map_path)
	var open_scenes_dict :Dictionary = get_open_scenes_in_editor()
	var scene_index :int = 0
	for index in open_scenes_dict:
		if open_scenes_dict[index] == scene_name:
			scene_index = index
			break
	get_editor_tabbar().set_current_tab(scene_index)
	print("SET EDITOR SCENE END")


func delete_starting_position_from_map(previous_selection, node_name:String = "StartingPositionNode" ):
	print("PREVIOUS SELECTION: ", previous_selection)
	close_scene_in_editor(previous_selection)
	#OLD STARTING POSITION IS NOT REMOVED
	var maps_dict = import_data("Maps")
	var new_map_path = get_mappath_from_displayname(previous_selection)
	print("NEW MAP PATH: ", new_map_path)
	
	for map_id in maps_dict:
		print("MAP ID ", map_id)
		if map_id == previous_selection:
			new_map_path = maps_dict[map_id]["Path"]
			break

	print("NEW MAP PATH: ", new_map_path)
	if !new_map_path == null:
		var new_map_scene :Node = load(new_map_path).instantiate()
		new_map_scene.set_name(previous_selection)
#
		var start_node_dict: Dictionary
		var start_pos_node :StartingPosition = new_map_scene.get_node(node_name)
		
		if start_pos_node != null:
			print("START POS NODE: ", start_pos_node)
			new_map_scene.remove_child(start_pos_node)
			start_pos_node.queue_free()
			await get_tree().process_frame
			replace_scene(new_map_scene,new_map_path)
	await get_tree().process_frame


func add_starting_position_node_to_map(selectedItemID,previous_selectionID, parent_node):
	var selectedSceneName:String = get_text(import_data("Maps")[selectedItemID]["Display Name"])
	var previous_selection:String = get_text(import_data("Maps")[previous_selectionID]["Display Name"])
	var new_map_path:String = get_mappath_from_displayname(selectedSceneName)
	var previous_map_path: String = get_mappath_from_displayname(previous_selection)
	var starting_position_node = StartingPosition.new()
	var new_map_scene  = load(new_map_path).instantiate()
	var starting_position_icon :Texture = load("res://fart_data/png/StartingPosition.png")

	new_map_scene.add_child(starting_position_node)
	starting_position_node.set_owner(new_map_scene)
	starting_position_node.set_name("StartingPositionNode")
	starting_position_node.set_script(load("res://addons/fart_engine/Database_Manager/StartingPositionNode.gd"))
	starting_position_node.set_texture(starting_position_icon)
	replace_scene(new_map_scene, new_map_path)
	parent_node._on_Save_button_up()
	await delete_starting_position_from_map(previous_selection)
	set_editor_scene(new_map_path)
	await get_tree().process_frame
	select_scene_in_editor("StartingPositionNode")


func get_editor_tabbar() -> TabBar:
	var current_node: Node
	current_node = editor_interface.get_editor_main_screen().get_parent().get_parent()
	var tabArray: Array = current_node.find_children("*", "TabBar", true, false)
	return tabArray[0]
	
	
static func return_to_FartEngine():
	editor_interface.set_main_screen_editor("FART ENGINE")
	var editor_main_scene = await editor_interface.get_editor_main_screen().get_node("FART ENGINE")
	return editor_main_scene


static func get_UI_methods():
	var UIENGINE:UIEngine = UIEngine.new()
	var UIMethodList  = UIENGINE.get_method_list()
	var method_dict:Dictionary = {}
	for id in UIMethodList:
		if id["return"]["usage"] == 6 and id["flags"] == 1 and id["id"] == 0 and id.name != "free":
			method_dict[id.name] = id.name
	return method_dict


func select_scene_in_editor(node_name : String):
	editor_interface.get_selection().clear()
	var starting_pos_node: StartingPosition = editor_interface.get_edited_scene_root().get_node(node_name)
	editor_interface.get_selection().add_node(starting_pos_node)
	editor_interface.set_main_screen_editor("2D")
