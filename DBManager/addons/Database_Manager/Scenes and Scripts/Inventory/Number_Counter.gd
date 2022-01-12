extends VBoxContainer
tool
export var increment = 1

onready var number_input = $HBoxContainer/ItemCostText
var num_value

func _on_Add_Button_button_up():
	num_value = int(number_input.get_text())
	num_value += increment
	number_input.set_text(str(num_value))


func _on_Sub_Button_button_up():
	num_value = int(number_input.get_text())
	num_value -= increment
	number_input.set_text(str(num_value))
