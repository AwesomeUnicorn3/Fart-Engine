@tool
extends InputEngine
#
#signal input_selection_changed
#export var main_tab_group = "" #the main tab should be included in this group
@export var selection_table_name = "" #Name of the table to add to dropdown list


var selection_table  = {}
var selected_item_index : int = 1
var selectedItemName = ""
var relatedInputNode : Node = null
var relatedTableName = ""
var previous_selection :String = ""

func _init() -> void:
	type = "5"


func populate_list(update_selection_table :bool = true):
	#Add values from selected table to dropdown list
	if update_selection_table:
		selection_table = await DBENGINE.import_data(DBENGINE.table_save_path + selection_table_name + DBENGINE.file_format )
	
	inputNode.clear() #Clear values in dropdown list
	for n in selection_table: #Loop through the selected table and add each key to the dropdown list
		var displayName = n

		if n != "Default":
#			if selection_table.has("Event Name"):
#				displayName = str_to_var(selection_table["Event Name"])["text"]
#				print(selection_table[n])
#				print("TYPE OF IS NOT DICTIONARY")
					
			if typeof(selection_table[n]) != TYPE_DICTIONARY: #ONLY USED FOR THE EVENT NAME SELECTION WHEN ADDING NEW EVENT NODE TO MAP
				var eventName :String = n
				if eventName.contains("{"):
					displayName = str_to_var(eventName)["text"]
				#print(displayName)

			elif !selection_table[n].has("Display Name"):
				displayName = n

			else:
				var dict1  = selection_table[n]
				var text_input  = dict1["Display Name"]

				if typeof(text_input) == TYPE_STRING:
					text_input = str_to_var(text_input)

#				var text_input_dict :Dictionary = str_to_var(dict1["Display Name"])
				if typeof(text_input) == TYPE_DICTIONARY:
					displayName = text_input["text"]
					#print("TYPE IS DICTIONARY", " ", displayName)
				else:
					displayName = text_input
					#print(displayName)
#				if displayName == null:
#					pass

			if selection_table_name == "Table Data" and n != selection_table_name:
				var add_to_list = DBENGINE.convert_string_to_type(selection_table[n]["Is Dropdown Table"])
				if add_to_list:
					inputNode.add_item (displayName)
			else:
				#print(n, " ", displayName)
				inputNode.add_item (displayName)
		
	if selectedItemName == "":
		selectedItemName = get_selected_value(0)
		previous_selection = selectedItemName


func get_id(item_name : String = ""):
	#Get index # of selected item in dropdown list
	var dropDownSize :int = inputNode.get_popup().get_item_count()
	var item_id := 0
	for id in dropDownSize: #Loop through all values in dropdown list until the item name is found, return index #
		var list_ItemName = inputNode.get_item_text(id) #display name
		#need to get "display name" from item name
		for key in selection_table:
			var selectionKeyType :int = typeof(selection_table[key])
			if selectionKeyType == TYPE_STRING or selectionKeyType == TYPE_BOOL:
				if key == item_name:
					item_name = key
					#print("SelectionKeyType is eiher bool or string: Item Name = ", item_name)
					
			elif selection_table[key].has("Display Name"):
				#print(key, " ", item_name)
				if key == item_name:
					item_name = selection_table[key]["Display Name"]
					#print("selection table[key] has Display Name: Item Name = ", item_name)
			else:
				if key == item_name:
					item_name = key
					#print("catchall: Item Name = ", item_name)
		if item_name == list_ItemName:
			item_id = id
			break
	#print(item_id)
	return item_id


func get_dataType_ID(displayName : String):
	var returnValue
	var displayDict = selection_table

	for key in displayDict:
		if str_to_var(displayDict[key]["Display Name"])["text"] == displayName:
			returnValue = key
			break
		elif key == displayName:
			returnValue = key

	return returnValue

func get_index_from_displayName(display_name :String):
	for key in selection_table:
		if selection_table[key].has("Display Name"):
			if selection_table[key]["Display Name"] == display_name:
				for key2 in inputNode.item_list:
					var index = get_selected_value(int(key))
					return int(index)
					break
		
		else:
			var index = get_selected_value(int(key))
			return int(index)
			break


func get_selected_value(index : int):
	var type_name = inputNode.get_item_text(index)
	var selection_table_keys_array = selection_table.keys()
	
	if selection_table_keys_array.size() == 0:
		print("ERROR- NO DATA IN SELECTED TABLE NAMED: " + selection_table_name + "At Index: " + index)

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
	selected_item_index = index
	emit_signal("input_selection_changed") #used in event command forms
	if relatedInputNode != null:
		get_parent().swap_input_node(relatedInputNode, self, str(get_dataType_ID(selectedItemName)), relatedTableName)
	###########################
#	emit_signal("selected_item_changed")
	if table_name == "Global Data" and $Label/HBox1/Label_Button.get_text() == "Starting Map":
		await DBENGINE.delete_starting_position_from_old_map(previous_selection)
		await DBENGINE.add_starting_position_node_to_map(selectedItemName,previous_selection, parent_node)
	###############
	previous_selection = selectedItemName
	
	return selectedItemName


func select_index(index : int = 0):
	inputNode.select(index)
	_on_Input_item_selected(index)
	
func _set_input_value(node_value):
	if typeof(node_value) == 4:
		node_value = str_to_var(node_value)
#	labelNode.set_text(key_name)
	populate_list()
	if str(node_value) == "Default":
		node_value = default
	var type_id = node_value - 1
	inputNode.select(type_id)
	var itemSelected = await _on_Input_item_selected(type_id)


func _get_input_value():
	var value = get_id(selectedItemName) + 1
	return value
	
