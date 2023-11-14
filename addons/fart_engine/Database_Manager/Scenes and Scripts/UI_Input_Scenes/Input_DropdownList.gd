@tool
extends FartDatatype



var reference_table:Dictionary = {}
var reference_table_data: Dictionary = {}

var sorted_reference_table: Dictionary= {}

var selected_item_index : String= "0"
var selectedItemKey
var relatedInputNode : Node = null
var relatedTableName = ""
var previous_selection :String = ""
var is_custom_dict: bool = false


func _init() -> void:
	type = "5"


func populate_list(update_display_table :bool = true, select_index:bool = true, use_custom_dict :bool = false, custom_dict:Dictionary = {}):
#	print("POPULATE LIST")
	#get list_display_table
	if use_custom_dict:
		reference_table = custom_dict
		sorted_reference_table = custom_dict
		_populate_list()
#		select_index(0)
	elif reference_table_name != "" :

			#_populate_list_with_sorted_dict(custom_dict)

		if update_display_table:
			#print("REFERENCE TABLE NAME: ", reference_table_name)
			reference_table = all_tables_merged_dict[reference_table_name]
			reference_table_data = all_tables_merged_data_dict[reference_table_name]


		sorted_reference_table = await get_dict_in_display_order(reference_table_name)
		_populate_list()
		#select_index(0)
	else:
		print("ERROR REFERENCE TABLE NAME IS BLANK")


func _populate_list():
	#print("REFERENCE TABLE: ", reference_table_name)
	await clear_input_value()
	
	var dropdown_index: int = 0
	for keyID in sorted_reference_table:
		#print("KEY ID: ", keyID)

		#print("DISPLAY NAME: ", sorted_reference_table[keyID]["Display Name"])
		if sorted_reference_table[keyID].has("Display Name"):
			sorted_reference_table[keyID]["DropdownIndex"] = str(dropdown_index)
			inputNode.add_item (get_value_as_text(sorted_reference_table[keyID]["Display Name"]))
		else:
			inputNode.add_item (keyID)
		dropdown_index += 1

	#print("POPLUATE LIST COMPLETE")






func _set_input_value(node_value, populate_list:bool = true)-> void:
	if populate_list:
		labelNode = await get_label_node()
		labelNode.set_text_value(itemName)
		await populate_list(populate_list,true )
		
#	if str(node_value) == "Default":
#		node_value = default
	var table_key:String = str(node_value)
	#print("TABLE KEY: ", node_value)
	
	#var itemSelected = await _on_Input_item_selected(table_key)
	
	var dpdn_index = get_dropdown_index_from_key(node_value)
	select_index(int(dpdn_index))


func _get_input_value():
	
	selectedItemKey = int(get_key_from_dropdown_index(str($Input.get_selected_id())))
	#print("SEELCTED ITEM KEY: ", selectedItemKey)
	return selectedItemKey


func get_selected_table(Table_Name:String)->Dictionary:
	#Cannot use with events
	var index = get_dropdown_index_from_displayName(Table_Name)
	var new_table: Dictionary = all_tables_merged_dict[Table_Name]
	return new_table

#func _populate_list_with_sorted_dict(custom_dict):
#	var index = 1
#	selection_table = custom_dict
##	print("SELECTION TABLE: ", custom_dict)
#	sorted_table = {}
##	print("populate_list_with_custom_dict: ")
#	for key in selection_table:
#		var datatype = "0"
#		var display_name: String 
#		var table_key:String
#		if typeof(selection_table[key]) == TYPE_DICTIONARY :
##
#			if selection_table[key].has("Datatype"):
#				datatype = selection_table[key]["Datatype"]
#				display_name = key
#				table_key = key
#
#		else:
##			print("NOT DICTONARY")
#			display_name = selection_table[key][0]
#			table_key = selection_table[str(key)][1]
#		sorted_table[str(index)] = [display_name, table_key, datatype] #selection_table[str(key)][1]
#		index += 1
#	_populate_list_with_sorted_table()





#func _populate_list_with_selection_table(selectionTable := selection_table):
##	print("SELECTION TABLE: ", selectionTable)
#	clear_input_value()
#	selection_table = selectionTable
#
##	print("_populate_list_with_selection_table: ")
#	selection_table = await list_keys_in_display_order(selection_table, selection_table_name)
#	for keyID in sorted_table.size():
#		inputNode.add_item (sorted_table[str(keyID + 1)][0])
##	select_index(0)


func clear_input_value():
	if inputNode == null:
		await get_input_node()
	inputNode.clear() #Clear values in dropdoselection_tablewn list





func select_index(index : int = 0):
	inputNode.select(index)
	_on_Input_item_selected(str(index))


#SET INTIAL VALUE


func get_display_name_from_key(keyID:String)-> String:
	var display_name: String = ""
	display_name = sorted_reference_table[keyID]["DropdownIndex"]
#	for dropdown_index in display_table:
#		if key == display_table[dropdown_index][1]:
#			display_name = display_table[dropdown_index][0]
#			break
	return display_name


func get_dropdown_index_from_key(keyID:String):
	#print("TABLE KEY: ", keyID)
	var dropdown_index:String = sorted_reference_table[keyID]["DropdownIndex"]

	return dropdown_index


func get_dropdown_index_from_displayName(display_name :String) -> String:#changed= WONT WORK WITH NEW DISPLAY TABLE
	return sorted_reference_table[display_name]["DropdownIndex"]
#	var id: int = -1
#	for key in display_table:
#		if display_table[key][0] == display_name:
#			id = int(key) - 1
#			break
#	return id


func get_key_from_dropdown_index(dropdown_index : String): 
	var selected_key :String = "0"
	for keyID in sorted_reference_table:
		#print("GET KEY FROM DROPDOWN: KEYID:  ", keyID)
		if sorted_reference_table[keyID]["DropdownIndex"] == dropdown_index:
			selected_key = keyID
			break
#	if selected_key == "":
#		print("ERROR- KEY NOT FOUND FOR DROPDOWN INDEX: ", dropdown_index)
	#print("GET KEY FROM DROPDOWN: RETURN KEY: ", selected_key)
	return selected_key


func get_selection_datatype()-> String: #changed = WONT WORK WITH NEW DISPLAY TALBE
	return sorted_reference_table[selected_item_index]["Datatype"]


func get_datatype_ID(displayName : String) -> String:
	var returnValue: String
	var displayDict = sorted_reference_table
	if typeof(convert_string_to_type(displayName)) == TYPE_DICTIONARY:
		displayName = get_value_as_text(displayName)
	for key in displayDict:
		if get_value_as_text(displayDict[key]["Display Name"]) == displayName:
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


func filter_tables_for_condition(old_dict:Dictionary = sorted_reference_table.duplicate(true))->Dictionary:
	var filtered_dict: Dictionary = {}
	var table_list_dict: Dictionary = all_tables_merged_dict["10000"]
	for key in old_dict:
		var include_in_conditions:bool = convert_string_to_type(table_list_dict[key]["Include in Event Conditions"])
		if include_in_conditions == true:
			filtered_dict[key] = old_dict[key]
	return filtered_dict



func _on_Input_item_selected(index :String)-> String:
	#print("DROPDOEN INDEX: ", index)
	selectedItemKey = get_key_from_dropdown_index(index)
	selected_item_index = index
	#emit_signal("input_selection_changed") #used in event command forms
	
#	if relatedInputNode != null:
#		get_parent().swap_input_node(relatedInputNode, self, str(get_datatype_ID(selectedItemKey)), relatedTableName)
	
#	if table_name == "Global Data" and labelNode.get_label_text() == "Starting Map":
#		await fart_root.add_starting_position_node_to_map(selectedItemKey,previous_selection, parent_node)
	previous_selection = selectedItemKey
	return selectedItemKey


func _on_visibility_changed():
	if Engine.is_editor_hint() != null: #IS IN EDITOR
		
		#populate_list() #Comment this out when working with levels but uncomment when 
							#working on scenes that require testing of dropdown values
		pass


func _on_button_button_down():
	populate_list()


func _on_input_item_focused(index):
	print("DROPDOWN INDEX: ", index)
