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
	var datatype_name = datatype_node.selectedItemKey
	var datatype_id = datatype_node.get_dataType_ID(datatype_name)
	main_dict["datatype"] = datatype_id
	main_dict["showField"] = true
	main_dict["required"] = false
	main_dict["tableName"] = $PanelContainer/VBox1/HBox1/Table_Selection.selectedItemKey
	return main_dict
