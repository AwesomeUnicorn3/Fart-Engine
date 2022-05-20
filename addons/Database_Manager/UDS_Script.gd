tool
extends EditorPlugin

const MainPanel = preload("res://addons/Database_Manager/UDS_Main.tscn")
var main_panel_instance
var toolbar = preload("res://addons/Event_Manager/Event Tools.tscn").instance()

	
func _init():
	add_autoload_singleton('udsmain', "res://addons/UDS_Singleton.gd")
#	add_autoload_singleton('Quest', "res://addons/Quest_Manager/Quest_Scripts.gd")

	


func _enter_tree():
	main_panel_instance = MainPanel.instance()
	# Add the main panel to the editor's main viewport.
	get_editor_interface().get_editor_viewport().add_child(main_panel_instance)
#	main_panel_instance._start()
	# Hide the main panel. Very much required.
	make_visible(false)
	var icon = get_editor_interface().get_base_control().get_icon("Area2D", "EditorIcons")
	add_custom_type("Event", "Area2D", preload("res://addons/Example Game/Event.gd"), icon)
	add_control_to_container(EditorPlugin.CONTAINER_CANVAS_EDITOR_MENU, toolbar)
	toolbar.hide()
	

func _exit_tree():
	if main_panel_instance:
		main_panel_instance.queue_free()
	if toolbar:
		toolbar.queue_free()


func has_main_screen():
	return true

func get_plugin_name():
	return "AU3DB"

func get_plugin_icon():
	return get_editor_interface().get_base_control().get_icon("Node", "EditorIcons")

func make_visible(visible):
	if main_panel_instance:
		main_panel_instance.visible = visible

func refresh_data():
	get_editor_interface().get_resource_filesystem.scan()


var selected_node  = null
func _process(delta: float) -> void:
	var selected_nodes :Array = get_editor_interface().get_selection().get_selected_nodes()
	if selected_nodes.size() == 1:
#		print(selected_nodes.size())
		var current_selection :Node = selected_nodes[0]
		if !is_instance_valid(selected_node):
			selected_node = current_selection
#		print(selected_node, " ", current_selection)
		if selected_node != current_selection:
			selected_node = current_selection
#			print(current_selection.has_method("show_toolbar_in_editor"))
			if current_selection.has_method("show_toolbar_in_editor"):
				current_selection._get_property_list()
				current_selection.show_toolbar_in_editor(current_selection.name)
				toolbar.visible = true
#				print(current_selection.event_name)
#				toolbar.event_node_name = current_selection.name
#				toolbar.event_Node = selected_node
#				print(current_selection.get_parent().get_parent())
				
			else:
				toolbar.visible = false
	else:
		toolbar.visible = false
		selected_node = null
