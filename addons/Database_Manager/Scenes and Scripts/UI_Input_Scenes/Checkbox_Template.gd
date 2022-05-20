extends InputEngine
tool

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func _init() -> void:
	type = "4"
# Called when the node enters the scene tree for the first time.
#func _ready():
#	type = "Checkbox"
#	default = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func Input_toggled(button_pressed: bool) -> void:
	inputNode.set_text(str(button_pressed))
