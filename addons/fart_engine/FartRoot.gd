@tool

extends EditorManager
#
#signal refresh_all_data
#signal save_complete


#@onready var DBENGINE :DatabaseManager = DatabaseManager.new()
@onready var tabTemplate := preload("res://addons/fart_engine/Database_Manager/Scenes and Scripts/UI_Navigation_Scenes/TableTemplate.tscn")
@onready var NavigationButton := preload("res://addons/fart_engine/Database_Manager/Scenes and Scripts/UI_Navigation_Scenes/Navigation_Button.tscn")
@onready var main_display_level_1 := $MainDisplay_Level1
@onready var main_display_level_2 := $MainDisplay_Level1/MainDisplay_Level2
@onready var main_project_header := $MainDisplay_Level1/MainDisplay_Level2/MainDisplay_Level3/MainProjectHeaderScroll/MainProjectHeader
@onready var table_category := $MainDisplay_Level1/MainDisplay_Level2/MainDisplay_Level3/TableCategoryScroll/TableCategory
@onready var table_buttons := $MainDisplay_Level1/MainDisplay_Level2/MainDisplay_Level3/TableButtonsScroll/TableButtons
@onready var welcome_label = $ProjectWelcomeLabel/Welcome_Label
@onready var table_display := $MainDisplay_Level1/MainDisplay_Level2/TableDisplay


func _ready():
	if is_uds_main_updating == false:
		set_fart_root(self)
		is_uds_main_updating = true
		print("FART Main _Ready Begin")
		connect_signals()
		add_database_tabs_to_display_dict() #ADD THE EVENTS AND EDIT SAVE FILE TABS
		await clear_data_tabs()
		await clear_all_buttons()
		add_category_buttons()
		add_database_buttons_to_button_dict()
		add_other_nav_buttons_to_button_dict()
		add_database_tabs_to_display_dict()

		for key in display_form_dict:
			var display_node = display_form_dict[key]["Node"]
			if display_node != null:
				if display_node.has_method("reload_data_without_saving"):
					if key != selected_tab_name:
						display_form_dict[key]["Node"].reload_data_without_saving()

		set_buttom_theme("Top Row")
		set_buttom_theme("Category")
		set_background_theme($Background)
		await get_tree().create_timer(0.1).timeout
		is_uds_main_updating = false
		
		
		table_category.get_node(selected_category)._on_Navigation_Button_button_up()


func add_category_buttons():
	var categories_dict :Dictionary = import_data("Table Category")
	var sorted_category_dict :Dictionary = list_keys_in_display_order("Table Category")
	for key in sorted_category_dict.size():
		var key_string:String = str(key + 1)
		var category_name :String = get_text(categories_dict[sorted_category_dict[key_string][1]]["Display Name"])
		var new_button :TextureButton = add_new_button(category_name, category_name, NavigationButton, table_category, "Category")
		add_category_to_dict(category_name)
	await get_tree().process_frame


func add_category_to_dict(category_name):
	if !category_settings_dict.has(category_name):
		category_settings_dict[category_name] = {"Selected Table" : "Blank"}


func add_new_button(BtnIndex:String,display_name:String, buttonScene, parentContainer, group:String):
	var newbtn = buttonScene.instantiate()
	var currButtonName :String = BtnIndex
	newbtn.name = currButtonName
	newbtn.set_label_text(display_name)
	
	if currButtonName != "Table Data" and currButtonName != "Project Settings":
		parentContainer.add_child(newbtn)
		button_dict[currButtonName] = newbtn
	
	newbtn.name = BtnIndex
	newbtn.add_to_group(group)
	newbtn.root = self
	return newbtn


func add_database_tabs_to_display_dict():
	for child in table_display.get_children():
		if !display_form_dict.has(child.name):
			display_form_dict[child.name] = {"Node" : child, "Selected Key" : "None Selected"}
		else:
			display_form_dict[child.name]["Node"] = child
		if !display_form_dict[child.name].has("Selected Key"):
			display_form_dict[child.name]["Selected Key"] = "None Selected"


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


func clear_data_tabs():
	for display_tab_name in display_form_dict:
		var display_tab = display_form_dict[display_tab_name]["Node"]
		var do_not_delete_me :bool = false
		if display_tab != null:
			do_not_delete_me = display_tab.is_in_group("Database")
		if do_not_delete_me:
			do_not_delete_dict[display_tab] = display_tab_name
			display_tab._ready()
		else:
			display_form_dict[display_tab_name]["Node"] = null

	for child in table_display.get_children():
		if !child.is_in_group("Database"):
			child.queue_free()

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
	await get_tree().create_timer(0.25).timeout


func set_buttom_theme(group: String):
	var project_table: Dictionary = import_data("Project Settings")
	var fart_editor_themes_table: Dictionary = import_data("Fart Editor Themes")
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
	if display_form_dict.has(tabName):
		table_display.visible = true
		var display_node = display_form_dict[tabName]["Node"]
		if !display_node == null:
			display_form_dict[tabName]["Node"].visible = true
			var current_button = button_dict[tabName]
			if tabName != "Project Settings" and tabName != "Table Data":
				selected_tab_name = tabName


func hide_all_tables():
	for tbl_form in display_form_dict:
		if display_form_dict[tbl_form]["Node"] != null:
			display_form_dict[tbl_form]["Node"].visible = false


func set_category_selected_table(category_name:String, selected_table_name:String, buttonNode:Object):
	var update_category: bool = !buttonNode.is_in_group("Top Row")
	if update_category == true:
		category_settings_dict[category_name]["Selected Table"] = selected_table_name


func navigation_button_click(btnName, btnNode):
	if btnNode.is_in_group("Category"):
		await clear_table_buttons()
		await clear_data_tabs()
		add_tables_in_category(btnName)
		enable_category_buttons()
		set_buttom_theme("Table")
		selected_category = btnName
		show_selected_tab(selected_tab_name)
		auto_select_table()
	else:
		hide_all_tables()
		show_selected_tab(btnName)
		set_category_selected_table(selected_category, btnName, btnNode)
		enable_database_buttons()
		enable_table_buttons()

	btnNode.disabled = true
	btnNode._on_texture_button_down()


func auto_select_table():
	var selected_table:String = category_settings_dict[selected_category]["Selected Table"]
	if selected_table == "Blank":
		selected_table = table_buttons.get_child(0).name
		category_settings_dict[selected_category]["Selected Table"] = selected_table
	var btn_node = await find_child(category_settings_dict[selected_category]["Selected Table"], true, false)
	btn_node._on_Navigation_Button_button_up()


func add_tables_in_category(category :String):
	var tables_dict = import_data("Table Data")
	var sorted_tables_dict = list_keys_in_display_order("Table Data")
	var table_data = import_data("Table Data", true)
	var category_dict = import_data("Table Category")
	var category_key = get_id_from_display_name(category_dict, category)
	for BtnIndex in sorted_tables_dict:
		var tableKey: String = sorted_tables_dict[BtnIndex][1]
		var create_tab :bool = convert_string_to_type(tables_dict[tableKey]["Create Tab"])
		var table_category_key :String  = str(tables_dict[tableKey]["Table Category"])
		var display_name: String = get_text(tables_dict[tableKey]["Display Name"])
		var table_already_exists: bool = false
		if display_form_dict.has(tableKey):
			if display_form_dict[tableKey]["Node"] != null:
				table_already_exists = true
		if category_key == table_category_key and create_tab and !table_already_exists:
			var newbtn = add_new_button(tableKey, display_name , NavigationButton, table_buttons, "Table")
			var newbtn_name = newbtn.name
			var newtab = tabTemplate.instantiate()
			newtab.tableName = tableKey
			newtab.name = newbtn_name
			if newbtn_name == "Table Data" or newbtn_name == "Project Settings":
				newtab.add_to_group("Database")
			if !display_form_dict.has(newbtn_name):
				display_form_dict[newbtn_name] = {"Node" : newtab, "Selected Key": "None Selected"}
			table_display.add_child(newtab)
			newtab.get_node("VBox1/TableName/Input_Node/Label/HBox1/Label_Button").set_text(display_name)
			var new_node = newtab.get_node("VBox1/Key")
			new_node.table_ref = newtab.set_ref_table()
			newtab.visible = false
			display_form_dict[newbtn_name]["Node"] = newtab


func connect_signals():
	pass


func _change_button_size(newbtn):
	newbtn.change_button_size()
	await newbtn.button_size_changed


func _on_hide_navigation_button_up():
	$MainDisplay_Level1/MainDisplay_Level2/MainDisplay_Level3.visible = !$MainDisplay_Level1/MainDisplay_Level2/MainDisplay_Level3.visible