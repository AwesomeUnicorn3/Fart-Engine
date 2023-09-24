@tool
extends InputEngine

@export var true_text :String = "True"
@export var false_text :String = "False"
@export var is_checkbox: bool = false

func _init() -> void:
	type = "4"


func _on_input_toggled(button_pressed :bool, do_not_emit_signal:bool = false):
	var button_text :String
	if button_pressed:
		button_text = true_text
	else:
		button_text = false_text
	if inputNode == null:
		await _get_input_node()
	inputNode.set_text(str(button_text))
	if !do_not_emit_signal:
		emit_signal("checkbox_pressed", button_pressed)


func _set_input_value(node_value):
	if typeof(node_value) == TYPE_STRING:
		node_value = DBENGINE.custom_to_bool(node_value)
		
	inputNode = await _get_input_node()
	inputNode.visible = true
	inputNode.button_pressed = node_value
	_on_input_toggled(node_value, true)


func _get_input_value():
	var return_value :bool
	inputNode = await _get_input_node()
	return_value = inputNode.button_pressed
	return return_value


func _get_input_node()-> Node:
	var new_node:Node

	if is_checkbox:
		new_node = $Hbox1/Background/CheckBox
		if !new_node.is_connected("pressed", on_text_changed):
			new_node.pressed.connect(on_text_changed.bind(new_node.pressed))
	else:
		new_node = await get_input_node()
	return new_node



func _on_visibility_changed():
	#only runs when testing in editor
	if Engine.is_editor_hint() and visible: #IS IN EDITOR
		$Hbox1/Background/Input.visible = false
		$Hbox1/Background/CheckBox.visible = false
		inputNode = await _get_input_node()
		var button_text :String
		if inputNode.button_pressed:
			button_text = true_text
		else:
			button_text = false_text
		
		inputNode.set_text(str(button_text))
		inputNode.visible = true
