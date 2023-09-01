extends Control

@onready var loadFileSelect : Resource = load("res://addons/fart_engine/Example Game/LoadFileSelect.tscn")
@onready var file_list_container := $VBox1/Scroll1/VBox1

var save_files_arr: Array =[]

func _ready() -> void:
	
	save_files_arr = FART.get_save_files()
	for i in save_files_arr:
		var save_file_dict : Dictionary = FART.load_save_file(i)
		var loadFileSelect_new :Node = loadFileSelect.instantiate()
		loadFileSelect_new.get_node("Load").set_text("Load File " + i)
#		var map_path
		var map_path : String = FART.get_text(save_file_dict["Global Data"][await FART.get_global_settings_profile()]["Current Map"])
		
		loadFileSelect_new.file_name = i
		loadFileSelect_new.parent_container = self
		loadFileSelect_new.get_node("ColorRect/VBoxContainer/MapNameInput").set_text(await FART.get_map_name(map_path))
		
		file_list_container.add_child(loadFileSelect_new)


func _on_ReturnToTitle_button_up() -> void:
	FART.set_game_state("1")
#	remove_load_menu()

func remove_load_menu():
	queue_free()

func clear_save_file_list():
	for i in file_list_container.get_children():
		i.queue_free()


func _on_visibility_changed():
	if visible:
		for file in file_list_container.get_children():
			file.queue_free()
		_ready()
		
