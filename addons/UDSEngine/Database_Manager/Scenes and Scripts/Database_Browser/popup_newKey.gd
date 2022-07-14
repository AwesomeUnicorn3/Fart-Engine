@tool
extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_popup_newKey_visibility_changed():
	if visible:
		$PanelContainer/VBox1/HBox1/VBox2/ItemType_Selection.populate_list()
