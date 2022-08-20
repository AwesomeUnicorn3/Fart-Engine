extends CharacterBody2D
class_name CharacterEngine

# NO DB = No Database Entry needed for this variable
# DBA - Need to add this variable to the database
# DBAA - Value set from DB Manager
var player_animation_dictionary :Dictionary = {}
var sprite_animation
var character_dictionary_name = "Characters"
var gravity: float = 300 #Game gravity (Think of this as y acceleration) - DBAA
#var characterSprite #Character spritesheet texture - DBAA
var characterMaxSpeed :int = 0#character max speed - DBAA
var characterFriction :int = 0 # stop speed- DBAA
var characterAcceleration :int = 0 #how quickly to max speed
var characterJumpSpeed : int = 0 # character jump speed (jump velocity) - DBAA
var activeCharacterName : String = "" #Use function get_lead_character() to set value -DBAA

	
func startup() -> void:
	if udsmain.dict_loaded == false:
		await udsmain.DbManager_loaded
	activeCharacterName = udsmain.get_lead_character()
	var use_save_dict :bool = true
	var newgame = udsmain.get_data_value("Global Data", udsmain.global_settings, "NewGame")
	if newgame:
		use_save_dict = false
		udsmain.set_save_data_value("Global Data", udsmain.global_settings, "NewGame", false)
	characterFriction = udsmain.get_data_value(character_dictionary_name, activeCharacterName, "Friction", use_save_dict)
	characterAcceleration = udsmain.get_data_value(character_dictionary_name, activeCharacterName, "Acceleration", use_save_dict)
	characterMaxSpeed = udsmain.get_data_value(character_dictionary_name, activeCharacterName, "Max Speed", use_save_dict)
	characterJumpSpeed = udsmain.get_data_value(character_dictionary_name, activeCharacterName, "Jump Speed", use_save_dict)
	udsmain.save_game_data.connect(save_player_position)
	
	var sprite_group_name :String = udsmain.Static_Game_Dict["Characters"][udsmain.get_lead_character()]["Sprite Group"]
	player_animation_dictionary = udsmain.add_sprite_group_to_animatedSprite(self, sprite_group_name)
	sprite_animation = player_animation_dictionary["animated_sprite"]
	$Body.add_child(sprite_animation)

#	var sprite_group_dict :Dictionary = udsmain.Static_Game_Dict["Sprite Groups"]
#	var sprite_group_name :String = udsmain.Static_Game_Dict["Characters"][udsmain.get_lead_character()]["Sprite Group"]
#
#	sprite_animation = udsmain.create_sprite_animation()
#	var spriteFrames : SpriteFrames = SpriteFrames.new()
#
#	for i in sprite_group_dict:
#		if sprite_group_dict[i]["Display Name"] == sprite_group_name:
#			player_sprite_group_dict = udsmain.Static_Game_Dict["Sprite Groups"][i]
#
#	for j in player_sprite_group_dict:
#		if j != "Display Name":
#			var animation_name : String = j
#			var anim_array :Array = udsmain.add_animation_to_animatedSprite( animation_name, udsmain.convert_string_to_type(player_sprite_group_dict[j]), true ,sprite_animation, spriteFrames)
#			add_child(anim_array[1])
#
#	$Body.add_child(sprite_animation)

#	get_gravity()

#func add_sprite_group_to_animatedSprite(Sprite_Group_Name :String):
#	var return_value_dictionary :Dictionary= {}
#	var animation_dictionary :Dictionary = {}
#	var new_animatedsprite2d :AnimatedSprite2D = udsmain.create_sprite_animation()
#	var sprite_group_dict :Dictionary = udsmain.Static_Game_Dict["Sprite Groups"]
#	var spriteFrames : SpriteFrames = SpriteFrames.new()
#
#	for i in sprite_group_dict:
#		if sprite_group_dict[i]["Display Name"] == Sprite_Group_Name:
#			animation_dictionary = udsmain.Static_Game_Dict["Sprite Groups"][i]
#
#	for j in animation_dictionary:
#		if j != "Display Name":
#			var animation_name : String = j
#			var anim_array :Array = udsmain.add_animation_to_animatedSprite( animation_name, udsmain.convert_string_to_type(animation_dictionary[j]), true ,new_animatedsprite2d, spriteFrames)
#			add_child(anim_array[1])
#	return_value_dictionary["animated_sprite"] = new_animatedsprite2d
#	return_value_dictionary["animation_dictionary"] = animation_dictionary
#	return return_value_dictionary
	


func get_direction():
	var dir = Vector2.ZERO
	dir.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	dir.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
#	if Input.is_action_just_pressed("jump") and is_on_floor():
#		dir.y = -1.0
	return dir


func disable_all_collisions():
	for i in get_children():
		if i is CollisionShape2D:
			i.disabled = true
			i.visible = false

func enable_collision(collision_name :String):
	if get_node(collision_name + " Collision").disabled == true:
		disable_all_collisions()
		get_node(collision_name + " Collision").disabled = false
		get_node(collision_name + " Collision").visible = true


#func get_gravity(): #CURRENTLY NOT BEING USED
#	#increase falling speed unless speed is greater than character gravity
#	if velocity.y <= characterMass:
#		velocity.y += gravity


func set_player_position(new_position :Vector2):
	set_global_position(new_position)
	save_player_position()

func get_player_position():
	return get_global_position()


func save_player_position():
	udsmain.set_player_position_in_db(get_global_position())


#func set_sprite_scale(animation_name:String):
#	var sprite_dict :Dictionary = udsmain.convert_string_to_type(player_animation_dictionary["animation_dictionary"][animation_name])
#	var atlas_dict :Dictionary = sprite_dict["atlas_dict"]
#	var advanced_dict :Dictionary  = sprite_dict["advanced_dict"]
#	var sprite_texture = load(udsmain.table_save_path + udsmain.icon_folder + atlas_dict["texture_name"])
#	var sprite_frame_size = atlas_dict["frames"]
#	var sprite_final_size = advanced_dict["sprite_size"]
#	var sprite_cell_size := Vector2(sprite_texture.get_size().x / sprite_frame_size.y ,sprite_texture.get_size().y / sprite_frame_size.x)
#	var modified_sprite_size_y = sprite_final_size.x
#	var modified_sprite_size_x = sprite_final_size.y
#	var y_scale_value = modified_sprite_size_y / sprite_cell_size.y
#	var x_scale_value = modified_sprite_size_x / sprite_cell_size.x
#	sprite_animation.set_scale(Vector2(x_scale_value, y_scale_value))
