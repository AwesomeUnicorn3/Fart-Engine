@tool
extends VBoxContainer

@export var  is_left: bool = true
@onready var table_drop_down := $TableKeyField_Combo/Table_DropDown
@onready var key_drop_down := $TableKeyField_Combo/Key_DropDown
@onready var field_drop_down := $TableKeyField_Combo/Field_DropDown

var DBENGINE :DatabaseEngine = DatabaseEngine.new()
var selected_datatype: String = "1"



func _ready():
	if is_left:
		table_drop_down.populate_list()
		table_drop_down.selection_table = table_drop_down.filter_tables_for_condition()
		table_drop_down.populate_list_with_selection_table()
		await get_tree().create_timer(.1).timeout
		table_drop_down.select_index(0)



func _on_table_drop_down_input_selection_changed():
	if is_left:
		update_left_key_and_field()
	else:
		update_right_side()


func _on_field_drop_down_input_selection_changed():
	if is_left:
		var filter:Dictionary = get_filtered_table()
		if "filtered_right_table" in get_parent():
			get_parent().filtered_right_table = filter


func get_filtered_table():
	var filterd_table: Dictionary = {}
	selected_datatype = field_drop_down.get_selection_datatype()
	var table_list_dict: Dictionary = table_drop_down.selection_table
	table_list_dict.erase("Table Data")
	for table in table_list_dict:
		var table_data_dict: Dictionary = DBENGINE.import_data(table, true)
		for field in table_data_dict[table_data_dict.keys()[0]]:
			var field_name: String = table_data_dict["Column"][field]["FieldName"]
			var field_datatype: String = DBENGINE.get_datatype(field_name, table_data_dict)
			if selected_datatype == field_datatype:
				if filterd_table.has(table):
					var new_dict:Dictionary = {field_name: selected_datatype}
					filterd_table[table].merge(new_dict)
				else:
					filterd_table[table] = {field_name: selected_datatype}

	return filterd_table


func update_left_key_and_field(include_display_name:bool = false):
	var selected_table_key: String = table_drop_down.selectedItemKey
	var selected_table_dict: Dictionary = DBENGINE.import_data(selected_table_key)
	var selected_table_data_dict: Dictionary = DBENGINE.import_data(selected_table_key, true)

	key_drop_down.selection_table_name = table_drop_down._get_input_value()

	var sorted_key_list: Dictionary = key_drop_down.populate_list()
	
	var field_list: Dictionary = {}
	for key in selected_table_dict[selected_table_dict.keys()[0]]:
		field_list[key] = {"Datatype": DBENGINE.get_datatype(key, selected_table_data_dict)}
		if key == "Display Name":
			if !include_display_name:
				field_list.erase(key)
			
#		print("KEY: ", key)
	field_drop_down.selection_table = field_list
	field_drop_down.populate_list(false, true)



func filter_by_datatype():
#	var table_dict:Dictionary = {}
	var filtered_table: Dictionary = get_parent().filtered_right_table
	table_drop_down.selection_table = filtered_table
	var sorted_table :Dictionary = DBENGINE.list_custom_dict_keys_in_display_order(filtered_table, "Table Data")
	table_drop_down.populate_list_with_sorted_table(sorted_table)
	await get_tree().create_timer(.25).timeout
	#table_drop_down.select_index(0)

	update_right_side()



func update_right_side(include_display_name:bool = false):
	var filtered_table: Dictionary = get_parent().filtered_right_table
	var selected_table_key: String = table_drop_down.selectedItemKey
	var selected_table_dict: Dictionary = DBENGINE.import_data(selected_table_key)
	var selected_table_data_dict: Dictionary = DBENGINE.import_data(selected_table_key, true)
	key_drop_down.selection_table_name = table_drop_down._get_input_value()
	var sorted_key_list: Dictionary = key_drop_down.populate_list()

	var field_list: Dictionary = {}
	for field in selected_table_dict[selected_table_dict.keys()[0]]:
		if filtered_table[selected_table_key].has(field):
			field_list[field] = {"Datatype": DBENGINE.get_datatype(field, selected_table_data_dict)}
		if field == "Display Name":
			if !include_display_name:
				field_list.erase(field)

	field_drop_down.selection_table = field_list
	field_drop_down.populate_list(false, true)


func get_input_value():
	var return_dict:Dictionary = {}
	if table_drop_down.get_input_value() == "Items":
		return_dict["TableID"] = "Inventory"
	else:
		return_dict["TableID"]=  table_drop_down.get_input_value()
	
		
	return_dict["KeyID"]=  key_drop_down.get_input_value()
	return_dict["FieldID"]=  field_drop_down.get_input_value()
	return return_dict


func set_input_values(value:Dictionary):
#	print("Table ID: ", value["TableID"] )
	if value["TableID"] == "Inventory":
		table_drop_down.set_value_do_not_populate("Items")
	else:
		table_drop_down.set_value_do_not_populate(value["TableID"])
	
	key_drop_down.set_value_do_not_populate(value["KeyID"])
	field_drop_down.set_value_do_not_populate(value["FieldID"])
