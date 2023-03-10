@tool
extends InputEngine

@export var true_text :String = "True"
@export var false_text :String = "False"

func _init() -> void:
	type = "4"


func _on_input_toggled(button_pressed :bool):
	var button_text :String
	if button_pressed:
		button_text = true_text
	else:
		button_text = false_text
	$Hbox1/Background/Input.set_text(str(button_text))
	emit_signal("checkbox_pressed", button_pressed)


func _set_input_value(node_value):
	if typeof(node_value) == TYPE_STRING:
		node_value = DBENGINE.custom_to_bool(node_value)
	if inputNode == null:
		await get_input_node()
	inputNode.button_pressed = node_value


func _get_input_value():
	var return_value :bool
	return_value = inputNode.button_pressed
	return return_value
