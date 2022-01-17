extends "res://addons/Database_Manager/Scenes and Scripts/InputScene.gd"
tool
export var main_tab_group = "" #the main tab should be included in this group
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var texture_button = $HBoxContainer/ColorRect/TextureButton


# Called when the node enters the scene tree for the first time.
func _ready():
	type = "Icon"
	inputNode = $HBoxContainer/Input



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func get_main_tab():
	var par = get_parent()
	#Get main tab scene which should have the popup container and necessary script
	while !par.get_groups().has(main_tab_group):
		par = par.get_parent()
	return par

func _on_TextureButton_button_down():
	pass
	#$HBoxContainer/ColorRect/TextureButton.set_modulate(Color(0.3,0.3,0.3,1.0))


func _on_TextureButton_button_up():
	get_main_tab().get_node("Popups/FileDialog").visible = true
	get_main_tab().get_node("Popups/FileDialog").set_show_hidden_files(false)

	#$HBoxContainer/ColorRect/TextureButton.set_modulate(Color(1.0,1.0,1.0,1.0))
