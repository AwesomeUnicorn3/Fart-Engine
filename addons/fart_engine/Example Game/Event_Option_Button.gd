extends TextureButton

var label_text
var options_variable
var event_name


@onready var label_node = $Label



func set_input_values(btn_text:String, options_var:String, evnt_name:String):
	label_text = btn_text
	options_variable = options_var
	event_name = evnt_name
	label_node.parse_bbcode("[center]" + label_text)
	print(label_text)


func _on_button_button_up():
	pass # Replace with function body.
