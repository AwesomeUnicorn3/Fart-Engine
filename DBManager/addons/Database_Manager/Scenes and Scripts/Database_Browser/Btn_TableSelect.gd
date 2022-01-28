extends Button
tool


func _on_TextureButton_button_up():
	var name = $Label.get_text()
	get_node("../../../../..").refresh_table_data(name)
