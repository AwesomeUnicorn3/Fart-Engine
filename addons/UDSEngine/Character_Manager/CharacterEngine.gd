extends MovementEngine
class_name CharacterEngine

signal interaction_raycast_collided

#var state = "Idle"
var character_can_move :bool = false


# NO DB = No Database Entry needed for this variable
# DBA - Need to add this variable to the database
# DBAA - Value set from DB Manager
var interaction_raycast :RayCast2D
var current_selected_interactive_body = null
var player_animation_dictionary :Dictionary = {}
var player_shadow_dictionary :Dictionary = {}
var sprite_animation :AnimatedSprite2D
var shadow_sprite_animation  :AnimatedSprite2D
var shadow_sprite_frames :SpriteFrames
var sprite_group_id :String
var use_save_dict :bool = true
var character_dictionary_name = "Characters"
var gravity: float  #Game gravity (Think of this as y acceleration) - DBAA
var is_gravity_active:bool
var base_gravity: float
var characterMaxSpeed :int = 0#character max speed - DBAA
var characterFriction :int = 0 # stop speed- DBAA
var characterAcceleration :int = 0 #how quickly to max speed
var characterJumpSpeed : int = 0 # character jump speed (jump velocity) - DBAA
var activeCharacterId : String = "" #Use function get_lead_character() to set value -DBAA
var characterMass :int
var draw_shadow :bool

var player_starting_jump_y :float = 0.0
var player_ending_jump_y :float = 0.0
var gravity_flip : bool = false

var temp_gravity_active :bool = false
#var previous_direction_string :String = "Down"
#var previous_state :String = ""



func _ready() -> void:
	if is_inside_tree():
		if AU3ENGINE.dict_loaded == false:
			await AU3ENGINE.DbManager_loaded
		var newgame = AU3ENGINE.get_field_value("Global Data",await AU3ENGINE.get_global_settings_profile(), "NewGame")
		if newgame:
			use_save_dict = false
			#AU3ENGINE.set_save_data_value("Global Data", await AU3ENGINE.get_global_settings_profile(), "NewGame", false)
		set_required_variables()
		AU3ENGINE.save_game_data.connect(save_player_position)
		set_animation_sprites()
		add_raycast()
#		if draw_shadow:
#			set_shadow_animation()


func set_required_variables():
	var activeCharacterId = AU3ENGINE.get_lead_character_id()
	characterFriction = AU3ENGINE.get_field_value(character_dictionary_name, activeCharacterId, "Friction", use_save_dict)
	characterAcceleration = AU3ENGINE.get_field_value(character_dictionary_name, activeCharacterId, "Acceleration", use_save_dict)
	characterMaxSpeed = AU3ENGINE.get_field_value(character_dictionary_name, activeCharacterId, "Max Speed", use_save_dict)
	characterJumpSpeed = AU3ENGINE.get_field_value(character_dictionary_name, activeCharacterId, "Jump Speed", use_save_dict)
	draw_shadow = AU3ENGINE.get_field_value(character_dictionary_name, activeCharacterId, "Draw Shadow", use_save_dict)
	gravity = AU3ENGINE.get_field_value("Global Data", await AU3ENGINE.get_global_settings_profile(), "Gravity Force", use_save_dict)
	base_gravity = gravity
	characterMass = AU3ENGINE.get_field_value(character_dictionary_name, activeCharacterId, "Mass", use_save_dict)


func add_raycast():
	for child in get_children():
		if child.name == "InteractionRaycast":
			child.name = str(child.get_instance_id())
			child.queue_free()
	
	interaction_raycast = RayCast2D.new()
	interaction_raycast.set_collision_mask_value(1,true)
	interaction_raycast.set_collision_mask_value(2,false)
	interaction_raycast.set_collision_mask_value(3,true)
	interaction_raycast.set_collide_with_areas(true)
	interaction_raycast.set_collide_with_bodies(true)
	
	var interactionArea :float = AU3ENGINE.get_player_interaction_area().get_child(0).shape.get_radius()
	interaction_raycast.set_target_position(Vector2(0,interactionArea/3)) #The "3" could be set in character table
#	interaction_raycast.set_hit_from_inside(true)
#	interaction_raycast.set_exclude_parent_body(true)
	interaction_raycast_collided.connect(interaction_raycast_collision)
	add_child(interaction_raycast)
	interaction_raycast.set_name("InteractionRaycast")


func _physics_process(delta):
	if AU3ENGINE.Dynamic_Game_Dict.has("Global Data"):
		var game_active :bool = AU3ENGINE.Dynamic_Game_Dict['Global Data'][await AU3ENGINE.get_global_settings_profile()]["Is Game Active"]
		if game_active:
			
			if interaction_raycast != null:
				if interaction_raycast.is_colliding():
					emit_signal("interaction_raycast_collided", interaction_raycast.get_collider())
				elif current_selected_interactive_body != null:
					current_selected_interactive_body.emit_signal("player_exited_interaction_area")
					current_selected_interactive_body = null
			is_gravity_active =  AU3ENGINE.get_field_value("Global Data", await AU3ENGINE.get_global_settings_profile(), "Is Gravity Active", use_save_dict)

#			input_process()
			state_machine(delta)

			move_and_slide()


var moveshadowto:Vector2 = Vector2.ZERO
func set_gravity(delta): 
#	#increase falling speed unless speed is greater than character mass
	if is_gravity_active or temp_gravity_active :
		if !is_on_floor():
			var massXgravity :float = characterMass * gravity
			velocity.y +=  (gravity * delta)
			var player_distance_to_end_y :float = global_position.y - player_ending_jump_y
			if !temp_gravity_active:
				$ShadowAnimSprites.position.y = -player_distance_to_end_y
			
			if temp_gravity_active:
				var player_distance_from_begining :float = global_position.y - player_starting_jump_y
				moveshadowto = Vector2(0, -player_distance_to_end_y)
				if player_ending_jump_y == player_starting_jump_y:
					$ShadowAnimSprites.position.y = -player_distance_to_end_y

				elif player_ending_jump_y > player_starting_jump_y:
					$ShadowAnimSprites.position.y = $ShadowAnimSprites.position.move_toward(moveshadowto, characterAcceleration/10 * delta).y
					if $ShadowAnimSprites.global_position.y > player_ending_jump_y:
						$ShadowAnimSprites.position.y = -player_distance_to_end_y
	
				elif player_ending_jump_y < player_starting_jump_y:
					if velocity.y <= -characterJumpSpeed + characterJumpSpeed/4:
						$ShadowAnimSprites.position.y = -player_distance_from_begining
					else: 
						$ShadowAnimSprites.position.y = $ShadowAnimSprites.position.move_toward(moveshadowto, characterAcceleration/10 * delta).y
		else:
			$ShadowAnimSprites.position = Vector2(0, 0)
	
	else:
		moveshadowto = Vector2.ZERO
		$ShadowAnimSprites.position = Vector2(0, 0)


func interaction_raycast_collision(body):
	var main_body = body.get_parent()
	if !is_instance_valid(current_selected_interactive_body):
		if main_body.is_in_group("Events"):
			assign_interactive_body_and_apply_shader(main_body)
	elif main_body != current_selected_interactive_body:
		current_selected_interactive_body.emit_signal("player_exited_interaction_area")
		current_selected_interactive_body = null

func set_character_movement(canMove :bool):
	character_can_move = canMove
	

func assign_interactive_body_and_apply_shader(body):
	current_selected_interactive_body = body
	current_selected_interactive_body.emit_signal("player_entered_interaction_area")


func get_direction():
	var direction :Vector2 = Vector2.ZERO
	if character_can_move:
		#loop through input actions, if action is movement, run the below code
		for actionKey in AU3ENGINE.CurrentInputAction_dict: #ONCE SET UP, THIS SHOULD BE ONLY MOVEMENT ACTIONS
				var actionStrength :float = AU3ENGINE.CurrentInputAction_dict[actionKey]["action_strength"]
				var directionKey :String  = str(AU3ENGINE.convert_string_to_type(AU3ENGINE.Static_Game_Dict["Input Actions"][actionKey]["Movement Direction"]))
				var movement_direction = AU3ENGINE.convert_string_to_vector(AU3ENGINE.Static_Game_Dict["Movement Directions"][directionKey]["Direction Vector"])
				direction.x += movement_direction.x * actionStrength
				direction.y += movement_direction.y * actionStrength

	return direction


func disable_all_collisions():
	for i in get_children():
		if i is CollisionShape2D:
			i.disabled = true
			i.visible = false


func enable_collision(collision_name :String):
	
	if self.has_node(collision_name + "Collision"):
		if get_node(collision_name + "Collision").disabled == true:
			disable_all_collisions()
			get_node(collision_name + "Collision").disabled = false
			get_node(collision_name + "Collision").visible = true


func set_player_position(new_position :Vector2):
	set_global_position(new_position)
	save_player_position()

func get_player_position():
	return get_global_position()


func save_player_position():
	AU3ENGINE.set_player_position_in_db(get_global_position())

func set_animation_sprites():
	sprite_group_id = str(AU3ENGINE.Static_Game_Dict["Characters"][AU3ENGINE.get_lead_character_id()]["Animation State Profile"])
	#sprite group dict should containe one state's up,down,left,right animations
	
	var animationStates_dict :Dictionary = AU3ENGINE.Static_Game_Dict["Animation States"]
	var animationGroups_dict :Dictionary = AU3ENGINE.Static_Game_Dict["Animation Groups"]
	
	for animState in animationStates_dict[sprite_group_id]:
		if animState != "Display Name":
			var new_animation = AnimatedSprite2D.new()
			var new_shadow_animation = AnimatedSprite2D.new()
			var animGroupID :String = str(animationStates_dict[sprite_group_id][animState])
			new_animation.name = animState
			var sprite_dict :Dictionary = animationGroups_dict[animGroupID]
		
			add_sprite_group_to_node(new_animation, sprite_dict, animState)
		
			#Add Shadow sprites
			if draw_shadow:
				new_shadow_animation.name = animState
				add_sprite_group_to_node(new_shadow_animation, sprite_dict, animState)
				new_shadow_animation.show_behind_parent = true
				new_shadow_animation.set_material(preload("res://addons/UDSEngine/Character_Manager/ShadowMaterial.tres"))
			
			$AnimSprites.add_child(new_animation)
			if draw_shadow:
				$ShadowAnimSprites.add_child(new_shadow_animation)

func add_sprite_group_to_node(animatedSprite :AnimatedSprite2D, sprite_dict :Dictionary, animation_state :String):
	var sprite_group_dict :Dictionary = AU3ENGINE.Static_Game_Dict["Sprite Groups"]
	var spriteFrames : SpriteFrames = SpriteFrames.new()
	for anim in sprite_dict:
		
		if anim != "Display Name":
			var animation_name : String = anim
			AU3ENGINE.set_sprite_scale(animatedSprite,animation_name ,AU3ENGINE.convert_string_to_type(sprite_dict[anim]))
			var anim_array :Array = AU3ENGINE.add_animation_to_animatedSprite( animation_name, AU3ENGINE.convert_string_to_type(sprite_dict[anim]), true ,animatedSprite, spriteFrames)
			var collisionShape = anim_array[1]
			collisionShape.name = animation_state + anim + "Collision"
			var collisionShapeName :String = collisionShape.name
			
			if self.has_node(collisionShapeName):
				var collisionNode_delete = get_node(collisionShapeName)
				await remove_child(collisionNode_delete)
				collisionNode_delete.queue_free()

			add_child(collisionShape)


func set_shadow_animation():
	player_shadow_dictionary = AU3ENGINE.add_sprite_group_to_animatedSprite(self, sprite_group_id)
	shadow_sprite_animation = player_shadow_dictionary["animated_sprite"]
	shadow_sprite_animation.set_name("ShadowSprite")
	shadow_sprite_frames = shadow_sprite_animation.sprite_frames
	shadow_sprite_animation.show_behind_parent = true
	shadow_sprite_animation.set_material(preload("res://addons/UDSEngine/Character_Manager/ShadowMaterial.tres"))
	$Body.add_child(shadow_sprite_animation)


func set_state():
	#set state
	if velocity == Vector2.ZERO and state != "Jump":
		state = "Idle"
	else:
		state = "Walk"
		
	if Input.is_action_just_pressed("Jump"):
			state = "Jump"

	if is_gravity_active:
		if velocity.y > 0:
			state = "Fall"
		elif velocity.y < 0:
			state = "Jump"

	if temp_gravity_active:
		if is_gravity_flipped():
			pass
		if velocity.y < 0:
			state = "Jump"
		elif get_player_position().y >= player_ending_jump_y or is_on_floor():
			temp_gravity_active = false
			velocity.y = 0
		else:
			state = "Jump"


func set_gravity_flip(flip_gravity :bool = true):
	if flip_gravity:#flipt the direction of gravity
		gravity = base_gravity * -1
		gravity_flip = true
	else:#Return to origianl gravity settings
		gravity = base_gravity
		gravity_flip = false

func is_gravity_flipped():
	return gravity_flip

func state_machine(delta):
	var dir :Vector2 = get_direction()
	velocity = set_character_velocity(velocity,dir,characterMaxSpeed, characterFriction,characterAcceleration, is_gravity_active, delta)
	set_gravity(delta)
	set_state()
	rotate_ineraction_raycast(dir)
	$ShadowAnimSprites.visible = true
	match state:
		"Fall":
			$ShadowAnimSprites.visible = false

		"Jump":
			if is_gravity_active:
				if is_on_floor():
					velocity.y += -characterJumpSpeed
					player_starting_jump_y = get_player_position().y
					player_ending_jump_y = player_starting_jump_y

			elif !temp_gravity_active:
				player_starting_jump_y = get_player_position().y

				if dir.y != 0:
					if dir.y < 0: #Moving "UP"
						player_ending_jump_y = player_starting_jump_y - 20 #THIS NUMBER NEEDS TO BE SET EITHER BY DEVELOPER OR CALCULATED BASED ON SPRITE SIZE
						temp_gravity_active = true
						velocity.y -= -characterJumpSpeed * .2

					else:
						player_ending_jump_y = player_starting_jump_y + 20  #THIS NUMBER NEEDS TO BE SET EITHER BY DEVELOPER OR CALCULATED BASED ON SPRITE SIZE
						temp_gravity_active = true

				else: #IF PLAYER IS NOT MOVING UP OR DOWN
					temp_gravity_active = true
					player_ending_jump_y = player_starting_jump_y
				
				velocity.y += -characterJumpSpeed
	play_sprite_animation(dir, $AnimSprites.get_node(state),$ShadowAnimSprites.get_node(state), draw_shadow)
#	direction_string = get_direction_string(dir)
	enable_collision(state + direction_string)

func rotate_ineraction_raycast(direction:Vector2):
	if direction != Vector2.ZERO:
		var rotation :int = 0
		if direction.x < 0:
				rotation = 90
		elif direction.x > 0:
			rotation = -90
		if direction.y < 0:
			rotation = 180
		elif direction.y > 0:
			rotation = 0

		var current_rotation :int = rad_to_deg(interaction_raycast.get_rotation())
		if current_rotation != rotation:
			interaction_raycast.set_rotation(deg_to_rad(rotation))
