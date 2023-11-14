@tool
extends FartDatatype

var selected_color: Color

func _init() -> void:
	type = "3"


func _get_input_value() -> Color:
	
	#var return_value :Color = selected_color
#	print("GET VALUE: ", return_value)
	return selected_color


func _set_input_value(node_value):
	#print("NODE VALUE: ",node_value)
	#var selected_color:Color = 
	#print("SELECTED COLOR: ", selected_color)
#	inputNode.set_text(str(node_value))
	_on_open_scene_color_changed(str_to_var(node_value))
	#$HBoxContainer/OpenScene.emit_signal("color_changed", selected_color)


func _on_open_scene_color_changed(color:Color):
	#print("COLOR : ", color)
	var snap_step: float = 0.01
	$HBoxContainer/OpenScene.set_pick_color(color)
	color.r = snapped(color.r, snap_step)
	color.g = snapped(color.g, snap_step)
	color.b = snapped(color.b, snap_step)
	color.a = snapped(color.a, snap_step)
	
#	$HBoxContainer/HBox3/InputR.set_text(str(color.r))
#	$HBoxContainer/HBox3/InputG.set_text(str(color.g))
#	$HBoxContainer/HBox3/InputB.set_text(str(color.b))
#	$HBoxContainer/HBox3/InputA.set_text(str(color.a))
	inputNode.set_text(var_to_str(color))
	selected_color = color
	#print("COLOR CHANGED TO VALUE: ", var_to_str(color))


#func _on_open_scene_button_up():
#	var picker_popup = $HBoxContainer/OpenScene.get_picker()
#	picker_popup.color_changed.connect(_on_open_scene_color_changed)
#
#
#func _on_open_scene_popup_closed():
#	var picker_popup = $HBoxContainer/OpenScene.get_picker()
#	picker_popup.color_changed.disconnect(_on_open_scene_color_changed)
