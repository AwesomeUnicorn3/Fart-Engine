@tool
extends Control


signal edit_field_values_closed
@onready var DATA_CONTAINER :VBoxContainer = $PanelContainer/VBox1/Scroll1/VBox1
@onready var label : = $PanelContainer/VBox1/Label/HBox1/Label_Button
var DBENGINE : DatabaseManager = DatabaseManager.new()
var parent_node :Object
var keyName : String
var fieldName :String

var datatype_input :Object
var reference_table_input :Object
var initial_data_type :String
var update_data := false
var is_datatype_changed := false
var field_index : String
var data_dict :Dictionary

func _ready() -> void:
	var accept = $PanelContainer/VBox1/HBox2/Accept
	var cancel = $PanelContainer/VBox1/HBox2/Cancel
	add_field_data_to_container()


func add_field_data_to_container():
	DBENGINE.currentData_dict = data_dict
	field_index = DBENGINE.get_data_index(fieldName, "Column")
	var this_data_dict = data_dict["Column"][field_index]
	var field_type_dict = DBENGINE.import_data("Field_Pref_Values")
	var data_type_dict = DBENGINE.import_data("DataTypes")
	var field_data_type :String = this_data_dict["DataType"]
	var input_node_type_name :String = DBENGINE.get_text(data_type_dict[field_data_type]["Display Name"])

	for child in $PanelContainer/VBox1/Scroll1/VBox1.get_children():
		var node_value = DBENGINE.convert_string_to_type(this_data_dict[child.name])
		var ref_table_name :String = ""
		var child_name :String = child.name
		match child_name:
			"FieldName":
				$PanelContainer/VBox1/Scroll1/VBox1/FieldName._set_input_value({"text" : this_data_dict[child_name] })
				$PanelContainer/VBox1/Scroll1/VBox1/FieldName.visible = false
				$PanelContainer/VBox1/Label/HBox1/Label_Button.set_text(this_data_dict[child_name])
				
			"DataType":
				ref_table_name = "DataTypes"
				datatype_input = child
				child.populate_list()
				datatype_input.input_selection_changed.connect(on_text_changed)
				var dropdown_index :int = child.get_dropdown_index_from_displayName(input_node_type_name)
				child.select_index(dropdown_index)

			"RequiredValue":
				var reqired_value = DBENGINE.custom_to_bool(node_value)
				child.inputNode.set_pressed(reqired_value)
				child._on_input_toggled(reqired_value)
				
			"ShowValue":
				var reqired_value = DBENGINE.custom_to_bool(node_value)
				child.inputNode.set_pressed(reqired_value)
				child._on_input_toggled(reqired_value)

			"TableRef":
				child.populate_list()
				var field_table_ref :String = this_data_dict["TableRef"]
				var table_ref_name :String = DBENGINE.get_text(child.selection_table[field_table_ref]["Display Name"])
				datatype_input = child
				var dropdown_index :int = child.get_dropdown_index_from_key(table_ref_name)
				child.select_index(dropdown_index)
		child.is_label_button = false


func on_text_changed(new_text = "Blank"):
	var selectedName :String = $PanelContainer/VBox1/Scroll1/VBox1/DataType.get_display_name_from_key($PanelContainer/VBox1/Scroll1/VBox1/DataType.selectedItemKey)
	if selectedName == "Dropdown List":
		$PanelContainer/VBox1/Scroll1/VBox1/TableRef.visible = true
	else:
		$PanelContainer/VBox1/Scroll1/VBox1/TableRef.visible = false


func _on_Input_toggled(button_pressed: bool) -> void:
	$PanelContainer/VBox1/Field_Input.visible = !button_pressed


func _on_Accept_button_up() -> void:
	update_data = true
	if datatype_input.get_display_name_from_key(datatype_input.selectedItemKey) != initial_data_type:
		is_datatype_changed = true
		initial_data_type = datatype_input.get_display_name_from_key(datatype_input.selectedItemKey)
	_on_Cancel_button_up()


func _on_Cancel_button_up() -> void:
	emit_signal("edit_field_values_closed")
