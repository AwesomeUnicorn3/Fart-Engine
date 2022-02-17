extends InputEngine
tool

var increment = 0.1

var num_value

func _ready():
	type = "Number Counter"
	default  = 0.0

func _on_Add_Button_button_up():
	num_value = float(inputNode.get_text())
	num_value += increment
	inputNode.set_text(str(num_value))
	inputNode.emit_signal("text_changed", inputNode.text)


func _on_Sub_Button_button_up():
	num_value = float(inputNode.get_text())
	num_value -= increment
	inputNode.set_text(str(num_value))
	inputNode.emit_signal("text_changed", inputNode.text)
