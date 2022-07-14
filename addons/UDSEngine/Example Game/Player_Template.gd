extends Character

@onready var characterBody_node = $Body/FullBody
@onready var collisions_node = self


var state = "IDLE"
var sprite_animation
var idle = "Idle"
var walk_left = "Walk Left"
var walk_right ="Walk Right"
var walk_up = "Walk Up"
var walk_down ="Walk Down"
var frame_count_index := 0


func _ready() -> void:
	if is_inside_tree():
		var sprite_group_dict :Dictionary = udsmain.Static_Game_Dict["Sprite Groups"]
		var sprite_group_name :String = udsmain.Static_Game_Dict["Characters"][udsmain.get_lead_character()]["Sprite Group"]
		var player_sprite_group_dict :Dictionary = {}
		sprite_animation = udsmain.create_sprite_animation()
		var spriteFrames : SpriteFrames = SpriteFrames.new()
		for i in sprite_group_dict:
			if sprite_group_dict[i]["Display Name"] == sprite_group_name:
				player_sprite_group_dict = udsmain.Static_Game_Dict["Sprite Groups"][i]
		for j in player_sprite_group_dict:
			if j != "Display Name":

				var animation_name : String = j
				var anim_array :Array = udsmain.add_animation_to_animatedSprite( animation_name, udsmain.convert_string_to_type(player_sprite_group_dict[j]), true ,sprite_animation, spriteFrames)
				collisions_node.add_child(anim_array[1])
#		idle = udsmain.add_animation_to_animatedSprite(idle, udsmain.convert_string_to_type(udsmain.Static_Game_Dict['Characters'][udsmain.get_lead_character()][idle]) ,sprite_animation, spriteFrames)
#		walk_left = udsmain.add_animation_to_animatedSprite(walk_left, udsmain.convert_string_to_type(udsmain.Static_Game_Dict['Characters'][udsmain.get_lead_character()][walk_left]) ,sprite_animation, spriteFrames)
#		walk_right = udsmain.add_animation_to_animatedSprite(walk_right, udsmain.convert_string_to_type(udsmain.Static_Game_Dict['Characters'][udsmain.get_lead_character()][walk_right]) ,sprite_animation, spriteFrames)
#		walk_up = udsmain.add_animation_to_animatedSprite(walk_up, udsmain.convert_string_to_type(udsmain.Static_Game_Dict['Characters'][udsmain.get_lead_character()][walk_up]) ,sprite_animation, spriteFrames)
#		walk_down = udsmain.add_animation_to_animatedSprite(walk_down, udsmain.convert_string_to_type(udsmain.Static_Game_Dict['Characters'][udsmain.get_lead_character()][walk_down]) ,sprite_animation, spriteFrames)
		$Body.add_child(sprite_animation)
#
#
#		if has_node("Collision_Shape"):
#			$Collision_Shape.queue_free()
#		

func _physics_process(delta: float) -> void:

		#EITHER NEED TO LOAD PLAYER AFTER SELECTING NEW GAME OR LOAD, OR SET THIS TO NOT PROCESS UNTIL GAME LOADED
		#UNTIL THEN, THIS WILL WORK
	if udsmain.Dynamic_Game_Dict.has("Global Data"):
		if udsmain.Dynamic_Game_Dict['Global Data']["Global Data"]["Is Game Active"]:
			if velocity == Vector2.ZERO:
				state = "IDLE"
				#set animation speed
				characterBody_node.set_speed_scale(1)
			else:
				state = "WALK"
				#set Animation speed
				var anim_speed = (min((abs(velocity.x) + .1/characterMaxSpeed + abs(velocity.y) + .1/characterMaxSpeed ), characterMaxSpeed)/characterMaxSpeed)
				characterBody_node.set_speed_scale(anim_speed)

			state_machine()
			move_and_slide()


func _process(delta: float) -> void:
	if udsmain.Dynamic_Game_Dict.has("Global Data"):
		if udsmain.Dynamic_Game_Dict['Global Data']["Global Data"]["Is Game Active"]:
			frame_count_index += 1
			if frame_count_index >= 240:
				udsmain.Dynamic_Game_Dict['Global Data']["Global Data"]["Player POS"] = get_global_position()
				frame_count_index = 0

func state_machine():
	match state:
		"IDLE":
			sprite_animation.play(idle)
			enable_collision(idle)
		"WALK":
			var dir = get_direction()
			if dir.x < 0:
				sprite_animation.play(walk_left)
				enable_collision(walk_left)
			elif dir.x > 0:
				sprite_animation.play(walk_right)
				enable_collision(walk_right)
			elif dir.y < 0:
				sprite_animation.play(walk_up)
				enable_collision(walk_up)
			elif dir.y > 0:
				sprite_animation.play(walk_down)
				enable_collision(walk_down)
			
			

func disable_all_collisions():
	for i in collisions_node.get_children():
		if i is CollisionShape2D:
			i.disabled = true
			i.visible = false

func enable_collision(collision_name :String):
	if collisions_node.get_node(collision_name + " Collision").disabled == true:
		disable_all_collisions()
		collisions_node.get_node(collision_name + " Collision").disabled = false
		collisions_node.get_node(collision_name + " Collision").visible = true
#func get_character_sprite(sprite_field_name):
#	var sprite_texture_info = udsmain.Static_Game_Dict['Characters'][activeCharacterName][sprite_field_name]
#	if characterSprite != sprite_texture_info:
##		print(characterSprite, " ", sprite_field_name)
#		characterSprite = udsmain.Static_Game_Dict['Characters'][activeCharacterName][sprite_field_name] #udsmain.Static_Game_Dict['Characters'][activeCharacterName]['Walk Sprite']
#		var frameVector : Vector2 = udsmain.convert_string_to_Vector(characterSprite[1])
#		var spriteMap = load(characterSprite[0])
#
#			#SET COLLISION SHAPE = TO SPRITE SIZE
#		var sprite_size = Vector2(spriteMap.get_size().x/frameVector.y,spriteMap.get_size().y/frameVector.x)
#		$Collision_Primary.shape.set_extents(Vector2(sprite_size.x / 2, sprite_size.y / 2))
#
#		#CREATE ANIMATION BASED ON THE NUMBER OF FRAMES
#		var total_frames = frameVector.x * frameVector.y
#		var spriteFrame = SpriteFrames.new()
#		if spriteFrame.has_animation(sprite_field_name):
#			spriteFrame.clear(sprite_field_name)
#		spriteFrame.add_animation(sprite_field_name)
#
#		for i in range(0, total_frames):
#			characterBody.set_sprite_frames(spriteFrame)
#			var region_offset = sprite_size * i
#			var region := Rect2( region_offset.x ,  0, sprite_size.x , sprite_size.y)
#			var cropped_texture = get_cropped_texture(spriteMap, region)
#			spriteFrame.add_frame(sprite_field_name, cropped_texture , i)
#
#		characterBody.play(sprite_field_name)
#
#
#func get_cropped_texture(texture : Texture, region : Rect2) -> AtlasTexture:
#	var atlas_texture = AtlasTexture.new()
#	atlas_texture.set_atlas(texture)
#	atlas_texture.set_region(region)
#	return atlas_texture


func _on_Player_tree_exiting() -> void:
	pass
