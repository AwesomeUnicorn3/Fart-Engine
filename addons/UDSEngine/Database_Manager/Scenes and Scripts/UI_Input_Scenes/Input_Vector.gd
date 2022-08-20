@tool
extends InputEngine

var x_label #= $HBox2/X
var x_input #= $HBox3/InputX
var y_label #= $HBox2/Y
var y_input #= $HBox3/InputY
var z_label #= $HBox2/Z
var z_input #= $HBox3/InputZ

var vector_type = "Vector2"

var omit_changed = true


func _init() -> void:
	type = "9"
	await input_load_complete
	x_label = $HBox2/X
	x_input = $HBox3/InputX
	y_label = $HBox2/Y
	y_input = $HBox3/InputY
	z_label = $HBox2/Z
	z_input = $HBox3/InputZ


func _on_Button2_button_up() -> void:
	$Hbox1/Button.disabled = false
	$Hbox1/Button2.disabled = true
	$HBox3/InputZ.visible = true
	z_label.visible = true
	vector_type = "Vector3"
	default = Vector3(0,0,0)
	inputNode.set_text(str(default))


func _on_Button_button_up() -> void:
	$Hbox1/Button.disabled = true
	$Hbox1/Button2.disabled = false
	$HBox3/InputZ.visible = false
	z_label.visible = false
	vector_type = "Vector2"
	default = Vector2(0,0)
	inputNode.set_text(str(default))


func _on_InputZ_text_changed(new_text: String) -> void:
	set_inputNode_value()

func _on_InputY_text_changed(new_text: String) -> void:
	set_inputNode_value()

func _on_InputX_text_changed(new_text: String) -> void:
	set_inputNode_value()

func set_inputNode_value():
#	var returnVector
	var xvalue = x_input.text
	var yvalue = y_input.text
	var zvalue = z_input.text
	if inputNode.get_text().count(",") == 1:
		vector_type = "Vector2"
	else:
		vector_type = "Vector3"

	match vector_type:
		"Vector2":
			var returnVector :Vector2 = Vector2(xvalue.to_float(), yvalue.to_float())
			inputNode.set_text(str(returnVector))

		"Vector3":
			var returnVector :Vector3 = Vector3(xvalue.to_float(), yvalue.to_float(), zvalue.to_float())
			inputNode.set_text(str(returnVector))
	if !omit_changed:
		inputNode.emit_signal("text_changed", inputNode.text)


func set_user_input_value():
	var DBENGINE = DatabaseEngine.new()
	var vec = inputNode.get_text()
	vec = DBENGINE.convert_string_to_vector(vec)
	
	match typeof(vec):
		TYPE_VECTOR2:
			_on_Button_button_up()
			x_input.set_text(str(vec.x))
			y_input.set_text(str(vec.y))


		TYPE_VECTOR3:
			_on_Button2_button_up()
			x_input.set_text(str(vec.x))
			y_input.set_text(str(vec.y))
			z_input.set_text(str(vec.z))
	omit_changed = false
	
