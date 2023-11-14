@tool
extends Control

#var par
var event_page_number :String = ""
# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func set_disabled(value: bool):
	$"Navigation Button".disabled = value
	$"Navigation Button".reset_self_modulate()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
func set_label(text: String):
	#print("TEXT VALUE FOR SET LABEL: ", text)
	$"Navigation Button".set_text_value(text)

func on_Button_button_up() -> void:
	get_node("../../..").enable_all_page_buttons()
	get_node("../../..").on_page_button_pressed(event_page_number)
#	$"Navigation Button".grab_focus()
	$"Navigation Button".set_disabled(true)
	$"Navigation Button".reset_self_modulate()
