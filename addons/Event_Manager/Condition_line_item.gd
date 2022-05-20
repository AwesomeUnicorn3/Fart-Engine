extends DatabaseEngine
tool

var table = "DataTypes"
var relatedNodeName
var parent_node : Object
var line_item_dictionary :Dictionary = {}


onready var Key_field = $Key
onready var If := $If_DropDown
onready var If_Table_Node := $If_Table_Name_DropDown
onready var If_Key_Node := $If_Key_Name_DropDown
onready var If_Value_Node := $if_Value_Name_DropDown
onready var Is := $Is_DropDown
onready var Is_Text_Node := $Is_Text
onready var Is_Value_Text := $Is_Value_Text
onready var Is_Value_Float := $Is_Value_Float
onready var Is_Value_Bool := $Is_Value_Bool
onready var If_Event_Variable := $Is_Event_Variable
onready var Is_Value_Int := $Is_Value_Int

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
#					print(tableName)
				line_item_dictionary[item_node.name] = {"value" :item_node.inputNode.get_text(), "table_name" : tableName}


func _on_DeleteButton_button_up() -> void:
#	var parent_node = get_node("../../../..")
	var keyValue = Key_field.inputNode.text
	parent_node._delete_selected_list_item(keyValue)
#	print(keyValue)



func _on_If_DropDown_selected_item_changed() -> void:
	condition_type = If.selectedItemName
#	print(condition_type)
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
	Is_Value_Int.visible = false

	match condition_type:
		"Global Variable":
			If_Table_Node.populate_list()
			If_Table_Node.selectedItemName = "Global Variables"
			_on_If_Table_Name_DropDown_selected_item_changed()
			If_Key_Node.visible = true


		"Inventory Item":
			If_Table_Node.selectedItemName = "Items"
			_on_If_Table_Name_DropDown_selected_item_changed()
			Is_Text_Node.inputNode.set_text("In Player Inventory")
			Is_Text_Node.visible = true
			If_Key_Node.visible = true


		"Event Variable":
#			Is_Node.select_index()
			If_Event_Variable.selection_table = parent_node.local_variable_dictionary
			If_Event_Variable.selection_table_name = "" #REPLACE THIS WITH DICTIONARY INPUT IN EVENT TABLE???
			If_Event_Variable.populate_list(false)
			If_Event_Variable.visible = true
			
			Is_Text_Node.inputNode.set_text("Equal To")
			Is_Text_Node.visible = true
			Is_Value_Bool.visible = true



func _on_If_Table_Name_DropDown_selected_item_changed() -> void:
	var table_name :String = If_Table_Node.selectedItemName
	If_Key_Node.selection_table_name = table_name
	If_Key_Node.populate_list()
	If_Key_Node.select_index()
	_on_If_Key_Name_DropDown_selected_item_changed()
	

func _on_If_Key_Name_DropDown_selected_item_changed() -> void:
	var key_name :String = If_Key_Node.selectedItemName
	If_Value_Node.selection_table_name = key_name
	if !If_Key_Node.selection_table.has(key_name) and If_Key_Node.selection_table[If_Key_Node.selection_table.keys()[0]].has("Display Name") :
		for i in If_Key_Node.selection_table:
			if If_Key_Node.selection_table[i]["Display Name"] == key_name:
				If_Value_Node.selection_table = If_Key_Node.selection_table[i]
				break
	elif If_Key_Node.selection_table.has(key_name) :
		If_Value_Node.selection_table =  If_Key_Node.selection_table[key_name]
	
	match condition_type:
		"Global Variable":
			If_Value_Node.populate_list(false)
			If_Value_Node.select_index()
			If_Value_Node.visible = true
			_on_if_Value_Name_DropDown_selected_item_changed()
			
		"Inventory Item":
			pass
			
		"Event Variable":
			pass


func _on_if_Value_Name_DropDown_selected_item_changed() -> void:
	var value_type :String = If_Value_Node.selectedItemName
	var data_type :String = get_value_type(value_type, import_data(table_save_path + If_Table_Node.selectedItemName + table_info_file_format ))
	Is_Value_Text.visible = false
	Is_Value_Float.visible = false
	Is_Value_Int.visible = false
	Is_Value_Bool.visible = false
	Is_Text_Node.visible = false
	Is.visible = false
#	print(data_type)
	match data_type:
		"1":
			Is_Text_Node.inputNode.set_text("Equal To")
			Is_Text_Node.visible = true
			Is_Value_Text.visible = true
		"3":
#			Is.selection_table_name = "Local"
#			Is.selection_table = parent_node.condition_number_inequality_dict
#			Is.populate_list()
#			Is.select_index()
			Is.visible = true
			Is_Value_Float.visible = true
		"5":
#			Is.selection_table_name = "Local"
#			Is.selection_table = parent_node.condition_number_inequality_dict
#			Is.populate_list()
#			Is.select_index()
			Is_Value_Int.visible = true
			Is.visible = true
		"4":
#			Is_Node.visible = false
			Is_Text_Node.visible = true
			Is_Text_Node.inputNode.set_text("Equal To")
			Is_Value_Bool.visible = true

