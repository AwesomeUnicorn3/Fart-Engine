extends DatabaseEngine
tool

onready var tabTemplate = preload("res://addons/Database_Manager/Scenes and Scripts/UI_Navigation_Scenes/Tab_Template.tscn")
onready var navButton = preload("res://addons/Database_Manager/Scenes and Scripts/UI_Navigation_Scenes/Navigation_Button.tscn")
onready var tabs = $Tabs
onready var navigation_buttons = $HBox_1/VBox_1/Hbox_1


func _ready():
	create_tabs()


func hide_all_tabs(): #Hides all of the modules
	for i in tabs.get_children():
		i.visible = false


func create_tabs():
	clear_data_tabs()
	clear_buttons()
	var tables_dict = import_data(table_save_path + "Table Data.json")
	for i in tables_dict:
		var create_tab = convert_string_to_type(tables_dict[i]["Create Tab"])
		if create_tab:
			#Create button for tab
			var newbtn = navButton.instance()
			newbtn.name = i
			newbtn.set_text(i)
			navigation_buttons.add_child(newbtn)
			
			#Create tab datainput node
			
			var newtab = tabTemplate.instance()
			newtab.tableName = i
			newtab.name = i
			
			tabs.add_child(newtab)
			newtab.get_node("VBox1/HBox2/Panel1/VBox1/HBox1/Scroll1/VBox1/Key").table_ref = newtab.set_ref_table()
			newtab.visible = false

func clear_data_tabs():
	for i in tabs.get_children():
		var delete_me = i.is_in_group("Database")
		if delete_me == false:
			i.queue_free()

func clear_buttons():
	for i in navigation_buttons.get_children():
		var delete_me = i.is_in_group("Database")
		if delete_me == false:
			i.queue_free()

func enable_navigation_buttons(): #Enables all Navigation buttons
	for i in navigation_buttons.get_children():
		i.disabled = false

func show_selected_tab(tabName):
	var tabKeys = {}
	for i in tabs.get_children():
		tabKeys[i.name] = i
	if tabKeys.has(tabName):
		tabs.get_node(tabName).visible = true

func tab_settings():
	hide_all_tabs()
	enable_navigation_buttons()


func nav_button_click(btnName, btnNode):
	tab_settings()
	show_selected_tab(btnName)
	btnNode.disabled = true
