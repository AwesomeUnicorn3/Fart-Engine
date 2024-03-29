@tool
extends FartDatatype

@onready var input_form = preload("res://addons/fart_engine/Event_Manager/Command_input_form.tscn")

var omit_changed = true
var main_dictionary : Dictionary = {}
var local_variable_dictionary :Dictionary


func _init() -> void:
	type = "15"


func temp():
	pass


func set_inputValue():
	pass


func _on_Add_New_Item_button_up() -> void:
	var main_node_for_dict_form : Node = null
	var root_node = fart_root
	if root_node.name == "root":
		main_node_for_dict_form = parent_node.popup_main.get_node("ListInput")
	else:
		main_node_for_dict_form = fart_root
	var inputForm = input_form.instantiate()
	on_text_changed()
	parent_node.popup_main.visible = true
	inputForm = parent_node.add_input_field(main_node_for_dict_form, input_form)
	inputForm.startup(main_dictionary, labelNode.get_text(), self)
	await inputForm.save_complete
	parent_node.popup_main.visible = false


func _on_text_changed():
	pass


func _get_input_value() -> Dictionary:
	var return_value :Dictionary
	return_value = main_dictionary
	return return_value


func _set_input_value(node_value):
	get_input_node()
	if typeof(node_value) == TYPE_STRING:
		node_value = str_to_var(node_value)
	main_dictionary = node_value
	inputNode.set_text(str(node_value))
