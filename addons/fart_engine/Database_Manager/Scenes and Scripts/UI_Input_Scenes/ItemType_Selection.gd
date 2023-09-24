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
var is_custom_dict: bool = false


func _init() -> void:
	type = "5"


#CHANGE LIST VALUES
func populate_list(update_selected_table :bool = true, select_index:bool = true, use_custom_dict :bool = false, custom_dict:Dictionary = {}):
#	print("POPULATE LIST")
#	var return_table:Dictionary = {}
	if update_selected_table:
		update_selection_table()
	if use_custom_dict:
		_populate_list_with_custom_dict(custom_dict)
	else:
#		print("POPULATE LIST WITTH SELECTION TABLE")
		_populate_list_with_selection_table()
		
	if select_index:
		select_index(0)
#	return return_table


func _populate_list_with_custom_dict(custom_dict):
	var index = 1
	selection_table = custom_dict
#	print("SELECTION TABLE: ", custom_dict)
	sorted_table = {}
#	print("populate_list_with_custom_dict: ")
	for key in selection_table:
		var datatype = "0"
		var display_name: String 
		var table_key:String
		if typeof(selection_table[key]) == TYPE_DICTIONARY :
#
			if selection_table[key].has("Datatype"):
				datatype = selection_table[key]["Datatype"]
				display_name = key
				table_key = key
			
		else:
#			print("NOT DICTONARY")
			display_name = selection_table[key][0]
			table_key = selection_table[str(key)][1]
		sorted_table[str(index)] = [display_name, table_key, datatype] #selection_table[str(key)][1]
		index += 1
	_populate_list_with_sorted_table()


func _populate_list_with_sorted_table(sortedTable:= sorted_table):
#	print("populate list with sorted tabled")
#	print(sortedTable)
	clear_input_value()
	for keyID in sortedTable.size():
		inputNode.add_item (sortedTable[str(keyID + 1)][0])
	sorted_table = sortedTable
#	select_index(0)


func _populate_list_with_selection_table(selectionTable := selection_table):
#	print("SELECTION TABLE: ", selectionTable)
	clear_input_value()
	selection_table = selectionTable
	var DBENGINE: DatabaseManager = DatabaseManager.new()
#	print("_populate_list_with_selection_table: ")
	sorted_table = await DBENGINE.list_custom_dict_keys_in_display_order(selectionTable, selection_table_name)
	for keyID in sorted_table.size():
		inputNode.add_item (sorted_table[str(keyID + 1)][0])
#	select_index(0)


func clear_input_value():
	if inputNode == null:
		await get_input_node()
	inputNode.clear() #Clear values in dropdown list


func update_selection_table():
	#Cannot use with events
	var index = get_dropdown_index_from_displayName(selection_table_name)
#	print("Selection table name: ", selection_table_name)
	selection_table = await DBENGINE.import_data(selection_table_name)
#	print(selection_table)


func select_index(index : int = 0):
	inputNode.select(index)
	_on_Input_item_selected(index)


#SET INTIAL VALUE

func _set_input_value(node_value, populate_list:bool = true):
	if populate_list:
		labelNode = await get_label_node()
		labelNode.set_text(itemName)
		populate_list(populate_list,true )
		
	if str(node_value) == "Default":
		node_value = default
	var table_key = str(node_value)
	var itemSelected = await _on_Input_item_selected(get_dropdown_index_from_key(table_key))
	inputNode.select(get_dropdown_index_from_key(table_key))


#READ ONLY FUNCTIONS

func _get_input_value()-> String:
	var value :String = selectedItemKey
	return value

func get_display_name_from_key(key:String)-> String:
	var display_name: String = ""
	for dropdown_index in sorted_table:
		if key == sorted_table[dropdown_index][1]:
			display_name = sorted_table[dropdown_index][0]
			break
	return display_name


func get_dropdown_index_from_key(table_key:String)-> int:
	var dropdown_index:int = 0
	for sortedKey in sorted_table.size():
		sortedKey = sortedKey + 1
		if sorted_table[str(sortedKey)][1] == table_key:
			dropdown_index = sortedKey - 1
	return dropdown_index


func get_dropdown_index_from_displayName(display_name :String) -> int:
	var id: int = -1
	for key in sorted_table:
		if sorted_table[key][0] == display_name:
			id = int(key) - 1
			break
	return id


func get_key_from_dropdown_index(dropdown_index : int) -> String:
#	print("get_key_from_dropdown_index SORTED TABLE: ", sorted_table)

	var selected_display_name = sorted_table[str(dropdown_index + 1)][0]
	var selected_key :String = sorted_table[str(dropdown_index + 1)][1]
#	print("SORETED TABLE: ", sorted_table)
	var selection_table_keys_array = sorted_table.keys()
	if selection_table_keys_array.size() == 0:
		print("ERROR- NO DATA IN SELECTED TABLE NAMED: " , selection_table_name , " At Index: " , index)
#	print("ITEM TYPE SELECTED KEY: ", selected_key)
	return selected_key


func get_selection_datatype()-> String:
	return sorted_table[str(selected_item_index + 1)][2]


func get_dataType_ID(displayName : String) -> String:
	var returnValue: String
	var displayDict = selection_table
	if typeof(DBENGINE.convert_string_to_type(displayName)) == TYPE_DICTIONARY:
		displayName = DBENGINE.get_text(displayName)
	for key in displayDict:
		if DBENGINE.get_text(displayDict[key]["Display Name"]) == displayName:
			returnValue = key
			break
		elif key == displayName:
			returnValue = key
			break
	return returnValue


#func getDict_filter_by_datatype(datatype:String, old_dict:Dictionary = sorted_table.duplicate(true)) ->Dictionary:
#	var filtered_dict: Dictionary = {}
#	for key in old_dict.size():
#		var strkey = str(key + 1)
#		var key_datatype: String = old_dict[strkey][2]
#		if key_datatype == datatype:
#			filtered_dict[strkey] = old_dict[strkey]
#	return filtered_dict


func filter_tables_for_condition(old_dict:Dictionary = selection_table.duplicate(true))->Dictionary:
	var filtered_dict: Dictionary = {}
	var table_list_dict: Dictionary = DBENGINE.import_data("Table Data")
	for key in old_dict:
		var include_in_conditions:bool = DBENGINE.convert_string_to_type(table_list_dict[key]["Include in Event Conditions"])
		if include_in_conditions == true:
			filtered_dict[key] = old_dict[key]
	return filtered_dict


#SIGNAL FUNCTIONS
func _on_Input_item_selected(index :int):
#	print("DROPDOEN INDEX: ", index)
	selectedItemKey = get_key_from_dropdown_index(index)
	selected_item_index = index
	emit_signal("input_selection_changed") #used in event command forms
	
	if relatedInputNode != null:
		get_parent().swap_input_node(relatedInputNode, self, str(get_dataType_ID(selectedItemKey)), relatedTableName)
	
	if table_name == "Global Data" and $Label/HBox1/Label_Button.get_text() == "Starting Map":
		await DBENGINE.fart_root.add_starting_position_node_to_map(selectedItemKey,previous_selection, parent_node)
	previous_selection = selectedItemKey
	return selectedItemKey


func _on_visibility_changed():
	if Engine.is_editor_hint() != null: #IS IN EDITOR
		
		#populate_list() #Comment this out when working with levels but uncomment when 
							#working on scenes that require testing of dropdown values
		pass
