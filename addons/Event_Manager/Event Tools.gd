extends Control
tool

onready var event_input_form_preload := preload("res://addons/Event_Manager/Event Editor Input Form.tscn")
#var event_name :String
var event_Node : Event
#var event_node_name : String
var event_input_form
# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
#	event_input_form = event_input_form_preload.instance()
#	var editor := EditorPlugin.new()
#	editor.add_control_to_container(EditorPlugin.CONTAINER_CANVAS_EDITOR_BOTTOM, event_input_form)
#	event_input_form.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass


func _on_Button_button_up() -> void:
#	print(event_Node)
	var editor := EditorPlugin.new()
	event_input_form = event_input_form_preload.instance()
#	event_input_form.parent_node = self
#	print(event_Node, " ", event_input_form.parent_node)
	
	editor.add_control_to_container(EditorPlugin.CONTAINER_CANVAS_EDITOR_BOTTOM, event_input_form)
#	event_input_form.visible = true
	event_input_form.parent_node = self
	event_input_form.load_event()
#	print(event_node_name)
#	event_input_form.event_node_name = event_node_name
	var window_height :int = event_input_form.get_parent().rect_size.y
	event_input_form.rect_min_size.y = window_height


#func _on_Event_Tools_visibility_changed() -> void:
#	if visible:
#		event_input_form.parent_node = self
#		event_input_form.event_node_name = event_node_name
#
#		print(event_input_form.event_name)
