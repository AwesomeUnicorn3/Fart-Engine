extends Character

onready var characterBody = $Body/FullBody
var state = "IDLE"
var sprite_animation :AnimatedSprite
var idle = "Idle Sprite"
var walk_left = "WalkLeft Sprite"
var walk_right ="WalkRight Sprite"
var walk_up = "WalkUp Sprite"
var walk_down ="WalkDown Sprite"

func _ready() -> void:
	if is_inside_tree():
		sprite_animation = udsmain.create_sprite_animation()
		var spriteFrames : SpriteFrames = SpriteFrames.new()
		idle = udsmain.add_animation_to_animatedSprite(idle, udsmain.Static_Game_Dict['Characters'][udsmain.get_lead_character()][idle] ,sprite_animation, spriteFrames)
		walk_left = udsmain.add_animation_to_animatedSprite(walk_left, udsmain.Static_Game_Dict['Characters'][udsmain.get_lead_character()][walk_left] ,sprite_animation, spriteFrames)
		walk_right = udsmain.add_animation_to_animatedSprite(walk_right, udsmain.Static_Game_Dict['Characters'][udsmain.get_lead_character()][walk_right] ,sprite_animation, spriteFrames)
		walk_up = udsmain.add_animation_to_animatedSprite(walk_up, udsmain.Static_Game_Dict['Characters'][udsmain.get_lead_character()][walk_up] ,sprite_animation, spriteFrames)
		walk_down = udsmain.add_animation_to_animatedSprite(walk_down, udsmain.Static_Game_Dict['Characters'][udsmain.get_lead_character()][walk_down] ,sprite_animation, spriteFrames)
		$Body.add_child(sprite_animation)

		
		if has_node("Collision_Shape"):
			$Collision_Shape.queue_free()
		add_child(udsmain.get_collision_shape("Idle Sprite"))

func _physics_process(delta: float) -> void:
		#EITHER NEED TO LOAD PLAYER AFTER SELECTING NEW GAME OR LOAD, OR SET THIS TO NOT PROCESS UNTIL GAME LOADED
		#UNTIL THEN, THIS WILL WORK
	if !udsmain.Dynamic_Game_Dict.empty():
		if velocity == Vector2.ZERO:
			state = "IDLE"
			#set animation speed
			characterBody.set_speed_scale(1)
		else:
			state = "WALK"
			#set Animation speed
			var anim_speed = (min((abs(velocity.x) + .1/characterMaxSpeed + abs(velocity.y) + .1/characterMaxSpeed ), characterMaxSpeed)/characterMaxSpeed)
			characterBody.set_speed_scale(anim_speed)

		state_machine()
		velocity = move_and_slide(velocity)
		udsmain.Dynamic_Game_Dict['Global Data']["Global Data"]["Player POS"] = get_global_position()


func state_machine():
	match state:
		"IDLE":
			sprite_animation.play(idle)

		"WALK":
			var dir = get_direction()
			if dir.x < 0:
				sprite_animation.play(walk_left)
			elif dir.x > 0:
				sprite_animation.play(walk_right)
			elif dir.y < 0:
				sprite_animation.play(walk_up)
			elif dir.y > 0:
				sprite_animation.play(walk_down)



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
