@tool
extends EditorPlugin

const MainPanel = preload("res://addons/UDSEngine/UDS_Main.tscn")
var main_panel_instance
var toolbar = preload("res://addons/UDSEngine/Event_Manager/Event Tools.tscn").instantiate()

	
#func _init():
#	add_autoload_singleton('udsmain', "res://addons/UDS_Singleton.gd")
#	add_autoload_singleton('Quest', "res://addons/Quest_Manager/Quest_Scripts.gd")

	


func _enter_tree():
	print("Plugin Has Entered the Chat")
	main_panel_instance = MainPanel.instantiate()
	main_panel_instance.set_name("MainPanel")
	# Add the main panel to the editor's main viewport.
	get_editor_interface().get_editor_main_control().add_child(main_panel_instance)
	var mainPanel = get_editor_interface().get_editor_main_control().get_node("MainPanel")

# Hide the main panel. Very much required.
	_make_visible(false)

	var icon = get_editor_interface().get_base_control().get_theme_icon("Node", "EditorIcons")
	add_custom_type("Event", "Area2D", preload("res://addons/UDSEngine/Example Game/Event.gd"), icon)

	
	add_custom_type("Map", "Node", preload("res://addons/UDSEngine/Example Game/Event.gd"), icon)

	add_control_to_container(EditorPlugin.CONTAINER_CANVAS_EDITOR_MENU, toolbar)
	toolbar.visible = false
	

func _exit_tree():
	if main_panel_instance:
		main_panel_instance.queue_free()
	if toolbar:
		toolbar.queue_free()

func _has_main_screen():
	return true

func _get_plugin_name():
	return "UDS Engine"

func _get_plugin_icon():
	return get_editor_interface().get_base_control().get_theme_icon("Node", "EditorIcons")

func _make_visible(visible):
	if main_panel_instance:
		main_panel_instance.visible = visible

func _refresh_data():
	get_editor_interface().get_resource_filesystem().scan()


var selected_node  = null
func _process(delta: float) -> void:
	var selected_nodes :Array = get_editor_interface().get_selection().get_selected_nodes()
	if selected_nodes.size() == 1:
		var current_selection :Node = selected_nodes[0]
		if !is_instance_valid(selected_node):
			selected_node = current_selection
		if selected_node != current_selection:
			selected_node = current_selection
			if current_selection.has_method("show_toolbar_in_editor"):
				current_selection._get_property_list()
				current_selection.show_toolbar_in_editor(current_selection.name)
				toolbar.visible = true
#				toolbar.event_node_name = current_selection.name
#				toolbar.event_Node = selected_node
				
			else:
				toolbar.visible = false
	else:
		toolbar.visible = false
		selected_node = null
