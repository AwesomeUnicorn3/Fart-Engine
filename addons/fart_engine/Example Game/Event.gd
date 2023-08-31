@tool
extends MovementEngine
class_name EventHandler

signal player_entered_interaction_area
signal player_exited_interaction_area
#signal player_entered_damage_area
#signal player_exited_damage_area
#@onready var MOVEMENTENGINE :MovementEngine = MovementEngine.new()
#@onready var DBENGINE :DatabaseEngine = DatabaseEngine.new()
@onready var interaction_shader_material :ShaderMaterial = load("res://addons/fart_engine/Event_Manager/2dOutline_Material.tres")
@onready var shadow_shader:ShaderMaterial = preload("res://addons/fart_engine/Character_Manager/ShadowMaterial.tres")

@export var event_name :String = ""
var DBENGINE:DatabaseEngine
#var velocity :Vector2
var root_node : EventHandler
var collision_node :CollisionShape2D
var sprite_animation :AnimatedSprite2D
var shadow_sprite_animation :AnimatedSprite2D
var shadow_sprite_frames :SpriteFrames
var event_animation_dictionary :Dictionary = {}
var event_shadow_dictionary :Dictionary = {}
var interaction_area :Area2D
var attack_area :Area2D
var event_list :Array = []
var event_dict :Dictionary = {}
var command_dict :Dictionary = {}
var event_node_name := ""
var event_trigger := ""
var active_page := ""
var is_refreshing:bool = false
var current_map_name : String 
var current_map_key :String
var is_queued_for_delete :bool = false
var character_is_in_interaction_area :bool = false
var is_interaction_in_progress :bool = false
var autorun_complete :bool = true
var event_info_loaded := false
var map_node
var player_node
var player_interaction_area
var timer_running :bool = false
var direction :Vector2
var is_updating_animations :bool = false
var can_interact :bool = true
var action_button_pressed:bool = false

#DAMAGE VARS
var damage_cooldown:float = 0.1
var is_damage_cooldown_active:bool = false
var player_is_in_damage_area:bool = false

#DATA FROM TABLE
var collide_with_player :bool = true
var triggerIndex :String = "0"
var does_event_move :bool
var attack_player :bool
var max_speed :int 
var acceleration :int 
var friction :int 
var animation_group :String
var draw_shadow :bool
var loop_animation :bool = true
var damage_player_on_touch:bool = true
var knockback_power:float = 0
var damage_cooldown_time:float = 0
var damage_amount:int = 0


var idle = "Idle"
var walk_left = "Walk Left"
var walk_right ="Walk Right"
var walk_up = "Walk Up"
var walk_down ="Walk Down"


func _ready() -> void:
	
	if Engine.is_editor_hint():
		DBENGINE = DatabaseEngine.new()
		root_node = get_tree().get_edited_scene_root().get_child(get_index())
		event_list = DBENGINE.list_files_with_param(DBENGINE.table_save_path + DBENGINE.event_folder, DBENGINE.table_file_format)
		connect("draw",_on_event_draw)

	else:
		DBENGINE = FARTENGINE
		event_list = DBENGINE.list_files_with_param(DBENGINE.table_save_path + DBENGINE.event_folder, DBENGINE.table_file_format)
		is_updating_animations = true
		await DBENGINE.map_loaded
		
		set_initial_in_game_values()


		if event_name != "":
			set_initial_values()


			await add_sprite_and_collision()

			if active_page != "":
				autorun_commands()
				interaction_area.monitoring = true
#			else:
#				clear_event_children()

	set_event_node_default_settings()
	is_updating_animations = false
	event_info_loaded = true


func connect_signals():
	if !Engine.is_editor_hint():
		DBENGINE.save_game_data.connect(save_game_data)
		interaction_area.area_entered.connect(interaction_area_entered)
		player_exited_interaction_area.connect(player_interaction_excited)
		player_entered_interaction_area.connect(player_interaction_entered)


func player_damage_entered(area):
	if area.get_parent() == FARTENGINE.player_node:
		player_is_in_damage_area = true

func player_damage_exited(area):
	if area.get_parent() == FARTENGINE.player_node:
		player_is_in_damage_area = false


func player_interaction_entered():
	if triggerIndex == "2": #Touch and Interact
		set_interaction_shader()
	character_is_in_interaction_area = true
	interaction_area_entered(self)


func player_interaction_excited():
	clear_interaction_shader()
	character_is_in_interaction_area = false


func set_interaction_shader():
	sprite_animation.set_material(interaction_shader_material)

func clear_interaction_shader():
	if sprite_animation != null:
		sprite_animation.set_material(null)

func set_event_node_default_settings():
	set_collision_layer_value(1, false)
	set_collision_layer_value(2, true)
	set_collision_mask_value(2, true)
	add_to_group("Events")
	set_slide_on_ceiling_enabled(true)
	set_floor_stop_on_slope_enabled(true)
	set_motion_mode(0)
	set_floor_snap_length(0.0)
	set_platform_floor_layers(0)
	set_floor_max_angle(deg_to_rad(180))
	connect_signals()


func set_initial_in_game_values():
	
	root_node = self
	current_map_key = DBENGINE.current_map_key
	DBENGINE.get_event_save_dict()
	create_event_data_dict()
	var Name = name
	var event_position = DBENGINE.save_game_data_dict[current_map_key][name]["Position"]
#	create_event_data_dict()
#	event_dict = get_event_dict(event_name)

	if DBENGINE.save_game_data_dict[current_map_key].has(name):
#		update_event_data()
		var attached_event_editor :String = event_name
		var attached_event_save_file :String = DBENGINE.save_game_data_dict[current_map_key][name]["Attached Event"]["text"]
		if attached_event_editor != attached_event_save_file:
			DBENGINE.save_game_data_dict[current_map_key][name]  = {}
			create_event_data_dict()

	event_position = DBENGINE.save_game_data_dict[current_map_key][name]["Position"]
	var posvect :Vector2 = DBENGINE.convert_string_to_vector(str(event_position))
	set_global_position(posvect)
	
#	local_variables_dict = DBENGINE.convert_string_to_type(DBENGINE.save_game_data_dict[current_map_key][name]["Local Variables"])
#	options_button_variables_dict = DBENGINE.convert_string_to_type(DBENGINE.save_game_data_dict[current_map_key][name]["Event Dialog Variables"])


func set_initial_values():
	event_dict = get_event_dict(event_name)
	active_page = get_active_event_page()
	set_active_page_variables()


func get_trigger_index(triggerKey:String):
	triggerIndex = triggerKey
	return triggerIndex


func _on_event_draw():
	if event_name != "":
		clear_event_children()
		event_dict = get_event_dict(event_name)
		active_page = "1"
#		var DBENGINE :DatabaseEngine = DatabaseEngine.new()
#		loop_animation = DBENGINE.convert_string_to_type(event_dict[active_page]["Loop Animation"])
#		DBENGINE.queue_free()
		add_sprite_and_collision()


func emit_refresh_event_signal():
	map_node.refresh_events()


func _process(delta):
	if !Engine.is_editor_hint() and get_tree().get_edited_scene_root() == null:
		event_damage_player()
		if character_is_in_interaction_area:
			match event_trigger:
				"2": #Touch and "action_pressed" 
					if action_button_pressed and !is_interaction_in_progress:
						await run_commands()
		if event_trigger == "4": #loop continuosly while conditions are true
			await run_commands()
		else:
			autorun_commands()



func event_damage_player():
	if damage_player_on_touch and !is_damage_cooldown_active and player_is_in_damage_area:
		FARTENGINE.damage_player(damage_amount, knockback_power, self.position)
		damage_cooldown_timer()


func damage_cooldown_timer():
	is_damage_cooldown_active = true
	await get_tree().create_timer(damage_cooldown_time).timeout
	is_damage_cooldown_active = false


func _physics_process(delta):
	if !is_queued_for_delete:
		if !Engine.is_editor_hint():
			state_machine(delta)
			move_and_slide()


func autorun_commands():
	if autorun_complete:
		match event_trigger:
			"3": #Immediately
				autorun_complete = false
#				await get_tree().process_frame
				await run_commands()
				autorun_complete = true
#				emit_refresh_event_signal()


func state_machine(delta):
	if does_event_move :
		match state:
			"Idle":
				idle_movement(delta)

			"Move Towards Player":
				move_toward_player(delta)

			"Random Movement":
				random_movement(delta)

#	else:
#		static_movement(delta)


#func static_movement(delta):
#	if !is_updating_animations:
#		var sprite_texture_data  :Dictionary
#		if Engine.is_editor_hint() or sprite_animation == null:
#			pass
##			DBENGINE = DatabaseEngine.new()
##			sprite_texture_data = DBENGINE.convert_string_to_type(event_dict[active_page]["Default Animation"])
#		else:
#			sprite_texture_data = DBENGINE.convert_string_to_type(event_dict[active_page]["Default Animation"])
#
##		if loop_animation:
##			if draw_shadow:
##				set_shadow("Default Animation", sprite_texture_data)
##				shadow_sprite_animation.play("Default Animation")
##			sprite_animation.play("Default Animation")
#
#
#
#
#
#
#				#var sprite_texture_data  :Dictionary = DBENGINE.convert_string_to_type(event_dict[active_page]["Default Animation"])
##				var sprite_atlas_dict :Dictionary = sprite_texture_data["atlas_dict"]
##				var sprite_advanced_dict :Dictionary = sprite_texture_data["advanced_dict"]
##				var begin_frame :int = DBENGINE.convert_string_to_vector(sprite_advanced_dict["frame_range"]).x
##				sprite_animation.play("Default Animation")
##				sprite_animation.stop()
##				sprite_animation.set_frame(begin_frame - 1)
#			if draw_shadow:
##					set_shadow("Default Animation", sprite_texture_data)
#				shadow_sprite_animation.play("Default Animation")
##					shadow_sprite_animation.stop()
##					shadow_sprite_animation.set_frame(begin_frame - 1)
##				sprite_animation.play("Default Animation")
#			call_deferred("enable_collision","Default Animation")
#			DBENGINE.set_sprite_scale(sprite_animation,"Default Animation" , sprite_texture_data)
#	velocity = velocity.move_toward(Vector2.ZERO, friction * delta)


func random_movement(delta):
	if !timer_running:
		direction = get_next_direction()
		var time :float = randi_range(5, 10)
		timer_running = true
		await get_tree().create_timer(time).timeout
		timer_running = false
	move_event(delta)


func get_next_direction() -> Vector2:
	randomize()
	var dirX :float = randf_range(-.99, .99)
	var dirY :float = randf_range(-.99, .99)
	return Vector2(dirX, dirY)


func idle_movement(delta):
	if !is_updating_animations:
		play_event_sprite_animation(idle)
	velocity = velocity.move_toward(Vector2.ZERO, friction * delta)


func move_toward_player(delta):
	if player_node != null:
		direction = (player_node.global_position - global_position).normalized()
		move_event(delta)


func move_event(delta):
	if direction.x < 0 and abs(direction.y) < abs(direction.x):
		play_event_sprite_animation(walk_left)
	elif direction.x > 0 and abs(direction.y) < abs(direction.x):
		play_event_sprite_animation(walk_right)
	elif direction.y < 0:
		play_event_sprite_animation(walk_up)
	elif direction.y > 0:
		play_event_sprite_animation(walk_down)
	velocity = set_character_velocity(velocity,direction,max_speed,friction,acceleration,false,delta)


func play_event_sprite_animation(animation_name: String):
	if !is_updating_animations and !is_queued_for_delete:
		sprite_animation.play(animation_name)
		enable_collision(animation_name)
		DBENGINE.set_sprite_scale(sprite_animation,animation_name , event_animation_dictionary)
#		if draw_shadow:
#			set_shadow(animation_name)


func play_sprite_animation_static_or_editor(sprite_texture_data: Dictionary):
	if is_instance_valid(sprite_animation.sprite_frames):
		if sprite_animation.sprite_frames.has_animation("Default Animation"):
			var sprite_atlas_dict :Dictionary = sprite_texture_data["atlas_dict"]
			var sprite_advanced_dict :Dictionary = sprite_texture_data["advanced_dict"]
			var begin_frame :int = DBENGINE.convert_string_to_vector(sprite_advanced_dict["frame_range"]).x
			sprite_animation.play("Default Animation")
#	sprite_animation.stop()
#	sprite_animation.set_frame(begin_frame - 1)
#	if draw_shadow:
#		shadow_sprite_animation.play("Default Animation")
#		shadow_sprite_animation.stop()
#		shadow_sprite_animation.set_frame(begin_frame - 1)


func set_shadow(animation_name :String, texture_data :Dictionary = event_animation_dictionary):
	
#	var scale_size = shadow_sprite_animation.get_scale()
#	shadow_sprite_animation.set_scale(Vector2(shadow_sprite_animation.scale.x,shadow_sprite_animation.scale.y))
	shadow_sprite_frames = shadow_sprite_animation.sprite_frames
	if texture_data.has("animation_dictionary"):
		texture_data  = DBENGINE.convert_string_to_type(texture_data["animation_dictionary"][animation_name])
	var atlas_dict :Dictionary = texture_data["atlas_dict"]
	var advanced_dict :Dictionary  = texture_data["advanced_dict"]
	var sprite_texture = load(DBENGINE.table_save_path + DBENGINE.icon_folder + atlas_dict["texture_name"])
	var sprite_frame_size:Vector2 = DBENGINE.convert_string_to_vector(str(atlas_dict["frames"]))
	var sprite_final_size = advanced_dict["sprite_size"]
	var sprite_cell_size := Vector2(sprite_texture.get_size().x / sprite_frame_size.y ,sprite_texture.get_size().y / sprite_frame_size.x)
	DBENGINE.set_sprite_scale(shadow_sprite_animation,animation_name , texture_data)
#	shadow_sprite_animation.set_material(shadow_shader)
#	shadow_sprite_animation.material.set_shader_parameter("sprite_size", sprite_cell_size)


func add_shadow_animation():
	shadow_sprite_animation.set_name("ShadowSprite")
	shadow_sprite_frames = shadow_sprite_animation.sprite_frames
	shadow_sprite_animation.show_behind_parent = true
	add_child(shadow_sprite_animation)



func set_editor_or_static_shadow():
	shadow_sprite_animation = AnimatedSprite2D.new()
	var shadow_sprite_texture_data :Dictionary = DBENGINE.convert_string_to_type(event_dict[active_page]["Default Animation"])
	set_default_animation(shadow_sprite_texture_data, shadow_sprite_animation)
	set_shadow("Default Animation", shadow_sprite_texture_data)


func set_default_animation(sprite_texture_data, animation_player):
	var sprite_atlas_dict :Dictionary = sprite_texture_data["atlas_dict"]
	var sprite_advanced_dict :Dictionary = sprite_texture_data["advanced_dict"]
	var sprite_texture = load(DBENGINE.table_save_path + DBENGINE.icon_folder + sprite_atlas_dict["texture_name"])
	var sprite_texture_name:String =  sprite_atlas_dict["texture_name"]
	if sprite_texture_name != "Blank.png":
		var sprite_frame_size:Vector2 = DBENGINE.convert_string_to_vector(str(sprite_atlas_dict["frames"]))
		var sprite_final_size :Vector2 = DBENGINE.convert_string_to_vector(str(sprite_advanced_dict["sprite_size"]))
		var sprite_cell_size := Vector2(sprite_texture.get_size().x / sprite_frame_size.y ,sprite_texture.get_size().y / sprite_frame_size.x)
		var modified_sprite_size_y = sprite_final_size.x
		var modified_sprite_size_x = sprite_final_size.y
		var y_scale_value = modified_sprite_size_y / sprite_cell_size.y
		var x_scale_value = modified_sprite_size_x / sprite_cell_size.x
		animation_player.set_scale(Vector2(x_scale_value, y_scale_value))
		DBENGINE.add_animation_to_animatedSprite("Default Animation", sprite_texture_data, animation_player,false)
		if !loop_animation:
			animation_player.sprite_frames.set_animation_loop("Default Animation", false)
#		animation_player.stop()
#		animation_player.play()
#		animation_player.sprite_frames.set_animation_speed("Default Animation", 5.0)
#		print(animation_player.sprite_frames.get_animation_loop("Default Animation"))
#	await get_tree().process_frame


func clear_event_animations():
	for child_node in get_children():
		if is_instance_valid(child_node):
			if child_node.get_class() == "AnimatedSprite2D":
				child_node.name = child_node.name + "Q"
				child_node.queue_free()
#	print("animations cleared")
	await get_tree().process_frame
func remove_collisions():
	for child in get_children():
		if child is CollisionShape2D:
			child.queue_free()


func enable_collision(collision_name :String):
	if !is_queued_for_delete and collide_with_player:
		if get_node(collision_name + " Collision").disabled == true:
			disable_all_collisions()
			get_node(collision_name + " Collision").disabled = false
			get_node(collision_name + " Collision").visible = true


func disable_all_collisions():
	for i in get_children():
		if i is CollisionShape2D:
			i.disabled = true
			i.visible = false

func _input(event): #CHANGE THIS TO RECIEVE SIGNAL FROM CHARACTER ENGINE BASED ON IF BUTTON IS ASSINGED TO INTERACTION/DIALOG ACTION TYPE
	#THIS MIGHT IMPROVE PERFORMACE SINCE EACH EVENT WON'T BE CONSTATNLY LOOKING FOR INPUT
	if Input.is_action_just_pressed("Interact_Advance Dialog"):
		if is_interaction_in_progress:
			DBENGINE.EVENTS.DIALOG.next_message()

		elif can_interact and !action_button_pressed and character_is_in_interaction_area:
			action_button_pressed = true





func save_game_data():
	DBENGINE.set_save_game_data()
	
	
func create_event_data_dict():
	if DBENGINE.save_game_data_dict[current_map_key].has(name) and DBENGINE.save_game_data_dict[current_map_key][name] == {}:
		DBENGINE.save_game_data_dict[current_map_key][name] =  {"Position":get_global_position()}
		DBENGINE.save_game_data_dict[current_map_key][name]["Local Variables"] = DBENGINE.import_data("Local Variables")["1"]
		DBENGINE.save_game_data_dict[current_map_key][name]["Local Variables"].erase("Display Name")
		DBENGINE.save_game_data_dict[current_map_key][name]["Local Variables"] = {"input_dict": DBENGINE.save_game_data_dict[current_map_key][name]["Local Variables"]}
		DBENGINE.save_game_data_dict[current_map_key][name]["Local Variables"]["options_dict"] = {"action": "4"}

		DBENGINE.save_game_data_dict[current_map_key][name]["Event Dialog Variables"] = DBENGINE.import_data("Event Dialog Variables")["1"]
		DBENGINE.save_game_data_dict[current_map_key][name]["Event Dialog Variables"].erase("Display Name")
		DBENGINE.save_game_data_dict[current_map_key][name]["Event Dialog Variables"] = {"input_dict": DBENGINE.save_game_data_dict[current_map_key][name]["Event Dialog Variables"]}
		DBENGINE.save_game_data_dict[current_map_key][name]["Event Dialog Variables"]["options_dict"] = {"action": "4"}
	
		DBENGINE.save_game_data_dict[current_map_key][name]["Attached Event"] = {"text" : event_name}







#func interaction_area_exited(area):
#	if area.get_parent() == FARTENGINE.player_node:
#		player_damage_exited()

func interaction_area_entered(area): #Player touch
#	if area.get_parent() == FARTENGINE.player_node:
#		player_damage_entered()
	
	if !is_interaction_in_progress:
		if event_trigger == "1" and character_is_in_interaction_area and can_interact: #Player Touch
			await run_commands()
		elif area.get_parent().get_class() == get_class() and can_interact:
			if event_trigger == "5": #another event touches this event
				await run_commands()


func run_commands():
	can_interact = false
	is_interaction_in_progress = true
	await call_commands()#Run script
	await get_tree().process_frame
	emit_refresh_event_signal()
	action_button_pressed = false
	is_interaction_in_progress = false
	can_interact = true


func attack_player_area_exited(area):
	state = previous_state


func attack_player_area_entered(area): #Player touch
	if !is_interaction_in_progress and state != "Move Towards Player":
		previous_state = state
		state = "Move Towards Player"


func call_commands():
	if command_dict != {}:
		for command_index in command_dict:
			var function_name :String = command_dict[command_index].keys()[0]
			var variable_array: Array = command_dict[command_index][function_name]
			var temp_variable_array :Array
			for index in variable_array:
				var variable_with_type = DBENGINE.convert_string_to_type(index)
				temp_variable_array.append(variable_with_type)
			temp_variable_array.append(name)
			temp_variable_array.append(self)
			variable_array = temp_variable_array
			await DBENGINE.EVENTS.callv(function_name, variable_array)
#			await get_tree().process_frame
	else:
		print("Command dict is empty")
#	await get_tree().create_timer(0.1).timeout



func get_event_dict(event_name:String):
	var all_events_dict := {}
	var this_event_dict:= {}
	for eventName in event_list:
		var array = []
		array = eventName.rsplit(".")
		eventName = array[0]
		all_events_dict[eventName] = DBENGINE.import_event_data(eventName)
	this_event_dict = all_events_dict[event_name]
	return this_event_dict


func get_active_event_page() -> String:
	var active_page :String = "" 
	var conditions_met :bool = true
	if !Engine.is_editor_hint():
		current_map_key  = DBENGINE.current_map_key
		for page in range(event_dict.size() - 1,0,-1): #Loop through event pages starting with LAST page but dont include index 0
			var page_string :String = str(page)
			var conditions_dict :Dictionary = DBENGINE.convert_string_to_type(event_dict[page_string]["Conditions"])
			if conditions_dict != {}:
				for condition in conditions_dict:
					var datatype:String = conditions_dict[condition]["Datatype"]
					var compare_right_value
					var compare_left_value = DBENGINE.convert_string_to_type(get_condition_value(conditions_dict, condition, "Compare Left"),datatype)
					var is_static:bool = conditions_dict[condition]["Is Static"]

					if is_static:
						compare_right_value = DBENGINE.convert_string_to_type(conditions_dict[condition]["Static Value 1"],datatype)
					else:
						compare_right_value = DBENGINE.convert_string_to_type(get_condition_value(conditions_dict, condition, "Variable Value"),datatype)

					var is_datatype_numeric:bool = DBENGINE.get_field_value("DataTypes", datatype, "Is Number", false)
					
					if is_datatype_numeric:
						var static_value_2 = DBENGINE.convert_string_to_type(conditions_dict[condition]["Static Value 2"],datatype)
						var optional_operations = conditions_dict[condition]["Optional Operations"]
						compare_right_value = apply_operator(compare_right_value, static_value_2, optional_operations)

					var inequality = conditions_dict[condition]["Inequalities"]
					conditions_met = compare_condition_values(compare_left_value, compare_right_value, inequality)

					var is_and:bool = conditions_dict[condition]["Is And"]
					if is_and:#if AND:  All AND's must be true if any are false, break and return false
						if !conditions_met:
							conditions_met = false
							break
					else: #IF ANY OR's are true, return true
						if conditions_met == true:
							break
			else: #if there are no conditions
				conditions_met = true
			if conditions_met == true:
				active_page = str(page)
				break
	else:
		active_page = "1"
	return active_page



func apply_operator(value1, value2, operator):
	var return_value
	match operator:
		"1":#+
			return_value = value1 + value2
		"2":#-
			return_value = value1 - value2
		"3":#*
			return_value = value1 * value2
		"4":#/
			return_value = value1 / value2
		"5":#%
			return_value = roundi(value1) % roundi(value2)
	return return_value


func compare_condition_values(value1, value2, inequality):
	var return_value:bool
	var value1_type = typeof(value1)

	if value1_type == TYPE_VECTOR2 or value1_type == TYPE_VECTOR3:
		value1 = value1.normalized()
		value2 = value2.normalized()
	match inequality:
		"1":#>
			return_value = value1 > value2
		"2":#<
			return_value = value1 < value2
		"3":#==
			return_value = value1 == value2
		"4":#!=
			return_value = value1 != value2
		"5":#>=
			return_value = value1 >= value2
		"6":#<=
			return_value = value1 <= value2
	return return_value


func get_condition_value(conditions_dict:Dictionary, condition:String, fieldID:String):
	var compare_dict :Dictionary = conditions_dict[condition][fieldID]
	var table_ID:String = compare_dict["TableID"]
	var key_ID: String =  compare_dict["KeyID"]
	var field_ID = compare_dict["FieldID"]
	var condition_value

	if table_ID == "Local Variables":
		var local_variables_dict = DBENGINE.convert_string_to_type(DBENGINE.save_game_data_dict[current_map_key][name]["Local Variables"]["input_dict"])
		condition_value = local_variables_dict[field_ID]
	
	elif table_ID == "Event Dialog Variables":
		var options_button_variables_dict = DBENGINE.convert_string_to_type(DBENGINE.save_game_data_dict[current_map_key][name]["Event Dialog Variables"]["input_dict"])
		condition_value = options_button_variables_dict[field_ID]
	else:
		condition_value = DBENGINE.get_field_value(table_ID, key_ID, field_ID, true)
	
	return condition_value


func get_global_variable_index_name_from_display_name(If_Key_Name_DropDown):
	var global_variable_dict :Dictionary = DBENGINE.Dynamic_Game_Dict["Global Variables"]
	var index
	for id in global_variable_dict:
		if DBENGINE.get_text(global_variable_dict[id]["Display Name"]) == If_Key_Name_DropDown:
			index = id
	return index


func refresh_event_data():
	if !is_refreshing:
		if !is_queued_for_delete:
#			visible = false
##			sprite_animation.stop()
#			call_deferred("queue_free")
#		else:
			var current_active_page := active_page
			active_page = get_active_event_page()
			if active_page != "":

				if current_active_page != active_page:

					set_active_page_variables()
					is_updating_animations = true
					clear_event_children()
					add_sprite_and_collision()
					is_updating_animations = false
#			else:
#				clear_event_children()
		else:
			call_deferred("queue_free")
		is_refreshing = false


func set_active_page_variables():
	command_dict = DBENGINE.convert_string_to_type(event_dict[active_page]["Commands"])
	event_trigger = get_trigger_index(event_dict[active_page]["Event Trigger"])
	does_event_move = DBENGINE.convert_string_to_type(event_dict[active_page]["Does Event Move?"])
	attack_player = DBENGINE.convert_string_to_type(event_dict[active_page]["Attack Player?"])
	animation_group = event_dict[active_page]["Animation Group"]
	loop_animation = DBENGINE.convert_string_to_type(event_dict[active_page]["Loop Animation"])
	max_speed = DBENGINE.convert_string_to_type(event_dict[active_page]["Max Speed"])
	acceleration = DBENGINE.convert_string_to_type(event_dict[active_page]["Acceleration"])
	friction = DBENGINE.convert_string_to_type(event_dict[active_page]["Friction"])
	draw_shadow = DBENGINE.convert_string_to_type(event_dict[active_page]["Draw Shadow?"])
	damage_player_on_touch = DBENGINE.convert_string_to_type(event_dict[active_page]["Damage Player on Touch"])
	knockback_power = DBENGINE.convert_string_to_type(event_dict[active_page]["Knockback Power"])
	damage_cooldown_time = DBENGINE.convert_string_to_type(event_dict[active_page]["Damage Cooldown Time"])
	damage_amount = DBENGINE.convert_string_to_type(event_dict[active_page]["Damage Amount"])


func add_sprite_and_collision():
	var active_page_data :Dictionary = DBENGINE.convert_string_to_type(event_dict[active_page])
	var sprite_texture_data :Dictionary = DBENGINE.convert_string_to_type(active_page_data["Default Animation"])
	does_event_move = DBENGINE.convert_string_to_type(event_dict[active_page]["Does Event Move?"])
	collide_with_player = DBENGINE.convert_string_to_type(event_dict[active_page]["Collide with Player?"])
	if Engine.is_editor_hint() or !does_event_move:
		await set_editor_or_static_animation(sprite_texture_data)

#		if draw_shadow:
#			set_editor_or_static_shadow()
#			add_shadow_animation()

		
#		sprite_animation.play("Default Animation")
#		if draw_shadow:
#			shadow_sprite_animation.play("Default Animation")
#		else:
		play_sprite_animation_static_or_editor(sprite_texture_data)
	else :
		add_and_play_animation_group()

#		if draw_shadow:
#			add_shadow_animation()

	if collide_with_player:
		set_collision_area(sprite_texture_data)

	set_interaction_area(sprite_texture_data)
	if attack_player and does_event_move:
		set_attack_player_area(sprite_texture_data)


func add_and_play_animation_group():
	event_animation_dictionary = DBENGINE.add_sprite_group_to_animatedSprite(self, animation_group)
	event_shadow_dictionary = DBENGINE.add_sprite_group_to_animatedSprite(self, animation_group)
	sprite_animation = event_animation_dictionary["animated_sprite"]
	shadow_sprite_animation = event_shadow_dictionary["animated_sprite"]
	add_child(sprite_animation)
	sprite_animation.play("Idle")


func set_editor_or_static_animation(sprite_texture_data:Dictionary):
#	await clear_event_animations()
	sprite_animation = AnimatedSprite2D.new()
	sprite_animation.set_name("event_sprite")
	sprite_texture_data  = DBENGINE.convert_string_to_type(event_dict[active_page]["Default Animation"])
	
	set_default_animation(sprite_texture_data, sprite_animation)

	add_child(sprite_animation)


#	sprite_animation.set_owner(self)


func set_collision_area(sprite_texture_data:Dictionary):
	collision_node = DBENGINE.get_collision_shape("Default Animation", sprite_texture_data)
	add_child(collision_node)
	collision_node.disabled = false


func set_interaction_area(sprite_texture_data:Dictionary):
	interaction_area = DBENGINE.create_event_interaction_area("Default Animation", sprite_texture_data)
	add_child(interaction_area)
#	call_deferred("add_child", interaction_area)
	interaction_area.set_collision_layer_value(1, false)
	interaction_area.set_collision_layer_value(2, false)
	interaction_area.set_collision_layer_value(3, true)
	interaction_area.set_collision_mask_value(1, false)
	interaction_area.set_collision_mask_value(2, false)
	interaction_area.set_collision_mask_value(3, true)
	interaction_area.monitoring = true
	interaction_area.area_entered.connect(player_damage_entered)
	interaction_area.area_exited.connect(player_damage_exited)

func set_attack_player_area(sprite_texture_data:Dictionary):
	attack_area = DBENGINE.create_event_attack_area("Default Animation", sprite_texture_data)
	call_deferred("add_child", attack_area)
	attack_area.area_entered.connect(attack_player_area_entered)
	attack_area.area_exited.connect(attack_player_area_exited)
	attack_area.set_collision_layer_value(1, false)
	attack_area.set_collision_layer_value(2, false)
	attack_area.set_collision_mask_value(1, false)
	attack_area.set_collision_mask_value(2, false)
	attack_area.set_collision_mask_value(4, true)
	attack_area.monitoring = true


func clear_event_children():
	if root_node.get_child_count() != 0:
		for child in root_node.get_children():
			var childname :String = child.name
			child.name = childname + "1"
			child.call_deferred("queue_free")
			#child.queue_free()


func show_event_toolbar_in_editor(selected_node_name):
	event_node_name = selected_node_name


func is_new_event_object() -> void:
	pass
