@tool
extends PopupForm

var selected_datatype:String = "1"
var selected_table_name:String = "10000"



func get_values()-> Dictionary:
	var return_dict: Dictionary = {}
	$VBox1/HBox1/ItemType_Selection.populate_list()
	$VBox1/HBox1/Table_Selection.populate_list()
	$VBox1/HBox1/Input_Text/Input_Node/Input.placeholder_text = "Default Field Name"
	return_dict["FieldName"] = $VBox1/HBox1/Input_Text.get_text_value()
	return_dict["DataType"] = selected_datatype
	return_dict["ShowValue"] = true
	return_dict["RequiredValue"] = false
	return_dict["TableRef"] = selected_table_name
	return return_dict


func set_values(arg_array:Array)-> void:
	$VBox1/HBox1/ItemType_Selection.populate_list()
	$VBox1/HBox1/Table_Selection.populate_list()
	
	if str($VBox1/HBox1/Input_Text.get_input_value()) == "":
		$VBox1/HBox1/Input_Text/Input_Node/Input.placeholder_text = "Default Field Name"
	$VBox1/HBox1/Table_Selection.visible = false
	
func _on_accept_button_up():
	PopupManager.set_return_value(get_values())
	PopupManager.hide_all_popups()


func _on_cancel_button_up():
	PopupManager.set_return_value("")
	PopupManager.hide_all_popups()


func _on_input_item_selected(index:int):
	selected_datatype = $VBox1/HBox1/ItemType_Selection.get_key_from_dropdown_index(str(index))
	$VBox1/HBox1/Table_Selection.visible = false
	if selected_datatype == "5":
		$VBox1/HBox1/Table_Selection.visible = true


func _on_table_input_item_selected(index):
	selected_table_name = $VBox1/HBox1/Table_Selection.get_key_from_dropdown_index(str(index))
