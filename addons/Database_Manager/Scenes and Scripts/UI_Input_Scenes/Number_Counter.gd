extends InputEngine
tool

export var increment = 1

var num_value

func _init() -> void:
	type = "TYPE_INT"

#func _ready():
##	inputNode = $HBox1/Input
##	labelNode = $HBox1/Label
#	type = "Number Counter"
#	default = 0

func _on_Add_Button_button_up():
	num_value = int(inputNode.get_text())
	num_value += increment
	inputNode.set_text(str(num_value))
	inputNode.emit_signal("text_changed", inputNode.text)
 
func _on_Sub_Button_button_up():
	num_value = int(inputNode.get_text())
	num_value -= increment
	inputNode.set_text(str(num_value))
	inputNode.emit_signal("text_changed", inputNode.text)
