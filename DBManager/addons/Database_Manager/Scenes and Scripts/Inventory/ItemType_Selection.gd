extends "res://addons/Database_Manager/Scenes and Scripts/InputScene.gd"
tool


#export var main_tab_group = "" #the main tab should be included in this group
export var selection_table_name = "" #Name of the table to add to dropdown list


var selection_table = {}
var main_scene : Node
var selected_item_index
var selectedItemName = ""

func _ready():
	default = 0
	type = "Dropdown List"


	

#func get_main_tab(par):
#	#Get main tab scene which should have the popup container and necessary script
#	while !par.get_groups().has("Tab"):
#		par = par.get_parent()
#	return par

func populate_list():
	#Add values from selected table to dropdown list
	main_scene = get_main_tab(get_parent())
	selection_table = main_scene.udsEngine.import_data(main_scene.udsEngine.table_save_path + selection_table_name +".json" )
	inputNode.clear() #Clear values in dropdown list
	for n in selection_table: #Loop through the selected table and add each key to the dropdown list
		var displayName
		if !selection_table[n].has("Display Name"):
			displayName = n
		else:
			displayName = selection_table[n]["Display Name"]
		inputNode.add_item (displayName)
	if selectedItemName == "":
		selectedItemName = get_selected_value(0)


func get_id(item_name : String = ""):
	#Get index # of selected item in dropdown list
	var dropDownSize = inputNode.get_popup().get_item_count()
	var item_id = -1
	for i in dropDownSize: #Loop through all values in dropdown list until the item name is found, return index #
#		print(itemName, " ", inputNode.get_item_text(i))
		var list_ItemName = inputNode.get_item_text(i)
		if item_name == list_ItemName:
			item_id = i
			break
	
	return item_id

func get_selected_value(index):
	var type_name = inputNode.get_item_text(index)
	var rand_item_array = selection_table.keys()
	if selection_table[rand_item_array[0]].has("Display Name"):
		for i in selection_table:
			if selection_table[i]["Display Name"] == type_name:
				type_name = selection_table[i]["ID"]
				break
	return type_name

func _on_Input_item_selected(index):
	selectedItemName = get_selected_value(index)
	


