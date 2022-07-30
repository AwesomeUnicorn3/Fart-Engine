@tool
extends Control

signal edit_table_values_closed
@onready var DATA_CONTAINER :VBoxContainer = $PanelContainer/VBox1/Scroll1/VBox1

var main_node : Object
var parent_node :Object
var keyName : String
var tableName :String

#var datatype_input :Object
#var reference_table_input :Object
#var initial_data_type :String
var update_data := false
var is_datatype_changed := false
#var field_index : String

func _ready() -> void:
#	var accept = $PanelContainer/VBox1/HBox2/Accept
#	var cancel = $PanelContainer/VBox1/HBox2/Cancel
	add_field_data_to_container()

func add_field_data_to_container():
#	field_index  = main_node.get_data_index(tableName, "Column")
	var all_table_data_dict :Dictionary = main_node.import_data(main_node.table_save_path + "Table Data" + main_node.file_format)
	var current_table_dict :Dictionary = all_table_data_dict[tableName]
	var current_table_data_dict :Dictionary = main_node.import_data(main_node.table_save_path + "Table Data" + main_node.table_info_file_format)["Column"]
#	var data_type_dict = main_node.import_data(main_node.table_save_path + "DataTypes" + main_node.file_format)
	print("add field datat to container beigin")
	reset_values()

	for i in current_table_dict:
		var field_data_type :String
		for j in current_table_data_dict:
			if str(current_table_data_dict[j]["FieldName"]) == i:
				field_data_type = str(current_table_data_dict[j]["DataType"])
				break
#		var input_node :Object = main_node.get_input_type_node(field_data_type)
		var node_value = main_node.convert_string_to_type(current_table_dict[i], field_data_type)
		var ref_table_name :String = ""
#		match i:
#			"DataType":
#				ref_table_name = "DataTypes"
#				for k in data_type_dict:
#					if node_value == data_type_dict[k]["ID"]:
#						node_value = data_type_dict[k]["Display Name"]
#						break
#			"TableRef":
#				ref_table_name = "Table Data"

		var new_field :Object = main_node.add_input_node(1, 1, i, current_table_dict, DATA_CONTAINER, null, node_value, field_data_type, ref_table_name)
#		match i:
#			"TableRef":
#				if data_dict[i] != "5":
#					new_field.visible = false
#				reference_table_input = new_field
#			"DataType":
#				datatype_input = new_field
#				initial_data_type = datatype_input.selectedItemName
#				datatype_input.connect("selected_item_changed", self, "on_text_changed")
#
#			"FieldName":
#				new_field.visible = false
#				$PanelContainer/VBox1/Label.set_text(data_dict[i])
		new_field.is_label_button = false
	print("add field datat to container end")

#func on_text_changed(new_text = "Blank"):
#	if datatype_input.selectedItemName == "5":
#		reference_table_input.visible = true
#	else:
#		reference_table_input.visible = false

#func _on_Input_toggled(button_pressed: bool) -> void:
##	$PanelContainer/VBox1/Key_Input.visible = !button_pressed
#	$PanelContainer/VBox1/Field_Input.visible = !button_pressed

func reset_values():
	for i in DATA_CONTAINER.get_children():
		i.queue_free()


func _on_Accept_button_up() -> void:
	update_data = true
#	if datatype_input.selectedItemName != initial_data_type:
#		is_datatype_changed = true
#		initial_data_type = datatype_input.selectedItemName
	print("accepted")

	_on_Cancel_button_up()
	


func _on_Cancel_button_up() -> void:
	emit_signal("edit_table_values_closed")
