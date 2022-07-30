@tool
extends DatabaseEngine

var parent_node : Object
var line_item_dictionary :Dictionary = {}
var CommandInputForm

@onready var Key_field := $Key
@onready var script_input := $ScriptInput


func _on_DeleteButton_button_up() -> void:
	var keyValue = Key_field.inputNode.text
	parent_node._delete_selected_list_item(keyValue)


func _on_command_up_button_up():
	pass # Replace with function body.


func _on_command_down_button_up():
	pass # Replace with function body.


func _on_edit_command_button_up():
	#open LocalVariables_EventInputForm directly from here
	#add it as a child of "List_Input"
	#assign the local variable dict to "selection_node"
	#populate list on selection_node
	#call set_input_values() 
	pass # Replace with function body.
