@tool
extends Control

@onready var text_node = $Control/VBoxContainer/Input_Text


var commandListForm :Control

var function_name :String = "print_to_console" #must be name of valid function
var text_input :String
var event_name :String = ""


func set_input_values():
	pass


func _on_accept_button_up():
	#Get input values as dictionary
	text_input = text_node.inputNode.text
	event_name = commandListForm.CommandInputForm.source_node.parent_node.event_name
	var function_dict :Dictionary = {function_name : [text_input, event_name]}
	commandListForm.CommandInputForm.function_dict = function_dict
	#Send it all the way back to the command input form node and add it to main dictionary
	get_parent()._on_close_button_up()


func _on_cancel_button_up():
	queue_free()
