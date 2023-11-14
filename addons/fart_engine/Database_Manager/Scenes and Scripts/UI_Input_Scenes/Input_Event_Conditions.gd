@tool
extends FartDatatype

var omit_changed = true
var main_dictionary : Dictionary = {}
@onready var input_form = preload("res://addons/fart_engine/Event_Manager/Condition_input_form.tscn")


func _init() -> void:
	type = "14"


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
#	inputForm.mainDictionary = main_dictionary
	inputForm.par_node = main_node_for_dict_form
	inputForm.source_node = self
	inputForm.get_node("VBox1/HBox1/Label").set_text(labelNode.get_text())
#	inputForm.local_variable_dictionary = parent_node.get_local_variables()
	inputForm.set_input_values(main_dictionary)
	await inputForm.save_complete
	parent_node.popup_main.visible = false
	main_dictionary = inputForm.get_input_values()
	set_text_display()


func _on_text_changed():
	pass

func set_text_display():
	get_input_node()
	inputNode.set_text(var_to_str(main_dictionary))

func _get_input_value() -> Dictionary:
	var return_value :Dictionary
	return_value = main_dictionary
	
	return return_value
	
func _set_input_value(node_value):
	if typeof(node_value) == TYPE_STRING:
		node_value = str_to_var(node_value)
	main_dictionary = node_value
#	inputNode.set_text(str(node_value))
	set_text_display()
