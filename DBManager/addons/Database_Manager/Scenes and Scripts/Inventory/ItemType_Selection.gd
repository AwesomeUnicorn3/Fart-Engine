extends "res://addons/Database_Manager/Scenes and Scripts/InputScene.gd"
tool


export var main_tab_group = "" #the main tab should be included in this group
export var selection_table_name = "" #Name of the table to add to dropdown list


var selection_table = {}
var main_scene : Node
var selected_item_index
var selectedItemName = ""

func _ready():
	default = 0
	type = "Dropdown"

	

func get_main_tab(par):
	#Get main tab scene which should have the popup container and necessary script
	while !par.get_groups().has(main_tab_group):
		par = par.get_parent()
	return par

func populate_list():
	#Add values from selected table to dropdown list
	main_scene = get_main_tab(get_parent())
	selection_table = main_scene.udsEngine.import_data(main_scene.udsEngine.table_save_path + selection_table_name +".json" )
	inputNode.clear() #Clear values in dropdown list
	for n in selection_table: #Loop through the selected table and add each key to the dropdown list
		var t = selection_table[n]["ID"]
		inputNode.add_item (t)
	selectedItemName = get_selected_value(0)

func get_item_id(item_name : String = ""):
	#Get index # of selected item in dropdown list
	var dropDownSize = inputNode.get_popup().get_item_count()
	var item_id = -1
	for i in dropDownSize: #Loop through all values in dropdown list until the item name is found, return index #
		if item_name == inputNode.get_item_text(i):
			item_id = i
			break
	return item_id

func get_selected_value(index):
	var type_id = inputNode.get_item_text(index)
	for i in selection_table:
		if selection_table[i]["ID"] == type_id:
			type_id = i
			break
	return type_id

func _on_Input_item_selected(index):
	selectedItemName = get_selected_value(index)

