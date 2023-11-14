@tool
extends PopupManager

signal edit_table_values_closed
@onready var DATA_CONTAINER :VBoxContainer = $VBox1/Scroll1/VBox1

#var main_node : Object
#var parent_node 
var keyName : String
var tableName :String
var update_data := false
var is_datatype_changed := false


#func _ready() -> void:
#	add_field_data_to_container()

func add_field_data_to_container():
	pass
#	var all_table_data_dict :Dictionary = import_data("10000")
#	var current_table_dict :Dictionary = all_tables_dict[tableName]
#	var current_table_data_dict :Dictionary = import_data(tableName, true)[DatabaseManager.FIELD]
#	reset_values()
#
#	for i in current_table_dict:
#		var field_data_type :String
#		for j in current_table_data_dict:
#			if str(current_table_data_dict[j]["FieldName"]) == i:
#				field_data_type = str(current_table_data_dict[j]["DataType"])
#				break
#		var node_value = DatabaseManager.convert_string_to_type(current_table_dict[i], field_data_type)
#		var ref_table_name :String = ""
#		var new_field = DatabaseManager.add_input_node(1, 1, i, current_table_dict, DATA_CONTAINER, null, node_value, field_data_type, ref_table_name)
#		new_field.is_label_button = false


func reset_values():
	for i in DATA_CONTAINER.get_children():
		i.queue_free()


func _on_Accept_button_up() -> void:
	update_data = true
	_on_Cancel_button_up()


func _on_Cancel_button_up() -> void:
	emit_signal("edit_table_values_closed")


func _on_accept_btn_pressed(btn_name):
	pass # Replace with function body.


func _on_cancel_btn_pressed(btn_name):
	pass # Replace with function body.
