extends CharacterBody2D
class_name CharacterEngine

signal interaction_raycast_collided

var state = "IDLE"
var idle = "Idle"
var walk_left = "Walk Left"
var walk_right ="Walk Right"
var walk_up = "Walk Up"
var walk_down ="Walk Down"




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
var sprite_group_name :String
var use_save_dict :bool = true
var character_dictionary_name = "Characters"
var gravity: float = 300 #Game gravity (Think of this as y acceleration) - DBAA
#var characterSprite #Character spritesheet texture - DBAA
var characterMaxSpeed :int = 0#character max speed - DBAA
var characterFriction :int = 0 # stop speed- DBAA
var characterAcceleration :int = 0 #how quickly to max speed
var characterJumpSpeed : int = 0 # character jump speed (jump velocity) - DBAA
var activeCharacterName : String = "" #Use function get_lead_character() to set value -DBAA
var draw_shadow :bool
	
func _ready() -> void:
	if is_inside_tree():
		if udsmain.dict_loaded == false:
			await udsmain.DbManager_loaded
		var newgame = udsmain.get_data_value("Global Data", udsmain.global_settings, "NewGame")
		if newgame:
			use_save_dict = false
			udsmain.set_save_data_value("Global Data", udsmain.global_settings, "NewGame", false)
		set_required_variables()
		udsmain.save_game_data.connect(save_player_position)
		set_animation_sprite()
		add_raycast()
		if draw_shadow:
			set_shadow_animation()

func set_required_variables():
	activeCharacterName = udsmain.get_lead_character()
	characterFriction = udsmain.get_data_value(character_dictionary_name, activeCharacterName, "Friction", use_save_dict)
	characterAcceleration = udsmain.get_data_value(character_dictionary_name, activeCharacterName, "Acceleration", use_save_dict)
	characterMaxSpeed = udsmain.get_data_value(character_dictionary_name, activeCharacterName, "Max Speed", use_save_dict)
	characterJumpSpeed = udsmain.get_data_value(character_dictionary_name, activeCharacterName, "Jump Speed", use_save_dict)
	draw_shadow = udsmain.get_data_value(character_dictionary_name, activeCharacterName, "Draw Shadow", use_save_dict)

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
	if udsmain.Dynamic_Game_Dict.has("Global Data"):
		var game_active :bool = udsmain.Dynamic_Game_Dict['Global Data'][udsmain.global_settings]["Is Game Active"]
		if game_active:
			
			if interaction_raycast != null:
				if interaction_raycast.is_colliding():
					emit_signal("interaction_raycast_collided", interaction_raycast.get_collider())
				elif current_selected_interactive_body != null:
					current_selected_interactive_body.emit_signal("player_exited_interaction_area")
					current_selected_interactive_body = null

			state_machine(delta)
			self.move_and_slide()


func set_vel(direction, delta):
	if abs(velocity.x) < characterMaxSpeed:
		velocity.x += direction.x
	if abs(velocity.y) < characterMaxSpeed:
		velocity.y += direction.y
	velocity = velocity.move_toward(direction * characterMaxSpeed, characterAcceleration * delta)


func interaction_raycast_collision(body):
	var main_body = body.get_parent()
	if !is_instance_valid(current_selected_interactive_body):
		if main_body.is_in_group("Events"):
			assign_interactive_body_and_apply_shader(main_body)
	elif main_body != current_selected_interactive_body:
		current_selected_interactive_body.emit_signal("player_exited_interaction_area")
		current_selected_interactive_body = null



func assign_interactive_body_and_apply_shader(body):
	current_selected_interactive_body = body
	current_selected_interactive_body.emit_signal("player_entered_interaction_area")

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

func set_animation_sprite():
	sprite_group_name = udsmain.Static_Game_Dict["Characters"][udsmain.get_lead_character()]["Sprite Group"]
	player_animation_dictionary = udsmain.add_sprite_group_to_animatedSprite(self, sprite_group_name)
	sprite_animation = player_animation_dictionary["animated_sprite"]
	$Body.add_child(sprite_animation)


func set_shadow_animation():
	player_shadow_dictionary = udsmain.add_sprite_group_to_animatedSprite(self, sprite_group_name)
	shadow_sprite_animation = player_shadow_dictionary["animated_sprite"]
	shadow_sprite_animation.set_name("ShadowSprite")
	shadow_sprite_frames = shadow_sprite_animation.frames
	shadow_sprite_animation.show_behind_parent = true
	shadow_sprite_animation.set_material(preload("res://addons/UDSEngine/Character_Manager/ShadowMaterial.tres"))
	shadow_sprite_animation.set_skew(deg_to_rad(50))
	$Body.add_child(shadow_sprite_animation)


func play_shadow_animation(animation_name :String):
	shadow_sprite_animation.play(animation_name)
	udsmain.set_sprite_scale(shadow_sprite_animation,animation_name , player_animation_dictionary)
	var scale_size = shadow_sprite_animation.get_scale()
	shadow_sprite_animation.set_scale(Vector2(shadow_sprite_animation.scale.x * .90,shadow_sprite_animation.scale.y * .90))
	shadow_sprite_frames = shadow_sprite_animation.frames
	var frame_size = shadow_sprite_frames.get_frame(animation_name, 0).get_size()
	var final_frame_size :Vector2 = Vector2(scale_size.x * frame_size.x, scale_size.y * frame_size.y) * .75
	var skew_adjustment :Vector2 = Vector2(frame_size.x * .7 , frame_size.y * .4)
	shadow_sprite_animation.set_offset(skew_adjustment)



func play_sprite_animation(animation_name :String):
	sprite_animation.play(animation_name)
	enable_collision(animation_name)
	udsmain.set_sprite_scale(sprite_animation,animation_name , player_animation_dictionary)
	if draw_shadow:
		play_shadow_animation(animation_name)


func state_machine(delta):
	var dir :Vector2 = get_direction()
	set_vel(dir, delta)

	if dir == Vector2.ZERO:
		state = "IDLE"
	else:
		state = "WALK"

	match state:
		"IDLE":
			velocity = velocity.move_toward(Vector2.ZERO, characterFriction * delta)
			play_sprite_animation(idle)
		"WALK":
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


func rotate_ineraction_raycast(rotation_degrees:int):
	var current_rotation :int = rad_to_deg(interaction_raycast.get_rotation())
	if current_rotation != rotation_degrees:
		interaction_raycast.set_rotation(deg_to_rad(rotation_degrees))
