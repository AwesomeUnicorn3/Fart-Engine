@tool
extends Control

signal edit_table_values_closed
@onready var DATA_CONTAINER :VBoxContainer = $PanelContainer/VBox1/Scroll1/VBox1

var main_node : Object
var parent_node :Object
var keyName : String
var tableName :String
var update_data := false
var is_datatype_changed := false


func _ready() -> void:
	add_field_data_to_container()

func add_field_data_to_container():
	var all_table_data_dict :Dictionary = main_node.import_data("Table Data")
	var current_table_dict :Dictionary = all_table_data_dict[tableName]
	var current_table_data_dict :Dictionary = main_node.import_data("Table Data", true)["Column"]
	reset_values()

	for i in current_table_dict:
		var field_data_type :String
		for j in current_table_data_dict:
			if str(current_table_data_dict[j]["FieldName"]) == i:
				field_data_type = str(current_table_data_dict[j]["DataType"])
				break
		var node_value = main_node.convert_string_to_type(current_table_dict[i], field_data_type)
		var ref_table_name :String = ""
		var new_field :Object = main_node.add_input_node(1, 1, i, current_table_dict, DATA_CONTAINER, null, node_value, field_data_type, ref_table_name)
		new_field.is_label_button = false


func reset_values():
	for i in DATA_CONTAINER.get_children():
		i.queue_free()


func _on_Accept_button_up() -> void:
	update_data = true
	_on_Cancel_button_up()


func _on_Cancel_button_up() -> void:
	emit_signal("edit_table_values_closed")
