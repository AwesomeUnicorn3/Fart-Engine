@tool
extends PopupForm

var selected_index: String = "0"


func _on_accept_button_up():
	set_popup_return_value()
	PopupManager.hide_all_popups()


func _on_cancel_button_up():
	PopupManager.set_return_value("")
	PopupManager.hide_all_popups()


func set_popup_return_value():
	PopupManager.set_return_value(selected_index)
	var inputNode: FartDatatype = $VBoxContainer/Input_Dropdown


func set_values(arg_array:Array)-> void:
	populate_field_list(arg_array[0])


func populate_field_list(Field_Dict:Dictionary):
	$VBoxContainer/Input_Dropdown.populate_list(false, false, true, Field_Dict)
	selected_index = $VBoxContainer/Input_Dropdown.get_key_from_dropdown_index(str(0))
	$VBoxContainer/Input_Dropdown._set_input_value(selected_index)


func _on_input_item_selected(index):
	selected_index = $VBoxContainer/Input_Dropdown.get_key_from_dropdown_index(str(index))
