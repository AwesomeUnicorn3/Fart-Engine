@tool
class_name StartingPosition extends Sprite2D

var current_position :Vector2 = Vector2.ZERO
var previous_position:Vector2 = Vector2.ZERO
var position_updated :bool = true
var current_map_path:String
var DBENGINE 
var save_table_wait_index :int = 0


func _ready():
	if get_tree().get_edited_scene_root() != null:
	#Set current position based on Global Data info
		DBENGINE = DatabaseManager.new()
		var global_data_dict = DBENGINE.import_data("Global Data")
		current_position = DBENGINE.convert_string_to_vector(global_data_dict[await DBENGINE.get_global_settings_profile()]["Player Starting Position"])
		set_position(current_position)
		previous_position = current_position
		
		#print(current_position)
	else:
		queue_free()


func update_starting_position_in_profile(CurrentPosition):
#	print("BEGIN UPDATE STARTING POSITION IN PROFILE")
	var display_form_dict = DatabaseManager.display_form_dict
	var global_data_dict = DBENGINE.import_data("Global Data")
	var profileid:String = await DBENGINE.get_global_settings_profile()
#	print("CurrentPosition: ", CurrentPosition)
	global_data_dict[profileid]["Player Starting Position"] = CurrentPosition
	DBENGINE.save_file(DBENGINE.table_save_path + "Global Data" + DBENGINE.table_file_format, global_data_dict)
	if display_form_dict.has("Global Data"):
		var display_node:Node = display_form_dict["Global Data"]["Node"]
		if display_node!= null:
			display_node.reload_data_without_saving()
#	print("END UPDATE STARTING POSITION IN PROFILE")

func remove_starting_node(map):
	#GET MAP NODE
	#REMOVE SELF
	queue_free()

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
		update_starting_position_in_profile(current_position)

