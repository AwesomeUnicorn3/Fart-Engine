@tool
extends Button



func _on_TextureButton_button_up():
	var name = $Label.get_text()
#	disabled = true
	get_node("../../../../..").refresh_data(name)
#	print(name + " Pressed Is " + str(disabled))
