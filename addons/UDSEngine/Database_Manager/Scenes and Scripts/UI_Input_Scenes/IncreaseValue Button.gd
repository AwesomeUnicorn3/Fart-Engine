@tool
extends Button

signal self_pressed(increase)

@export var increase_value :bool = true



func _on_add_button_v_self_pressed():
	emit_signal("self_pressed", increase_value)
