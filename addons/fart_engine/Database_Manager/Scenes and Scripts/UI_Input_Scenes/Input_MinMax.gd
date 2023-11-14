@tool
extends FartDatatype

var x_label #= $HBox2/X
var x_input #= $HBox3/InputX
var y_label #= $HBox2/Y
var y_input #= $HBox3/InputY
var z_label #= $HBox2/Z
var z_input #= $HBox3/InputZ
var vector_type = "Vector3"
var omit_changed = true


func _init() -> void:
	type = "12"
	await input_load_complete
	x_label = $HBox2/X
	x_input = $HBox3/InputX
	y_label = $HBox2/Y
	y_input = $HBox3/InputY
	z_label = $HBox2/Z
	z_input = $HBox3/InputZ


func _on_InputZ_text_changed(new_text: String) -> void:
	set_inputNode_value()


func _on_InputY_text_changed(new_text: String) -> void:
	set_inputNode_value()


func _on_InputX_text_changed(new_text: String) -> void:
	set_inputNode_value()


func set_inputNode_value():
	var returnVector
	var xvalue = x_input.text.to_int()
	var yvalue = y_input.text.to_int()
	var zvalue = z_input.text.to_int()
	vector_type = "Vector3"
	if yvalue > zvalue:
		yvalue = zvalue
		y_input.set_text(str(yvalue))
	if yvalue < xvalue:
		yvalue = xvalue
		y_input.set_text(str(yvalue))
	
	returnVector = Vector3(xvalue, yvalue, zvalue)
	inputNode.set_text(str(returnVector))
	if !omit_changed:
		inputNode.emit_signal("text_changed", inputNode.text)


func set_user_input_value():
	var vec = inputNode.get_text()
	vec = get_main_tab(get_parent()).convert_string_to_vector(vec)
	x_input.set_text(str(vec.x))
	y_input.set_text(str(vec.y))
	z_input.set_text(str(vec.z))
	omit_changed = false


func _get_input_value() -> String:
	var return_value :String
	return_value = inputNode.get_text()
	return return_value


func _set_input_value(node_value):
	inputNode.set_text(str(node_value))
	set_user_input_value()
	set_inputNode_value()
