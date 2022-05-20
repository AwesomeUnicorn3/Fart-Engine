extends InputEngine
tool


#export var main_tab_group = "" #the main tab should be included in this group
export var selection_table_name = "" #Name of the table to add to dropdown list


var selection_table  = {}
var main_scene : Node
var selected_item_index
var selectedItemName = ""
var relatedInputNode : Node = null
var relatedTableName = ""

func _init() -> void:
	type = "5"

#func _ready():
#	default = 0
#	type = "Dropdown List"


	

#func get_main_tab(par):
#	#Get main tab scene which should have the popup container and necessary script
#	while !par.get_groups().has("Tab"):
#		par = par.get_parent()
#	return par

func populate_list(update_selection_table :bool = true):
	#Add values from selected table to dropdown list
	main_scene = get_main_tab(get_parent())
	if update_selection_table:
#		print(selection_table_name)
		selection_table = main_scene.import_data(main_scene.table_save_path + selection_table_name +".json" )
	inputNode.clear() #Clear values in dropdown list
	for n in selection_table: #Loop through the selected table and add each key to the dropdown list
		var displayName
		if n != "Default":
			if typeof(selection_table[n]) != TYPE_DICTIONARY:
				displayName = n
			
			elif !selection_table[n].has("Display Name"):
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
	for id in dropDownSize: #Loop through all values in dropdown list until the item name is found, return index #
#		print(itemName, " ", inputNode.get_item_text(i))
		var list_ItemName = inputNode.get_item_text(id) #display name
		#need to get "display name" from item name
		for key in selection_table:
			if typeof(selection_table[key]) == TYPE_STRING or typeof(selection_table[key]) == TYPE_BOOL:
				if key == item_name:
					item_name = key
					
			elif selection_table[key].has("Display Name"):
#				print(item_name)
				if key == item_name:
					item_name = selection_table[key]["Display Name"]
#					print(item_name)
			else:
				if key == item_name:
					item_name = key
#					print(item_name)
		
		if item_name == list_ItemName:
			item_id = id
#			print(list_ItemName, " ", item_id)
			break
	return item_id



#func get_dataType_name(displayName : String, returnInt = false):
#	var returnValue
#
#	var displayDict = selection_table
#
#	for key in displayDict:
#
#		if key == displayName:
#			if !returnInt:
#				returnValue = key
#			else:
#				returnValue = get_id(key)
#
#			break
#		if key == displayName:
#			if !returnInt:
#				returnValue = displayDict[i]["ID"]
#			else:
#				returnValue = get_id(displayDict[i]["ID"])
##	print(returnValue)
#	return returnValue


func get_dataType_ID(displayName : String):
	var returnValue
	var displayDict = selection_table

	for key in displayDict:
		if displayDict[key]["Display Name"] == displayName:
			returnValue = key
			break
		elif key == displayName:
			returnValue = key

	return returnValue

func get_index_from_displayName(display_name :String):
#	print(selection_table)
	for key in selection_table:
#		print(selection_table[key])
		if selection_table[key].has("Display Name"):
			if selection_table[key]["Display Name"] == display_name:
				for key2 in inputNode.item_list:
#					print(key2)
					var index = get_selected_value(int(key))
				
					return int(index)
					break
		
		else:
			var index = get_selected_value(int(key))
#			print(index)
			return int(index)
			break
			


	

func get_selected_value(index : int):
	var type_name = inputNode.get_item_text(index)
	var selection_table_keys_array = selection_table.keys()
	
#	if selection_table_keys_array.size() == 0:
#		print(selection_table_name)
#		print(index)
#		print("ERROR- NO DATA IN SELECTED TABLE")

	if typeof(selection_table[selection_table_keys_array[0]]) != TYPE_DICTIONARY:
		pass

	elif selection_table[selection_table_keys_array[0]].has("Display Name"):
		for i in selection_table:
			if selection_table[i]["Display Name"] == type_name:
				if selection_table[i].has("ID"):
					type_name = selection_table[i]["ID"]
				else:
					type_name = selection_table[i]["Display Name"]
				break
	return type_name


func _on_Input_item_selected(index :int):
	selectedItemName = get_selected_value(index)
	if relatedInputNode != null:
#		print(str(get_dataType_ID(selectedItemName)))
		get_parent().swap_input_node(relatedInputNode, self, str(get_dataType_ID(selectedItemName)), relatedTableName)
	emit_signal("selected_item_changed")
	return selectedItemName


func select_index(index : int = 0):
	inputNode.select(index)
	_on_Input_item_selected(index)
