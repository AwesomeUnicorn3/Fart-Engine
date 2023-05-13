@tool

extends Control

signal refresh_all_data



@onready var DBENGINE :DatabaseEngine = DatabaseEngine.new()
@onready var tabTemplate := preload("res://addons/fart_engine/Database_Manager/Scenes and Scripts/UI_Navigation_Scenes/Tab_Template.tscn")
@onready var NavigationButton := preload("res://addons/fart_engine/Database_Manager/Scenes and Scripts/UI_Navigation_Scenes/Navigation_Button.tscn")
#@onready var CategoryButton := preload("res://addons/fart_engine/Database_Manager/Scenes and Scripts/UI_Navigation_Scenes/Category_Button.tscn")

@onready var main_display_level_1 := $MainDisplay_Level1
@onready var main_display_level_2 := $MainDisplay_Level1/MainDisplay_Level2
@onready var main_project_header := $MainDisplay_Level1/MainDisplay_Level2/MainDisplay_Level3/MainProjectHeaderScroll/MainProjectHeader
@onready var table_category := $MainDisplay_Level1/MainDisplay_Level2/MainDisplay_Level3/TableCategoryScroll/TableCategory
@onready var table_buttons := $MainDisplay_Level1/MainDisplay_Level2/MainDisplay_Level3/TableButtonsScroll/TableButtons
@onready var welcome_label = $ProjectWelcomeLabel/Welcome_Label
@onready var table_display := $MainDisplay_Level1/MainDisplay_Level2/TableDisplay

var settings_dict :Dictionary = {}
var global_data_dict :Dictionary = {}
var global_settings_profile :String = ""

var button_dict :Dictionary = {}
var display_form_dict :Dictionary = {}
var selected_tab_name :String= ""
var selected_category :String = ""
var selected_key :String = ""
#var selected_table :String = ""
var is_uds_main_updating: bool = false


func _ready():
	if is_uds_main_updating == false:
		is_uds_main_updating = true
		print("FART Main _Ready Begin")
		connect_signals()
		await clear_data_tabs()
		await clear_all_buttons()
		add_category_buttons()
		add_database_buttons_to_button_dict()
		add_other_nav_buttons_to_button_dict()
		add_database_tabs_to_display_dict()

		for key in display_form_dict:
			if display_form_dict[key].has_method("reload_data_without_saving"):
				display_form_dict[key].reload_data_without_saving()
		set_buttom_theme("Top Row")
		set_buttom_theme("Category")
		DBENGINE.set_background_theme($Background)

		is_uds_main_updating = false

#func set_background_theme(background_node = $Background):
##	print("BUTTON THEME: ", group)
#	#SET COLOR BASED ON GROUP
#	#get project table
#	var project_table: Dictionary = DBENGINE.import_data("Project Settings")
#	var fart_editor_themes_table: Dictionary = DBENGINE.import_data("Fart Editor Themes")
#
#	var theme_profile: String = project_table["1"]["Fart Editor Theme"]
#	var category_color: Color = str_to_var(fart_editor_themes_table[theme_profile]["Background"])
#	background_node.set_base_color(category_color)



func add_category_buttons():
	var categories_dict :Dictionary = DBENGINE.import_data("Table Category")
	var sorted_category_dict :Dictionary = DBENGINE.list_keys_in_display_order("Table Category")
	for key in sorted_category_dict.size():
		var key_string:String = str(key + 1)
		#print(categories_dict[sorted_category_dict[key_string][1]])
		
		var category_name :String = DBENGINE.get_text(categories_dict[sorted_category_dict[key_string][1]]["Display Name"])
		#print(category_name)
		var new_button :TextureButton = add_new_button(category_name, category_name, NavigationButton, table_category, "Category")
#		new_button.add_to_group("Category")
#
#		await change_button_size(new_button)
	await get_tree().process_frame

	if selected_category == "":
		selected_category = "Game Settings"
	button_dict[selected_category]._on_Navigation_Button_button_up()
	

func add_new_button(BtnIndex:String,display_name:String, buttonScene, parentContainer, group:String):
#	#Create button for table
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
#	print(newbtn.get_groups())
	newbtn.auto_set_color = false
	
	
	return newbtn


func add_database_tabs_to_display_dict():
	for child in table_display.get_children():
		if !display_form_dict.has(child.name):
			display_form_dict[child.name] = child


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
	var display_form_dict_copy :Dictionary = display_form_dict.duplicate(true)
	for display_tab_name in display_form_dict_copy:
		var display_tab = display_form_dict_copy[display_tab_name]
		var do_not_delete_me = display_tab.is_in_group("Database")
		if do_not_delete_me:
			display_tab._ready()
		else:
			display_tab.queue_free()
			display_form_dict.erase(display_tab_name)
#		await get_tree().process_frame


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
			await get_tree().process_frame
#	await get_tree().process_frame


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
#	await get_tree().process_frame


func set_buttom_theme(group: String):
#	print("BUTTON THEME: ", group)
	#SET COLOR BASED ON GROUP
	#get project table
	var project_table: Dictionary = DBENGINE.import_data("Project Settings")
	var fart_editor_themes_table: Dictionary = DBENGINE.import_data("Fart Editor Themes")
	
	var theme_profile: String = project_table["1"]["Fart Editor Theme"]
	var category_color: Color = str_to_var(fart_editor_themes_table[theme_profile][group + " Button"])
#	var group_name: String = group
	for buttonName in button_dict:
		var button_node = button_dict[buttonName]
		button_node.root = self
		if button_node.is_in_group(group):
#			print(buttonName, " Group: ", group)
			_change_button_size(button_node)
			button_node.set_base_color(category_color)


func enable_table_buttons():
	for buttonName in button_dict:
		var currButton :TextureButton = button_dict[buttonName]
		#print(currButton.get_parent())
		if currButton.get_parent() == table_buttons:
			button_dict[buttonName].disabled = false
			button_dict[buttonName].reset_self_modulate()



func enable_category_buttons():
	for buttonName in button_dict:
		var currButton :TextureButton = button_dict[buttonName]
		#print(currButton.get_parent(), "  ", table_category)
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
#	print(tabName)
	if display_form_dict.has(tabName):
		table_display.visible = true
		display_form_dict[tabName].visible = true
		var current_button = button_dict[tabName]
		current_button.set_disabled(true)
		if tabName != "Project Settings" and tabName != "Table Data":
			selected_tab_name = tabName


func hide_all_tables(): #Hides all of the Tables
	for tbl_form in display_form_dict:
		display_form_dict[tbl_form].visible = false



func navigation_button_click(btnName, btnNode):
#	print("Category Button: ", btnName)
	
	#if button is category
	if btnNode.is_in_group("Category"):

		clear_table_buttons()
		clear_data_tabs()
		
		add_tables_in_category(btnName)
		enable_category_buttons()
		
		set_buttom_theme("Table")
#		print(display_form_dict)
#		print(display_form_dict.keys())
#		show_selected_tab(selected_tab_name)
	else:
		hide_all_tables()
		show_selected_tab(btnName)
		enable_database_buttons()
		enable_table_buttons()
		


	btnNode.disabled = true
	btnNode._on_texture_button_down()
#	print("NAVIGATION BUTTON CLICK COMPLETE")

#func category_button_click(btnName, btnNode):
#	selected_category = btnName
#	await clear_data_tabs()
#	await clear_table_buttons()
#	add_tables_in_category(btnName)
#	enable_category_buttons()
#	btnNode.disabled = true


func add_tables_in_category(category :String):

#	print("Category Name: ", category)
#	await get_tree().process_frame
	var tables_dict = DBENGINE.import_data("Table Data")
	var sorted_tables_dict = DBENGINE.list_keys_in_display_order("Table Data")
	var table_data = DBENGINE.import_data("Table Data", true)
	var category_dict = DBENGINE.import_data("Table Category")
	var category_key = DBENGINE.get_id_from_display_name(category_dict, category)
#	print(sorted_tables_dict)
	for BtnIndex in sorted_tables_dict:
		
		#var BtnIndex :String = sorted_tables_dict[table_name][1]
		
		var tableKey: String = sorted_tables_dict[BtnIndex][1]
		
		#BtnIndex = table_data["Row"][BtnIndex]["FieldName"] #TABLE NAME
		var create_tab :bool = DBENGINE.convert_string_to_type(tables_dict[tableKey]["Create Tab"])
		var table_category_key :String  = str(tables_dict[tableKey]["Table Category"])
		var display_name: String = DBENGINE.get_text(tables_dict[tableKey]["Display Name"])

		
		if category_key == table_category_key and create_tab:
			var newbtn = add_new_button(tableKey, display_name , NavigationButton, table_buttons, "Table")
			var newbtn_name = newbtn.name

			var newtab = tabTemplate.instantiate()
			newtab.tableName = tableKey
			newtab.name = newbtn_name
			if newbtn_name == "Table Data" or newbtn_name == "Project Settings":
				newtab.add_to_group("Database")

				#IF NEW TAB ALREADY EXISTS IN TABLE DO NOTHING
				
			if !display_form_dict.has(newbtn_name):
				table_display.add_child(newtab)
				display_form_dict[newbtn_name] = newtab
				newtab.get_node("VBox1/TableName/Input_Node/Label/HBox1/Label_Button").set_text(display_name)
				var new_node = newtab.get_node("VBox1/Key")
				new_node.table_ref = newtab.set_ref_table()
				newtab.visible = false
				
			
#			await change_button_size(newbtn)
#	print("END OF ADD TABLES TO CATEGORY")
#	selected_tab_name = ""
#	table_buttons.get_child(0)._on_Navigation_Button_button_up()
	await get_tree().create_timer(0.1).timeout
	
	if selected_tab_name != "":
		if button_dict.has(selected_tab_name):
#		print(selected_tab_name)
#		print(table_buttons.find_child(selected_tab_name))
			button_dict[selected_tab_name]._on_Navigation_Button_button_up()
		else:
#			print("NOPE")
#			print(button_dict)
			table_buttons.get_child(0, true)._on_Navigation_Button_button_up()
	else:
		selected_tab_name = "Global Data"
		button_dict[selected_tab_name]._on_Navigation_Button_button_up()
#		#print(selected_tab_name)
#		show_selected_tab(selected_tab_name)


func when_editor_saved():
	while is_uds_main_updating:
		await get_tree().process_frame
	if display_form_dict.has(selected_tab_name):
		display_form_dict[selected_tab_name]._on_Save_button_up()
	print("PROJECT SETTINGS CHANGED")
	DBENGINE.update_input_actions_table()
	DBENGINE.update_UI_method_table()
	await get_tree().create_timer(.1).timeout
	_ready()



func connect_signals():
	pass
#	if !has_signal("editor_saved"):
#		connect("editor_saved",when_editor_saved)


func _change_button_size(newbtn):
#	await get_tree().process_frame
	newbtn.change_button_size()
	await newbtn.button_size_changed


func _on_hide_navigation_button_up():
	$MainDisplay_Level1/MainDisplay_Level2/MainDisplay_Level3.visible = !$MainDisplay_Level1/MainDisplay_Level2/MainDisplay_Level3.visible
