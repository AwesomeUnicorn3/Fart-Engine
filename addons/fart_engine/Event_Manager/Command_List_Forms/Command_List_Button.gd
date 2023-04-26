@tool
extends Button

signal btn_pressed(btn_name:String)



func _on_command_list_button_button_up():
	emit_signal("btn_pressed", str(name))

