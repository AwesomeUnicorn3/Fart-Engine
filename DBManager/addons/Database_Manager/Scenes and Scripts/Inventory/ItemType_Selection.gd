extends VBoxContainer
tool


export var main_tab_group = "" #the main tab should be included in this group
export var selection_table_name = "" #Name of the table to add to dropdown list

onready var dropDown = $Hbox1/ColorRect/OptionButton
onready var input_field = $Hbox1/ColorRect/OptionButton

var selection_table = {}
var main_scene : Node
var selected_item_index


func _on_OptionButton_button_down():
	populate_list()


func get_main_tab(par):
	#Get main tab scene which should have the popup container and necessary script
	while !par.get_groups().has(main_tab_group):
		par = par.get_parent()
	return par

func populate_list():
	#Add values from selected table to dropdown list
	main_scene = get_main_tab(get_parent())
	selection_table = main_scene.import_data(main_scene.save_path + selection_table_name +".json" )
	dropDown.clear() #Clear values in dropdown list
	for n in selection_table: #Loop through the selected table and add each key to the dropdown list
		var t = selection_table[n]["TypeID"]
		dropDown.add_item (t)

func get_item_id(item_name : String = ""):
	#Get index # of selected item in dropdown list
	var dropDownSize = dropDown.get_popup().get_item_count()
	var item_id = -1
	for i in dropDownSize: #Loop through all values in dropdown list until the item name is found, return index #
		if item_name == dropDown.get_item_text(i):
			item_id = i
			break
	return item_id
