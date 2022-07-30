@tool
extends Button

signal btn_pressed(btn_name:String)
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_command_list_button_button_up():
	emit_signal("btn_pressed", str(name))

