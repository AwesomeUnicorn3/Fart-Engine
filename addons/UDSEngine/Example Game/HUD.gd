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
	udsmain.save_game()
	$Label.visible = true
	timer(1.5)
	await Timer_Complete
	$Label.visible = false


func timer(wait_time : float = 1.0):
	var t = Timer.new()
	t.set_one_shot(true)
	self.add_child(t)
	t.set_wait_time(.5)
	t.start()
	await t.timeout
	t.queue_free()
	emit_signal("Timer_Complete")
