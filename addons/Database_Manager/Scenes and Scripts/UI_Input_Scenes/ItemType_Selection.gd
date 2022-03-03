extends InputEngine
tool


#export var main_tab_group = "" #the main tab should be included in this group
export var selection_table_name = "" #Name of the table to add to dropdown list


var selection_table = {}
var main_scene : Node
var selected_item_index
var selectedItemName = ""
var relatedInputNode : Node = null
var relatedTableName = ""
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
	selection_table = main_scene.import_data(main_scene.table_save_path + selection_table_name +".json" )
	inputNode.clear() #Clear values in dropdown list
	for n in selection_table: #Loop through the selected table and add each key to the dropdown list
		var displayName
		if n != "Default":
			if !selection_table[n].has("Display Name"):
				displayName = n
			else:
				displayName = selection_table[n]["Display Name"]
			
			if selection_table_name == "Table Data" and n != selection_table_name:
				var engine = get_main_tab(self)
#				print(selection_table[n])
				var add_to_list = engine.convert_string_to_type(selection_table[n]["Is Dropdown Table"])
				if add_to_list:
					inputNode.add_item (displayName)
			else:
				inputNode.add_item (displayName)

	if selectedItemName == "":
		selectedItemName = get_selected_value(0)


func get_id(item_name : String = ""):
	#Get index # of selected item in dropdown list
	var dropDownSize = inputNode.get_popup().get_item_count()
	var item_id = 0
	for i in dropDownSize: #Loop through all values in dropdown list until the item name is found, return index #
#		print(itemName, " ", inputNode.get_item_text(i))
		var list_ItemName = inputNode.get_item_text(i)
		if item_name == list_ItemName:
			item_id = i
			break
	return item_id

func get_dataType_name(displayName : String, returnInt = false):
	var returnValue
	
	var displayDict = selection_table

	for i in displayDict:

		if displayDict[i]["Display Name"] == displayName:
			if !returnInt:
				returnValue = displayDict[i]["ID"]
			else:
				returnValue = get_id(displayDict[i]["Display Name"])

			break
		if displayDict[i]["ID"] == displayName:
			if !returnInt:
				returnValue = displayDict[i]["Display Name"]
			else:
				returnValue = get_id(displayDict[i]["Display Name"])
#	print(returnValue)
	return returnValue


func get_selected_value(index):
	var type_name = inputNode.get_item_text(index)
	var rand_item_array = selection_table.keys()
	
	if selection_table[rand_item_array[0]].has("Display Name"):
		for i in selection_table:
			if selection_table[i]["Display Name"] == type_name:
				type_name = selection_table[i]["ID"]
				break
#	elif selection_table[rand_item_array[0]].has("Reference Name"):
#		for i in selection_table:
#			if selection_table[i]["Reference Name"] == type_name:
#				type_name = selection_table[i]["Reference Name"]
#				break
	return type_name

func _on_Input_item_selected(index):
#	print(index)
	selectedItemName = get_selected_value(index)
	if relatedInputNode != null:
		get_parent().swap_input_node(relatedInputNode, self, selectedItemName, relatedTableName)
		
	return selectedItemName
