extends ColorRect
tool

# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$FileSelectDialog.visible = true


func _on_FileSelectDialog_hide() -> void:
	queue_free()
