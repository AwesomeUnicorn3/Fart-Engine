@tool
extends InputEngine

var omit_changed = true
var main_dictionary : Dictionary = {}
@onready var input_form = load("res://addons/UDSEngine/Database_Manager/Scenes and Scripts/UI_Input_Scenes/DictionaryInput_Form.tscn")



func _init() -> void:
	type = "10"
	

#func _ready():
#	default = var2str(default)
#	inputNode = $HBoxContainer/Input
#	labelNode = $Label/HBox1/Label_Button
	

func temp():
	pass

func set_inputValue():
	pass


func _on_Add_New_Item_button_up() -> void:
	var main_node_for_dict_form : Node = parent_node.popup_main.get_node("ListInput")
	var inputForm = input_form.instantiate()
	on_text_changed()
	parent_node.popup_main.visible = true
#	parent_node.popup_main.get_node("ListInput").visible = true
	inputForm = parent_node.add_input_field(main_node_for_dict_form, input_form)
#	print(inputForm.mainDictionary)
	inputForm.mainDictionary = main_dictionary
	inputForm.parent_node = main_node_for_dict_form
	inputForm.source_node = self
	inputForm.get_node("VBox1/HBox1/Label").set_text(labelNode.get_text())
	inputForm.create_input_fields()


func _on_text_changed():
	pass
