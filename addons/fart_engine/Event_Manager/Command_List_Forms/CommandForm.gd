@tool
extends DatabaseManager
class_name CommandForm

var edit_state :bool = false
var commandListForm :Control
var function_dict :Dictionary




func _on_cancel_button_up():
	if edit_state:
		get_parent()._on_close_button_up()
	else:
		queue_free()
