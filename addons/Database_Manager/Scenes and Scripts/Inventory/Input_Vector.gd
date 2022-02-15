extends "res://addons/Database_Manager/Scenes and Scripts/InputScene.gd"
tool

onready var x_label = $HBox2/X
onready var x_input = $HBox3/InputX
onready var y_label = $HBox2/Y
onready var y_input = $HBox3/InputY
onready var z_label = $HBox2/Z
onready var z_input = $HBox3/InputZ

var vector_type = "Vector2"

var omit_changed = true

func _ready():
	type = "Vector"
	default = ""

func temp():
	pass

func _on_Button2_button_up() -> void:
	$Hbox1/Button.disabled = false
	$Hbox1/Button2.disabled = true
	$HBox3/InputZ.visible = true
	z_label.visible = true
	vector_type = "Vector3"

	set_inputValue()


func _on_Button_button_up() -> void:
	$Hbox1/Button.disabled = true
	$Hbox1/Button2.disabled = false
	$HBox3/InputZ.visible = false
	z_label.visible = false
	vector_type = "Vector2"
	set_inputValue()


func _on_InputZ_text_changed(new_text: String) -> void:
	set_inputValue()


func _on_InputY_text_changed(new_text: String) -> void:
	set_inputValue()


func _on_InputX_text_changed(new_text: String) -> void:
	set_inputValue()

func set_inputValue():
	var xvalue = x_input.text
	var yvalue = y_input.text
	var zvalue = z_input.text

	match vector_type:
		"Vector2":
			var vec2 = Vector2(xvalue, yvalue)
			inputNode.set_text(str(vec2))
		"Vector3":
			var vec3 = Vector3(xvalue, yvalue, zvalue)
			inputNode.set_text(str(vec3))
	if !omit_changed:
		inputNode.emit_signal("text_changed", inputNode.text)



func get_inputValue():
	var xvalue = x_input.text
	var yvalue = y_input.text
	var zvalue = z_input.text

	var vec = inputNode.get_text()
	vec = get_main_tab(get_parent()).convert_string_to_Vector(vec)
	
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



