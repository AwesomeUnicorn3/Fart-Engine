@tool
extends Control

@onready var event_input_form_preload := preload("res://addons/UDSEngine/Event_Manager/Event Editor Input Form.tscn")
#var event_name :String
var event_Node : EventHandler
#var event_node_name : String
var event_input_form
# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
#	event_input_form = event_input_form_preload.instantiate()
#	var editor := EditorPlugin.new()
#	editor.add_control_to_container(EditorPlugin.CONTAINER_CANVAS_EDITOR_BOTTOM, event_input_form)
#	event_input_form.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass


func _on_Button_button_up() -> void:
	var editor := EditorPlugin.new()
	event_input_form = event_input_form_preload.instantiate()
#	event_input_form.parent_node = self

	
	editor.add_control_to_container(EditorPlugin.CONTAINER_CANVAS_EDITOR_BOTTOM, event_input_form)

#	event_input_form.visible = true
	event_input_form.parent_node = self
	event_input_form.load_event()
	event_input_form.get_node("Scroll1/VBox1/HBox2/Save_Page_Button").visible = true

#	event_input_form.event_node_name = event_node_name
	var vsplit := VSplitContainer.new()
#	vsplit.get_viewport_rect()
	var window_height  = event_input_form.get_parent().get_viewport_rect().size
#	print("Window Height is: ", window_height)
	event_input_form.custom_minimum_size.y = window_height.y - (window_height.y * .5)
	$HBoxContainer/Edit_Event_Button.disabled = true
#	yield(event_input_form, "event_editor_input_form_closed")
	await event_input_form.event_editor_input_form_closed
	$HBoxContainer/Edit_Event_Button.disabled = false
#func _on_Event_Tools_visibility_changed() -> void:
#	if visible:
#		event_input_form.parent_node = self
#		event_input_form.event_node_name = event_node_name

