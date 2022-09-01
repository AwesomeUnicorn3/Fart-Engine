@tool
extends InputEngine

var omit_changed = true
var main_dictionary : Dictionary = {}
@onready var input_form = load("res://addons/UDSEngine/Event_Manager/Command_input_form.tscn")

var local_variable_dictionary :Dictionary

func _init() -> void:
	type = "15"

func temp():
	pass

func set_inputValue():
	pass


func _on_Add_New_Item_button_up() -> void:
	var main_node_for_dict_form : Node = null
	var root_node = parent_node.get_main_node(parent_node)

	if root_node.name == "root":
		main_node_for_dict_form = parent_node.popup_main.get_node("ListInput")
	else:
		main_node_for_dict_form = parent_node.get_main_node(parent_node)

	var inputForm = input_form.instantiate()
	on_text_changed()
	parent_node.popup_main.visible = true
	var local_var :Dictionary = parent_node.get_local_variables()
	inputForm = parent_node.add_input_field(main_node_for_dict_form, input_form)
	inputForm.startup(local_var, main_dictionary, labelNode.get_text(), self)
	await inputForm.save_complete
	parent_node.popup_main.visible = false

func _on_text_changed():
	pass
