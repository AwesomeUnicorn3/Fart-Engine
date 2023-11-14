@tool
extends FartDatatype

var input_vector:Vector3 = Vector3(0,0,0)

func _init() -> void:
	type = "9"


func _get_input_value():
	#var return_value :Vector3
#	return_value = inputNode.get_text_value()
	input_vector.x = $HBox3/InputX.get_input_value()
	input_vector.y = $HBox3/InputY.get_input_value()
	input_vector.z = $HBox3/InputZ.get_input_value()
	#print("INPUT VECTOR: ", input_vector)
	return input_vector


func _set_input_value(node_value:String):
	input_vector = str_to_var(node_value)
	#print("INPUT VECTOR: ", input_vector)
	#print("INPUT VECTOR Y: ", var_to_str(input_vector.y))
	$HBox3/InputX.set_input_value(var_to_str(input_vector.x))
	$HBox3/InputY.set_input_value(var_to_str(input_vector.y))
	$HBox3/InputZ.set_input_value(var_to_str(input_vector.z))
