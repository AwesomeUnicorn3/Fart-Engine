extends Button
tool
#var par
var event_page_number = ""
# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass


func on_Button_button_up() -> void:
	get_node("../../../..").enable_all_page_buttons()
	get_node("../../../..").on_page_button_pressed(event_page_number)
	grab_focus()
	set_disabled(true)
