@tool
extends Control

@onready var event_input_form_preload := preload("res://addons/fart_engine/Event_Manager/Event Editor Input Form.tscn")
@onready var UIMethod_Selection_form:= preload("res://addons/fart_engine/UI_Manager/popup_UIMethod_Selection.tscn")
@onready var event_selection_form_preload:= preload("res://addons/fart_engine/Event_Manager/popup_Event_Selection.tscn")


var event_Node : EventHandler
var event_input_form


func _on_Button_button_up() -> void: #Edit EVent Button
	var editorPlugin: EditorPlugin = EditorPlugin.new()
	var editor := EditorScript.new()
	var selection_array = editor.get_editor_interface().get_selection().get_selected_nodes()
	if selection_array.size() != 0:
		if selection_array.size() == 1:
			var event_node = editor.get_editor_interface().get_selection().get_selected_nodes()[0]
			var event_name = event_node.event_name


			event_input_form = event_input_form_preload.instantiate()
			editorPlugin.add_control_to_container(EditorPlugin.CONTAINER_CANVAS_EDITOR_SIDE_RIGHT, event_input_form)
#			event_input_form.parent_node = self
			if event_name == "":
				event_input_form.show_event_selection_popup()
				event_input_form.event_node = event_node
				await event_input_form.event_selection_popup_closed
				event_name = event_input_form.event_name
			
			if event_name != "":

				
				
				event_input_form.load_event(event_name)
		#	event_input_form.get_node("Scroll1/VBox1/HBox2/Save_Page_Button").visible = true
		#	event_input_form.set_name("EventInputForm")

			$HBoxContainer/Edit_Event_Button.disabled = true
			await event_input_form.event_editor_input_form_closed
			$HBoxContainer/Edit_Event_Button.disabled = false
			
			editorPlugin.remove_control_from_container(EditorPlugin.CONTAINER_CANVAS_EDITOR_SIDE_RIGHT, event_input_form)
			event_input_form.queue_free()


func _on_assign_function_button_up():
	var editorPlugin: EditorPlugin = EditorPlugin.new()
	var uimethod_selection_form = UIMethod_Selection_form.instantiate()
	editorPlugin.add_control_to_container(EditorPlugin.CONTAINER_CANVAS_EDITOR_SIDE_RIGHT, uimethod_selection_form)
	uimethod_selection_form.set_name("UI_Navigation_Selection")
	$HBoxContainer/Assign_Function.disabled = true
	
	await uimethod_selection_form.input_closed
	
	$HBoxContainer/Assign_Function.disabled = false
