extends Control

signal Timer_Complete
# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass


func _on_SaveButton_button_up() -> void:
	AU3ENGINE.save_game()
	$Label.visible = true
	await get_tree().create_timer(1.5).timeout
	$Label.visible = false
