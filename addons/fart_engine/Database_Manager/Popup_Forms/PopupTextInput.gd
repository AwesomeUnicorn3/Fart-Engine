@tool
extends PopupForm


func _on_accept_button_up():
	set_popup_return_value()
	popup_form_return_value = ""
	PopupManager.hide_all_popups()


func _on_cancel_button_up():
	PopupManager.set_return_value("")
	popup_form_return_value = ""
	PopupManager.hide_all_popups()


func set_popup_return_value():
	_on_input_text_changed()
	PopupManager.set_return_value(popup_form_return_value)


func set_values(arg_array:Array)-> void:
	$VBoxContainer/Input_Text.set_input_value(arg_array[0])
	_on_input_text_changed()


func _on_input_text_changed(new_text:String = ""):
	popup_form_return_value = $VBoxContainer/Input_Text.get_input_value()
