@tool
extends Control

@onready var key_node := $Control/VBoxContainer/KeyDropdown
@onready var increase_node := $Control/VBoxContainer/TrueorFalse
@onready var how_many_node := $Control/VBoxContainer/WholeNumber

var value_node
var commandListForm :Control

var function_name :String = "modify_player_inventory" #must be name of valid function
var what :String
var how_many :String
var increase :String = "+"
var event_name :String = ""



func _ready():
	key_node.populate_list()


func set_input_values():
	pass


func _on_accept_button_up():
	#Get input values as dictionary
	what = key_node.inputNode.text
	how_many = how_many_node.inputNode.text
	increase = increase_node.inputNode.text
	event_name = commandListForm.CommandInputForm.source_node.parent_node.event_name
	var function_dict :Dictionary = {function_name : [what, how_many, increase, event_name]}
	commandListForm.CommandInputForm.function_dict = function_dict
	# {function Name : [which var, to_what]}
	#Send it all the way back to the command input form node and add it to main dictionary
	get_parent()._on_close_button_up()


func _on_cancel_button_up():
	queue_free()
