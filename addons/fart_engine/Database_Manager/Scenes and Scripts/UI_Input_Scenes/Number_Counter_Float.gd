@tool
extends FartDatatype
@export var is_int: bool = false
@export var can_be_negative:bool = true


var increment = 0.1
var num_value
var is_new_decimal:bool

func _init() -> void:
	type = "3"


#func startup():
#	print("NUMBER INPUT STARTUP BEGIN")
#	inputNode = $HBox1/Input
#	labelNode = $Label

func set_increment():
	if is_int:
		increment = 1.0


func _on_Add_Button_button_up():
	set_increment()
	num_value = float(inputNode.get_text())
	num_value += increment
#	inputNode.set_text(num_value)
	update_text()


func _on_Sub_Button_button_up():
	set_increment()
	num_value = float(inputNode.get_text())
	num_value -= increment
#	inputNode.set_text(num_value)
	update_text()



func _get_input_value():
	#print("GET INPUT VALUE NUMBER COUNTER: ", num_value)
	return num_value


func _set_input_value(node_value: String):
	num_value = float(node_value)
	$HBox1/Input.set_text(node_value)

func _on_input_text_changed(new_text:String):
	if !is_updating_text:
#		print("NEW TEXT: ", new_text)
		num_value = new_text.to_float()
		if new_text.right(1) == "." and !is_int:
			is_new_decimal = true
#		print("NUM VALUE: ", num_value)
		#update_text()



var is_updating_text:bool = false

func update_text():
	var caret_position: int = 0
	if !can_be_negative:
		print("CANNOT BE NEGATIVE")
		num_value = abs(num_value)
	
	caret_position = inputNode.get_caret_column()
	
	is_updating_text = true
	if is_int:
		num_value = roundi(num_value)

#	var text_string:String = ""
#	if is_new_decimal:
#		text_string = str(num_value) + ".0"
#		is_new_decimal = false
#	else:
#		text_string = str(num_value)
#
#	if text_string == "0" :
#		text_string = ""
#
#	if text_string == "-0":
#		text_string = "-"


	inputNode.set_text(str(num_value))
	inputNode.caret_column = caret_position

	is_updating_text = false
