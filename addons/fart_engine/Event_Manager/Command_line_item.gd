@tool
extends CommandManager

var line_item_dictionary :Dictionary = {}


@onready var Key_field := $Key
@onready var script_input := $ScriptInput

var key_index :String


func _on_DeleteButton_button_up() -> void:
	key_index = Key_field.inputNode.text
	_delete_selected_list_item(key_index)


func _on_command_up_button_up():
	key_index = Key_field.inputNode.text
	parent_node.emit_signal("rearrange_commands", key_index, -1)


func _on_command_down_button_up():
	key_index = Key_field.inputNode.text
	parent_node.emit_signal("rearrange_commands", key_index, 1)



func _on_edit_command_button_up():
	key_index = Key_field.inputNode.text
	parent_node.emit_signal("edit_command", key_index)
