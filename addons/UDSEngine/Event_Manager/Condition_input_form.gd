@tool
extends DatabaseEngine

signal save_complete
#@onready var engine = preload("res://addons/Database_Manager/DatabaseEngine.gd")
@onready var conditionLineItem = preload("res://addons/UDSEngine/Event_Manager/Condition_line_item.tscn")
@onready var inputContainer = $VBox1/Scroll1/VBox1
var mainDictionary : Dictionary = {}
var local_variable_dictionary : Dictionary = {"A" : false, "B": false, "C": false, "D" : false, "E": false, "F": false} #SET TO EMPTY AFTER EVENT IS ABLE TO LOAD DATA
#var true_or_false_dictionary : Dictionary = {"True" : true, "False" : false}
#var condition_number_inequality_dict : Dictionary = {"Greater Than": ">", "Less Than": "<", "Equal To": "=", "Not Equal To" : "/=", "Greater Than OR Equal To": ">=", "Less Than OR Equal To": "<="}
var condition_types_dict : Dictionary = {"Inventory Item": "", "Event Variable": "", "Global Variable": ""}
var par_node
var source_node


func _ready() -> void:
	
#	$VBox1/Scroll1/VBox1/Condition_line_item.parent_node = self
#	$VBox1/Scroll1/VBox1/Condition_line_item.If.selection_table = condition_types_dict
#	$VBox1/Scroll1/VBox1/Condition_line_item.If.selection_table_name = "condition_types_dict"
#	$VBox1/Scroll1/VBox1/Condition_line_item.If.populate_list(false)
#	$VBox1/Scroll1/VBox1/Condition_line_item.If.select_index()
#	$VBox1/Scroll1/VBox1/Condition_line_item._on_If_DropDown_selected_item_changed() 
	pass
	#WHEN EVENT IS ABLE TO LOAD DATA- DONT FORGET TO SET LOCAL VAR DICT TO DICT FROM THE EVENT DATA
	#SAME AS ABOVE BUT WITH SETTING THE PARENT NODE
#	print(mainDictionary)
#DELETE THIS WHEN CONDITION LINE ITEM IS LOADED AT RUNTIME

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
	#WHEN BUTTON IS PRESSED IT WILL GET THE KEY VALUE FROM IT'S PARENT NODE
	#THEN IT WILL RUN THIS SCRIPT WITH THE STRING OF THE KEY VALUE
	
	#THIS SCRIPT WILL THEN DELETE THE SELECTED KEY FROM THE MAINDICTIONARY
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
#			print(display_node.name)
			match display_node.type:
				"4": #Bool
					value = convert_string_to_type(value)
					display_node.inputNode.set_pressed(value)
					display_node.Input_toggled(value)
					
				"1": #String
					display_node.inputNode.set_text(value)
				"5": #Dropdown
					if table == "":
#						print(display_node.name)
						match display_node.name:
							"If_DropDown":
								display_node.selection_table = condition_types_dict
								display_node.populate_list(false)
#								display_node.If.selectedItemName = value
#								print("IF DROPDOWN")
								condition_line_node._on_If_DropDown_selected_item_changed()
#
#							"Is_DropDown":
#								display_node.selection_table = condition_number_inequality_dict
#								display_node.populate_list(false)
#								print("IS DROPDOWN")



					if str(value) == "Default":
						value = display_node.default
#					print(value)
					var type_id = display_node.get_id(str(value))
#					print(value)
					display_node.select_index(type_id)
#					var itemSelected = display_node._on_Input_item_selected(type_id)
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
#		print(mainDictionary)
		nextKeyValue = 1
	else:
		nextKeyValue = int(mainDictionary.keys().max()) + 1
	var default_dictionary :Dictionary = get_default_value("14")

	mainDictionary[str(nextKeyValue)] = default_dictionary["1"]
#	print(mainDictionary)
	refresh_form()
	_on_SaveChanges_button_up()


func refresh_form():
	clear_input_fields()
	create_input_fields()
