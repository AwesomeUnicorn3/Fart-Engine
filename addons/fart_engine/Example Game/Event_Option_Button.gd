extends TextureButton

var label_text
var options_variable
var event_name



func set_input_values(btn_text:String, options_var:String, evnt_name:String):
	label_text = btn_text
	options_variable = options_var
	event_name = evnt_name
	print(label_text)
