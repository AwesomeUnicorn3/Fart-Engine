@tool
extends EditorPlugin

const MainPanel = preload("res://addons/fart_engine/fart_main.tscn")
var main_panel_instance
var toolbar = preload("res://addons/fart_engine/Event_Manager/Event_Tools.tscn").instantiate()


func _init():
	add_autoload_singleton("FARTENGINE", "res://addons/fart_engine/fart_singleton.gd")
#	add_autoload_singleton('Quest', "res://addons/Quest_Manager/Quest_Scripts.gd")


func _enter_tree():
	print("Plugin Has Entered the Chat")
	main_panel_instance = MainPanel.instantiate()
	main_panel_instance.set_name("FART ENGINE")
	# Add the main panel to the editor's main viewport.
	get_editor_interface().get_editor_main_screen().add_child(main_panel_instance)
	var mainPanel = get_editor_interface().get_editor_main_screen().get_node("FART ENGINE")
# Hide the main panel. Very much required.
	print("Main Panel added")
	_make_visible(false)
	add_custom_types()
	
	add_control_to_container(CONTAINER_CANVAS_EDITOR_MENU, toolbar)
	
	connect_singals()
	print("Signals Connected")
	toolbar.visible = false


func _exit_tree():
	if main_panel_instance:
		main_panel_instance.queue_free()
	if toolbar:
		toolbar.queue_free()

func add_custom_types():
	var icon =preload("res://addons/fart_engine/Editor_Icons/FartEngineIcon.png") #get_editor_interface().get_base_control().get_theme_icon("CharacterBody2D", "EditorIcons")
	add_custom_type("Fart Event", "CharacterBody2D", preload("res://addons/fart_engine/Example Game/Event.gd"), icon)
	add_custom_type("Fart UI Button", "TextureButton", preload("res://addons/fart_engine/UI_Manager/au3_ui_button.gd"), icon)
	add_custom_type("Fart Data Display", "Control", preload("res://addons/fart_engine/Fart_Custom_Nodes/Fart_Data_Display.gd"), icon)
	

func _has_main_screen():
	return true



func _get_plugin_name():
	return "FART ENGINE"


func _get_plugin_icon():
	return preload("res://addons/fart_engine/Editor_Icons/FartEngineIcon.png")
#	return get_editor_interface().get_base_control().get_theme_icon("Node", "EditorIcons")


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
			if current_selection.has_method("show_event_toolbar_in_editor"):
				current_selection.show_event_toolbar_in_editor(current_selection.name)
				toolbar.event_Node = current_selection
				toolbar.visible = true
				toolbar.get_node("HBoxContainer/Edit_Event_Button").visible = true
				toolbar.get_node("HBoxContainer/Assign_Function").visible = false
				toolbar.get_node("HBoxContainer/Edit_Data_Display").visible = false
				
			elif current_selection.has_method("show_UIMethod_selection_in_editor"):
				toolbar.visible = true
				toolbar.get_node("HBoxContainer/Assign_Function").visible = true
				toolbar.get_node("HBoxContainer/Edit_Event_Button").visible = false
				toolbar.get_node("HBoxContainer/Edit_Data_Display").visible = false
				
			elif current_selection.has_method("data_display"):
				toolbar.visible = true
				toolbar.get_node("HBoxContainer/Edit_Data_Display").visible = true
				toolbar.get_node("HBoxContainer/Edit_Event_Button").visible = false
				toolbar.get_node("HBoxContainer/Assign_Function").visible = false
			else:
				toolbar.get_node("HBoxContainer/Edit_Event_Button").visible = false
				toolbar.get_node("HBoxContainer/Assign_Function").visible = false
				toolbar.get_node("HBoxContainer/Edit_Data_Display").visible = false

				toolbar.visible = false
	else:
		toolbar.visible = false
		toolbar.get_node("HBoxContainer/Edit_Event_Button").visible = false
		toolbar.get_node("HBoxContainer/Assign_Function").visible = false
		toolbar.get_node("HBoxContainer/Edit_Data_Display").visible = false
		selected_node = null


func connect_singals():
	pass

#func _apply_changes():
#	print("APPLY CHANGES")
#	main_panel_instance.when_editor_saved()

func _save_external_data():
	if !main_panel_instance.is_editor_saving:
#		print("FART ENGINE PLUGIN: SAVE EXTERNAL DATA - BEGIN")
		main_panel_instance.when_editor_saved()
		await main_panel_instance.save_complete
		print("FART ENGINE SAVE COMPLETE")
#		print("FART ENGINE PLUGIN: SAVE EXTERNAL DATA - END")
