@tool
extends Node
class_name Map

@onready var DBENGINE :DatabaseEngine = DatabaseEngine.new()


func _ready() -> void:
	var root_node :Map
	if get_tree().get_edited_scene_root() != null:
		root_node = get_tree().get_edited_scene_root().get_child(get_index())
	else:
		root_node = self


func get_event_dict():
	#EVENT DICT NEEDS TO BE THE TABLE DATA BUT ONLY THE TABLES THAT ARE DESIGNATED AS EVENTS
	var table_dict :Dictionary = DBENGINE.import_data("Table Data")
	var event_dict = {}
	for table_name in table_dict:
		var is_event = DBENGINE.convert_string_to_type(table_dict[table_name]["Is Event"])
		if is_event:
			event_dict[table_name] = table_dict[table_name]["Display Name"]
	return event_dict


func _on_Event_body_entered(body: Node) -> void:
	pass # Replace with function body.


func _on_Event_body_exited(body: Node) -> void:
	pass # Replace with function body.


func is_new_event_object() -> void:
	pass
	#("Event Added")

