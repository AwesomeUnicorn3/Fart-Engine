@tool
extends InputEngine


func _init() -> void:
	type = "3"


func _get_input_value() -> String:
	var return_value :String
	return_value = inputNode.get_text()
	
	return return_value


func _set_input_value(node_value):
#	print(var_to_str(node_value))
	var selected_color: Color = node_value
#	inputNode.set_text(str(node_value))
	$HBoxContainer/OpenScene.set_pick_color(node_value)
	$HBoxContainer/OpenScene.emit_signal("color_changed", node_value)
	




func _on_open_scene_color_changed(color):
	$HBoxContainer/HBox3/InputR.set_text(str(color.r))
	$HBoxContainer/HBox3/InputG.set_text(str(color.g))
	$HBoxContainer/HBox3/InputB.set_text(str(color.b))
	$HBoxContainer/HBox3/InputA.set_text(str(color.a))
	inputNode.set_text(var_to_str(color))
#	print(var_to_str(color))


#func _on_open_scene_button_up():
#	var picker_popup = $HBoxContainer/OpenScene.get_picker()
#	picker_popup.color_changed.connect(_on_open_scene_color_changed)
#
#
#func _on_open_scene_popup_closed():
#	var picker_popup = $HBoxContainer/OpenScene.get_picker()
#	picker_popup.color_changed.disconnect(_on_open_scene_color_changed)
