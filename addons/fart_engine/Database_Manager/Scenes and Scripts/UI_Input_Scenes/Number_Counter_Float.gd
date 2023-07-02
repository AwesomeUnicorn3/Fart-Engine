@tool
extends InputEngine
@export var is_int: bool = false

var increment = 0.1
var num_value

func _init() -> void:
	type = "3"


func set_increment():
	if is_int:
		increment = 1.0


func _on_Add_Button_button_up():
	set_increment()
	num_value = inputNode.get_text().to_float()
	num_value += increment
	inputNode.set_text(str(num_value))
	inputNode.emit_signal("text_changed", inputNode.text)


func _on_Sub_Button_button_up():
	set_increment()
	num_value = inputNode.get_text().to_float()
	num_value -= increment
	inputNode.set_text(str(num_value))
	inputNode.emit_signal("text_changed", inputNode.text)


func _get_input_value() -> float:
	var return_value :float
	return inputNode.get_text().to_float()
	
func _set_input_value(node_value):
	inputNode.set_text(str(node_value))
