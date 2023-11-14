@tool
class_name TableDisplayTemplate extends EditorManager
signal popup_closed
#signal table_refresh_complete

@onready var KeyNavigationButton = preload("res://addons/fart_engine/Database_Manager/Scenes and Scripts/UI_Navigation_Scenes/KeyNavigationButton.tscn")

@onready var btn_saveChanges := $VBox1/HBox1/SaveChanges_Button
@onready var btn_addNewItem := $VBox1/HBox1/AddNewKey_Button
@onready var btn_delete = $VBox1/HBox1/DeleteSelectedKey_Button
@onready var btn_newField = $VBox1/HBox2/AddNewField_Button
@onready var btn_deleteField = $VBox1/HBox2/DeleteField_Button

@onready var table_node := $VBox1/HBox3/Scroll1/Key_List_Vbox
@onready var scroll_table_list :ScrollContainer = $VBox1/HBox3/Scroll1
@onready var container_list1 := $VBox1/HBox3/Scroll2/Field_List_Vbox
@onready var container_list2 := $VBox1/HBox3/Scroll3/Field_List_Vbox
@onready var key_node := $VBox1/Key
@onready var item_name_input := $VBox1/Key/Input_Node/Input
@onready var label_changeNotification := $VBox1/HBox1/CenterContainer/Label

var field_dict:Dictionary = {}
var field_list_dict: Dictionary = {}
#var data_dict := {}
#var table_dict := {}
var sorted_table_dict: = {}
var data_type : String = FIELD
var table_ID : String = "0"
var table_display_name = ""
var selected_field_name = ""
var delete_field_name = ""
var first_load = true
var input_changed = false
var error
var useDisplayName :bool = false
var selectedKeyID :String = "0"#USED WHEN GRABBING DATA
var KeyName :String = "" #USED WHEN CHANGING DATA
var allow_duplicate_display_name:bool = false


func _ready():
	if first_load:
		field_dict = {}
		field_list_dict = {}
		for nav_button in $VBox1/HBox1.get_children():
			if nav_button.get_class() == "NavigationManager":
				nav_button.set_button_theme()
		while !fart_root.has_method("when_editor_saved"):
			await fart_root.get_tree().process_frame
		#print("TABLE NAME: ", table_name)
		first_load = false
		#set_table_name()
		#table_display_name = table_name #get_value_as_text(all_tables_dict[table_name]["Display Name"])

#		table_dict = await get_table_dict(str(table_ID))
#		data_dict = await get_data_dict(str(table_ID))
#		#while table_ID == "0":
#			#print("TABLE ID IS 0")
		await set_sorted_dict()
		await set_field_dict()
		
		await reload_buttons()
		await set_table_display_name()
		await use_display_name()
		await custom_table_settings()
		await auto_select_key()
		



func set_sorted_dict():
	#print("SET SORTED TABLE NAME: ", table_name)
	sorted_table_dict = await get_dict_in_display_order(table_ID)
	#print("SORTED TABLE DICT: ", sorted_table_dict)


func refresh_data(KeyID: String):
	#print("SET KEY NAME: ", KeyID)
	reload_buttons()
	set_key_name(KeyID)
	
	enable_all_buttons()
	set_selected_keyid(KeyID)
	clear_data()
#	table_dict = await get_table_dict(str(table_ID))
#	data_dict = await get_data_dict(str(table_ID))
	set_sorted_dict()
	item_name_input.set_text(str(KeyID)) #Sets the key in the first input
	await update_field_dict()
	add_fields_to_table(KeyID)

func key_button_pressed(KeyID: String):
	#print("SET KEY NAME: ", KeyID)
#	reload_buttons()
	set_key_name(KeyID)
	
	enable_all_buttons()
	set_selected_keyid(KeyID)
	clear_data()
#	table_dict = await get_table_dict(str(table_ID))
#	data_dict = await get_data_dict(str(table_ID))
	set_sorted_dict()
	item_name_input.set_text(str(KeyID)) #Sets the key in the first input
	await update_field_dict()
	add_fields_to_table(KeyID)


func clear_fields():
	for field in container_list1.get_children():
		field.queue_free()


func add_fields_to_table(keyID: String):
	clear_fields()
	var selected_dict: Dictionary = all_tables_merged_data_dict[table_ID][FIELD]

	for fieldID in selected_dict.size():
		var strfieldID = str(fieldID + 1)
		#print("FIELD ID: ", strfieldID)
		var field_name: String = selected_dict[strfieldID]["FieldName"]
		#print("CREATE INPUT NODE FOR: ", selectedKeyID)
		var new_input: FartDatatype = await create_input_node(str(table_ID), str(selectedKeyID), field_name)
		if new_input != null:
			#print("field_name: ", field_name)
			if new_input.get_node_or_null("show_advanced_options_node") != null:
				new_input.show_advanced_options_node = false
			new_input.set_label_text(field_name)
			container_list1.add_child(new_input)
			#print("TABLE ID: ", table_ID)
			var node_value = all_tables_merged_dict[table_ID][keyID][field_name]
			new_input.set_input_value(node_value)
			#print("FIELD NAME: ", field_name)
			append_field_dict(keyID, field_name, new_input, node_value)
		await new_input.get_tree().process_frame
		custom_table_settings()


func set_field_dict():
	field_dict = {}
	field_list_dict = {}
	for keyID in all_tables_merged_dict[table_ID]:
		
		for field_name in all_tables_merged_dict[table_ID][keyID]:
			#print("FIELD NAME: ", field_name)
			if field_name != "ReferenceTableName" and field_name != "Datatype": #I HATE THIS BUT I CANT FIGURE OUT WHY THOSE ARE BEING ADDED
			#var field_name:String = all_tables_merged_data_dict[table_ID][FIELD][fieldID]["FieldName"]
				append_field_dict(keyID, field_name, null, {} )
#		field_dict[all_tables_merged_data_dict[table_ID][FIELD][fieldID]["FieldName"]] = {"Index":  fieldID}





func append_field_dict(keyID:String, field_name:String, field_node:FartDatatype, field_value:Variant)-> void:
	#print("APPEND DICT FIELD NAME: ", field_name)
	if !field_dict.has(keyID):
		field_dict[keyID] = {}
	if !field_dict[keyID].has(field_name):
		field_dict[keyID][field_name] = {}

	field_dict[keyID][field_name]["Node"] = field_node
	field_dict[keyID][field_name]["Value"] = field_value
	
	if !field_list_dict.has(field_name):
		field_list_dict[field_name] = {field_name: field_name ,"DropdownIndex": str(field_list_dict.size())}


func remove_field_from_field_dict(field_name: String):
	for keyID in field_dict:
		field_dict[keyID].erase(field_name)

func update_all_tables_dict()-> void:
	#print("THIS TABLE DICT: ", all_tables_merged_dict[table_ID][selectedKeyID])
	if all_tables_merged_dict[table_ID].has(selectedKeyID):
		for field_name in all_tables_merged_dict[table_ID][selectedKeyID]:
			if field_dict[selectedKeyID].has(field_name):
				all_tables_merged_dict[table_ID][selectedKeyID][field_name] = var_to_str(field_dict[selectedKeyID][field_name]["Value"])
		#update_project_settings()
	#print("THIS TABLE DICT: ", all_tables_merged_dict[table_ID][selectedKeyID])



func set_table_id(new_table_id:String):
	table_ID = new_table_id


func auto_select_key():
	if table_node.get_child_count() > 0:
#		for tablechild in table_node.get_children():
#			print("AUTO SELECTE TABLE CHILD: ", tablechild.name)
		var keyNode:NavigationManager = null
		#print("1 SELECTED KEY ID IS :", display_form_dict[table_ID]["Selected Key"])
		#print("SELECTED KEY ID IS: ", selectedKeyID)
		if display_form_dict[table_ID]["Selected Key"] == "0":
			#print("e SELECTED KEY ID IS :", display_form_dict[table_ID]["Selected Key"])
			keyNode = table_node.get_child(0)
			await set_selected_keyid(keyNode.key_id)
		else:
			#print("SELECTED KEY ID: ", selectedKeyID)
			#print("2 SELECTED KEY ID IS :", display_form_dict[table_ID]["Selected Key"])
			await set_selected_keyid(display_form_dict[table_ID]["Selected Key"])
			keyNode = table_node.get_node(display_form_dict[table_ID]["Selected Key"])
		#print("3 SELECTED KEY ID IS :", display_form_dict[table_ID]["Selected Key"])
			#print("DISPLAY FORM DICT: ", display_form_dict)
		
		#print("KEY NAME SET KEY NAME: ", selectedKeyID)
		if keyNode!= null:
			keyNode._on_Navigation_Button_button_up()


func set_selected_keyid(selected_key: String):
#	if selectedKeyID == "0":
		#print("SELECTED KEY ID IS NONE")
	var keyID:String 
#	selectedKeyID = str(keyNode.key_id)

	if table_node.get_node(selected_key):
		keyID = table_node.get_node(selected_key).key_id
	else: 
		print("SELECTED KEY ID IS NONE")
		keyID = table_node.get_child(0).key_id
	selectedKeyID = selected_key
#	selectedKeyID = selected_key
	display_form_dict[table_ID]["Selected Key"] = selected_key
	#print("SET SELECTED KEY ID: ", selected_key)
	await get_tree().process_frame
	print("SELECTED KEY ID CHANGED TO: ", display_form_dict[table_ID]["Selected Key"])
	set_key_name(selected_key)
	
	
func custom_table_settings():
	#var curr_table_settings_dict: Dictionary = all_tables_merged_dict[table_name] 
	#Disable editing the key for ALL tables
	item_name_input.editable = false
	key_node.is_label_button = false
	for keyID in all_tables_merged_dict["10000"][table_ID] :
		#print("KEY ID: ", keyID)
		var KeyValue = convert_string_to_type(all_tables_merged_dict["10000"][table_ID][keyID])
		#print("KEY VALUE: ", KeyValue)
		match keyID:
			"Show Delete Table Button":
				$VBox1/HBox1/DeleteTable_Button.visible = KeyValue
				$VBox1/HBox1/AddNewTable_Button.visible  = KeyValue

			"Enable Key Options":
				$VBox1/HBox1/AddNewKey_Button.visible = KeyValue
				$VBox1/HBox1/DeleteSelectedKey_Button.visible = KeyValue
				$VBox1/HBox1/DuplicateKey_Button.visible = KeyValue

			"Enable Field Options":
				$VBox1/HBox2.visible = KeyValue
			
			"Allow Duplicate Display Name":
				allow_duplicate_display_name = KeyValue

	if is_table_dropdown_list(str(table_ID)):
		item_name_input.editable = false


func does_key_display_name_exist(keyname:String)-> bool:
	var exists :bool = false
	for keyid in all_tables_merged_data_dict[table_ID]:
		if keyname == get_display_name_from_key(keyid):
			exists = true
	return exists


func get_display_name_from_key(key:String)-> String:
	return get_value_as_text(all_tables_merged_data_dict[table_ID][key]["Display Name"])
	

func set_table_display_name():
	if selectedKeyID != "0":
		table_display_name = get_value_as_text(all_tables_merged_dict["10000"][table_ID]["Display Name"])


func use_display_name() -> bool:
	#print("TABLE NAME: ",table_name)
	if selectedKeyID != "0":
		useDisplayName = convert_string_to_type(str(all_tables_merged_dict["10000"][table_ID]["Use Display Name in Editor"]))
	return useDisplayName


func _on_visibility_changed():
	if visible:
		_ready()
		hide_all_popups()
		show_control_buttons()
		if is_data_updated():
			reload_buttons()
			reload_data_without_saving()
	else:
		hide_all_popups()


func is_data_updated():
	var is_updated := false
	var old_data_dict :Dictionary = all_tables_merged_data_dict[table_ID].duplicate(true)
	reset_dictionaries(table_ID)
	for i in all_tables_merged_data_dict[table_ID]:
		if !old_data_dict.keys().has(i):
			is_updated = true
			break
	return is_updated


func show_control_buttons():
	if table_ID == "10004":
		btn_newField.visible = false
		btn_deleteField.visible = false
	else:
		btn_newField.visible = true
		btn_deleteField.visible = true


func hide_all_popups():
	PopupManager.hide_all_popups()
#	popup_main.visible = false
#	popup_deleteConfirm.visible = false
#	popup_deleteKey.visible = false
#	var child_count := PopupManager.POPUP_CONTROL.get_child_count()
#	while child_count > 0:
#		PopupManager.POPUP_CONTROL.get_child(child_count - 1)._on_Close_button_up()
#		child_count -= 1


func clear_buttons():
	for i in table_node.get_children():
		table_node.remove_child(i)
		i.queue_free()


func reload_buttons():
	clear_buttons()
	create_key_buttons(sorted_table_dict,all_tables_merged_data_dict[table_ID])


func clear_data():
	label_changeNotification.visible = false
	input_changed = false
	for i in container_list1.get_children():
		if i.name != "Key":
			i.queue_free()
#	for i in container_list2.get_children():
#		var current_node = i
#		i.queue_free()
	#print("CLEAR DATA COMPLETE")


func enable_all_buttons(value : bool = true):
	for i in table_node.get_children():
		i.disabled = !value
		i.reset_self_modulate()


func set_key_name(new_name: String)-> void:
	KeyName = new_name


func create_key_buttons(sorted_key_dict:Dictionary, Key_data_Dict: Dictionary):
	for keyID in sorted_key_dict:
		var displayName :String = keyID #= get_value_as_text(sorted_key_dict[keyID]["Display Name"])
		var key_dict :Dictionary = sorted_key_dict[keyID]
		if key_dict.has("Display Name"):# and table_name != "Table Data":
			displayName = get_value_as_text(sorted_key_dict[keyID]["Display Name"])
		var newbtn  = KeyNavigationButton.instantiate()
		newbtn.set_name(keyID)
		
		#print("SET KEY ID TO: ", keyID)
		newbtn.key_id = keyID
		newbtn.add_to_group("Key")
		set_buttom_theme(newbtn, "Key")
		newbtn.set_label_text(keyID, displayName, useDisplayName)
		newbtn.main_page = self
		table_node.add_child(newbtn)
		#set_selected_keyid(newbtn.key_id)
#		if keyID == selectedKeyID:
#			newbtn.disabled = true
		





func set_buttom_theme(button_node: TextureButton, group: String):
	if !all_tables_loaded:
		print("TABLES STILL LOADING")
		await get_tree().process_frame
	var project_table: Dictionary = all_tables_merged_dict["10038"]
	var fart_editor_themes_table: Dictionary = all_tables_merged_dict["10025"]
	var theme_profile: String = project_table["1"]["Fart Editor Theme"]
	#print("GROUP NAME: ", group)
	#print("CATEGORY COLOR: ",fart_editor_themes_table[theme_profile][group + " Button"] )
	var category_color: Color = str_to_var(fart_editor_themes_table[theme_profile][group + " Button"])
	if button_node.is_in_group(group):
		#print("CATEGORY COLOR IN GROUP: ", category_color)
		button_node.set_button_base_color(category_color)


var is_saving_table:bool = false
func _on_Save_button_up(update_Values : bool = true):
	#print("ON SAVE BUTTON UP - BEGIN")
	if !is_saving_table:  # and is_inside_tree():
		#print("ON SAVE BUTTON UP - IS NOT SAVING AND IS IN TREE")
		is_saving_table = true
		if !has_empty_fields():
			if update_Values:
				await update_field_dict()
				update_all_tables_dict()
				#print("TABLE DICT: ",  all_tables_merged_dict[table_ID])
				save_file(table_save_path + table_ID + table_file_format, all_tables_merged_dict[table_ID])
				save_file(table_save_path + table_ID + table_info_file_format, all_tables_merged_data_dict[table_ID])
				reload_data_without_saving()
		else:	
			print("There was an error. Data has not been updated")
#		table_save_complete.emit()
		is_saving_table = false
	#print("ON SAVE BUTTON UP - END")



func update_dropdown_tables():
	for i in get_node("..").get_children():
		if i != self and i.is_in_group("Tab") and i.has_method("reload_buttons"):
			i.reload_buttons()


func reload_data_without_saving():
	first_load = true
	_ready()


func update_field_dict():
	#print("FIELD DICT: ", field_dict)
#	for keyID in field_dict:
	var inc_amount:int = -1
	while !field_dict.has(selectedKeyID):
		if selectedKeyID == "0":
			inc_amount = 1
		selectedKeyID = str(int(selectedKeyID)  + inc_amount)

	for field_name in field_dict[selectedKeyID]:
		#print("FIELD NAME: ", field_name)
		if field_dict[selectedKeyID][field_name]["Node"] != null:
			field_dict[selectedKeyID][field_name]["Value"] = field_dict[selectedKeyID][field_name]["Node"].get_input_value()
	#print("FIELD DICT: ", field_dict)
#	var value
#	var keyNode = null
#	keyNode = key_node
#	get_value_from_input_node(key_node,"Key")
#	for i in container_list1.get_children():
#		value = i.labelNode.get_label_text()
#		get_value_from_input_node(i, value)
#	if key_node != null:
#		reload_buttons()
#		refresh_data(get_value_as_text(keyNode.get_input_value()))




func does_key_contain_invalid_characters(key):
	var value = false
	#loop through invalid characters and compare to item name, if any match, return error
	var array = [":", "/", "."]
	for i in array:
		if i in key:
			value = true
			print("'",i,"' is an invalid character. Please remove and try again")
			break
	return value


func has_empty_fields():
	var value = false
	return value





func delete_selected_key(item_name: String = KeyName):
	data_type = KEY
	delete_key(item_name, table_ID)
	save_all_db_files()
	reload_buttons()
	if is_instance_valid(table_node.get_child(0)):
		table_node.get_child(0)._on_Navigation_Button_button_up()


func _on_FileDialog_hide() -> void:
	hide_all_popups()

func _on_FileDialog_sprite_hide() -> void:
	hide_all_popups()


func remove_special_char(text : String):
	var array = [" "]
	var result = text
	for i in array:
		result = result.replace(i, "")
	return result







#func _on_Itemlist_item_selected(index):
#	delete_field_name = data_dict[data_type][str(index + 1)]["FieldName"]





#func _on_DeleteField_Cancel_button_up():
#	PopupManager.hide_all_popups()
#	popup_main.visible = false
#	popup_deleteKey.visible = false

func input_node_changed(value):
	label_changeNotification.visible = true
	input_changed = true





################NEW KEY FUNCTIONS######################
func _on_duplicate_key_button_button_up():
	#var next_key :String = get_next_key_number(table_ID)
	var new_entry :Dictionary = all_tables_merged_dict[table_ID][KeyName].duplicate(true)
	#print("NEW ENTRY: ", new_entry)
	show_new_key_input_form(new_entry)
	
	#_on_SaveNewItem_button_up(str(next_key),new_entry )





func _on_SaveNewItem_button_up(newKeyName :String, new_key_dict :Dictionary = {}):
	var displayName :String = newKeyName
	if is_table_dropdown_list(str(table_ID)):
		newKeyName = str(get_next_key_number(table_ID))
	if !allow_duplicate_display_name:
		if does_key_display_name_exist(displayName):
			print("ERROR: Duplicate Display Name Exists, to Allow this, change 'Allow Duplicate Display Name' in Table Options")
			return
	if !does_key_exist(newKeyName):
		if !does_key_contain_invalid_characters(str(newKeyName)):
			if !has_empty_fields():
				add_key(table_ID, newKeyName, "1", true, false, false,newKeyName,false, new_key_dict)
				if all_tables_merged_dict[table_ID][newKeyName].has("Display Name"):
					all_tables_merged_dict[table_ID][newKeyName]["Display Name"] = {"text" : displayName}
			#update new dict entry with input values from item form
				update_field_dict()
				save_all_db_files()
				reload_buttons()

				refresh_data(newKeyName)
				await get_tree().create_timer(.25).timeout
				var max_v_scroll = scroll_table_list.get_v_scroll_bar().max_value
				scroll_table_list.set_v_scroll(max_v_scroll)
	else:
		print("ERROR! No changes were made")




#_________________________________________________________________#
func set_display_name_first():
	var table_list: Dictionary = get_list_of_all_tables()
	for table_name in table_list:
		var read_dict:Dictionary = all_tables_merged_data_dict[table_name][FIELD].duplicate(true)
		var write_dict: Dictionary = all_tables_merged_data_dict[table_name]
		for order_number in read_dict:
			var field_name: String = read_dict[order_number]["FieldName"]
			if field_name == "Display Name" and order_number != str(1):
				var display_dict: Dictionary = read_dict[order_number].duplicate(true)
				var index_1_dict: Dictionary = read_dict["1"].duplicate(true)
				write_dict[FIELD]["1"] = display_dict
				write_dict[FIELD][order_number] = index_1_dict
				save_file(table_save_path + table_name + table_info_file_format, write_dict)





















##________________________________________________________________SEPERATE BETWEEN THOSE THAT CAN MOVE TO TABLE MANAGER AND THOSE THAT SHOULD BE HANDLED BY INDIVIDUAL TABLE DISPLAY##

func get_table_keys():
	return all_tables_merged_dict[table_ID].keys()




func get_input_type_id_from_name(input_type_name :String):
	for key in datatype_dict:
		var displayname_dict :Dictionary = str_to_var(datatype_dict[key]["Display Name"])
		var key_name :String = get_value_as_text(displayname_dict)
#
		if key_name == input_type_name:
			return key


func update_key_name(old_name : String, new_name : String):
	var return_key = old_name
	if old_name != new_name: #if changes are made to item name
		var is_dropdown_table = convert_string_to_type(all_tables_settings_dict[table_ID]["Show in Dropdown Lists"])
		if is_dropdown_table == true:
			print("Cannot update keys in a table used as a dropdown list")

		if !does_key_exist(new_name):
			
			var item_name_dict = all_tables_merged_data_dict[table_ID][KEY]
			for i in item_name_dict: #loop through item_row table until it finds the key number for the item
				if item_name_dict[i]["FieldName"] == old_name:
					all_tables_merged_data_dict[table_ID][KEY][i]["FieldName"] = new_name #Replace old value with new value
					break

			var old_key_entry : Dictionary = all_tables_merged_dict[table_ID][KeyName].duplicate(true) #Create copy of item values
			all_tables_merged_dict[table_ID].erase(KeyName) #Erase old item entry
			all_tables_merged_dict[table_ID][new_name] = old_key_entry #add new item entry
			set_key_name(new_name) #Update script variable with correct item name
			return_key = new_name

		else:
			print("Duplicate key exists in table DATA WAS NOT UPDATED")

	return return_key


func does_key_exist(key):
	var value = false
	if all_tables_merged_dict[table_ID].has(key):
		value = true
	return value


func rearrange_table_keys(new_index :String , old_index:String ):
	new_index = get_data_index(new_index, KEY, all_tables_merged_data_dict[table_ID])
	old_index = get_data_index(old_index, KEY, all_tables_merged_data_dict[table_ID])
	var key_data = all_tables_merged_data_dict[table_ID][KEY][old_index]
	var test_dict = all_tables_merged_data_dict[table_ID].duplicate(true)
	#remove the old index
	test_dict[KEY].erase(old_index)
	for key in test_dict[KEY].size():
		key += 1
		var key_string :String = str(key)
		if !test_dict[KEY].has(key_string):
			var next_key = str(key + 1)
			var next_key_data = test_dict[KEY][next_key]
			test_dict[KEY][key_string] = next_key_data
			test_dict[KEY].erase(next_key)
	#insert the old key data in the new key index and shift all the remaining keys down
	for key in range(test_dict[KEY].size() + 1,0,-1):
		var key_string :String = str(key)
		var previous_key = str(key - 1)
		if key_string == new_index:
			test_dict[KEY].erase(key_string)
			test_dict[KEY][key_string] = key_data
			break
		else:
			var prev_key_data = test_dict[KEY][previous_key]
			test_dict[KEY].erase(previous_key)
			test_dict[KEY][key_string] = prev_key_data

	all_tables_merged_data_dict[table_ID][KEY] = test_dict[KEY]
	for child in $Button_Float.get_children():
		child._on_input_audio.navigation_Button_button_up()
		child.queue_free()


func get_table_values():
	var return_dict = {}
	#pulls table values in custom order
	for i in all_tables_merged_data_dict[table_ID][data_type].size():
		var order_value = str(i + 1)
		var value = all_tables_merged_data_dict[table_ID][data_type][order_value]
		return_dict[value] = order_value
	return return_dict


func add_new_table(newTableName, keyName, keyDatatype, keyVisible, fieldName, fieldDatatype, fieldVisible, dropdown, RefName, createTab, canDelete, isDropdown, add_toSaveFile, is_event):
	all_tables_merged_data_dict[table_ID] = {}
#	data_dict["Row"] = {}
#	data_dict[FIELD] = {}
#	#set_table_name(newTableName)
#	if isDropdown:
#		#THIS IS WHnput_audio.gd' to a variable of type 'FartDatatype.gd'.ERE I WILL USE THE DROPDOWN TEMPLATE TO CREATE A NEW LIST STYLE TABLE (KEY IS NUMBER, ID, DISPLAY NAME)
#		add_key("1", "1", keyVisible, true, dropdown, true)
#		#add_field("Display Name", "1", fieldVisible, true,  dropdown, true)
#		await add_field(table_name, "Display Name", table_dict, true)
#		table_dict["1"]["Display Name"] = var_to_str({"text" : keyName})
#
#	else:
#		add_key(keyName, keyDatatype, keyVisible, true, dropdown, true)
#		await add_field(table_name, fieldName, table_dict, true)
#		#add_field(fieldName, fieldDatatype, fieldVisible, true,  dropdown, true)
#	save_all_db_files()
#
#	#save information about new table in the Table Data file
#	var TABLEDATA:String = "Table Data"
#	data_type = "Row"
#	reset_dictionaries(table_name)
#	add_key(TABLEDATA, newTableName, keyDatatype, keyVisible, true, dropdown)
#	#Input data for table list
#	if RefName == "":
#		RefName = newTableName
##	else:
##		table_dict[newTableName]["Display Name"] = RefName
#
#	table_dict[newTableName]["Display Name"] = var_to_str({"text" : RefName})
#	table_dict[newTableName]["Create Tab"] = createTab
#	table_dict[newTableName]["Show in Dropdown Lists"] = isDropdown
#	table_dict[newTableName]["Include in Save File"] = add_toSaveFile
#	table_dict[newTableName]["Can Delete"] = true
#	table_dict[newTableName]["Is Event"] = is_event
#	save_all_db_files()


func create_new_table(newTableID:String, newTable_dict: Dictionary):
	all_tables_merged_data_dict[table_ID] = {}
#	data_dict[KEY] = {}
#	data_dict[FIELD] = {}
#
#		#THIS IS WHERE I WILL USE THE DROPDOWN TEMPLATE TO CREATE A NEW LIST STYLE TABLE (KEY IS NUMBER, ID, DISPLAY NAME)
#	add_key(newTableID, "1", "1", true, true, true, true)
#	await add_field(table_ID, "Display Name", table_dict, true)
#	#add_field("Display Name", "1", true, true,  true, true)
#	save_all_db_files()
#	#save information about new table in the Table Data file
#	var TableData: String = "10000"
#	data_type = KEY
#	reset_dictionaries(newTableID)
#	add_key(TableData, newTableID, "1", true, true, true)
#	table_dict[newTableID] = newTable_dict
#	save_all_db_files()


func add_event_key(keyName, datatype, showKey, requiredValue, dropdown,  newTable : bool = false, new_data := {}):
	var index = all_tables_merged_data_dict[table_ID][KEY].size() + 1
	var CustomData_dict = all_tables_merged_dict["10026"]
	var newOptions_dict = {}
	var newValue
	#create and save new table with values from input form
	#Get custom key fields and add them to tableData dict
	for i in CustomData_dict:
		var currentKey_dict :Dictionary = str_to_var(CustomData_dict[i]["ItemID"])
		var currentKey :String = get_value_as_text(currentKey_dict)
		match currentKey:
			"DataType":
				newValue = datatype
			"FieldName":
				newValue = keyName
			"RequiredValue":
				newValue = requiredValue
			"ShowValue":
				newValue = showKey
			"TableRef":
				newValue = dropdown

		newOptions_dict[currentKey] = newValue

	all_tables_merged_data_dict[table_ID][KEY][str(index)] =  newOptions_dict

	if newTable:
		all_tables_merged_data_dict[table_ID][keyName] = "empty"

	else:
		var new_key_data = all_tables_merged_data_dict[table_ID][all_tables_merged_data_dict[table_ID].keys()[0]].duplicate(true)
		if new_data != {}:
			new_key_data = new_data
		all_tables_merged_data_dict[table_ID][keyName] = new_key_data  #CHANGE THIS TO DEFAULT VALUE FOR DATATYPE #Set new key values based on the default (first line of table)


func add_line_to_currDataDict():
	var this_dict = all_tables_merged_data_dict[str(table_ID)]
	for i in this_dict[FIELD]:
		var dict = all_tables_merged_data_dict[table_ID][FIELD][i]
		if !dict.has("TableRef"):
			all_tables_merged_data_dict[table_ID][FIELD][i]["TableRef"] = "empty"
	for i in this_dict[KEY]:
		var dict = all_tables_merged_data_dict[table_ID][KEY][i]
		if !dict.has("TableRef"):
			all_tables_merged_data_dict[table_ID][KEY][i]["TableRef"] = "empty"


#func add_new_field(new_field:Dictionary):
#	var new_ID:String = str(all_tables_merged_data_dict[table_ID][FIELD].size() + 1)
#	all_tables_merged_data_dict[table_ID][FIELD][new_ID] = new_field
#	var default_value:Variant = get_default_value(new_field["DataType"])
#	#print("DEFAULT VALUE: ", default_value)
#	for keyID in all_tables_merged_dict[table_ID]:
#		all_tables_merged_dict[table_ID][keyID][new_field["FieldName"]] = default_value
#	print("DICT: ", all_tables_merged_dict[table_ID])
#	print("DATA DICT: ", all_tables_merged_data_dict[table_ID][FIELD])
#
#	_on_Save_button_up()
#	add_fields_to_table(selectedKeyID)
	#append_field_dict(new_ID,new_field["FieldName"],null, default_value)

	#refresh_data(selectedKeyID)


#_______STILL NEED TO CONNECT THE BELOW TO THEIR FUCNTION CALLS____________

func _on_delete_field_button_button_up():
	PopupManager.show_popup("SelectField", [field_list_dict])
	while all_popups_dict["Active"]:
		await get_tree().process_frame
	if PopupManager.get_return_value() != "":
		var field_deleted:bool = delete_field(PopupManager.get_return_value(),table_ID)
		remove_field_from_field_dict(PopupManager.get_return_value())
		await add_fields_to_table(selectedKeyID)
		_on_Save_button_up()
		#reload_data_without_saving()
		print("DELETE SELECTED KEY: ",PopupManager.get_return_value(), " WAS SUCCESSFUL: ",field_deleted)
	else:
		print("DELETE FIELD CANCELED")


func _on_add_new_field_button_button_up():
	PopupManager.show_popup("NewField")

	while all_popups_dict["Active"]:
		await get_tree().process_frame
	if str(PopupManager.get_return_value()) != "":
		var new_field_dict :Dictionary = PopupManager.get_return_value()
		add_field(new_field_dict, table_ID)
		await add_fields_to_table(selectedKeyID)
		_on_Save_button_up()
		#reload_data_without_saving()
	else:
		print("NEW FIELD CANCELED")



func show_new_key_input_form(new_data:Dictionary ={}):
	PopupManager.show_popup("TextInput", [""])
	while all_popups_dict["Active"]:
		await get_tree().process_frame
	var display_name:String = get_value_as_text(PopupManager.get_return_value())
	var keyID:String = get_next_key_number(table_ID)

	if display_name != "":
		#print("NEW DATA: ", new_data)
		add_key(table_ID, keyID, "1", true, false, false, display_name,false,new_data)
		
		await set_sorted_dict()
		if new_data !={}:
			new_data
		
		var display_dict:Dictionary = convert_string_to_type(all_tables_merged_dict[table_ID][keyID]["Display Name"])
		display_dict["text"] = display_name
		all_tables_merged_dict[table_ID][keyID]["Display Name"] = display_dict
		#print("DISPLAY DICT: ", display_dict)
		display_dict["text"] = display_name
		_on_Save_button_up()
		#reload_data_without_saving()
		
		#print("NEW KEY NAME: ",display_name)
	else:
		print("POPUP NEW KEY CANCELED")


func _on_delete_selected_key_button_button_up():
	#print("DELETE KEY BEGIN")
	PopupManager.show_popup("SelectField", [all_tables_merged_dict[table_ID]])
	while all_popups_dict["Active"]:
		await get_tree().process_frame
	if PopupManager.get_return_value() != "" and all_tables_merged_dict[table_ID].size() > 0:
		#if all_tables_merged_dict[table_ID].size > 1:
		var key_deleted:bool = await delete_key(PopupManager.get_return_value(),table_ID)
		#set_sorted_dict()
		if PopupManager.get_return_value() == selectedKeyID:
#			set_selected_keyid(sorted_key_dict["1"])
#			table_node.get_child(0)._on_Navigation_Button_button_up
			print("KEY NO LONGER EXISTS", all_tables_merged_data_dict[table_ID][KEY]["1"]["FieldName"])
#			set_selected_keyid(all_tables_merged_data_dict[table_ID][KEY]["1"]["FieldName"])
		print("DELETED KEY: ",PopupManager.get_return_value())
		_on_Save_button_up()
		print("DELETE SELECTED KEY: ",PopupManager.get_return_value(), " WAS SUCCESSFUL: ",key_deleted)
	else:
		print("DELETE KEY CANCELED")








################NEW TABLE FUNCTIONS######################
func _on_add_new_table_button_button_up():
	PopupManager.show_popup("NewTable", [all_tables_merged_dict["10003"]])

	while all_popups_dict["Active"]:
		await get_tree().process_frame
	if str(PopupManager.get_return_value()) != "":
		var new_field_dict :Dictionary = PopupManager.get_return_value()
		var new_table_ID:String = get_next_key_number("10000", 10050)
		print("NEW TABLE ACCEPTED", new_field_dict)
		var new_display_name: String = get_value_as_text(convert_string_to_type(new_field_dict["Display Name"]))
		print("NEW TABLE DISPLAY NAME: ",new_display_name  )
		
		var dict_array:Array = add_key_to_table(new_table_ID, new_display_name, "10000")
		all_tables_merged_dict["10000"] = dict_array[0]
		all_tables_merged_data_dict["10000"] = dict_array[1]
		save_file(table_save_path + new_table_ID + table_file_format, all_tables_merged_dict["10000"])
		save_file(table_save_path + new_table_ID + table_info_file_format,all_tables_merged_data_dict["10000"])
		
		all_tables_merged_dict[new_table_ID] = all_tables_merged_dict["10003"].duplicate(true)
		all_tables_merged_data_dict[new_table_ID] = all_tables_merged_data_dict["10003"].duplicate(true)
		save_file(table_save_path + new_table_ID + table_file_format, all_tables_merged_data_dict[new_table_ID])
		save_file(table_save_path + new_table_ID + table_info_file_format,all_tables_merged_data_dict[new_table_ID])
		_on_Save_button_up()
#		first_load = true
#		_ready()

	else:
		print("NEW TABLE CANCELED")


func get_next_key_number(tableID :String, min_id:int = 1) -> String:
	var next_key_number :int = min_id
	print("FIRST KEY NUMBER: ", next_key_number)
	while all_tables_merged_dict[table_ID].has(str(next_key_number)):
		next_key_number += 1
		print("NEXT KEY NUMBER: ", next_key_number)
	return str(next_key_number)


func get_first_key_number(tableID :String) -> String:
	var next_key_number :int = 1
	print("NEXT KEY NUMBER: ", next_key_number)
	while !all_tables_merged_dict[table_ID].has(str(next_key_number)):
		next_key_number += 1
		print("NEXT KEY NUMBER: ", next_key_number)
#	else:
#		print("TABLE DOES not HAVE KEY")
		#print(all_tables_merged_dict[table_ID])
		#next_key_number += 1
	await get_tree().process_frame
	return str(next_key_number)


func add_table():
	var newTableInput := $Popups/popup_newTable
	var new_table_dict :Dictionary = newTableInput.get_input()
	var newTableName = get_value_as_text(new_table_dict["Display Name"])
	if newTableName == "":
		print("ERROR: Table Name Cannot be Blank")
	elif all_tables_dict_sorted.has(newTableName):
		print("ERROR: Table Name already in use. Please try again with a different name")
	else:
		create_new_table(newTableName, new_table_dict)
	return newTableName


#func Delete_Table(table_id:String):
#	var del_tbl_name = key_node.inputNode.get_value_as_text()
#	delete_table(del_tbl_name)
#	fart_root._ready()
#	await get_tree().process_frame



func delete_table(delete_tbl_name):
	###NEED TO CHECK IF TABLE CAN BE DELETED####
	
	#First delete table reference from "Table Data" file and delete the entry in the table_data main table
	all_tables_merged_dict["10000"].erase(delete_tbl_name)
	var merged_data_copy:Dictionary = all_tables_merged_data_dict[delete_tbl_name].duplicate(true)
	for key in merged_data_copy[KEY]:
		if all_tables_merged_data_dict["10000"][KEY][key]["FieldName"] == delete_tbl_name:
			all_tables_merged_data_dict["10000"][KEY].erase(key)
			break
	#Then delete all of the files associated with the delted table
	save_file(table_save_path + delete_tbl_name + table_file_format, all_tables_merged_dict["10000"])
	save_file(table_save_path + delete_tbl_name + table_info_file_format, all_tables_merged_data_dict["10000"])
	var dir :DirAccess = DirAccess.open(table_save_path)
	var file_delete = table_save_path + delete_tbl_name + table_file_format
	dir.remove(file_delete)
	file_delete = table_save_path + delete_tbl_name + table_info_file_format
	dir.remove(file_delete)
#	reload_data_without_saving()
	if display_form_dict[table_ID]["Selected Key"] == delete_tbl_name:
		auto_select_key()
	_on_Save_button_up()
	
	#table_name = ""


func _on_delete_table_button_button_up():
	#print("DELETE KEY BEGIN")
	PopupManager.show_popup("SelectField", [all_tables_merged_dict["10000"]])
	while all_popups_dict["Active"]:
		await get_tree().process_frame
	if PopupManager.get_return_value() != "" and all_tables_merged_dict[table_ID].size() > 0:
		print("DELETED TABLE: ",PopupManager.get_return_value())
		delete_table(PopupManager.get_return_value())

	else:
		print("DELETE KEY CANCELED")
