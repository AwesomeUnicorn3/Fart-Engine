extends MovementEngine
class_name CharacterEngine

signal interaction_raycast_collided
@onready var damage_shader: ShaderMaterial = load("res://addons/fart_engine/Character_Manager/PlayerDamageFlash_Shader.tres")
#var state = "Idle"
var character_can_move :bool = false
var load_game:bool = false

# NO DB = No Database Entry needed for this variable
# DBA - Need to add this variable to the database
# DBAA - Value set from DB Manager
var interaction_raycast_dict: Dictionary = {}
#var interaction_raycast :RayCast2D
var current_selected_interactive_body = null
var player_animation_dictionary :Dictionary = {}
var player_shadow_dictionary :Dictionary = {}
var sprite_animation :AnimatedSprite2D
var shadow_sprite_animation  :AnimatedSprite2D
var shadow_sprite_frames :SpriteFrames
var sprite_group_id :String
var use_save_dict :bool = true
var character_dictionary_name = "10016"
var gravity: float  #Game gravity (Think of this as y acceleration) - DBAA
var is_gravity_active:bool
var base_gravity: float
var characterMaxSpeed :float = 0#character max speed - DBAA
var characterFriction :float= 0 # stop speed- DBAA
var characterAcceleration :float = 0 #how quickly to max speed
var characterJumpSpeed : float = 0 # character jump speed (jump velocity) - DBAA
var activeCharacterId : String = "" #Use function get_lead_character() to set value -DBAA
var characterMass :float
var draw_shadow :bool

var player_starting_jump_y :float = 0.0
var player_ending_jump_y :float = 0.0
var gravity_flip : bool = false

var temp_gravity_active :bool = false
var is_knockback_active:bool = false
var invincibility_time:float
var is_player_invincible:bool = false
var current_health

var raycast_offset:float = 15


func _ready() -> void:
	if is_inside_tree():
		if FART.dict_loaded == false:
			await FART.DbManager_loaded
		FART.CAMERA._ready()
		var newgame = await FART.get_field_value("10002",await FART.get_global_settings_profile(), "NewGame")
		if newgame:
			use_save_dict = false
			#FARTset_save_data_value("Global Data", await FART.get_global_settings_profile(), "NewGame", false)
		
		if !load_game:
			FART.save_game_data.connect(save_player_data)
			add_raycasts_to_player()
			set_animation_sprites()

		set_required_variables()
		load_game = false
		use_save_dict = true
		
#		if draw_shadow:
#			set_shadow_animation()


func set_required_variables():
	var upscale :float = 10.0

	var activeCharacterId = FART.get_lead_character_id()
	characterFriction = await FART.get_field_value(character_dictionary_name, activeCharacterId, "Friction", use_save_dict) * upscale
	characterAcceleration = await FART.get_field_value(character_dictionary_name, activeCharacterId, "Acceleration", use_save_dict) * upscale
	characterMaxSpeed = await FART.get_field_value(character_dictionary_name, activeCharacterId, "Max Speed", use_save_dict) * upscale
	characterJumpSpeed = await FART.get_field_value(character_dictionary_name, activeCharacterId, "Jump Speed", use_save_dict) * upscale
	draw_shadow = await FART.get_field_value(character_dictionary_name, activeCharacterId, "Draw Shadow", use_save_dict)
	invincibility_time = await FART.get_field_value(character_dictionary_name, activeCharacterId, "Invincible Time", use_save_dict)

	gravity =await  FART.get_field_value("10002", await FART.get_global_settings_profile(), "Gravity Force", use_save_dict) * upscale
	base_gravity = gravity
	characterMass = await FART.get_field_value(character_dictionary_name, activeCharacterId, "Mass", use_save_dict) * upscale
	is_gravity_active = await FART.get_field_value("10002", await FART.get_global_settings_profile(), "Is Gravity Active", use_save_dict)
	set_initial_player_health()


func add_raycasts_to_player():
	#clear old raycast nodes
	for child in interaction_raycast_dict:
		interaction_raycast_dict[child]["raycast_node"].queue_free()
	await get_tree().process_frame
	create_raycast(raycast_offset)
	create_raycast(-raycast_offset)



func create_raycast(target_pos_x:int)-> RayCast2D:
	var interaction_raycast := RayCast2D.new()
	interaction_raycast.set_collision_mask_value(1,true)
	interaction_raycast.set_collision_mask_value(2,false)
	interaction_raycast.set_collision_mask_value(3,true)
	interaction_raycast.set_collide_with_areas(true)
	interaction_raycast.set_collide_with_bodies(true)
	
	set_raycast_target_position(interaction_raycast, target_pos_x)
#	var interactionArea :float = FART.get_player_interaction_area().get_child(0).shape.get_radius()
#	interaction_raycast.set_target_position(Vector2(target_pos_x,interactionArea)) 

	add_child(interaction_raycast)
	interaction_raycast.set_name(str(interaction_raycast.get_instance_id()))
	interaction_raycast_dict[interaction_raycast_dict.size() + 1] = {"raycast_node": interaction_raycast}
	return interaction_raycast


func set_raycast_target_position(interaction_raycast:RayCast2D, target_pos_x:float = raycast_offset, interaction_radius:float = FART.get_player_interaction_area().get_child(0).shape.get_radius()):
#	var interactionArea_radius :float = FART.get_player_interaction_area().get_child(0).shape.get_radius()
	interaction_raycast.set_target_position(Vector2(target_pos_x, interaction_radius)) 


func _physics_process(delta):

	if FART.Dynamic_Game_Dict.has("10002"):
		var game_active :bool = FART.Dynamic_Game_Dict["10002"][await FART.get_global_settings_profile()]["Is Game Active"]
		if game_active:

			emit_player_exited_interaction_signal()
			FART.CAMERA.camera_physics_process(delta)
			state_machine(delta)
			move_and_slide()


func emit_player_exited_interaction_signal():
	var is_interaction_colliding :bool = is_interaction_raycast_colliding()
	if !is_interaction_colliding and current_selected_interactive_body != null:
		current_selected_interactive_body.emit_signal("player_exited_interaction_area")
		current_selected_interactive_body.push_ended()
		current_selected_interactive_body = null


func emit_player_entered_interaction_signal(body):
	var main_body = body
	if !is_instance_valid(current_selected_interactive_body):
		if main_body.is_in_group("Events"):
			current_selected_interactive_body = main_body
			current_selected_interactive_body.emit_signal("player_entered_interaction_area")
			current_selected_interactive_body.set_pushed_state()


func is_interaction_raycast_colliding() -> bool:
	var is_colliding:bool = false
	if interaction_raycast_dict != {}:
		for ray in interaction_raycast_dict:
			var interaction_raycast = interaction_raycast_dict[ray]["raycast_node"]
			if interaction_raycast.is_colliding():
				var collision_body = interaction_raycast.get_collider()
				if collision_body != null:
					var collision_parent  = collision_body.get_parent()
					if "can_interact" in collision_parent:
#						print(collision_parent.name)
						emit_player_entered_interaction_signal(collision_parent)
						is_colliding = true

	return is_colliding


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


#func interaction_raycast_collision(body):
##	if body != null:
#	var main_body = body
#	if !is_instance_valid(current_selected_interactive_body):
#		if main_body.is_in_group("Events"):
#			current_selected_interactive_body = main_body
#			current_selected_interactive_body.emit_signal("player_entered_interaction_area")
			#MOVE THIS AFTER TESTING
			
#	elif main_body != current_selected_interactive_body:
#		current_selected_interactive_body.emit_signal("player_exited_interaction_area")
#		current_selected_interactive_body = main_body




func set_character_movement(canMove :bool):
	character_can_move = canMove
	

#func assign_interactive_body_and_apply_shader(body):
#	current_selected_interactive_body = body
#	current_selected_interactive_body.emit_signal("player_entered_interaction_area")


func get_direction():
	var direction :Vector2 = Vector2.ZERO
	if character_can_move:
		#loop through input actions, if action is movement, run the below code
		for actionKey in FART.CurrentInputAction_dict: #ONCE SET UP, THIS SHOULD BE ONLY MOVEMENT ACTIONS
				var actionStrength :float = FART.CurrentInputAction_dict[actionKey]["action_strength"]
				var directionKey :String  = str(FART.convert_string_to_type(FART.Static_Game_Dict["10007"][actionKey]["Movement Direction"]))
				var movement_direction = FART.convert_string_to_vector(FART.Static_Game_Dict["10035"][directionKey]["Direction Vector"])
				direction.x += movement_direction.x * actionStrength
				direction.y += movement_direction.y * actionStrength
	direction = direction.normalized()
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



func save_player_position():
	FART.set_player_position_in_db(get_global_position())


func set_player_position(new_position :Vector2):
	set_global_position(new_position)
	save_player_position()

func get_player_position():
	return get_global_position()

func save_player_data():
	save_player_position()
	save_player_health()



func set_initial_player_health():
	await get_tree().create_timer(0.1).timeout
	current_health = await FART.get_save_data_value(character_dictionary_name, FART.get_lead_character_id(), "HP", use_save_dict)
	FART.emit_signal("player_health_updated")
#	print("CURRENT HEALTH: ", current_health)

func save_player_health():
	FART.set_save_data_value(character_dictionary_name, FART.get_lead_character_id(), "HP", current_health)

func set_animation_sprites():
	sprite_group_id = str(FART.Static_Game_Dict["10016"][FART.get_lead_character_id()]["Animation State Profile"])
	#sprite group dict should containe one state's up,down,left,right animations
	
	var animationStates_dict :Dictionary = FART.Static_Game_Dict["10010"]
	var animationGroups_dict :Dictionary = FART.Static_Game_Dict["10009"]
	
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
				new_shadow_animation.set_material(preload("res://addons/fart_engine/Character_Manager/ShadowMaterial.tres"))
			
			$AnimSprites.add_child(new_animation)
			new_animation.set_material(damage_shader)
			if draw_shadow:
				$ShadowAnimSprites.add_child(new_shadow_animation)

func add_sprite_group_to_node(animatedSprite :AnimatedSprite2D, sprite_dict :Dictionary, animation_state :String):
	var sprite_group_dict :Dictionary = FART.Static_Game_Dict["10040"]
	var spriteFrames : SpriteFrames = SpriteFrames.new()
	for anim in sprite_dict:
		
		if anim != "Display Name":
			var animation_name : String = anim
			FART.set_sprite_scale(animatedSprite,animation_name ,FART.convert_string_to_type(sprite_dict[anim]))
			var anim_array :Array = FART.add_animation_to_animatedSprite( animation_name, FART.convert_string_to_type(sprite_dict[anim]),animatedSprite,true , spriteFrames)
			var collisionShape = anim_array[1]
			collisionShape.name = animation_state + anim + "Collision"
			var collisionShapeName :String = collisionShape.name
			
			if self.has_node(collisionShapeName):
				var collisionNode_delete = get_node(collisionShapeName)
				await remove_child(collisionNode_delete)
				collisionNode_delete.queue_free()

			add_child(collisionShape)


func set_shadow_animation():
	player_shadow_dictionary = FART.add_sprite_group_to_animatedSprite(self, sprite_group_id)
	shadow_sprite_animation = player_shadow_dictionary["animated_sprite"]
	shadow_sprite_animation.set_name("ShadowSprite")
	shadow_sprite_frames = shadow_sprite_animation.sprite_frames
	shadow_sprite_animation.show_behind_parent = true
	shadow_sprite_animation.set_material(preload("res://addons/fart_engine/Character_Manager/ShadowMaterial.tres"))
	$Body.add_child(shadow_sprite_animation)


func set_state():
	#set state
	if velocity == Vector2.ZERO and state != "Jump":
		state = "Idle"
	else:
		state = "Walk"
		
	if Input.is_action_just_pressed("jump"):
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
			
	if is_knockback_active:
		state = "Knockback"


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
	play_sprite_animation(dir, $AnimSprites.get_node(state),$ShadowAnimSprites.get_node_or_null(state), draw_shadow)
#	direction_string = get_direction_string(dir)
	enable_collision(state + direction_string)

var self_rotation :int = 0
func rotate_ineraction_raycast(direction:Vector2):
	
	if direction != Vector2.ZERO:
		
		if direction.x < 0:
			
			self_rotation = 90
		elif direction.x > 0:
			self_rotation = -90
		if direction.y < 0:
			self_rotation = 180
		elif direction.y > 0:
			self_rotation = 0

	for ray in interaction_raycast_dict:
		var interaction_raycast :RayCast2D = interaction_raycast_dict[ray]["raycast_node"]
		var current_offset:float = interaction_raycast.target_position.x
		var current_rotation :int = rad_to_deg(interaction_raycast.get_rotation())
		if current_rotation != self_rotation:
			interaction_raycast.set_rotation(deg_to_rad(self_rotation))
			set_raycast_target_position(interaction_raycast, current_offset)


func change_player_health(health_change: float, knockback:float, custom_cooldown:float, use_default_cooldown:bool, set_number: bool, operation:int, event_node: EventHandler):
	var health_after_change = event_node.apply_operator(current_health.y, health_change, str(operation))
	if !set_number:
		health_change = health_after_change - current_health.y 
	else:
		health_change = current_health.y - health_change
		
#	health_change = -health_change
	if use_default_cooldown:
		custom_cooldown = invincibility_time

	if health_change >=0 :
		_heal_player(health_change,knockback, event_node.get_global_position(), custom_cooldown)
	else:
		_damage_player(-health_change,knockback, event_node.get_global_position(), custom_cooldown)
	
	if current_health.y <= current_health.x:
		player_death()


func _damage_player(damage_amount:float, knockback_power:float, event_position:Vector2, custom_invincible_time:float = invincibility_time):
	if !is_player_invincible:
		set_player_invincible(true)
		var distance:Vector2 = (position - event_position).normalized()
		if knockback_power != 0.0:
			velocity = distance * knockback_power * 10
		modify_player_health(damage_amount, "_event_name", "_event_node_name", "_event_node")
		if custom_invincible_time != 0.0:
			await damage_flash(custom_invincible_time)
		set_player_invincible(false)



func _heal_player(damage_amount:float, knockback_power:float, event_position:Vector2, custom_invincible_time:float = invincibility_time):
	if !is_player_invincible:
		set_player_invincible(true)
		var distance:Vector2 = (position - event_position).normalized()
		if knockback_power != 0.0:
			velocity = distance * knockback_power * 10
		modify_player_health(-damage_amount, "_event_name", "_event_node_name", "_event_node")
		if custom_invincible_time != 0.0:
			await damage_flash(custom_invincible_time)
		set_player_invincible(false)


func modify_player_health(to_what:float, _event_name :String, _event_node_name:String, _event_node):
	var player_node = FART.player_node
	var player_max_health: int = player_node.current_health.z
	var player_min_health: int = player_node.current_health.x
	var player_current_health: int = player_node.current_health.y
	
	player_node.current_health.y = clamp(player_current_health - to_what, player_min_health, player_max_health)
	FART.emit_signal("player_health_updated")


func player_death():
	#PLAY DEATH ANIMATION HERE
	# WAIT UNTIL IT IS COMPLETE, THEN SET DEATH GAME STATE
	FART.set_game_state("10")


func set_player_invincible(value:bool):
	is_player_invincible = value


func damage_flash(duration:float, frequency:float = 0.05):
	var anim_node: AnimatedSprite2D = $AnimSprites.get_node(state)
	while duration >= 0.0:
		var shader_value:bool = anim_node.material.get_shader_parameter("active")
		anim_node.material.set_shader_parameter("active", !shader_value)
		await get_tree().create_timer(frequency).timeout
		duration -= frequency
	anim_node.material.set_shader_parameter("active", false)

