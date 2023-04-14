@tool
extends DatabaseEngine

var table = "DataTypes"
var relatedNodeName
var parent_node : Object
var line_item_dictionary :Dictionary = {}



@onready var key_display = $Key_Display

@onready var If := $If_DropDown
@onready var If_Table_Node := $If_Table_Name_DropDown
@onready var If_Key_Node := $If_Key_Name_DropDown
@onready var If_Value_Node := $if_Value_Name_DropDown
@onready var Is := $Is_DropDown
@onready var Is_Text_Node := $Is_Text
@onready var Is_Value_Text := $Is_Value_Text
@onready var Is_Value_Float := $Is_Value_Float
@onready var Is_Value_Bool := $Is_Value_Bool
@onready var If_Event_Variable := $Is_Event_Variable
#@onready var Is_Value_Int := $Is_Value_Int
var condition_types_dict: Dictionary = import_data("Condition Types")
var condition_type : String

func _ready() -> void:
	Is.populate_list()


func item_selected(value):
	pass


func set_line_item_dictionary():
	line_item_dictionary = {}
	for item_node in get_children():
		if item_node.visible:
			if item_node.name != "DeleteButton" and item_node.name != "Key":
				var tableName = ""
				if item_node.type == "5":
					tableName = item_node.selection_table_name
				line_item_dictionary[item_node.name] = {"value" :item_node.inputNode.get_text(), "table_name" : tableName}


func _on_DeleteButton_button_up() -> void:
	var keyValue = key_display.inputNode.text
	parent_node._delete_selected_list_item(keyValue)


func _on_If_DropDown_selected_item_changed() -> void:
	condition_type = If.selectedItemKey
	If_Key_Node.visible = false
	If_Value_Node.visible = false
	If_Table_Node.visible = false
	Is.visible = false
	Is_Text_Node.visible = false
	Is.inputNode.disabled = false
	Is.inputNode.flat = false
	Is_Value_Bool.visible = false
	Is_Value_Text.visible = false
	Is_Value_Float.visible = false
	If_Event_Variable.visible = false

#	print(condition_type)
	match condition_type:
		"3":
			If_Table_Node.populate_list()
			If_Table_Node.selectedItemKey = condition_type
			_on_If_Table_Name_DropDown_selected_item_changed()
			If_Key_Node.visible = true

		"1":
			If_Table_Node.selectedItemKey = condition_type
			_on_If_Table_Name_DropDown_selected_item_changed()
			Is_Text_Node.inputNode.set_text("In Player Inventory")
			Is_Text_Node.visible = true
			If_Key_Node.visible = true

		"2":
			If_Event_Variable.selection_table = parent_node.local_variable_dictionary
			If_Event_Variable.selection_table_name = "" #REPLACE THIS WITH DICTIONARY INPUT IN EVENT TABLE???
			If_Event_Variable.populate_list(false)
			If_Event_Variable.visible = true
			Is_Text_Node.inputNode.set_text("Equal To")
			Is_Text_Node.visible = true
			Is_Value_Bool.visible = true


func _on_If_Table_Name_DropDown_selected_item_changed() -> void:
	var reference_table:String = condition_types_dict[condition_type]["Reference Table"]
	If_Key_Node.selection_table_name = reference_table
	If_Key_Node.populate_list()
	If_Key_Node.select_index()
	_on_If_Key_Name_DropDown_selected_item_changed()


func _on_If_Key_Name_DropDown_selected_item_changed() -> void:
	var key :String = If_Key_Node.selectedItemKey
	#print("Selected field key: ", key)
	If_Value_Node.selection_table_name = key
	#print(If_Key_Node.selection_table[key])
	var selection_table:Dictionary = {}
#	if !If_Key_Node.selection_table.has(key) and If_Key_Node.selection_table[If_Key_Node.selection_table.keys()[0]].has("Display Name") :
	
	for keyIndex in If_Key_Node.selection_table[key]:
		#print(If_Key_Node.selection_table[key][keyIndex])
		#if convert_string_to_type(If_Key_Node.selection_table[keyIndex]["Display Name"])["text"] == key:
		if keyIndex != "Display Name":
			selection_table[keyIndex] = keyIndex
#	print(selection_table)
	If_Value_Node.selection_table = selection_table
#				break
#	if If_Key_Node.selection_table.has(key) :
#		If_Value_Node.selection_table =  If_Key_Node.selection_table[key]
#	print('Condition Type: ', condition_type)
	match condition_type:
		"3":
			If_Value_Node.populate_list(false, false)
			If_Value_Node.select_index()
			If_Value_Node.visible = true
			#_on_if_Value_Name_DropDown_selected_item_changed()

		"Inventory Item":
			pass

		"Event Variable":
			pass


func _on_if_Value_Name_DropDown_selected_item_changed() -> void:
	var value_type :String = If_Value_Node.selectedItemKey
	var data_type :String = get_datatype(value_type, import_data(If_Table_Node.selectedItemKey, true))
	Is_Value_Text.visible = false
	Is_Value_Float.visible = false
	Is_Value_Bool.visible = false
	Is_Text_Node.visible = false
	Is.visible = false
	match data_type:
		"1":
			Is_Text_Node.inputNode.set_text("Equal To")
			Is_Text_Node.visible = true
			Is_Value_Text.visible = true
		"2":
			Is.visible = true
			Is_Value_Float.visible = true
		"4":
			Is_Text_Node.visible = true
			Is_Text_Node.inputNode.set_text("Equal To")
			Is_Value_Bool.visible = true
