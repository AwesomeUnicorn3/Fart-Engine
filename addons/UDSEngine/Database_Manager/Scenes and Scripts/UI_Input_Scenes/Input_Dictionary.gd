@tool
extends InputEngine

var omit_changed = true
var main_dictionary : Dictionary = {}
@onready var input_form = load("res://addons/UDSEngine/Database_Manager/Scenes and Scripts/UI_Input_Scenes/DictionaryInput_Form.tscn")



func _init() -> void:
	type = "10"
	

func temp():
	pass

func set_inputValue():
	pass


func _on_Add_New_Item_button_up() -> void:
	var main_node_for_dict_form : Node = parent_node.popup_main.get_node("ListInput")
	var inputForm = input_form.instantiate()
	on_text_changed()
	parent_node.popup_main.visible = true
	inputForm = parent_node.add_input_field(main_node_for_dict_form, input_form)
	inputForm.mainDictionary = main_dictionary
	inputForm.parent_node = main_node_for_dict_form
	inputForm.source_node = self
	inputForm.get_node("VBox1/HBox1/Label").set_text(labelNode.get_text())
	inputForm.create_input_fields()


func _on_text_changed():
	pass


func _get_input_value():
	return var_to_str(main_dictionary)

func _set_input_value(node_value):

	if str(node_value) == "Default":
		node_value = DBENGINE.convert_string_to_type(default)
	if typeof(node_value) == TYPE_STRING:
		node_value = str_to_var(node_value)
	main_dictionary = node_value
	inputNode.set_text(str(node_value))
