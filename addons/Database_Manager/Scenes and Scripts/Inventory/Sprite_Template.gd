extends "res://addons/Database_Manager/Scenes and Scripts/InputScene.gd"
tool

export var increment = 1

var num_value


func _ready():
	type = "SpriteDisplay"


func _on_TextureButton_button_up():
	var par = get_main_tab(self)
	par.get_node("Popups").visible = true
	par.get_node("Popups/FileDialog_sprite").visible = true
	par.get_node("Popups/FileDialog_sprite").set_show_hidden_files(false)
	on_text_changed(true)


func _on_Add_ButtonV_button_up() -> void:
	var numInputNode = $HBox1/VBox1/VBox1/VInput
	num_value = int(numInputNode.get_text())
	num_value += increment
	numInputNode.set_text(str(num_value))
	on_text_changed(true)


func _on_Sub_ButtonV_button_up() -> void:
	var numInputNode = $HBox1/VBox1/VBox1/VInput
	num_value = int(numInputNode.get_text())
	num_value -= increment
	numInputNode.set_text(str(num_value))
	on_text_changed(true)


func _on_Add_ButtonH_button_up() -> void:
	var numInputNode = $HBox1/VBox1/VBox1/HInput
	num_value = int(numInputNode.get_text())
	num_value += increment
	numInputNode.set_text(str(num_value))
	on_text_changed(true)


func _on_Sub_ButtonH_button_up() -> void:
	var numInputNode = $HBox1/VBox1/VBox1/HInput
	num_value = int(numInputNode.get_text())
	num_value -= increment
	numInputNode.set_text(str(num_value))
	on_text_changed(true)


func _on_HInput_text_changed(new_text: String) -> void:
	on_text_changed(true)


func _on_VInput_text_changed(new_text: String) -> void:
	on_text_changed(true)
