@tool
extends DatabaseEngine

signal save_complete
#@onready var engine = preload("res://addons/Database_Manager/DatabaseEngine.gd")
@onready var conditionLineItem = preload("res://addons/UDSEngine/Event_Manager/Condition_line_item.tscn")
@onready var inputContainer = $VBox1/Scroll1/VBox1
var mainDictionary : Dictionary = {}
var local_variable_dictionary : Dictionary #= {"A" : false, "B": false, "C": false, "D" : false, "E": false, "F": false} #SET TO EMPTY AFTER EVENT IS ABLE TO LOAD DATA
#var true_or_false_dictionary : Dictionary = {"True" : true, "False" : false}
#var condition_number_inequality_dict : Dictionary = {"Greater Than": ">", "Less Than": "<", "Equal To": "=", "Not Equal To" : "/=", "Greater Than OR Equal To": ">=", "Less Than OR Equal To": "<="}
var condition_types_dict : Dictionary = {"Inventory Item": "", "Event Variable": "", "Global Variable": ""}
var par_node
var source_node
var tab_node = null

func _on_Close_button_up() -> void:
	emit_signal("save_complete")
	_on_SaveChanges_button_up()
	self.call_deferred("close_form")

func close_form():
	call_deferred("delete_me")

func delete_me():
	self.queue_free()

func _on_SaveChanges_button_up() -> void:
	updateMainDict()


func updateMainDict():
	mainDictionary = {}
	for node in inputContainer.get_children():
		node.set_line_item_dictionary()
		mainDictionary[node.Key_field.inputNode.get_text()] = node.line_item_dictionary

	source_node.inputNode.set_text(var2str(mainDictionary))
	source_node.main_dictionary = mainDictionary


func clear_input_fields():
	for i in inputContainer.get_children():
		i.queue_free()

func _delete_selected_list_item(itemKey := ""):
	mainDictionary.erase(itemKey)
	refresh_form()


func create_input_fields():
	for condition_line in mainDictionary:
		var condition_line_node = conditionLineItem.instantiate()
		inputContainer.add_child(condition_line_node)
		condition_line_node.Key_field.inputNode.set_text(condition_line)
		condition_line_node.parent_node = self
		for key in mainDictionary[condition_line]:

			var value = mainDictionary[condition_line][key]["value"]
			var table = mainDictionary[condition_line][key]["table_name"]
			var display_node = condition_line_node.get_node(key)
			
			display_node.visible = true

			match display_node.type:
				"4": #Bool
					value = convert_string_to_type(value)
					display_node.inputNode.set_pressed(value)
					display_node.Input_toggled(value)
					
				"1": #String
					display_node.inputNode.set_text(value)
				"5": #Dropdown

					if table == "":
						var displayName :String = display_node.name

						match displayName:
							"If_DropDown":
								display_node.selection_table = condition_types_dict.duplicate(true)
								display_node.populate_list(false)
#								display_node.If.selectedItemName = value
								condition_line_node._on_If_DropDown_selected_item_changed()
#
#							"Is_DropDown":
#								display_node.selection_table = condition_number_inequality_dict
#								display_node.populate_list(false)



					if str(value) == "Default":
						value = display_node.default
					var type_id = display_node.get_id(str(value))
					display_node.select_index(type_id)
				"2":
					display_node.inputNode.set_text(value)
				"3":
					display_node.inputNode.set_text(value)


func _on_AddItem_button_up() -> void:
	_add_input_field()


func _add_input_field():
	_on_SaveChanges_button_up()
	var nextKeyValue :int
	
	if mainDictionary.size() == 0:
		nextKeyValue = 1
	else:
		nextKeyValue = (mainDictionary.keys().max()).to_int() + 1
	var default_dictionary :Dictionary = get_default_value("14")

	mainDictionary[str(nextKeyValue)] = default_dictionary["1"]
	refresh_form()
	_on_SaveChanges_button_up()


func refresh_form():
	clear_input_fields()
	create_input_fields()
