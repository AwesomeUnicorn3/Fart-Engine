@tool
class_name EditorManager extends DatabaseManager
#signal Editor_Refresh_Complete

signal refresh_all_data
signal save_complete
signal begin_save


static var toolbar 
static var selected_fart_node  = null
static var editor_interface : EditorInterface = EditorPlugin.new().get_editor_interface()

var parent_node:Node


func _ready():
	EditorPlugin.new().resource_saved.connect(when_editor_saved)
	

func when_editor_saved(arg1):
	
	if !is_editor_saving:
		is_editor_saving = true
		if !is_uds_main_updating:
			print("FART MAIN: WHEN EDITOR SAVED  - START")
			for table_name in display_form_dict:
				var table_node = display_form_dict[table_name]["Node"]
				if table_node != null:
					if !table_node.is_in_group("Database"):
						display_form_dict[table_name]["Node"]._on_Save_button_up()
						print(table_name, " SAVE COMPLETE")
			update_input_actions_table()
			update_UI_method_table()
			add_items_to_inventory_table()
			update_project_settings()
			await update_all_event_list(true)
			
			await get_tree().create_timer(0.5).timeout

			print("Editor Saved ", arg1)
		is_editor_saving = false
		print("FART MAIN - WHEN EDITOR SAVED - END")
	save_complete.emit()


func update_UI_method_table():
#	var AU3_UI_method_dict:Dictionary = all_tables_merged_dict["10045"]
#	var AU3_UI_method_data_dict: Dictionary = all_tables_merged_data_dict["10045"]
	var AU3_UI_method_display_name_dict:Dictionary = get_field_value_dict( all_tables_merged_dict["10045"])
	var method_dict:Dictionary = EditorManager.get_UI_methods()
	var delete_successful :bool = false
	for method_name in method_dict:
		if !AU3_UI_method_display_name_dict.has(method_name):
			var NewKeyName :String = str(get_next_key_ID( all_tables_merged_dict["10045"]))
			var displayName: Dictionary = {"text": method_name}
			var tempArray :Array = add_key_to_table(NewKeyName, method_name.replace("_", " "), "", all_tables_merged_dict["10045"],  all_tables_merged_data_dict["10045"] )
			all_tables_merged_dict["10045"][NewKeyName]["Function Name"] = displayName
	for id in  all_tables_merged_dict["10045"]:
		var functionName:String = get_value_as_text( all_tables_merged_dict["10045"][id]["Function Name"])
		if !method_dict.has(functionName):
			delete_successful  = await delete_key(id, "10045" )
#			AU3_UI_method_dict = newDictArray[0].duplicate(true)
#			AU3_UI_method_data_dict = newDictArray[1].duplicate(true)
	if delete_successful:
		save_file( table_save_path + "10045" + table_file_format,  all_tables_merged_dict["10045"] )
		save_file( table_save_path + "10045" + "_data" + table_file_format,  all_tables_merged_data_dict["10045"] )


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


func save_godot_current_scene():
	print("SAVED SCENE ", editor_interface.save_scene())


func update_input_actions_table():
#	print("UPDATE INPUT ACTIONS TABLE BEGIN")

	var AU3_input_map_data_dict: Dictionary = all_tables_merged_data_dict["10007"]
	var input_actions_display_name_dict:Dictionary = get_display_name( all_tables_merged_dict["10007"])
	InputMap.load_from_project_settings()
	var inputMap = InputMap.get_actions()
	

	for action_name in inputMap:
		if !action_name.left(3) == "ui_":
			if !input_actions_display_name_dict.has(action_name):
				var NewKeyName :String = str(get_next_key_ID(all_tables_merged_dict["10007"]))
				var tempArray :Array = add_key_to_table(NewKeyName, action_name, "",all_tables_merged_dict["10007"], AU3_input_map_data_dict )


	for id in all_tables_merged_dict["10007"]:
#		print(id)
		var displayName:String = get_value_as_text(all_tables_merged_dict["10007"][id]["Display Name"])

		if !inputMap.has(displayName):# or displayName.left(3) == "ui_":
			var delete_successful :bool = await delete_key(id, "10007")
#			AU3_input_map_dict = all_tables_merged_dict["10007"][0].duplicate(true)
#			AU3_input_map_data_dict = all_tables_merged_dict["10007"][1].duplicate(true)
	
		if displayName.left(3) == "ui_":
#			print(displayName)
			var newDictArray :bool = await delete_key(id,"10007" )
#			AU3_input_map_dict = all_tables_merged_dict["10007"][0].duplicate(true)
#			AU3_input_map_data_dict = all_tables_merged_data_dict["10007"][1].duplicate(true)

	save_file( table_save_path + "10007" + table_file_format, all_tables_merged_dict["10007"] )
	save_file( table_save_path + "10007" + "_data" + table_file_format, AU3_input_map_data_dict )


#
#func _process(delta: float) -> void: #ADD THIS TO TOOLBAR MANAGER SCRIPT AND BE SURE TO ONLY HAVE 1 INSTANCE OF IT AT ANY TIME
#
#	var selected_nodes :Array = editor_interface.get_selection().get_selected_nodes()
#	if selected_nodes.size() == 1:
#		var current_selection :Node = selected_nodes[0]
#		if !is_instance_valid(selected_fart_node):
#			selected_fart_node = current_selection
#		if selected_fart_node != current_selection:
#			selected_fart_node = current_selection
#			if current_selection.has_method("show_event_toolbar_in_editor"):
#				current_selection.show_event_toolbar_in_editor(current_selection.name)
#				toolbar.event_Node = current_selection
#				toolbar.visible = true
#				toolbar.get_node("HBoxContainer/Edit_Event_Button").visible = true
#				toolbar.get_node("HBoxContainer/Assign_Function").visible = false
#				toolbar.get_node("HBoxContainer/Edit_Data_Display").visible = false
#
#			elif current_selection.has_method("show_UIMethod_selection_in_editor"):
#				toolbar.visible = true
#				toolbar.get_node("HBoxContainer/Assign_Function").visible = true
#				toolbar.get_node("HBoxContainer/Edit_Event_Button").visible = false
#				toolbar.get_node("HBoxContainer/Edit_Data_Display").visible = false
#
#			elif current_selection.has_method("data_display"):
#				toolbar.visible = true
#				toolbar.get_node("HBoxContainer/Edit_Data_Display").visible = true
#				toolbar.get_node("HBoxContainer/Edit_Event_Button").visible = false
#				toolbar.get_node("HBoxContainer/Assign_Function").visible = false
#			else:
#				toolbar.get_node("HBoxContainer/Edit_Event_Button").visible = false
#				toolbar.get_node("HBoxContainer/Assign_Function").visible = false
#				toolbar.get_node("HBoxContainer/Edit_Data_Display").visible = false
#
#				toolbar.visible = false
#	else:
#		toolbar.visible = false
#		toolbar.get_node("HBoxContainer/Edit_Event_Button").visible = false
#		toolbar.get_node("HBoxContainer/Assign_Function").visible = false
#		toolbar.get_node("HBoxContainer/Edit_Data_Display").visible = false
#		selected_fart_node = null


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
	var maps_dict = all_tables_merged_dict["10034"]
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
	var selectedSceneName:String = get_value_as_text(all_tables_merged_dict["10034"][selectedItemID]["Display Name"])
	var previous_selection:String = get_value_as_text(all_tables_merged_dict["10034"][previous_selectionID]["Display Name"])
	var new_map_path:String = get_mappath_from_displayname(selectedSceneName)
	var previous_map_path: String = get_mappath_from_displayname(previous_selection)
	var starting_position_node = StartingPosition.new()
	var new_map_scene  = load(new_map_path).instantiate()
	var starting_position_icon :Texture = preload("res://fart_data/png/StartingPosition.png")

	new_map_scene.add_child(starting_position_node)
	starting_position_node.set_owner(new_map_scene)
	starting_position_node.set_name("StartingPositionNode")
	starting_position_node.set_script(preload("res://addons/fart_engine/Database_Manager/StartingPositionNode.gd"))
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
	
	
func return_to_FartEngine():
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


func create_input_node(table_name:String, selected_key_ID:String, field_ID :String) -> FartDatatype:
	var datatype:String = await get_datatype(field_ID,table_name)
	var return_node:FartDatatype
	#print("DATTYPE DICT: DATATYPE: ", field_ID)
	if datatype != "0":
		#print("DATATYPE: ", datatype)
		var default_scene: String = datatype_dict[datatype]["Default Scene"]
		
		if !datatype_dict.has(datatype):
			print(datatype, " IS NOT A VALID DATATYPE")
		return_node = await load(default_scene).instantiate()
		return_node.reference_table_name = get_reference_table_name(table_name,selected_key_ID,field_ID)
		return_node.set_name(field_ID)
		return_node.table_name = table_name
	else:
		return_node = null
	return return_node


func get_table_dict(Table_Name: String):
	return all_tables_merged_dict[Table_Name]


func get_data_dict(Table_Name: String):
	return all_tables_merged_data_dict[Table_Name]


func get_dict_in_display_order(table_id:String) -> Dictionary:
	#print("LIST KEYS IN DISPLAY ORDER BEGIN: ", Table_Name)
	var sorted_dict: Dictionary = {}
	var displayName: String = "10000"
	var datatype: String = "0"
	#print("DATA DICT: ", Table_Name)
	if  !all_tables_merged_data_dict.has(table_id):
		all_tables_merged_data_dict[table_id] = await import_data(table_id, true)
	if all_tables_merged_data_dict[table_id] != {}:
#	if Table_Data_Dict.has(KEY):
		for keyID in all_tables_merged_data_dict[table_id][KEY].size():
			keyID = str(keyID + 1) #row_dict key
			#print("ITEM NUMBER: ", keyID)
			datatype = all_tables_merged_data_dict[table_id][KEY][keyID]["DataType"]
			#print("DATATYPE: ", datatype)
			var key_name :String = all_tables_merged_data_dict[table_id][KEY][keyID]["FieldName"] #Use the row_dict key (item_number) to set the button label as the item name
			#print("KEY NAME: ", key_name)
			if !all_tables_merged_dict.has(table_id):
				all_tables_merged_dict[table_id] = await import_data(table_id)
			if all_tables_merged_dict[table_id].has(key_name):
				#print("TABLE DICT: ", all_tables_merged_dict[table_id][key_name])
				var key_dict :Dictionary = all_tables_merged_dict[table_id][key_name]
				#print("DISPLAY NAME: ", key_name)
				displayName = key_name
				if all_tables_merged_data_dict[table_id][KEY][keyID].has("Display Name"):
					displayName = await get_value_as_text(all_tables_merged_data_dict[table_id][KEY][keyID]["Display Name"])
				sorted_dict[key_name] = key_dict.duplicate(true)
				sorted_dict[key_name]["Datatype"] = datatype
	#			sorted_dict[key_name]["DisplayName"] = displayName
				sorted_dict[key_name]["ReferenceTableName"] = all_tables_merged_data_dict[table_id][KEY][keyID]["TableRef"]
			else:
				all_tables_merged_data_dict[table_id][KEY].erase(keyID)
				print("ALL TABLES MERGED DOES NOT HAVE KEY: ", key_name)
			
	else:
		for keyID in all_tables_merged_dict[table_id].size():
			var strKeyID: String = str(keyID + 1)
			displayName = get_value_as_text(all_tables_merged_dict[table_id][keyID]["Display Name"])
			sorted_dict[keyID] = all_tables_merged_dict[table_id][keyID]
			sorted_dict[keyID]["Datatype"] = datatype
#			sorted_dict[keyID]["DisplayName"] = displayName
#		print( KEY, " NOT FOUND")
	await get_tree().process_frame
	return sorted_dict


func delete_key(key_name:String, tableID:String )-> bool:
	print("DELETE KEY NAME: ", key_name)
	var tmp_dict :Dictionary = {}
	var main_tbl: Dictionary = {}
	var delete_successful :bool = false
#	var selectedDict:Dictionary = all_tables_merged_dict[tableID]
#	var selectedDataDict:Dictionary = all_tables_merged_data_dict[tableID]
#	data_type = KEY
#	match data_type:
		#KEY: #Deletes keys
	all_tables_merged_dict[tableID].erase(key_name) #Remove entry from current dict
#		FIELD: #Deletes fields
#			for i in selectedDict: #loop trhough main dictionary
#				selectedDict[i].erase(key_name)

	tmp_dict = all_tables_merged_data_dict[tableID][KEY].duplicate(true)
	#loop through row_dict to find item
	for keyID in tmp_dict:
		if all_tables_merged_data_dict[tableID][KEY][keyID]["FieldName"] == key_name:
			all_tables_merged_data_dict[tableID][KEY].erase(keyID) #Erase entry
#			print("BREAK1")
			break
	#Loop through number 0 to row_dict size
	tmp_dict = all_tables_merged_data_dict[tableID][KEY].duplicate(true)
	for keyID in tmp_dict.size():
		keyID += 1
		if !all_tables_merged_data_dict[tableID][KEY].has(str(keyID)):
			var next_entry_value = all_tables_merged_data_dict[tableID][KEY][str(keyID + 1)] 
			all_tables_merged_data_dict[tableID][KEY][str(keyID)] = next_entry_value.duplicate(true) #create new entry with current index and next entry
			var next_entry = str(keyID + 1)
			if all_tables_merged_data_dict[tableID][KEY].has(next_entry):
				all_tables_merged_data_dict[tableID][KEY].erase(next_entry) #Delete next entry
			else:
#				print("BREAK2")
				break
	delete_successful = true
	await get_tree().process_frame
#	print("delete key complete")
	return delete_successful


func set_all_tables_option_dicts() -> void:
	#Gets called before tall tables merged dict
	all_tables_settings_dict = await import_data("10000")
	all_tables_settings_data_dict = await import_data("10000",true)


func set_all_tables_dicts() -> void:
	print("ALL TABLES LOADED BEGIN")
	var settings_dict = await import_data("10000")
	for dictID in settings_dict:
		#print("TABLE ID: ", dictID)
		all_tables_merged_dict[dictID] = await import_data(dictID,false)
		all_tables_merged_data_dict[dictID] = await import_data(dictID,true)
	all_tables_loaded = true
	print("ALL TABLES LOADED END")



func set_all_fields_dict()-> void:
	var field_dict: Dictionary = {}
	for tableID in all_tables_merged_dict:
		for fieldID in all_tables_merged_data_dict[tableID][FIELD]:
			field_dict[all_tables_merged_data_dict[tableID][FIELD][fieldID]["FieldName"]] = {"Order" : fieldID, "TableName" : tableID}

	
	

func display_edit_field_menu(key_name:String ,labelNode: FartDatatype,TableDict:Dictionary, DataDict:Dictionary):
	var edit_field_values :PopupManager = all_popups_dict["FieldValues"]
#	parent_node  = get_main_tab(self)
#	var keyName :String = Item_Name
	var fieldName :String = labelNode.text 

	edit_field_values.parent_node = self
	edit_field_values.data_dict = DataDict
	edit_field_values.keyName = key_name
	edit_field_values.fieldName = fieldName
	get_node("Popups").visible = true
	get_node("Popups").add_child(edit_field_values)
	edit_field_values.label.set_text(fieldName + " Options")
	edit_field_values.reference_table_input = self

	await edit_field_values.edit_field_values_closed
	var datatype_id = 0

	if edit_field_values.update_data:
		for i in edit_field_values.DATA_CONTAINER.get_children():
			var curr_input = get_value_from_input_node(i,key_name)
			var field_name = i.name
			if field_name == "DataType":
				if edit_field_values.is_datatype_changed:
					curr_input = i.get_dataType_ID(i.selectedItemKey)
					datatype_id = curr_input

			if field_name == "TableRef":
				curr_input = i.selectedItemKey
				
			elif field_name == "FieldName":

				curr_input = get_value_as_text(curr_input)
			DataDict[FIELD][edit_field_values.field_index][field_name] = curr_input

	if edit_field_values.is_datatype_changed:
		var default_value = get_default_value(datatype_id)#edit_field_values.initial_data_type)
		for key in TableDict: #loop through all keys and set value for this file to "empty"
			TableDict[key][fieldName] = default_value
#	refresh_data()
#	_on_Save_button_up()
#	refresh_data()
	get_node("Popups").visible = false
	edit_field_values.queue_free()


func get_value_from_input_node(current_node, key_name:String) -> String:
	var input_type :String = current_node.type
	var input = current_node.inputNode
	var node_value:String
	var did_datatype_change = false

	if typeof(current_node.get_input_value()) == TYPE_STRING:
		node_value = current_node.get_input_value()
	else:
		node_value = var_to_str(current_node.get_input_value())

	return node_value

#
func create_input_node_custom_dict(key_name:String, table_name:String, table_dict:Dictionary = {}, table_data_dict: Dictionary = {}):
	var data_type:String
#	var node_input_value: Variant
	if table_dict == {}:
		table_dict = all_tables_merged_dict[table_name]
	if table_data_dict == {}:
		table_data_dict = all_tables_merged_data_dict[table_name]
	#print("CREATE INPUT NODE: KEY NAME: ", key_name)
	data_type = await get_datatype(key_name, table_name)
	#print("DATATYPE: ", data_type, " : ", key_name)
	#print("TABLE DICT: ", table_dict)

	var new_node = create_datatype_node(data_type)
	new_node.set_name(key_name)

	return new_node

func label_pressed(labelNode):
	var fieldName :String = labelNode.text
	if labelNode.is_label_button:
		if fieldName == "Key":
			labelNode.display_edit_table_menu()
		elif fieldName == "Display Name":
			labelNode.is_label_button = false
			print("Cannot Edit the settings for Display Name Node")
		else:
			labelNode.display_edit_field_menu(fieldName, labelNode)


func delete_field(field_name:String, tableID:String)-> bool:
	print("DELETE field NAME: ", field_name, " IN TABLE: ", tableID)
	var success:bool = false

	for keyID in all_tables_merged_dict[tableID]:
		all_tables_merged_dict[tableID][keyID].erase(field_name)

	var order_index:int = 1
	var copy_of_merged_data_dict:Dictionary = all_tables_merged_data_dict.duplicate(true)
	for ID in copy_of_merged_data_dict[tableID][FIELD].size():
		var order_ID: int = ID + 1
		#print("FIELD INDEX: ", all_tables_merged_data_dict[tableID][FIELD][str(order_ID)])
		if all_tables_merged_data_dict[tableID][FIELD][str(order_ID)]["FieldName"] == field_name:
			print("ERASE FIELD NAME: ", field_name)
			all_tables_merged_data_dict[tableID][FIELD].erase(str(order_ID))
			success = true
		else:
			if order_ID != order_index:
				var this_field_data:Dictionary = all_tables_merged_data_dict[tableID][FIELD][str(order_ID)]
				all_tables_merged_data_dict[tableID][FIELD][str(order_index)] = this_field_data
				all_tables_merged_data_dict[tableID][FIELD].erase(str(order_ID))
			order_index += 1
	save_file(table_save_path + tableID + table_file_format, all_tables_merged_dict[tableID])
	save_file(table_save_path + tableID + table_info_file_format, all_tables_merged_data_dict[tableID])
	
	print("DICT: ", all_tables_merged_dict[tableID])
	print("DATA DICT: ", all_tables_merged_data_dict[tableID][FIELD])
	
	return success


func add_field(new_field:Dictionary, tableID):
	var new_ID:String = str(all_tables_merged_data_dict[tableID][FIELD].size() + 1)
	all_tables_merged_data_dict[tableID][FIELD][new_ID] = new_field
	var default_value:Variant = get_default_value(new_field["DataType"])
	#print("DEFAULT VALUE: ", default_value)
	for keyID in all_tables_merged_dict[tableID]:
		all_tables_merged_dict[tableID][keyID][new_field["FieldName"]] = default_value
	print("DICT: ", all_tables_merged_dict[tableID])
	print("DATA DICT: ", all_tables_merged_data_dict[tableID][FIELD])
	

func add_key(tblName: String, keyName, datatype, showKey, requiredValue, dropdown, display_name:String = "",  newTable :bool = false, new_data := {}):
	var index = all_tables_merged_data_dict[tblName][KEY].size() + 1
	var CustomData_dict:Dictionary = all_tables_merged_dict["10026"] 
	var newOptions_dict :Dictionary= {}
	var newValue
	#create and save new table with values from input form
	#Get custom key fields and add them to tableData dict
	for key in CustomData_dict:
		var currentKey_dict :Dictionary = convert_string_to_type(CustomData_dict[key]["ItemID"])
		var currentKey :String = get_value_as_text(currentKey_dict)
		match currentKey:
			"DataType":
				newValue = datatype
			"FieldName":
				newValue = keyName
			"RequiredValue":
				newValue = requiredValue
			"ShowValue":
				newValue = showKey
			"TableRef":
				newValue = dropdown

		newOptions_dict[currentKey] = newValue

	all_tables_merged_data_dict[tblName][KEY][str(index)] =  newOptions_dict

	if newTable:
		all_tables_merged_dict[tblName][keyName] = "empty"

	else:
		var new_key_data:Dictionary = all_tables_merged_dict[tblName][all_tables_merged_dict[tblName].keys()[0]].duplicate(true)
		#print("NEW KEY DATA: ", new_key_data)
		if new_data != {}:
			new_key_data = new_data
			#new_key_data["Display Name"]["text"] = display_name
			#print("NEW KEY DATA: ", new_key_data)
		all_tables_merged_dict[tblName][keyName] = new_key_data


func save_all_db_files():#table_name :String, table_dict:Dictionary, data_dict:Dictionary):
	print("SAVE ALL DB FILES- EDITOR MANAGER")
	for form in display_form_dict:
		#print(display_form_dict[form])
		if form != null and display_form_dict[form]["Node"] != null:
			var form_node: Variant = display_form_dict[form]["Node"]
			#print("TABLE NAME: ", form_node.table_name)
			if form_node.table_name != null:
				await save_file(table_save_path + form_node.table_name + table_file_format, form_node.table_dict)
				await save_file(table_save_path + form_node.table_name + table_info_file_format, form_node.data_dict)
#	update_project_settings()


func reset_dictionaries(table_id:String) -> Array:
	#replaces dictionary data with data from saved files
	var data_dict : Dictionary = import_data(str(table_id), true) 
	var table_dict: Dictionary = import_data(str(table_id))
	
	return [data_dict, table_dict]


func get_data_index(value: String, dataType:String , data_dict :Dictionary):
	var index = ""
#	print("DATA DICT: ", data_dict)
	for i in data_dict[dataType]:
#		print()
		var fieldName = data_dict[dataType][str(i)]["FieldName"]
		if fieldName == value:
			index = i
			break
	return index


static func list_custom_dict_keys_in_display_order(table_dict:Dictionary, table_name:String):
#	print("TABLE NAME FOR LIST CUSTOM DICT IN DISPLAY ORDER: ", table_name)
	var data_dict:Dictionary = all_tables_merged_data_dict[table_name]
	var sorted_dict: Dictionary = {}
	if data_dict != {}:
		
		var index := 1
		for keyID in data_dict[KEY].size():

			var item_number = str(keyID + 1) #row_dict key
			var displayName :String = ""
			var datatype :String = data_dict[KEY][item_number]["DataType"]
			var key_name :String = data_dict[KEY][item_number]["FieldName"] #Use the row_dict key (item_number) to set the button label as the item name
	#		print(table_dict)
			if table_dict.has(key_name):
				
				var key_dict :Dictionary = table_dict[key_name]
	#			print("KEY DICT: ", key_dict)
				if key_dict.has("Display Name"):
	#
	#				print("HAS DISPLAY NAME")
	#				print(table_dict)
					displayName = get_value_as_text(table_dict[key_name]["Display Name"])
	#				print(displayName)
				else:
	#				print("NO DISPLAY NAME")
					displayName = key_name
				sorted_dict[str(index)] = [displayName, key_name, datatype]
				index += 1
	else:
		print("ERROR! DATA DICT IS EMPTY")
	return sorted_dict
