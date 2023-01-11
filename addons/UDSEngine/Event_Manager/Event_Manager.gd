@tool
extends DatabaseEngine

@onready var btn_itemselect = load("res://addons/UDSEngine/Database_Manager/Scenes and Scripts/UI_Input_Scenes/Btn_ItemSelect.tscn")
@onready var event_editor_input_form = load("res://addons/UDSEngine/Event_Manager/Event Editor Input Form.tscn")

@onready var btn_saveChanges = $VBox1/HBox1/SaveChanges
@onready var btn_addNewItem = $VBox1/HBox1/AddNewItem
@onready var btn_cancel = $VBox1/HBox1/Cancel
@onready var btn_delete = $VBox1/HBox1/DeleteSelectedItem
@onready var table_list = $VBox1/HBox2/Scroll1/Table_Buttons
@onready var popup_main := $Popups
@onready var popup_deleteConfirm = $Popups/popup_delete_confirm
@onready var popup_deleteKey = $Popups/popup_deleteKey
@onready var popup_newField = $Popups/popup_newValue
@onready var event_editor_panel := $VBox1/HBox2/Scroll2/Panel1


var field_dict1 = {}
var field_dict2 = {}
var field_dict3 = {}

var tableName = ""

var selected_field_name = ""
var first_load = true
var input_changed = false

var current_event_editor_input
var event_display_name :String = ""
var selected_button


func _ready():
	reload_buttons()
	table_list.get_child(0)._on_TextureButton_button_up()
	selected_button = table_list.get_child(0)
	
func set_ref_table():
	var tbl_ref_dict = import_data(table_save_path + "Table Data" + file_format)
	table_ref = tbl_ref_dict[tableName]["Display Name"]
	current_table_ref = table_ref
	return table_ref

func _on_visibility_changed():
	if visible:
		popup_main = $Popups
		if popup_main.visible:
			hide_all_popups()
	else:
		pass
#		hide_all_popups()

func is_data_updated():
	var is_updated := false
	var old_data_dict :Dictionary = currentData_dict.duplicate(true)
	update_dictionaries()
	for i in current_dict:
		if !old_data_dict.keys().has(i):
			is_updated = true
			break
	return is_updated
			

func show_control_buttons():
	if tableName == "Controls":
		$VBox1/HBox2/Panel1/VBox1/HBox2/AddField.visible = false
		$VBox1/HBox2/Panel1/VBox1/HBox2/DeleteField.visible = false
	else:
		$VBox1/HBox2/Panel1/VBox1/HBox2/AddField.visible = true
		$VBox1/HBox2/Panel1/VBox1/HBox2/DeleteField.visible = true


func get_values_dict(req = false):
	var custom_dict = {}
	var currentDict_inOrder = {}
	for i in currentData_dict["Column"].size():
		i = str(i + 1)
		currentDict_inOrder[i] = currentData_dict["Column"][i]

	for i in currentDict_inOrder:
		var value_name = currentData_dict["Column"][i]["FieldName"]
		var itemType = currentData_dict["Column"][i]["DataType"]
		var tableRef = currentData_dict["Column"][i]["TableRef"]
		var required  = convert_string_to_type(currentData_dict["Column"][i]["RequiredValue"])
		var showValue  = convert_string_to_type(currentData_dict["Column"][i]["ShowValue"])
		
		
			#THIS IS WHERE ALL VALUES SHO8LD BE SET TO DATATYPE DEFAULTS
			#DOING THIS WILL ALLOW ME TO DELETE ALL OF THE "DEFAULT" TABLES
		var item_value
		if Item_Name == "Default":
			item_value = get_default_value(itemType)
		else:

			item_value = current_dict[Item_Name][value_name]
		if required == req:# and showValue:
			custom_dict[value_name] = {"Value" : item_value, "DataType" : itemType, "TableRef" : tableRef, "Order" : i}

	return custom_dict



func hide_all_popups():
	popup_main = $Popups
	popup_main.visible  = false
	popup_deleteConfirm.visible = false
	popup_newField.visible = false
	popup_deleteKey.visible = false

	var child_count := $Popups/ListInput.get_child_count()
	while child_count > 0:
		$Popups/ListInput.get_child(child_count - 1)._on_Close_button_up()
		child_count -= 1


func clear_buttons():
	#Removes all item name buttons from table_list
	for i in table_list.get_children():
		table_list.remove_child(i)
		i.queue_free()


func reload_buttons():
	clear_buttons()
	create_table_buttons()


func enable_all_buttons(value : bool = true):
	#Enables user to interact with all item buttons on table_list
	for i in table_list.get_children():
		i.disabled = !value



func refresh_data(display_name : String):
	#clear existing event input forms
	enable_all_buttons()
	
	event_display_name = display_name

	for child_node in event_editor_panel.get_children():
		if child_node.has_method("close_event_input_form_in_dbmanager"):
			child_node.close_event_input_form_in_dbmanager()
			
			
	#translate display_name to event_name using the table data dictionary
	var tableData_dict = import_data(table_save_path + "Table Data" + file_format)
	var currentTable_name :String
	for table_name in tableData_dict:
#		print(table_name)
		var tempDisplayName :Dictionary= str_to_var(tableData_dict[table_name]["Display Name"])
		if tempDisplayName["text"] == display_name:
			currentTable_name = table_name

			#break
	#load event editor input form for event selected
	current_event_editor_input = event_editor_input_form.instantiate()
	current_event_editor_input.event_name = current_event_editor_input.get_table_data_key(currentTable_name)
#	
	event_editor_panel.add_child(current_event_editor_input)
	current_event_editor_input.get_node("Scroll1/VBox1/HBox2").visible = false
	current_event_editor_input.load_event_from_dbmanager()
	
	table_list.get_node(event_display_name).disabled = true #Sets current item button to disabled
	table_list.get_node(event_display_name).grab_focus()


func create_table_buttons():
#Loop through the item_list dictionary and add a button for each item
	clear_buttons()
		
	var event_list_dict :Dictionary = get_list_of_events(true)
	var table_dict :Dictionary = get_list_of_all_tables()
	for Event_Name in event_list_dict: 
		var label :String 
		if typeof(str_to_var(Event_Name)) == TYPE_DICTIONARY:
			var eventName_dict :Dictionary = str_to_var(Event_Name)
			label = eventName_dict["text"]
		else:
			label = Event_Name
		var newbtn = btn_itemselect.instantiate() #Create new instance of item button
		table_list.add_child(newbtn) #Add new item button to table_list
		#Use the row_dict key (item_number) to set the button label as the item name
		newbtn.set_name(label) #Set the name of the new button as the item name
		newbtn.main_page = self
		var labelNode :Label = newbtn.get_node("Label")
		labelNode.text = label


func _on_Save_button_up():
	event_display_name = current_event_editor_input.save_event_data(true)
	create_table_buttons()
#	get_AU3().create_tabs()
	table_list.get_node(event_display_name).disabled = true #Sets current item button to disabled
	table_list.get_node(event_display_name).grab_focus()

func get_AU3():
	var main_node = null
	var curr_selected_node = self
	while main_node == null:
		if curr_selected_node.get_parent().is_in_group("UDS_Root"):
			main_node = curr_selected_node.get_parent()
		else:
			curr_selected_node = curr_selected_node.get_parent()
	return main_node


func update_dropdown_tables():
	for i in get_node("..").get_children():
		if i != self and i.is_in_group("Tab") and i.has_method("reload_buttons"):
			i.reload_buttons()
			i.table_list.get_child(0)._on_TextureButton_button_up()

func reload_data_without_saving():
	reload_buttons()
	table_list.get_child(0)._on_TextureButton_button_up()


func add_entry_row(entry_value):
	var item_name_dict = currentData_dict["Row"]
	var item_name_dict_size = item_name_dict.size()
	currentData_dict["Row"][str(item_name_dict_size)] = entry_value

func add_table_key(key):
	#duplicate "Default" value
	var new_entry = current_dict["Default"].duplicate(true)
	#Add value to item dict
	current_dict[key] = new_entry
	



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
	#loop through input fields (need a better way to identify them and pull automatically instead of hard code)
	#if any of the fields are blank, return error
	var value = false
	#Iterate through input fields and verify that they values are not empty
	for i in field_dict1:
		#Remove blank spaces (so that you can't have an item name that is just spaces
		i = remove_special_char(i)
		if i == "":
			value = true
			print("ERROR! One or more fields are blank")
			break
	#return array of empty fields
	return value

func _on_AddNewItem_button_up():
	#input default item values to form
	event_display_name = current_event_editor_input._on_Create_New_Event_Button_button_up(false)
	#reload_buttons()
	get_main_node()._ready()
	table_list.get_node(event_display_name)._on_TextureButton_button_up()


func delete_selected_item():
	Delete_Table(current_event_editor_input.event_name)
	get_main_node()._ready()
	#reload_buttons()
	table_list.get_child(0)._on_TextureButton_button_up()

func _on_DeleteSelectedItem_button_up():
	var popup_label = $Popups/popup_delete_confirm/PanelContainer/VBoxContainer/Label
	var popup_label2 = $Popups/popup_delete_confirm/PanelContainer/VBoxContainer/Label2
	var lbl_text : String = popup_label2.get_text()
	lbl_text = lbl_text.replace("%", event_display_name.to_upper())
	popup_label.set_text(lbl_text)
	popup_main.visible = true
	popup_deleteConfirm.visible = true


func _on_deletePopup_Accept_button_up():
	delete_selected_item()
	_on__deletePopup_Cancel_button_up()


func _on__deletePopup_Cancel_button_up():
	popup_main.visible = false
	popup_deleteConfirm.visible = false


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


func _on_AddField_button_up():
	popup_main.visible = true
	$Popups/popup_newValue.visible = true


func _on_NewField_Accept_button_up():
	add_newField()
	_on_NewField_Cancel_button_up()


func _on_NewField_Cancel_button_up():
	popup_main.visible = false
	$Popups/popup_newValue.visible = false


func add_newField(): 
	var datafield = $Popups/popup_newValue/PanelContainer/VBox1/HBox1/VBox2/ItemType_Selection
	var fieldName = $Popups/popup_newValue/PanelContainer/VBox1/HBox1/VBox1/Input_Text/Input.get_text()
	var selected_item_name = datafield.selectedItemName
	var datatype = datafield.get_dataType_ID(selected_item_name)
	var showField = $Popups/popup_newValue/PanelContainer/VBox1/HBox1/VBox3/LineEdit3.is_pressed()
	var required = $Popups/popup_newValue/PanelContainer/VBox1/HBox1/VBox4/LineEdit3.is_pressed()
	var tableName = $Popups/popup_newValue/PanelContainer/VBox1/HBox1/Table_Selection.selectedItemName
	#Get input values and send them to the editor functions add new value script
	#NEED TO ADD ERROR CHECKING
	
	add_field(fieldName, datatype, showField, false, tableName)
	refresh_data(Item_Name)
	


func display_options():
	var values_in_order_dict = {}
	var dlg_keySelect = $Popups/popup_deleteKey/PanelContainer/VBoxContainer/Itemlist
	dlg_keySelect.clear()
	data_type = "Column"
	for n in currentData_dict[data_type].size(): #Arrange row dict values by order number
		var t = n + 1
		values_in_order_dict[n + 1] =  currentData_dict[data_type][str(t)]["FieldName"]

	for n in values_in_order_dict: #Add values to options menu
		var t = values_in_order_dict[n]
		dlg_keySelect.add_item (t,null,true )

	popup_main.visible = true
	popup_deleteKey.visible = true



var delete_field_name = ""
#var delete_field_index = 0
func _on_Itemlist_item_selected(index):
	delete_field_name = currentData_dict[data_type][str(index + 1)]["FieldName"]
#	delete_field_index = str(index + 1)


func _on_DeleteField_Accept_button_up():
	Delete_Key(delete_field_name)
	save_all_db_files(current_table_name)
	refresh_data(Item_Name)
	_on_DeleteField_Cancel_button_up()


func _on_DeleteField_Cancel_button_up():

	popup_main.visible = false
	popup_deleteKey.visible = false

func input_node_changed(value):
	$VBox1/HBox1/Center1/Label.visible = true
	input_changed = true

func clear_datachange_warning():
	$VBox1/HBox1/Center1/Label.visible = false
	input_changed = false

func _on_RefreshData_button_up() -> void:
	reload_data_without_saving()


func _on_SaveNewItem_button_up() -> void:
	pass # Replace with function body.
