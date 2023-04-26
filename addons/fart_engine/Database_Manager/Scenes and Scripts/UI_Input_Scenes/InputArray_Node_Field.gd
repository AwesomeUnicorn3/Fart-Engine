@tool
extends HBoxContainer
signal array_item_delete


func _on_button_button_up():
	
	emit_signal("array_item_delete", self.name)
