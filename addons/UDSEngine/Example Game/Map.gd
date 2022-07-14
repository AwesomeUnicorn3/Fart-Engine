@tool
extends Node
class_name Map

@onready var DBENGINE :DatabaseEngine = DatabaseEngine.new()
#var event_dict :Dictionary = {}
#var event_node_name := ""
#var event_name := ""
#var tab_number := "1"
#var selected_event_table :Dictionary = {}

func _ready() -> void:
	var root_node :Map
	if get_tree().get_edited_scene_root() != null:
		root_node = get_tree().get_edited_scene_root().get_child(get_index())
	else:
		root_node = self
#	if root_node.get_child_count() != 0:
#		for child in root_node.get_children():
#			child.queue_free()
#
#	if event_name != "":
#		print(event_name)
#		get_event_dict()
#		var sprite_animation :AnimatedSprite2D = DBENGINE.create_sprite_animation()
#
#
#		selected_event_table = DBENGINE.import_data(DBENGINE.table_save_path + event_name + DBENGINE.file_format)
#		var sprite_texture_data :Array = DBENGINE.convert_string_to_type(selected_event_table[tab_number]["Default Animation"])
#		var event_animation_array :Array = DBENGINE.add_animation_to_animatedSprite("Default Animation", sprite_texture_data, false, sprite_animation)
#		root_node.add_child(sprite_animation)
#
#
#		var sprite_texture = load(DBENGINE.table_save_path + DBENGINE.icon_folder + sprite_texture_data[0])
#		var sprite_count = DBENGINE.convert_string_to_Vector(sprite_texture_data[1])
#		var sprite_cell_size := Vector2(sprite_texture.get_size().x / sprite_count.y ,sprite_texture.get_size().y / sprite_count.x)
#		var sprite_cell_ratio : float = sprite_cell_size.y / sprite_cell_size.x
#		var modified_sprite_size_y = sprite_cell_size.y
#		var y_scale_value = modified_sprite_size_y / sprite_cell_size.y
#		var x_scale_value = y_scale_value * sprite_cell_ratio
#		sprite_animation.set_scale(Vector2(x_scale_value, y_scale_value))
		
		
#		sprite_animation.set_position(root_node.position)
#		sprite_animation.play("Default Animation")
#		var sprite_group_dict :Dictionary = udsmain.Static_Game_Dict["Sprite Groups"]
#		var sprite_group_name :String = udsmain.Static_Game_Dict["Characters"][udsmain.get_lead_character()]["Sprite Group"]
#		var player_sprite_group_dict :Dictionary = {}
#		sprite_animation = udsmain.create_sprite_animation()
#		var spriteFrames : SpriteFrames = SpriteFrames.new()
#		for i in sprite_group_dict:
#			if sprite_group_dict[i]["Display Name"] == sprite_group_name:
#				player_sprite_group_dict = udsmain.Static_Game_Dict["Sprite Groups"][i]
#		for j in player_sprite_group_dict:
#			if j != "Display Name":
#
#				var animation_name : String = j
#				var anim_array :Array = udsmain.add_animation_to_animatedSprite( animation_name, udsmain.convert_string_to_type(player_sprite_group_dict[j]), true ,sprite_animation, spriteFrames)
#				collisions_node.add_child(anim_array[1])

#		$Body.add_child(sprite_animation)

func get_event_dict():
	#EVENT DICT NEEDS TO BE THE TABLE DATA BUT ONLY THE TABLES THAT ARE DESIGNATED AS EVENTS
	var table_dict :Dictionary = DBENGINE.import_data(DBENGINE.table_save_path + "Table Data" + DBENGINE.file_format)
	var event_dict = {}
	for table_name in table_dict:
		var is_event = DBENGINE.convert_string_to_type(table_dict[table_name]["Is Event"])
		if is_event:
			event_dict[table_name] = table_dict[table_name]["Display Name"]
	return event_dict

#func _get_property_list():
#	var properties = []
#	var event_dict = get_event_dict()
#	var event_list :String = ""
#	for i in event_dict:
#		if event_list == "":
#			event_list = event_dict[i]
#		else:
#			event_list = event_list + "," + event_dict[i]
##		print(event_list)
#	if event_name != "":
#		# Same as "export(int) var my_property"
#		properties.append({
#			name = "event_name",
#			type = TYPE_STRING,
#			hint = 3,
#			hint_string = event_list,
#			usage = 8199
#			})



#	if !event_dict.has(event_name):
#		event_name = str(event_dict.size() + 1)
		
		#Add new event popup
		#ask user if they want to add new event or use existing
		
		#if new event:
#		DBENGINE.current_table_name = "events"
#		DBENGINE.update_dictionaries()
#		DBENGINE.add_key(event_name, "1", true, true, false)
#		DBENGINE.save_all_db_files()
		#create new table for new event

#		DBENGINE.current_table_name = "Event Table Template"
#		DBENGINE.update_dictionaries()
#		DBENGINE.current_table_name = "Event " + event_name
		
#		DBENGINE.add_key(event_name, "1", true, true, false)
#		DBENGINE.save_all_db_files()
#		DBENGINE.update_dictionaries()
		
		
		#if select event
		#DBENGINE.current_table_name = "selected event name" #need to set this variable from popup
		#DBENGINE.update_dictionaries()
#		DBENGINE.add_key(event_name, "1", true, true, false)
		#DBENGINE.save_all_db_files()
#	return properties


#func show_toolbar_in_editor(selected_node_name):
#	event_node_name = selected_node_name
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass


func _on_Event_body_entered(body: Node) -> void:
	pass # Replace with function body.


func _on_Event_body_exited(body: Node) -> void:
	pass # Replace with function body.


func is_new_event_object() -> void:
	print("Event Added")

