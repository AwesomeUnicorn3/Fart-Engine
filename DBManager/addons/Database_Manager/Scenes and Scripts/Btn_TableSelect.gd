extends Button
tool
func _on_button_up():
	var name = $Label.get_text()
	get_node("../../../../..").refresh_data(name)
