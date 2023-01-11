extends CharacterBody2D
class_name CharacterEngine

signal interaction_raycast_collided

var state = "IDLE"
var idle = "Idle"
var walk_left = "Walk Left"
var walk_right ="Walk Right"
var walk_up = "Walk Up"
var walk_down ="Walk Down"

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
#var characterSprite #Character spritesheet texture - DBAA
var characterMaxSpeed :int = 0#character max speed - DBAA
var characterFriction :int = 0 # stop speed- DBAA
var characterAcceleration :int = 0 #how quickly to max speed
var characterJumpSpeed : int = 0 # character jump speed (jump velocity) - DBAA
var activeCharacterId : String = "" #Use function get_lead_character() to set value -DBAA
var characterMass :int
var draw_shadow :bool
	
func _ready() -> void:
	if is_inside_tree():
		if AU3ENGINE.dict_loaded == false:
			await AU3ENGINE.DbManager_loaded
		var newgame = AU3ENGINE.get_data_value("Global Data", AU3ENGINE.global_settings_profile, "NewGame")
		if newgame:
			use_save_dict = false
			AU3ENGINE.set_save_data_value("Global Data", AU3ENGINE.global_settings_profile, "NewGame", false)
		set_required_variables()
		AU3ENGINE.save_game_data.connect(save_player_position)
		set_animation_sprite()
		add_raycast()
		if draw_shadow:
			set_shadow_animation()

func set_required_variables():
	var activeCharacterId = AU3ENGINE.get_lead_character_id()
	characterFriction = AU3ENGINE.get_data_value(character_dictionary_name, activeCharacterId, "Friction", use_save_dict)
	characterAcceleration = AU3ENGINE.get_data_value(character_dictionary_name, activeCharacterId, "Acceleration", use_save_dict)
	characterMaxSpeed = AU3ENGINE.get_data_value(character_dictionary_name, activeCharacterId, "Max Speed", use_save_dict)
	characterJumpSpeed = AU3ENGINE.get_data_value(character_dictionary_name, activeCharacterId, "Jump Speed", use_save_dict)
	draw_shadow = AU3ENGINE.get_data_value(character_dictionary_name, activeCharacterId, "Draw Shadow", use_save_dict)
	gravity = AU3ENGINE.get_data_value("Global Data", AU3ENGINE.global_settings_profile, "Gravity Force", use_save_dict)
	characterMass = AU3ENGINE.get_data_value(character_dictionary_name, activeCharacterId, "Mass", use_save_dict)
	
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
#	interaction_raycast.set_hit_from_inside(true)
#	interaction_raycast.set_exclude_parent_body(true)
	interaction_raycast_collided.connect(interaction_raycast_collision)
	add_child(interaction_raycast)
	interaction_raycast.set_name("InteractionRaycast")


func _physics_process(delta):
	if AU3ENGINE.Dynamic_Game_Dict.has("Global Data"):
		var game_active :bool = AU3ENGINE.Dynamic_Game_Dict['Global Data'][AU3ENGINE.global_settings_profile]["Is Game Active"]
		if game_active:
			
			if interaction_raycast != null:
				if interaction_raycast.is_colliding():
					emit_signal("interaction_raycast_collided", interaction_raycast.get_collider())
				elif current_selected_interactive_body != null:
					current_selected_interactive_body.emit_signal("player_exited_interaction_area")
					current_selected_interactive_body = null
			is_gravity_active =  AU3ENGINE.get_data_value("Global Data", AU3ENGINE.global_settings_profile, "Is Gravity Active", use_save_dict)

			
			state_machine(delta)
			#is_gravity_active =  AU3ENGINE.get_data_value("Global Data", AU3ENGINE.global_settings_profile, "Is Gravity Active", use_save_dict)

			#print("Before Move and slide: ", velocity.y)
			move_and_slide()


func set_vel(direction, delta):
	#if !state == "FALL":


	if !is_gravity_active:
		if abs(velocity.x) < characterMaxSpeed:
			velocity.x += direction.x
		if abs(velocity.y) < characterMaxSpeed:
			velocity.y += direction.y
		velocity = velocity.move_toward(direction * characterMaxSpeed, characterAcceleration * delta)
	else:
		velocity.x = velocity.move_toward(direction * characterMaxSpeed, characterAcceleration * delta).x


func set_gravity(delta): #CURRENTLY NOT BEING USED
#	#increase falling speed unless speed is greater than character mass
	if !is_on_floor():
		var massXgravity :float = characterMass * gravity
		velocity.y +=  (gravity * delta)
		velocity.y = clamp(velocity.y, 0, massXgravity)


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




#func _input(event):
#	print(event.InputEventAction.get_action())
#	var currentAction :String = ""
#	for action in AU3ENGINE.inputMapActions:
#		if event.is_action(action) and !event.is_echo():
#
#			currentAction = action
#			print(currentAction)
#			var actionKey :String = AU3ENGINE.get_id_from_display_name(AU3ENGINE.Static_Game_Dict["Input Actions"], action)
#			#get input action key from display name
#			var actionType :String = str(AU3ENGINE.Static_Game_Dict["Input Actions"][actionKey]["Action Type"])
#			#Get action type from table
#			#run method
#			var actionStrength :float = event.get_action_strength(action)
#			var directionKey :String  = str(AU3ENGINE.convert_string_to_type(AU3ENGINE.Static_Game_Dict["Input Actions"][actionKey]["Movement Direction"]))
#			var direction :Vector2 = AU3ENGINE.convert_string_to_vector(AU3ENGINE.Static_Game_Dict["Movement Directions"][directionKey]["Direction Vector"])
##			match actionType:
##				"1":
##					set_direction(actionStrength, direction)
#
#			break

#var currentDir :Vector2 = Vector2.ZERO

#func set_direction(actionStrength :float, direction : Vector2):
#	currentDir += direction
#	if currentDir.x > 1:
#		currentDir.x = 1
		


func get_direction():
	var direction :Vector2 = Vector2.ZERO
	if character_can_move:
		
		#var currentAction :String = ""
		#loop through input actions, if action is movement, run the below code
		for actionKey in AU3ENGINE.Static_Game_Dict["Input Actions"]:

			#currentAction = action
			#print(currentAction)
			#var actionKey :String = AU3ENGINE.get_id_from_display_name(AU3ENGINE.Static_Game_Dict["Input Actions"], action)
			#get input action key from display name
			var actionType :String = str(AU3ENGINE.Static_Game_Dict["Input Actions"][actionKey]["Action Type"])
			if actionType == "1":
			#Get action type from table
			#run method
				var action :String = AU3ENGINE.get_displayName_text(str_to_var(AU3ENGINE.Static_Game_Dict["Input Actions"][actionKey]["Display Name"]))
				var actionStrength :float = Input.get_action_strength(action)
#				print("Action: ", action, " Action Strength: ", actionStrength)
				#if actionStrength != 0:
				var directionKey :String  = str(AU3ENGINE.convert_string_to_type(AU3ENGINE.Static_Game_Dict["Input Actions"][actionKey]["Movement Direction"]))
				var movement_direction = AU3ENGINE.convert_string_to_vector(AU3ENGINE.Static_Game_Dict["Movement Directions"][directionKey]["Direction Vector"])
				direction.x += movement_direction.x * actionStrength
				direction.y += movement_direction.y * actionStrength
		#print(direction)

	#var dir = Vector2.ZERO
#	if character_can_move:
#		dir.x = direction.x
#		dir.y = direction.y
#		dir.x = Input.get_action_strength("2D move_right") - Input.get_action_strength("2D move_left")
#		dir.y = Input.get_action_strength("2D move_down") - Input.get_action_strength("2D move_up")
#	if Input.is_action_just_pressed("jump") and is_on_floor():
#		dir.y = -1.0

	#print(dir)
	return direction


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





func set_player_position(new_position :Vector2):
	set_global_position(new_position)
	save_player_position()

func get_player_position():
	return get_global_position()


func save_player_position():
	AU3ENGINE.set_player_position_in_db(get_global_position())

func set_animation_sprite():
	sprite_group_id = str(AU3ENGINE.Static_Game_Dict["Characters"][AU3ENGINE.get_lead_character_id()]["Sprite Group"])
	player_animation_dictionary = AU3ENGINE.add_sprite_group_to_animatedSprite(self, sprite_group_id)
	sprite_animation = player_animation_dictionary["animated_sprite"]
	$Body.add_child(sprite_animation)


func set_shadow_animation():
	player_shadow_dictionary = AU3ENGINE.add_sprite_group_to_animatedSprite(self, sprite_group_id)
	shadow_sprite_animation = player_shadow_dictionary["animated_sprite"]
	shadow_sprite_animation.set_name("ShadowSprite")
	shadow_sprite_frames = shadow_sprite_animation.frames
	shadow_sprite_animation.show_behind_parent = true
	shadow_sprite_animation.set_material(preload("res://addons/UDSEngine/Character_Manager/ShadowMaterial.tres"))
#	shadow_sprite_animation.set_skew(deg_to_rad(50))
	$Body.add_child(shadow_sprite_animation)


func play_shadow_animation(animation_name :String):
	shadow_sprite_animation.play(animation_name)
	AU3ENGINE.set_sprite_scale(shadow_sprite_animation,animation_name , player_animation_dictionary)
	var scale_size = shadow_sprite_animation.get_scale()
	shadow_sprite_animation.set_scale(Vector2(shadow_sprite_animation.scale.x,shadow_sprite_animation.scale.y))
	shadow_sprite_frames = shadow_sprite_animation.frames
#	var frame_size = shadow_sprite_frames.get_frame(animation_name, 0).get_size()
#	var final_frame_size :Vector2 = Vector2(scale_size.x * frame_size.x, scale_size.y * frame_size.y) * .75
#	var skew_adjustment :Vector2 = Vector2(frame_size.x * .7 , frame_size.y * .4)
#	shadow_sprite_animation.set_offset(skew_adjustment)



func play_sprite_animation(animation_name :String):
	sprite_animation.play(animation_name)
	enable_collision(animation_name)
	AU3ENGINE.set_sprite_scale(sprite_animation,animation_name , player_animation_dictionary)
	if draw_shadow:
		play_shadow_animation(animation_name)


func state_machine(delta):
	var dir :Vector2 = get_direction()
	if is_gravity_active and !is_on_floor():
		state = "FALL"

	elif dir == Vector2.ZERO:
		state = "IDLE"
	else:
		state = "WALK"

	match state:
		"IDLE":
			velocity = velocity.move_toward(Vector2.ZERO, characterFriction * delta)
			play_sprite_animation(idle)
		"WALK":
			
			set_vel(dir, delta)
			if dir.x < 0:
				play_sprite_animation(walk_left)
				rotate_ineraction_raycast(90)
			elif dir.x > 0:
				play_sprite_animation(walk_right)
				rotate_ineraction_raycast(-90)
			elif dir.y < 0:
				play_sprite_animation(walk_up)
				rotate_ineraction_raycast(180)
			elif dir.y > 0:
				play_sprite_animation(walk_down)
				rotate_ineraction_raycast(0)
		"FALL":
			set_vel(dir, delta)
			set_gravity(delta)
			play_sprite_animation(idle)
			if Input.is_action_pressed("2D move_up"): #Temporary "Jump" for testing
				velocity.y = -50
			#set FALL animation


func rotate_ineraction_raycast(rotation_degrees:int):
	var current_rotation :int = rad_to_deg(interaction_raycast.get_rotation())
	if current_rotation != rotation_degrees:
		interaction_raycast.set_rotation(deg_to_rad(rotation_degrees))
