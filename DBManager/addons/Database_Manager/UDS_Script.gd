tool
extends EditorPlugin

const MainPanel = preload("res://addons/Database_Manager/Database Manager Main Scene.tscn")
var main_panel_instance

	
func _init():
	add_autoload_singleton('DbManager', "res://addons/Database_Manager/UDS_Singleton.gd")
	


func _enter_tree():
	
	main_panel_instance = MainPanel.instance()
	# Add the main panel to the editor's main viewport.
	get_editor_interface().get_editor_viewport().add_child(main_panel_instance)
	main_panel_instance._start()
	# Hide the main panel. Very much required.
	make_visible(false)
	

func _exit_tree():
	if main_panel_instance:
		main_panel_instance.queue_free()


func has_main_screen():
	return true

func get_plugin_name():
	return "Unicorn Database System"

func get_plugin_icon():
	return get_editor_interface().get_base_control().get_icon("Node", "EditorIcons")

func make_visible(visible):
	if main_panel_instance:
		main_panel_instance.visible = visible
