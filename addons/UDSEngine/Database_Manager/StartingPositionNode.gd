@tool
extends Sprite2D

var current_position :Vector2 = Vector2.ZERO
var previous_position:Vector2 = Vector2.ZERO
var position_updated :bool = true
var DBENGINE = DatabaseEngine.new()
var editor :EditorPlugin
var save_table_wait_index :int = 0
var set_position_button

func _ready():
	
	if get_tree().get_edited_scene_root() != null:
	#Set current position based on Global Data info
		editor = EditorPlugin.new()
		var global_data_dict = DBENGINE.import_data(DBENGINE.table_save_path + "Global Data" + DBENGINE.file_format)
		current_position = DBENGINE.convert_string_to_vector(global_data_dict[DBENGINE.global_settings_profile]["Player Starting Position"])
		set_position(current_position)
		previous_position = current_position

	else:
		queue_free()


func update_starting_position(CurrentPosition):
	position_updated = true
	var global_data_dict = DBENGINE.import_data(DBENGINE.table_save_path + "Global Data" + DBENGINE.file_format)
	global_data_dict[DBENGINE.global_settings_profile]["Player Starting Position"] = CurrentPosition
	await DBENGINE.save_file(DBENGINE.table_save_path + "Global Data" + DBENGINE.file_format, global_data_dict)
	var main_node = editor.get_editor_interface().get_editor_main_screen().get_node("AU3ENGINE")
	main_node.get_node("Tabs").get_node("Global Data").update_dictionaries()
	main_node.get_node("Tabs").get_node("Global Data").reload_buttons()
	main_node.get_node("Tabs").get_node("Global Data").table_list.get_child(0)._on_TextureButton_button_up()
	editor.get_editor_interface().save_scene()


func _process(delta):
	if position != previous_position:
		current_position = position
		previous_position = position
		position_updated = false
		if save_table_wait_index != 200:
			save_table_wait_index = 200
		
	elif save_table_wait_index >= 1:
		save_table_wait_index -= 1
	
	elif save_table_wait_index == 0 and !position_updated:
		position_updated = true
		update_starting_position(current_position)

