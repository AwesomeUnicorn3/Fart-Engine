@tool
extends Control

@onready var selection_node = $Control/VBoxContainer/ItemType_Selection
@onready var value_node = $Control/VBoxContainer/Checkbox_Template

var commandListForm :Control

var function_name :String = "change_local_variable" #must be name of valid function
var which_var :String
var to_what :String
var event_name :String = ""
#in udsmain (UDS_Singleton) script
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func set_input_values():
	pass


func _on_accept_button_up():
	#Get input values as dictionary
	which_var = selection_node.inputNode.text
	to_what = value_node.inputNode.text
	event_name = commandListForm.CommandInputForm.source_node.parent_node.event_name
	var function_dict :Dictionary = {function_name : [which_var, to_what, event_name]}
	commandListForm.CommandInputForm.function_dict = function_dict
	# {function Name : [which var, to_what]}
	#Send it all the way back to the command input form node and add it to main dictionary
	get_parent()._on_close_button_up()


func _on_cancel_button_up():
	queue_free()
