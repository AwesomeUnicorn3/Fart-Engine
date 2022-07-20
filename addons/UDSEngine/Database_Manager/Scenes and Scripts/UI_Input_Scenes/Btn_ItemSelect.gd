@tool
extends Button


func set_label_text(labelText :String):
	$Label.set_text(labelText)

func _on_TextureButton_button_up():
	var name = $Label.get_text()
	get_node("../../../../..").refresh_data(name)

