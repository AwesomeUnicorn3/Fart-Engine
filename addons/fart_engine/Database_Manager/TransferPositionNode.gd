@tool
extends Sprite2D

signal position_changed

var current_position :Vector2 = Vector2.ZERO
var previous_position:Vector2 = Vector2.ZERO
var position_updated :bool = true

var save_table_wait_index :int = 0
var CurrentPosition
var par_node

func _ready():
	
	if get_tree().get_edited_scene_root() != null:
		var global_data_dict = DatabaseManager.all_tables_merged_dict["10002"]
		set_position(current_position)
		previous_position.x = current_position.x - 5
	else:
		queue_free()


func update_starting_position(current_position):
	position_updated = true
	CurrentPosition = current_position
	emit_signal("position_changed", CurrentPosition)



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
