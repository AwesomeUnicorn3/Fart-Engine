@tool
extends DatabaseEngine



@onready var right_operator := $RightOperator
@onready var left_operator = $LeftOperator

@onready var key_display := $Key_Display
@onready var inequality_dropdown := $Inequality_Dropdown
@onready var static_option = $Static_Option
@onready var static_value_1 = $StaticValue1
@onready var operations_dropdown = $Operations_Dropdown
@onready var static_value_2 = $StaticValue2
@onready var compare_option = $Compare_Option




var table = "DataTypes"
var relatedNodeName
var parent_node : Object
var inequalities_table:Dictionary ={}
var line_item_dictionary :Dictionary = {}
var text_inequality_dict: Dictionary = {}
var text_inequality_raw_dict:Dictionary = {}
var filtered_right_table:Dictionary = {}: 
	set = set_right_operators


func _ready() -> void:
	right_operator.is_left = false
	get_inequality_dicts()
	static_option._set_input_value(true)
	compare_option._set_input_value(true)
	operations_dropdown.populate_list()


func set_right_operators(value:Dictionary):
	if right_operator != null:
		filtered_right_table = value
		right_operator.filter_by_datatype()
		filter_inequalities()

		var table_ID:String = left_operator.table_drop_down.selectedItemKey
		var key_ID:String = left_operator.key_drop_down.selectedItemKey
		var field_ID:String = left_operator.field_drop_down.selectedItemKey
		add_input_node_for_event_condition(table_ID, key_ID, field_ID, $StaticValue2)
		add_input_node_for_event_condition(table_ID, key_ID, field_ID)


func filter_inequalities():
	var datatype = left_operator.selected_datatype
	var datatype_dict: Dictionary = import_data("Datatypes")
	var is_datatype_number:bool = convert_string_to_type(datatype_dict[datatype]["Is Number"])
	if !is_datatype_number:
		inequality_dropdown.populate_list_with_sorted_table(text_inequality_dict)
		$Operations_Dropdown.visible = false
		$StaticValue2.visible = false
	else:
		inequality_dropdown.populate_list()
		$Operations_Dropdown.visible = true
		$StaticValue2.visible = true


func get_inequality_dicts():
	inequalities_table = import_data(inequality_dropdown.selection_table_name)
	var datatype_table:Dictionary = import_data("DataTypes")

	var index:int = 1
	for key in inequalities_table:
		var is_text_operator:bool = convert_string_to_type(inequalities_table[key]["Is Text Operator"])
		if is_text_operator:
			text_inequality_raw_dict[key] = inequalities_table[key]
			var displayName:String = convert_string_to_type(inequalities_table[key]["Display Name"])["text"]
			text_inequality_dict[str(index)] = [displayName, key, "0"] 
			index += 1



func add_input_node_for_event_condition(table_name:String, key_ID:String, field_ID: String, newParent :Node= static_value_1 ):
	var datatype = left_operator.selected_datatype
	for child in newParent.get_children():
		child.queue_free()
	var new_input_node = create_independant_input_node(table_name, key_ID, field_ID )
	new_input_node.label_text = "VALUE"
	new_input_node.is_label_button = false
	new_input_node.show_field= true
	new_input_node.set_custom_minimum_size(Vector2(150,50))
	new_input_node.set_h_size_flags(SIZE_EXPAND)
	newParent.add_child(new_input_node)
	if datatype == "5":
		var left_field_ref_table: String = get_reference_table(table_name, key_ID, field_ID)
		new_input_node.selection_table_name = left_field_ref_table
		new_input_node.populate_list()



func show_right_side_selection(show:bool):
	right_operator.visible = show


func show_right_side_input_node(show:bool):
	static_value_1.visible = show


func _on_static_option_checkbox_pressed(button_pressed):
	show_right_side_selection(!button_pressed)
	show_right_side_input_node(button_pressed)


func get_key_ID():
	var return_val:String
	return_val = key_display.get_input_value()["text"]
	return return_val


func get_input_value():
	var return_dict:Dictionary = {}
	return_dict["Inequalities"] = inequality_dropdown.get_input_value()
	return_dict["Datatype"] =  left_operator.selected_datatype
	return_dict["Is Static"] = static_option.get_input_value()
	return_dict["Optional Operations"] = operations_dropdown.get_input_value()
	return_dict["Is And"] = compare_option.get_input_value()
	
	if static_value_1.get_children().size() != 0:
		return_dict["Static Value 1"] = static_value_1.get_child(0).get_input_value()
	if static_value_2.get_children().size() != 0:
		return_dict["Static Value 2"] = static_value_2.get_child(0).get_input_value()
		
	return_dict["Compare Left"] = left_operator.get_input_value()
	return_dict["Variable Value"] = right_operator.get_input_value()
	
	return return_dict


func set_input_values(value:Dictionary):
	if value != {}:
		left_operator.set_input_values(value["Compare Left"])
		await get_tree().create_timer(0.5).timeout
		right_operator.set_input_values(value["Variable Value"])
#		print("SET INPUT VALUES")
		filter_inequalities()
		
		inequality_dropdown.set_value_do_not_populate(value["Inequalities"])
		
		static_option.set_input_value(convert_string_to_type(value["Is Static"]))
		operations_dropdown.set_value_do_not_populate(value["Optional Operations"])
		compare_option.set_input_value(convert_string_to_type(value["Is And"]))

		#must be set last
		static_value_1.get_child(0).set_input_value(value["Static Value 1"])
		static_value_2.get_child(0).set_input_value(value["Static Value 2"])
		


func _on_delete_button_button_up():
	var keyID:String = get_key_ID()
	get_node("../../../..")._delete_selected_list_item(keyID)

