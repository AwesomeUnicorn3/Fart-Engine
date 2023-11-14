@tool

extends EditorManager

@onready var tabTemplate := preload("res://addons/fart_engine/Database_Manager/Scenes and Scripts/UI_Navigation_Scenes/TableDisplayTemplate.tscn")
@onready var CategoryNavigationButton := preload("res://addons/fart_engine/Database_Manager/Scenes and Scripts/UI_Navigation_Scenes/CategoryNavigationButton.tscn")

@onready var NavigationButton := preload("res://addons/fart_engine/Database_Manager/Scenes and Scripts/UI_Navigation_Scenes/NavigationButtonTemplate.tscn")
@onready var TableNavigationButton := preload("res://addons/fart_engine/Database_Manager/Scenes and Scripts/UI_Navigation_Scenes/TableNavigationButton.tscn")


@onready var main_display_level_1 := $MainDisplay_Level1
@onready var main_display_level_2 := $MainDisplay_Level1/MainDisplay_Level2
@onready var main_project_header := $MainDisplay_Level1/MainDisplay_Level2/MainDisplay_Level3/MainProjectHeaderScroll/MainProjectHeader
@onready var table_category := $MainDisplay_Level1/MainDisplay_Level2/MainDisplay_Level3/TableCategoryScroll/TableCategory
@onready var table_buttons := $MainDisplay_Level1/MainDisplay_Level2/MainDisplay_Level3/TableButtonsScroll/TableButtons
@onready var welcome_label = $ProjectWelcomeLabel/Welcome_Label
@onready var table_display := $MainDisplay_Level1/MainDisplay_Level2/TableDisplay


func _init():
	await set_all_tables_dicts()
	await set_datatype_dict()
	await update_all_event_list()
	await set_all_tables_option_dicts()

	await set_project_settings_dict()
	await set_global_data_dict()
#	await set_categories_dict()
	
	set_all_fields_dict()



func _ready():
	if is_uds_main_updating == false:
		set_fart_root(self)
		is_uds_main_updating = true
		print("FART Main _Ready Begin")
		connect_signals()
		#add_database_tabs_to_display_dict() #TOP ROW BUTTONS- NEED TO ADD THEM HERE
		await clear_data_tabs()
		await clear_all_buttons()
		add_category_buttons()
		add_database_buttons_to_button_dict()
		add_other_nav_buttons_to_button_dict()
		add_database_tabs_to_display_dict()
		PopupManager._set_popups_dict()
		await set_target_screen_size()
		print("ADD DATABASE TABLES COMPLETE")
		
#		for key in display_form_dict:
#			var display_node = display_form_dict[key]["Node"]
#			if display_node != null:
#				if display_node.has_method("reload_data_without_saving"):
#					if key != selected_tab_name:
#						display_form_dict[key]["Node"].reload_data_without_saving()

		set_buttom_theme("Top Row")
		set_buttom_theme("Category")
		set_background_theme($Background)
#		await get_tree().create_timer(0.1).timeout
		is_uds_main_updating = false

		while table_category.get_child_count() == 0:
			"TABLE CATEGORY HAS NO CHILDREN"
			await get_tree().process_frame
		#print("CATEGORY SETTINGS : ", category_settings_dict[selected_category])
		if selected_category == "1":
			table_category.get_children()[0]
		else:
			table_category.get_node(selected_category)._on_Navigation_Button_button_up()
		
		
		
		#get_all_gdscript_files()

func _process(delta: float) -> void: #ADD THIS TO TOOLBAR MANAGER SCRIPT AND BE SURE TO ONLY HAVE 1 INSTANCE OF IT AT ANY TIME

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


func add_category_buttons():
	var sorted_category_dict :Dictionary = await get_dict_in_display_order("10006")
	for key in sorted_category_dict:
		var key_string:String = str(key)
		var category_name :String = get_value_as_text(sorted_category_dict[key_string]["Display Name"])
		var new_button :TextureButton = add_new_button(category_name, category_name, CategoryNavigationButton, table_category, "Category")
		add_category_to_dict(category_name)
	print("CATEGORY BUTTONS ADDED")



func add_category_to_dict(category_name):
	if !category_settings_dict.has(category_name):
		category_settings_dict[category_name] = {"Selected Table" : "0"}


func add_new_button(BtnIndex:String,display_name:String, buttonScene, parentContainer, group:String):
	var newbtn = buttonScene.instantiate()
#	var currButtonName :String = BtnIndex
	newbtn.name = BtnIndex
	newbtn.set_label_text(BtnIndex, display_name)
	newbtn.add_to_group(group)
#	if BtnIndex != "10000" and BtnIndex != "10038":
	parentContainer.add_child(newbtn)
	button_dict[BtnIndex] = newbtn
	
#	newbtn.name = BtnIndex
	print("ADD TO NEW GROUP: ", group)
	
	newbtn.root = self
	return newbtn


func add_database_tabs_to_display_dict():
	for child in table_display.get_children():
		if !display_form_dict.has(child.name):
			display_form_dict[child.name] = {"Node" : child, "Selected Key" : "1"}
		else:
			display_form_dict[child.name]["Node"] = child
		if !display_form_dict[child.name].has("Selected Key"):
			display_form_dict[child.name]["Selected Key"] = "1"
	print("TABLES ADDED TO MEMORY")


func add_database_buttons_to_button_dict():
	for child in main_project_header.get_children():
		if !button_dict.has(child.name):
			var newbtn :TextureButton = child
			button_dict[child.name] = newbtn


func add_other_nav_buttons_to_button_dict():
	var child: TextureButton = $MainDisplay_Level1/MainDisplay_Level2/HideNavigation
	if !button_dict.has(child.name):
		var newbtn :TextureButton = child
		button_dict[child.name] = newbtn
	#NOT SURE WHAT THIS DOES
	print("OTHER NAVIGATION BUTTONS ADDED TO SCENE")
	


func clear_data_tabs():
	for display_tab_name in display_form_dict:
		var display_tab = display_form_dict[display_tab_name]["Node"]
		var do_not_delete_me :bool = false
		if display_tab != null:
			do_not_delete_me = display_tab.is_in_group("Database")
		if do_not_delete_me:
			do_not_delete_dict[display_tab] = display_tab_name
			#display_tab._ready()
		else:
			display_form_dict[display_tab_name]["Node"] = null

	for child in table_display.get_children():
		if !child.is_in_group("Database"):
			child.queue_free()
	print("TABLES CLEARED FROM MEMORY")


func clear_all_buttons():
	var button_dict_copy :Dictionary = button_dict.duplicate(true)
	for buttonName in button_dict_copy:
		var currButton :TextureButton = button_dict_copy[buttonName]
		var do_not_delete_me = currButton.is_in_group("Database")
		if do_not_delete_me:
			button_dict.erase(currButton.name)
		else:
			currButton.queue_free()
			button_dict.erase(currButton.name)
	await get_tree().create_timer(0.25).timeout


func clear_table_buttons():
	var button_dict_copy :Dictionary = button_dict.duplicate(true)
	for buttonName in button_dict_copy:
		var currButton :TextureButton = button_dict_copy[buttonName]
		if currButton.get_parent() == table_buttons:
			var do_not_delete_me = currButton.is_in_group("Database")
			if !do_not_delete_me:
				currButton.queue_free()
				button_dict.erase(currButton.name)
	await get_tree().process_frame


func set_buttom_theme(group: String):
	var project_table: Dictionary = import_data("10038")
	var fart_editor_themes_table: Dictionary = import_data("10025")
	var theme_profile: String = project_table["1"]["Fart Editor Theme"]
	var category_color: Color = str_to_var(fart_editor_themes_table[theme_profile][group + " Button"])

	for buttonName in button_dict:
		var button_node = button_dict[buttonName]
		button_node.root = self
		if button_node.is_in_group(group):
			_change_button_size(button_node)
			button_node.set_button_base_color(category_color)


func enable_table_buttons():
	for buttonName in button_dict:
		var currButton :TextureButton = button_dict[buttonName]
		if currButton.get_parent() == table_buttons:
			button_dict[buttonName].disabled = false
			button_dict[buttonName].reset_self_modulate()


func enable_category_buttons():
	for buttonName in button_dict:
		var currButton :TextureButton = button_dict[buttonName]
		if currButton.get_parent() == table_category:
			button_dict[buttonName].disabled = false
			button_dict[buttonName].reset_self_modulate()


func enable_database_buttons():
	for buttonName in button_dict:
		var currButton :TextureButton = button_dict[buttonName]
		if currButton.get_parent() == main_project_header:
			button_dict[buttonName].disabled = false
			button_dict[buttonName].reset_self_modulate()


func show_selected_tab(tabName : String = ""):
	table_display.visible = true
	if display_form_dict.has(tabName):
		
		var display_node = display_form_dict[tabName]["Node"]
		if !display_node == null:
			display_form_dict[tabName]["Node"].visible = true
			var current_button = button_dict[tabName]
			#if tabName != "10038" and tabName != "10000":
			selected_tab_name = tabName
	await get_tree().process_frame


func hide_all_tables():
	for tbl_form in display_form_dict:
		if display_form_dict[tbl_form]["Node"] != null:
			display_form_dict[tbl_form]["Node"].visible = false


func set_category_selected_table(category_name:String, selected_table_name:String, buttonNode:Object):
	var update_category: bool = !buttonNode.is_in_group("Top Row")
	if update_category == true:
		print("SET SELECTED TABLE: ", selected_table_name)
		category_settings_dict[category_name]["Selected Table"] = selected_table_name


func navigation_button_click(btnName, btnNode):
	if btnNode.is_in_group("Category"):
		await clear_table_buttons()
		await clear_data_tabs()
		add_tables_in_category(btnName)
		enable_category_buttons()
		set_buttom_theme("Table")
		selected_category = btnName
		await show_selected_tab(selected_tab_name)
		auto_select_table()
	else:
		hide_all_tables()
		await show_selected_tab(btnName)
		set_category_selected_table(selected_category, btnName, btnNode)
		enable_database_buttons()
		enable_table_buttons()

	btnNode.disabled = true
	btnNode._on_texture_button_down()


func auto_select_table()-> void:
#	while table_buttons.get_child_count() == 0:
#		print("GUVMENT CAME AN TOOK MA BABY")
#		get_tree().process_frame
	var btn_node 
	#print("TABLE ID-------: ", category_settings_dict)
	var selected_tableID:String = category_settings_dict[selected_category]["Selected Table"]
	if category_settings_dict[selected_category]["Selected Table"] != "0":
		print("SELECTED TABLE ID IS ", category_settings_dict[selected_category]["Selected Table"])

		category_settings_dict[selected_category]["Selected Table"] = selected_tableID
		btn_node = await table_buttons.get_node(selected_tableID)
	else:
		print("JUST GET FIRST CHILD IN TABLE_BUTTONS: ", table_buttons.get_children())
		btn_node = table_buttons.get_children()[0]
	btn_node._on_Navigation_Button_button_up()


func add_tables_in_category(category :String):
	all_tables_dict_sorted = await get_dict_in_display_order("10000")
	var category_key = get_id_from_display_name(all_tables_merged_dict["10006"], category)
	for TableName in all_tables_dict_sorted:
		#print("TABLE NAME: ", BtnIndex)
		var create_tab :bool = convert_string_to_type(all_tables_dict_sorted[TableName]["Create Tab"])
		var table_category_key :String  = str(all_tables_dict_sorted[TableName]["Table Category"])
		var display_name: String = get_value_as_text(all_tables_dict_sorted[TableName]["Display Name"])
		var table_already_exists: bool = false
		if display_form_dict.has(TableName):
			if display_form_dict[TableName]["Node"] != null:
				table_already_exists = true


		if category_key == table_category_key and create_tab and !table_already_exists:
			var newbtn = add_new_button(TableName, display_name , TableNavigationButton, table_buttons, "Table")
			var newbtn_name = newbtn.name
			var newtab :TableDisplayTemplate = tabTemplate.instantiate()
			newtab.set_table_id(TableName)
			#print("NEW TABLE NAME: ", TableName)
			newtab.table_ID = TableName

			newtab.name = newbtn_name
#			if newbtn_name == "10000" or newbtn_name == "10038":
#				newtab.add_to_group("Database")
			if !display_form_dict.has(newbtn_name):
				display_form_dict[newbtn_name] = {"Node" : newtab, "Selected Key": "1"}
			table_display.add_child(newtab)
			newtab.get_node("VBox1/TableName/Input_Node/Label/HBox1/Label_Button").set_text_value(display_name)
			display_form_dict[newbtn_name]["Node"] = newtab
			newtab.visible = false
	



func connect_signals():
	pass


func _change_button_size(newbtn):
	newbtn.change_button_size()
	await newbtn.button_size_changed


func _on_hide_navigation_button_up():
	$MainDisplay_Level1/MainDisplay_Level2/MainDisplay_Level3.visible = !$MainDisplay_Level1/MainDisplay_Level2/MainDisplay_Level3.visible
