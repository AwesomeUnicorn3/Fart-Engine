@tool
extends Control
signal newfieldinput_closed

var main_dict :Dictionary
var DBENGINE :DatabaseEngine = DatabaseEngine.new()


func _ready():
	$PanelContainer/VBox1/HBox1/ItemType_Selection.populate_list()
	$PanelContainer/VBox1/HBox1/Table_Selection.populate_list()

func reset_values():
	$PanelContainer/VBox1/HBox1/Table_Selection.visible = false

func _accept_button_up():
	get_values()
	_on_cancel_button_up()


func _on_cancel_button_up():
	emit_signal("newfieldinput_closed")


func get_values():
	main_dict = {}
	var fieldName :String = $PanelContainer/VBox1/HBox1/Input_Text.get_input_value()["text"]
	main_dict["fieldName"] = fieldName
	var datatype_node = $PanelContainer/VBox1/HBox1/ItemType_Selection
	var datatype_name = datatype_node.selectedItemName
	var datatype_id = datatype_node.get_dataType_ID(datatype_name)
	main_dict["datatype"] = datatype_id
	main_dict["showField"] = true
	main_dict["required"] = false
	main_dict["tableName"] = $PanelContainer/VBox1/HBox1/Table_Selection.selectedItemName
	return main_dict

#func add_newField(): 
#	var datafield = $PanelContainer/VBox1/HBox1/ItemType_Selectionn
#	var fieldName = $Popups/popup_newValue/PanelContainer/VBox1/HBox1/Input_Text/Input.get_text()
#	var selected_item_name = datafield.selectedItemName
#	var datatype = datafield.get_dataType_ID(selected_item_name)
#	var showField = true
#	var required = false
#	var tableName = $Popups/popup_newValue/PanelContainer/VBox1/HBox1/Table_Selection.selectedItemName
#	#Get input values and send them to the editor functions add new value script
#	#NEED TO ADD ERROR CHECKING
#
#	await add_field(fieldName, datatype, showField, false, tableName)
#	refresh_data(Item_Name)

