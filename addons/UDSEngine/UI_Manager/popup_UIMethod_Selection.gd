@tool
extends Control

signal input_closed
var selected_method_key :String
var selected_UIButton :Node

func _ready():
	get_button_method()
	$PanelContainer/VBox1/HBox1/Existing_Events_Dropdown._set_input_value(str(selected_method_key))


func _on_cancel_button_up():
	emit_signal("input_closed")
	call_deferred("queue_free")


func get_button_method():
	var editor := EditorScript.new()
	var selection_array = editor.get_editor_interface().get_selection().get_selected_nodes()
	if selection_array.size() != 0:
		if selection_array.size() == 1:
			selected_UIButton = editor.get_editor_interface().get_selection().get_selected_nodes()[0]
			selected_method_key = selected_UIButton.selected_method_key


func _on_accept_button_up():
	selected_method_key = $PanelContainer/VBox1/HBox1/Existing_Events_Dropdown._get_input_value()
	selected_UIButton.selected_method_key = selected_method_key
	_on_cancel_button_up()
