extends Character

#_____Variables for animation__________________________________________
#onready var animationPlayer = $AnimationPlayer
#onready var animationTree = $AnimationTree
#onready var animationState = animationTree.get("parameters/playback")
onready var characterBody = $Body/FullBody
var state = "IDLE"

#func _ready() -> void:

#	animationTree.set_active(true)

func _physics_process(delta: float) -> void:
	
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


func state_machine():
	match state:
		"IDLE":
			set_character_sprite("Idle Sprite")
#			set_animation_state()
		"WALK":
			var dir = get_direction()
			if dir.x < 0:
				set_character_sprite('WalkLeft Sprite')
			elif dir.x > 0:
				set_character_sprite('WalkRight Sprite')
			elif dir.y < 0:
				set_character_sprite('WalkUp Sprite')
			elif dir.y > 0:
				set_character_sprite('WalkDown Sprite')


func set_character_sprite(sprite_field_name):
	
	var sprite_texture_info = udsmain.Static_Game_Dict['Characters'][activeCharacterName][sprite_field_name]
	if characterSprite != sprite_texture_info:
#		print(characterSprite, " ", sprite_field_name)
		characterSprite = udsmain.Static_Game_Dict['Characters'][activeCharacterName][sprite_field_name] #udsmain.Static_Game_Dict['Characters'][activeCharacterName]['Walk Sprite']
		
		var frameVector : Vector2 = udsmain.convert_string_to_Vector(characterSprite[1])
		var spriteMap = load(characterSprite[0])
	
			#SET COLLISION SHAPE = TO SPRITE SIZE
		var sprite_size = Vector2(spriteMap.get_size().x/frameVector.y,spriteMap.get_size().y/frameVector.x)
		$Collision_Primary.shape.set_extents(Vector2(sprite_size.x / 2, sprite_size.y / 2))
		
		#CREATE ANIMATION BASED ON THE NUMBER OF FRAMES
		var total_frames = frameVector.x * frameVector.y
		var spriteFrame = SpriteFrames.new()
		if spriteFrame.has_animation(sprite_field_name):
			spriteFrame.clear(sprite_field_name)
		spriteFrame.add_animation(sprite_field_name)

		for i in range(0, total_frames):
			characterBody.set_sprite_frames(spriteFrame)
			var tlMap = TileMap.new()
			var region_offset = sprite_size * i
			var region := Rect2( region_offset.x ,  0, sprite_size.x , sprite_size.y)
			spriteFrame.add_frame(sprite_field_name, get_cropped_texture(spriteMap, region) , i)
		characterBody.play(sprite_field_name)


func get_cropped_texture(texture : Texture, region : Rect2) -> AtlasTexture:
	var atlas_texture := AtlasTexture.new()
	atlas_texture.set_atlas(texture)
	atlas_texture.set_region(region)
	return atlas_texture
