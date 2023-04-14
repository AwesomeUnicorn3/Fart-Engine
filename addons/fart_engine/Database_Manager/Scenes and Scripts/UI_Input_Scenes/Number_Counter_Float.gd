@tool
extends InputEngine

var increment = 0.1
var num_value

func _init() -> void:
	type = "3"

#func _ready():
#	inputNode = $HBox1/Input
#	labelNode = $Label/HBox1/Label_Button

func _on_Add_Button_button_up():
	num_value = inputNode.get_text().to_float()
	num_value += increment
	inputNode.set_text(str(num_value))
	inputNode.emit_signal("text_changed", inputNode.text)


func _on_Sub_Button_button_up():
	num_value = inputNode.get_text().to_float()
	num_value -= increment
	inputNode.set_text(str(num_value))
	inputNode.emit_signal("text_changed", inputNode.text)


func _get_input_value() -> float:
	var return_value :float
	return_value = inputNode.get_text().to_float()
	return return_value
	
func _set_input_value(node_value):
	get_input_node()
	inputNode.set_text(str(node_value))