extends InputEngine
tool

var omit_changed = true
var main_dictionary : Dictionary = {}
onready var input_form = load("res://addons/Database_Manager/Scenes and Scripts/UI_Input_Scenes/DictionaryInput_Form.tscn")
var def_dict : Dictionary = {
"1": {
"Datatype 1": "TYPE_STRING",
"Datatype 2": "TYPE_INT",
"TableName 1" : "DataTypes",
"TableName 2" : "DataTypes",
"Value 1": "Default Value1",
"Value 2": "1"
}
}


func _ready():
	type = "Dictionary"
	default = var2str(def_dict)
	inputNode.set_text(default)
	

func temp():
	pass

func set_inputValue():
	pass


func _on_Add_New_Item_button_up() -> void:
	var main_node_for_dict_form : Node = parent_node.popup_main.get_node("ListInput")
	var inputForm = input_form.instance()
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
