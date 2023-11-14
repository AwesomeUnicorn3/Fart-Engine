@tool
extends FartDatatype

var increment = 1
var num_value

func _init() -> void:
	type = "2"

#func _ready():
#	inputNode = $HBox1/Input
#	labelNode = $Label/HBox1/Label_Button
#	type = "Number Counter"
#	default = 0

func _on_Add_Button_button_up():
	num_value = float(inputNode.get_text())
	num_value += increment
	inputNode.set_text(str(num_value))
	#inputNode.emit_signal("text_changed", inputNode.text)
 
func _on_Sub_Button_button_up():
	num_value = float(inputNode.get_text())
	num_value -= increment
	inputNode.set_text(str(num_value))
	#inputNode.emit_signal("text_changed", inputNode.text)


func _get_input_value():
#	var return_value :int
	var return_value = float(inputNode.get_text())
	return return_value
	
func _set_input_value(node_value):
	inputNode.set_text(str_to_var(node_value))

