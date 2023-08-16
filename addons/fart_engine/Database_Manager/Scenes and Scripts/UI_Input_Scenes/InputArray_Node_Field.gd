@tool
extends HBoxContainer
signal array_item_delete

@export var showDeleteButton:bool = true

func _on_button_button_up():
	emit_signal("array_item_delete", self.name)


func show_delete_button(show:bool):
	$DeleteItemButton.visible = show
	showDeleteButton = show


func show_selection_checkbox(show:bool):
	$ChkBox.visible = show

func _get_input_value() -> Dictionary:
	var return_dict:Dictionary = {}
	for child in get_children():
		if child.has_method('_get_input_value'):
			return_dict[child.name] = child._get_input_value()
	print(return_dict)
	return return_dict


func _set_input_value(node_value):
	if typeof(node_value) == 4:
		node_value = str_to_var(node_value)
	for child in get_children():
		if child.has_method('_set_input_value'):
			print(node_value)
			child._set_input_value(node_value[child.name])
