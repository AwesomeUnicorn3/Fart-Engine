@tool
extends InputEngine

@export var selection_table_name = "" #Name of the table to add to dropdown list

var selection_table: Dictionary= {}
var selected_item_index : int = 1
var selectedItemKey = ""
var relatedInputNode : Node = null
var relatedTableName = ""
var previous_selection :String = ""
var sorted_table:Dictionary = {}


func _init() -> void:
	type = "5"


func populate_list(update_selection_table :bool = true, use_custom_dict :bool = false):
	sorted_table = {}
	if update_selection_table:
		update_selection_table()
		
	if !use_custom_dict:
		populate_list_with_selection_table()
	else:
		var index = 1
		for key in selection_table:
			sorted_table[str(index)] = [key, key, selection_table[key]["Datatype"]] 
			index += 1
		populate_list_with_sorted_table()
	
	select_index(0)
	return sorted_table


func populate_list_with_sorted_table(sortedTable:= sorted_table):
	clear_input_value()
	for keyID in sortedTable.size():
		inputNode.add_item (sortedTable[str(keyID + 1)][0])
	sorted_table = sortedTable
	select_index(0)


func populate_list_with_selection_table(selectionTable := selection_table, selectIndex:bool = false):
	clear_input_value()
	selection_table = selectionTable
	var DBENGINE: DatabaseEngine = DatabaseEngine.new()
	sorted_table = DBENGINE.list_custom_dict_keys_in_display_order(selectionTable, selection_table_name)
#	print(sorted_table)
	for keyID in sorted_table.size():
#		print(keyID)
		inputNode.add_item (sorted_table[str(keyID + 1)][0])
	if selectIndex:
		select_index(0)


func update_selection_table():
	#Cannot use with events
	var index = get_dropdown_index_from_displayName(selection_table_name)
#	print("Selection table name: ", selection_table_name)
	selection_table = await DBENGINE.import_data(selection_table_name)
#	print(selection_table)


func filter_by_datatype(datatype:String, old_dict:Dictionary = sorted_table):
	var filtered_dict: Dictionary = {}
	for key in old_dict.size():
		var strkey = str(key + 1)
		var key_datatype: String = old_dict[strkey][2]
		if key_datatype == datatype:
			filtered_dict[strkey] = old_dict[strkey]
	return filtered_dict


func filter_tables_for_condition(old_dict:Dictionary = selection_table):
	var filtered_dict: Dictionary = {}
	var table_list_dict: Dictionary = DBENGINE.import_data("Table Data")
	
	for key in old_dict:
		var include_in_conditions:bool = DBENGINE.convert_string_to_type(table_list_dict[key]["Include in Event Conditions"])
		if include_in_conditions == true:
			filtered_dict[key] = old_dict[key]
	return filtered_dict


func get_dataType_ID(displayName : String):
	var returnValue
	var displayDict = selection_table
	if typeof(DBENGINE.convert_string_to_type(displayName)) == TYPE_DICTIONARY:
		displayName = DBENGINE.convert_string_to_type(displayName)["text"]
	for key in displayDict:
		if str_to_var(displayDict[key]["Display Name"])["text"] == displayName:
			returnValue = key
			break
		elif key == displayName:
			returnValue = key
			break
	return returnValue


func get_display_name_from_key(key:String):
#	print("get display name from key: ", key)
	for dropdown_index in sorted_table:
#		print(dropdown_index)
		if key == sorted_table[dropdown_index][1]:
			return sorted_table[dropdown_index][0]
			break


func get_dropdown_index_from_displayName(display_name :String):
	for key in sorted_table:
		if sorted_table[key][0] == display_name:
			return int(key) - 1


func get_selection_datatype():
	return sorted_table[str(selected_item_index + 1)][2]


func get_key_from_dropdown_index(dropdown_index : int):
	var selected_display_name = sorted_table[str(dropdown_index + 1)][0]
	var selected_key = sorted_table[str(dropdown_index + 1)][1]
	var selection_table_keys_array = sorted_table.keys()
	
	if selection_table_keys_array.size() == 0:
		print("ERROR- NO DATA IN SELECTED TABLE NAMED: " , selection_table_name , " At Index: " , index)
	return selected_key


func _on_Input_item_selected(index :int):
	selectedItemKey = get_key_from_dropdown_index(index)
	selected_item_index = index
	emit_signal("input_selection_changed") #used in event command forms
	
	if relatedInputNode != null:
		get_parent().swap_input_node(relatedInputNode, self, str(get_dataType_ID(selectedItemKey)), relatedTableName)
	
	if table_name == "Global Data" and $Label/HBox1/Label_Button.get_text() == "Starting Map":
		await DBENGINE.delete_starting_position_from_old_map(previous_selection)
		await DBENGINE.add_starting_position_node_to_map(selectedItemKey,previous_selection, parent_node)
	previous_selection = selectedItemKey
	return selectedItemKey


func select_index(index : int = 0):
	inputNode.select(index)
	_on_Input_item_selected(index)


func clear_input_value():
	if inputNode == null:
		await get_input_node()
	inputNode.clear() #Clear values in dropdown list


func get_dropdown_index_from_key(table_key:String):
	var dropdown_index:int = 0
	for sortedKey in sorted_table.size():
		sortedKey = sortedKey + 1
		if sorted_table[str(sortedKey)][1] == table_key:
			dropdown_index = sortedKey - 1
	return dropdown_index


func _set_input_value(node_value):
	labelNode = await get_label_node()
	labelNode.set_text(itemName)
	populate_list()
	if str(node_value) == "Default":
		node_value = default
	var table_key = str(node_value)
	var itemSelected = await _on_Input_item_selected(get_dropdown_index_from_key(table_key))
	inputNode.select(get_dropdown_index_from_key(table_key))


func set_value_do_not_populate(node_value):
	labelNode = await get_label_node()
	if str(node_value) == "Default":
		node_value = default
	var table_key = str(node_value)
	var itemSelected = await _on_Input_item_selected(get_dropdown_index_from_key(table_key))
#	print(table_key)
	inputNode.select(get_dropdown_index_from_key(table_key))


func _get_input_value():
	var value = selectedItemKey
	return value


#func get_id(item_name : String = ""):
#	#Get index # of selected item in dropdown list
##	var dropDownSize :int = inputNode.get_popup().get_item_count()
#	var item_id := 0
#	print("Item Name in 'get_id' function: ", item_name)
##	for id in dropDownSize: #Loop through all values in dropdown list until the item name is found, return index #
##		var list_ItemName = inputNode.get_item_text(id) #display name
##		for key in selection_table:
##			var selectionKeyType :int = typeof(selection_table[key])
##			if selectionKeyType == TYPE_STRING or selectionKeyType == TYPE_BOOL:
##				if key == item_name:
##					item_name = key
##			elif selection_table[key].has("Display Name"):
##				if key == item_name:
##					item_name = DBENGINE.convert_string_to_type(selection_table[key]["Display Name"])["text"]
##			else:
##				if key == item_name:
##					item_name = key
##
##		if typeof(DBENGINE.convert_string_to_type(list_ItemName)) == TYPE_DICTIONARY:
##			list_ItemName = DBENGINE.convert_string_to_type(list_ItemName)["text"]
##
##		if typeof(DBENGINE.convert_string_to_type(item_name)) == TYPE_DICTIONARY:
##			item_name = DBENGINE.convert_string_to_type(item_name)["text"]
##
##		if item_name == list_ItemName:
##			item_id = id
##			break
#	return item_id
