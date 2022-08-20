@tool
extends InputEngine

@export var true_text :String = "True"
@export var false_text :String = "False"
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func _init() -> void:
	type = "4"
# Called when the node enters the scene tree for the first time.
#func _ready():
#	inputNode = $Hbox1/Background/Input
#	labelNode = $Label/HBox1/Label_Button


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func Input_toggled(button_pressed: bool) -> void:
	var button_text :String
	if button_pressed:
		button_text = true_text
	else:
		button_text = false_text
		
	inputNode.set_text(str(button_text))
