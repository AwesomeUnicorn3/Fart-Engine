@tool
extends Control
signal input_closed

var DBENGINE: DatabaseEngine = DatabaseEngine.new()

var display_type_selection: InputEngine = null
var table_selection: InputEngine = null
var key_selection: InputEngine = null
var field_selection: InputEngine = null
#var value_selection: InputEngine = null
#var name_value_checkbox:InputEngine = null

var display_type_selection_value :String = ""
var containers_identified: bool = false
var selected_table_dict:Dictionary = {}



func _ready():
	set_selection_containers()
	while !containers_identified:
		await get_tree().create_timer(0.1).timeout
	display_type_selection.populate_list()
	update_table_selection()


func _on_cancel_button_up():
	emit_signal("input_closed")
	call_deferred("queue_free")


func _on_displayTypeSelection_changed():
	display_type_selection_value = display_type_selection._get_input_value()
	
	match display_type_selection_value:
		"1": #Table Name
			key_selection.visible = false
			field_selection.visible = false


		"2": #Key Name
			key_selection.visible = true
			field_selection.visible = false
			_on_table_selection_input_changed()

			#UPDATE VALUE SELECTION WITH LIST OF VALUES

		"3": #Field Value
			key_selection.visible = true
			field_selection.visible = true
			_on_table_selection_input_changed()



func _on_name_value_checkbox_pressed(value:bool):
	print(value)
#	value_selection.visible = value


func _on_table_selection_input_changed():
	print("POPULATE KEY IF DISPLAY TYPE SELECTED IS NOT TABLE") #SEE TABLEDATAKEY TEMPLATE AS A GUIDE
	var display_selection_int:int = int(display_type_selection_value)
	if display_selection_int >= 2:
		update_key()


func _on_key_selection_input_changed():
	print("POPULATE FIELD IF DISPLAY TYPE SELECTED IS NOT TABLE OR KEY")  #SEE TABLEDATAKEY TEMPLATE AS A GUIDE
	var display_selection_int:int = int(display_type_selection_value)
	if display_selection_int >= 3:
		update_field()


func _on_field_selection_input_changed():
	#Get list of fields in table dict
	print("FIELD SELECTION CHANGED- NOT SURE YET WHAT TO DO HERE")


func update_table_selection():
	var selected_table_dict: Dictionary = {}
	table_selection.populate_list()
	selected_table_dict = table_selection.selection_table
	for key in selected_table_dict[selected_table_dict.keys()[0]]:
		if key == "Table Data":
			selected_table_dict.erase(key)
			
	table_selection.selection_table = selected_table_dict
	table_selection.populate_list(false, true)
	_on_key_selection_input_changed()


var field_list: Dictionary = {}
func update_key(include_display_name:bool = false):
	var selected_table_key: String = table_selection.selectedItemKey
	selected_table_dict = DBENGINE.import_data(selected_table_key)
	var selected_table_data_dict: Dictionary = DBENGINE.import_data(selected_table_key, true)

	key_selection.selection_table_name = table_selection._get_input_value()
	key_selection.populate_list()
	var sorted_key_list: Dictionary = key_selection.sorted_table
	field_list = {}
	for key in selected_table_dict[selected_table_dict.keys()[0]]:
		field_list[key] = {"Datatype": DBENGINE.get_datatype(key, selected_table_data_dict)} 


#		if key == "Display Name":
#			if !include_display_name:
#				field_list.erase(key)
	key_selection._on_Input_item_selected(0)
	
	_on_field_selection_input_changed()


func update_field(include_display_name:bool = false):
	update_selection_array()
#	field_selection.sorted_table = field_list
#	field_selection.populate_list(false, true, true, field_list)

func update_selection_array():
	field_selection._set_input_value(create_list_dict())
#{"input_dict": {"1": {"Input_Node": {"show_advanced_options": false,"text": "Default Text"},"ChkBox": true}},"options_dict": {"action": "1"}}

func create_list_dict()-> Dictionary:
	#iterate through keys in dict and get field names
	var field_dict:Dictionary = {}
	var return_dict:Dictionary = {}
	for field in field_list:
		field_dict[field] = {"Input_Node": {"show_advanced_options": false,"text": field},"ChkBox": true}
#	for field in selected_table_dict[selected_table_dict.keys()[0]]:
#		field_dict[field] = {"Input_Node": {"show_advanced_options": false,"text": field},"ChkBox": true}
	return_dict["input_dict"] = field_dict
	return_dict["options_dict"] = {"action": "1"}
	print(return_dict)
	return return_dict
	
func set_selection_containers(): #THIS MUST BE DONE INSTEAD OF ON_READY VAR BECAUSE THE
	#NODE WILL BE NULL EVEN AFTER LOADING WHEN USING TOOL SCRIPTS
	while display_type_selection == null:
		display_type_selection = $VBoxContainer/HBoxContainer/DisplayTypeSelection
		await get_tree().process_frame
		
	while table_selection == null:
		table_selection = $VBoxContainer/HBoxContainer2/TableDataSelections/TableSelection
		await get_tree().process_frame
		
	while key_selection == null:
		key_selection = $VBoxContainer/HBoxContainer2/TableDataSelections/KeySelection
		await get_tree().process_frame

	while field_selection == null:
		field_selection = $VBoxContainer/ValueArray
		await get_tree().process_frame
		
#	while value_selection == null:
#		value_selection = $VBoxContainer/HBoxContainer2/ValueArray
#		await get_tree().process_frame

#	while name_value_checkbox == null:
#		name_value_checkbox = $VBoxContainer/HBoxContainer/NameValueCheckbox
#		await get_tree().process_frame
	containers_identified = true
