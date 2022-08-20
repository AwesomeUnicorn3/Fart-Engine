@tool
extends Control

@onready var float_node = $Control/VBoxContainer/Number_Counter_Float


var commandListForm :Control

var function_name :String = "wait" #must be name of valid function
var how_long :String
var event_name :String = ""


func set_input_values():
	pass


func _on_accept_button_up():
	#Get input values as dictionary
	how_long = float_node.inputNode.text
	event_name = commandListForm.CommandInputForm.source_node.parent_node.event_name
	var function_dict :Dictionary = {function_name : [how_long, event_name]}
	commandListForm.CommandInputForm.function_dict = function_dict
	#Send it all the way back to the command input form node and add it to main dictionary
	get_parent()._on_close_button_up()


func _on_cancel_button_up():
	queue_free()
