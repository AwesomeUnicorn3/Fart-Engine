@tool

extends Control

signal refresh_all_data



@onready var DBENGINE :DatabaseEngine = DatabaseEngine.new()
@onready var tabTemplate := preload("res://addons/UDSEngine/Database_Manager/Scenes and Scripts/UI_Navigation_Scenes/Tab_Template.tscn")
@onready var navButton := preload("res://addons/UDSEngine/Database_Manager/Scenes and Scripts/UI_Navigation_Scenes/Navigation_Button.tscn")
@onready var CategoryButton := preload("res://addons/UDSEngine/Database_Manager/Scenes and Scripts/UI_Navigation_Scenes/Category_Button.tscn")

@onready var main_display_level_1 := $MainDisplay_Level1
@onready var main_display_level_2 := $MainDisplay_Level1/MainDisplay_Level2
@onready var main_project_header := $MainDisplay_Level1/MainDisplay_Level2/MainProjectHeaderScroll/MainProjectHeader
@onready var table_category := $MainDisplay_Level1/MainDisplay_Level2/TableCategoryScroll/TableCategory
@onready var table_buttons := $MainDisplay_Level1/MainDisplay_Level2/TableButtonsScroll/TableButtons
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
		print("UDS Main _Ready Begin")
		connect_signals()
		print("CLEAR DATA TABS")
		await clear_data_tabs()
		print("CLEAR ALL BUTTONS")
		await clear_all_buttons()
		print("ADD DATABASE BUTTONS TO DICT")
		add_database_buttons_to_button_dict()
		add_database_tabs_to_display_dict()
		print("ADD CATEGORY BUTTONS")
		add_category_buttons()
		for key in display_form_dict:
			if display_form_dict[key].has_method("reload_data_without_saving"):
				display_form_dict[key].reload_data_without_saving()
		is_uds_main_updating = false


func add_category_buttons():
	var categories_dict :Dictionary = DBENGINE.import_data("Table Category")
	var sorted_category_dict :Dictionary = DBENGINE.list_keys_in_display_order("Table Category")
	for key in sorted_category_dict.size():
		var key_string:String = str(key + 1)
		#print(categories_dict[sorted_category_dict[key_string][1]])
		
		var category_name :String = DBENGINE.convert_string_to_type(categories_dict[sorted_category_dict[key_string][1]]["Display Name"])["text"]
		#print(category_name)
		add_new_button(category_name, CategoryButton, table_category)

	await get_tree().process_frame
	if selected_category == "":
		selected_category = "Engine Critical"
	button_dict[selected_category]._on_Navigation_Button_button_up()


func add_new_button(BtnIndex:String, buttonScene:PackedScene, parentContainer) -> String:
#	#Create button for table
	var newbtn = buttonScene.instantiate()
	var currButtonName :String = BtnIndex
	newbtn.name = currButtonName
	newbtn.set_text(BtnIndex)
	if currButtonName != "Table Data" and currButtonName != "Project Settings":
		parentContainer.add_child(newbtn)
		button_dict[currButtonName] = newbtn

	newbtn.root = self
	return currButtonName


func add_database_tabs_to_display_dict():
	for child in table_display.get_children():
		if !display_form_dict.has(child.name):
			display_form_dict[child.name] = child


func add_database_buttons_to_button_dict():
	for child in main_project_header.get_children():
		if !button_dict.has(child.name):
			var newbtn :Button = child
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
		await get_tree().process_frame


func clear_all_buttons():
	var button_dict_copy :Dictionary = button_dict.duplicate(true)
	for buttonName in button_dict_copy:
		var currButton :Button = button_dict_copy[buttonName]
		var do_not_delete_me = currButton.is_in_group("Database")
		if !do_not_delete_me:
			currButton.queue_free()
			button_dict.erase(currButton.name)
			await get_tree().process_frame
		else:
			button_dict.erase(currButton.name)
	await get_tree().process_frame


func clear_table_buttons():
	var button_dict_copy :Dictionary = button_dict.duplicate(true)
	for buttonName in button_dict_copy:
		var currButton :Button = button_dict_copy[buttonName]
		if currButton.get_parent() == table_buttons:
			var do_not_delete_me = currButton.is_in_group("Database")
			if !do_not_delete_me:
				currButton.queue_free()
				button_dict.erase(currButton.name)
				await get_tree().process_frame
	await get_tree().process_frame

func enable_all_buttons(): #Enables all Navigation buttons
	for buttonName in button_dict:
		button_dict[buttonName].disabled = false


func enable_table_buttons():
	for buttonName in button_dict:
		var currButton :Button = button_dict[buttonName]
		if currButton.get_parent() == table_buttons:
			button_dict[buttonName].disabled = false


func enable_database_buttons():
	for buttonName in button_dict:
		var currButton :Button = button_dict[buttonName]
		if currButton.get_parent() == main_project_header:
			button_dict[buttonName].disabled = false


func show_selected_tab(tabName : String = ""):
	if display_form_dict.has(tabName):
		table_display.visible = true
		display_form_dict[tabName].visible = true
		var current_button = button_dict[tabName]
		current_button.set_disabled(true)
		selected_tab_name = tabName


func hide_all_tables(): #Hides all of the Tables
	for tbl_form in display_form_dict:
		display_form_dict[tbl_form].visible = false



func navigation_button_click(btnName, btnNode):
	hide_all_tables()
	show_selected_tab(btnName)
	enable_database_buttons()
	enable_table_buttons()
	btnNode.disabled = true


func category_button_click(btnName, btnNode):
	selected_category = btnName
	await clear_data_tabs()
	await clear_table_buttons()
	add_tables_in_category(btnName)
	enable_all_buttons()
	btnNode.disabled = true


func add_tables_in_category(category :String):
	await get_tree().process_frame
	var tables_dict = DBENGINE.import_data("Table Data")
	var sorted_tables_dict = DBENGINE.list_keys_in_display_order("Table Data")
	var table_data = DBENGINE.import_data("Table Data", true)
	var category_dict = DBENGINE.import_data("Table Category")
	var category_key = DBENGINE.get_id_from_display_name(category_dict, category)
	#print("Category Key: ", category_key)
	for BtnIndex in sorted_tables_dict:
		#var BtnIndex :String = sorted_tables_dict[table_name][1]
		#print(BtnIndex)
		var tableKey: String = sorted_tables_dict[BtnIndex][1]
		
		#BtnIndex = table_data["Row"][BtnIndex]["FieldName"] #TABLE NAME
		var create_tab :bool = DBENGINE.convert_string_to_type(tables_dict[tableKey]["Create Tab"])
		var table_category_key :String  = str(tables_dict[tableKey]["Table Category"])

		if category_key == table_category_key and create_tab:
			#print("Table ID: ", tableKey)
			#print("Table Category ID: ", table_category_ID)
			#print("Table Category Name: ", table_category_name)
			#print("Category: ", category)
#			print("Table Key: ", tableKey)
			var newbtn_name = add_new_button(tableKey, navButton, table_buttons)
			var newtab = tabTemplate.instantiate()
			newtab.tableName = tableKey
			newtab.name = newbtn_name
			if newbtn_name == "Table Data" or newbtn_name == "Project Settings":
				newtab.add_to_group("Database")

				#IF NEW TAB ALREADY EXISTS IN TABLE DO NOTHING
			if !display_form_dict.has(newbtn_name):
				table_display.add_child(newtab)
				display_form_dict[newbtn_name] = newtab
				newtab.get_node("VBox1/TableName/Label/HBox1/Label_Button").set_text(tableKey)
				var new_node = newtab.get_node("VBox1/Key")
				new_node.table_ref = newtab.set_ref_table()
				newtab.visible = false

	if selected_tab_name != "":
		#print(selected_tab_name)
		show_selected_tab(selected_tab_name)


func when_editor_saved():
	print("PROJECT SETTINGS CHANGED")
	DBENGINE.update_input_actions_table()
#	await get_tree().process_frame
	DBENGINE.update_UI_method_table()
	await get_tree().create_timer(.5).timeout
	_ready()



func connect_signals():
	pass
#	if !has_signal("editor_saved"):
#		connect("editor_saved",when_editor_saved)
