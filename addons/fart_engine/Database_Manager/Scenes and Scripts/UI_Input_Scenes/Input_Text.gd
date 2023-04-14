@tool
extends InputEngine

func _init() -> void:
	type = "1"

#func startup():
#	inputNode = $Input
#	labelNode = $Label/HBox1/Label_Button
	


func _set_input_value(node_value):
	if typeof(node_value) == 4:
		node_value = str_to_var(node_value)
	input_data = node_value
	var text :String = input_data["text"]
	$Input.set_text(text)


func _get_input_value():
	var text_dict :Dictionary
	var text_input :String = $Input.text
	text_dict["text"] = text_input
	return text_dict

