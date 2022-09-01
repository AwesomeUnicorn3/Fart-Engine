@tool
extends Control


signal edit_field_values_closed
@onready var DATA_CONTAINER :VBoxContainer = $PanelContainer/VBox1/Scroll1/VBox1
@onready var label : = $PanelContainer/VBox1/Label/HBox1/Label_Button
var DBENGINE : DatabaseEngine = DatabaseEngine.new()
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
	var field_type_dict = DBENGINE.import_data(DBENGINE.table_save_path + "Field_Pref_Values" + DBENGINE.file_format)
	var data_type_dict = DBENGINE.import_data(DBENGINE.table_save_path + "DataTypes" + DBENGINE.file_format)

	reset_values()

	for i in this_data_dict:
		print(i)
		var field_data_type :String
		for j in field_type_dict:
			if str(field_type_dict[j]["ItemID"]) == i:
				field_data_type = str(field_type_dict[j]["DataType"])
				break
		var node_value = DBENGINE.convert_string_to_type(this_data_dict[i], field_data_type)
		var ref_table_name :String = ""
		match i:
			"DataType":
				ref_table_name = "DataTypes"
				for data_key in data_type_dict:
					if node_value == data_key:
						if data_type_dict[data_key].has("Display Name"):
							node_value = data_type_dict[data_key]["Display Name"]
						else:
							node_value = data_key
						break
			"TableRef":
				ref_table_name = "Table Data"

		var new_field :Object = await DBENGINE.add_input_node(1, 1, i, data_dict, DATA_CONTAINER, null, node_value, field_data_type, ref_table_name)
		match i:
			"TableRef":
				if this_data_dict[i] != "5":
					new_field.visible = false
				reference_table_input = new_field
			"DataType":
				datatype_input = new_field
				initial_data_type = datatype_input.selectedItemName
				datatype_input.input_selection_changed.connect(on_text_changed)
			
			"FieldName":
				new_field.visible = false
				$PanelContainer/VBox1/Label/HBox1/Label_Button.set_text(this_data_dict[i])
		new_field.is_label_button = false


func on_text_changed(new_text = "Blank"):
	if datatype_input.selectedItemName == "5":
		reference_table_input.visible = true
	else:
		reference_table_input.visible = false

func _on_Input_toggled(button_pressed: bool) -> void:
	$PanelContainer/VBox1/Field_Input.visible = !button_pressed

func reset_values():
	for i in DATA_CONTAINER.get_children():
		i.queue_free()


func _on_Accept_button_up() -> void:
	update_data = true
	if datatype_input.selectedItemName != initial_data_type:
		is_datatype_changed = true
		initial_data_type = datatype_input.selectedItemName
	_on_Cancel_button_up()


func _on_Cancel_button_up() -> void:
	emit_signal("edit_field_values_closed")
