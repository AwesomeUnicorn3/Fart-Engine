@tool
extends Control
var DBENGINE: DatabaseEngine = DatabaseEngine.new()

@export var table: String = "Global Data"
@export var key:String = "1"
@export var field: String = "Current Map"
@export var field_type: String = "1"

var datatype_dict:Dictionary
var display_node
var field_value
var set_values_running:bool = false

#func _ready():
#	connect_signals()
#	size_flags_horizontal = Control.SIZE_EXPAND_FILL
#	size_flags_vertical = Control.SIZE_EXPAND_FILL
#	datatype_dict = DBENGINE.import_data("DataTypes")
#	if Engine.is_editor_hint():
#	set_values()

func data_display():
	pass
#func set_values(value = null):
#	while set_values_running:
#		await get_tree().process_frame
#	set_values_running = true
#	clear_display_node()
#	await get_tree().process_frame
#
#	#LOAD DISPLAY NODE BASED ON DATATYPE
#	#EACH DATATYPE WILL NEED A "SET_DISPLAY_VALUE" FUNCTION
#	#SEE TEXT INPUT FOR EXAMPLE
#	display_node = load("res://addons/fart_engine/Database_Manager/Scenes and Scripts/UI_Input_Scenes/Input_Text.tscn").instantiate()
#
#	field_value = DBENGINE.import_data(table)[key][field]
#	add_child(display_node)
#	if value == null:
#		display_node.set_display_value(field_value)
#	else:
#		display_node.set_display_value(value)
#	set_values_running = false


#func clear_display_node():
#	if display_node != null:
#		display_node.queue_free()
#
#
#
#func connect_signals():
#	visibility_changed.connect(_on_visibility_changed)


#func _on_visibility_changed():
#	if visible:
#		set_values()
