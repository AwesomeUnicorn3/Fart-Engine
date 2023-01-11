@tool

extends DatabaseEngine

signal refresh_all_data


@onready var tabTemplate = load("res://addons/UDSEngine/Database_Manager/Scenes and Scripts/UI_Navigation_Scenes/Tab_Template.tscn")
@onready var navButton = load("res://addons/UDSEngine/Database_Manager/Scenes and Scripts/UI_Navigation_Scenes/Navigation_Button.tscn")
@onready var tabs = $Tabs
@onready var navigation_buttons = $HBox_1/VBox_1/ScrollContainer/Hbox_1

var selected_tab_name := ""

func _ready():
	create_tabs()
	#print("Tab Creation Complete")


func hide_all_tabs(): #Hides all of the modules
	for i in tabs.get_children():
		i.visible = false


func create_tabs():
	#print("Begin Create Tabs")
	if tabs.get_children().size() > 0:
		clear_data_tabs()

	if navigation_buttons.get_children().size() > 0:
		clear_buttons()
	
	await get_tree().create_timer(.25).timeout
	#print("Start Import")
	var tables_dict = import_data(table_save_path + "Table Data.json")
	var table_data = import_data(table_save_path + "Table Data_data.json")
	#print("End Import")
	#print(tables_dict.size())
	for i in range(0, tables_dict.size()):
		var index :String = str(i + 1)
		#i = int(i)
#		i += 1
		#print("Index :" , index)
		#i = str(i)
		index = table_data["Row"][index]["FieldName"]
		
		var create_tab :bool = convert_string_to_type(tables_dict[index]["Create Tab"])
		if create_tab:
#			#Create button for tab
			var newbtn = navButton.instantiate()
			var newbtn_name :String = index
			
			if navigation_buttons.has_node(index):
				newbtn_name = str(index + " A")
			newbtn.name = newbtn_name
			#print(newbtn.name)
			newbtn.set_text(index)
			
			navigation_buttons.add_child(newbtn)
			#print(newbtn.name , " Added")
#
#			#Create tab datainput node
			var newtab = tabTemplate.instantiate()
			newtab.tableName = index
			newtab.name = newbtn_name
#			
			
			tabs.add_child(newtab)
			newtab.get_node("VBox1/TableName/Label/HBox1/Label_Button").set_text(index)
			var new_node = newtab.get_node("VBox1/Key")
			new_node.table_ref = newtab.set_ref_table()
			newtab.visible = false
			#print(newbtn_name)
			
	#print("Selected Tab Name: " , selected_tab_name)
	if selected_tab_name != "":
		#print("Show Selected Tab Start")
		show_selected_tab(selected_tab_name)
		#print("Show Selected Tab End")
#	emit_signal("table_loading_complete")
	#print("End Create Tabs")
	
func clear_data_tabs():
	for i in tabs.get_children():
		var delete_me = i.is_in_group("Database")
		if delete_me == false:
			i.queue_free()
		else:
			i._ready()


func clear_buttons():
	for i in navigation_buttons.get_children():
		var delete_me = i.is_in_group("Database")
		if delete_me == false:
			i.queue_free()


func enable_navigation_buttons(): #Enables all Navigation buttons
	for i in navigation_buttons.get_children():
		i.disabled = false

func show_selected_tab(tabName : String = ""):
	var tabKeys = {}
	for i in tabs.get_children():
		#print(i)
		tabKeys[i.name] = i
		
	if tabKeys.has(tabName):
		tabs.visible = true
		var current_button = navigation_buttons.get_node(tabName)
		current_button.set_disabled(true)
		var selected_node = tabs.get_node(tabName)
		selected_node.visible = true
		selected_tab_name = tabName

func tab_settings():
	hide_all_tabs()
	enable_navigation_buttons()


func nav_button_click(btnName, btnNode):
	tab_settings()
	show_selected_tab(btnName)
	btnNode.disabled = true
