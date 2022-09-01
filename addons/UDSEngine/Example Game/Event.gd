@tool
extends CharacterBody2D
class_name EventHandler

signal player_entered_interaction_area
signal player_exited_interaction_area

@onready var DBENGINE :DatabaseEngine = DatabaseEngine.new()
@export var event_name :String = ""

var root_node : EventHandler
var collision_node :CollisionShape2D
var sprite_animation :AnimatedSprite2D
var shadow_sprite_animation :AnimatedSprite2D
var shadow_sprite_frames :SpriteFrames
var event_animation_dictionary :Dictionary = {}
var event_shadow_dictionary :Dictionary = {}
var interaction_area :Area2D
var attack_area :Area2D
var event_list :Dictionary = {}
var event_dict :Dictionary = {}
var event_node_name := ""
var event_trigger := ""
var active_page := ""
var is_in_editor := false
var local_variables_dict :Dictionary = {}
var current_map_name : String 
var is_queued_for_delete :bool = false
var character_is_in_interaction_area :bool = false
var is_interaction_in_progress :bool = false
var autorun_complete :bool = false
var event_info_loaded := false
var map_node
var player_node
var player_interaction_area
var timer_running :bool = false
var direction :Vector2
var is_updating_animations :bool = false
var can_interact :bool = true
var action_button_pressed:bool = false


var state :String = "Idle"
var previous_state :String
var does_event_move :bool
var attack_player :bool
var max_speed :int 
var acceleration :int 
var friction :int 
var animation_group :String
var draw_shadow :bool
var loop_animation :bool = true
var idle = "Idle"
var walk_left = "Walk Left"
var walk_right ="Walk Right"
var walk_up = "Walk Up"
var walk_down ="Walk Down"


func _ready() -> void:


	if get_tree().get_edited_scene_root() != null:
		is_in_editor = true
		root_node = get_tree().get_edited_scene_root().get_child(get_index())
		connect("draw",_on_event_draw)
	else:
		is_updating_animations = true
		await udsmain.map_loaded
		set_initial_in_game_values()

	if event_name != "":
		set_initial_values()
		await add_sprite_and_collision()
		
		if active_page != "":
			autorun_commands()
			interaction_area.monitoring = true
		else:
			clear_event_children()

	set_event_node_default_settings()
	is_updating_animations = false
	event_info_loaded = true


func connect_signals():
	udsmain.save_game_data.connect(update_event_data)
	interaction_area.area_entered.connect(interaction_area_entered)
	player_exited_interaction_area.connect(player_interaction_excited)
	player_entered_interaction_area.connect(player_interaction_entered)

func player_interaction_entered():
	set_interaction_shader()
	character_is_in_interaction_area = true
	interaction_area_entered(self)

func player_interaction_excited():
	clear_interaction_shader()
	character_is_in_interaction_area = false


func set_interaction_shader():
	var interaction_shader_material :ShaderMaterial = load("res://addons/UDSEngine/Event_Manager/2dOutline_Material.tres")
	sprite_animation.set_material(interaction_shader_material)

func clear_interaction_shader():
	sprite_animation.set_material(null)

func set_event_node_default_settings():
	set_collision_layer_value(1, false)
	set_collision_layer_value(2, true)
	set_collision_mask_value(2, true)
	set_motion_mode(CharacterBody2D.MOTION_MODE_FLOATING)
#	set_moving_platform_apply_velocity_on_leave(CharacterBody2D.PLATFORM_VEL_ON_LEAVE_NEVER)
	add_to_group("Events")
	connect_signals()


func set_initial_in_game_values():
	root_node = self
	current_map_name = udsmain.current_map_name
	event_dict = get_event_dict()
	var pos :Vector2 = get_global_position()
	if !name in udsmain.Dynamic_Game_Dict["Event Save Data"][current_map_name]:
		update_event_data()
		var attached_event_editor :String = event_name
		var attached_event_save_file :String = udsmain.Dynamic_Game_Dict["Event Save Data"][current_map_name][name]["Attached Event"]
		if attached_event_editor != attached_event_save_file:
			udsmain.Dynamic_Game_Dict["Event Save Data"][current_map_name][name]["Position"] =  pos
			udsmain.Dynamic_Game_Dict["Event Save Data"][current_map_name][name]["Local Variables"] = event_dict["1"]["Local Variables"]
			udsmain.Dynamic_Game_Dict["Event Save Data"][current_map_name][name]["Attached Event"] = event_name

	var event_position = udsmain.Dynamic_Game_Dict["Event Save Data"][current_map_name][name]["Position"]
	var posvect :Vector2 = udsmain.convert_string_to_vector(str(event_position))
	set_global_position(posvect)
	
	local_variables_dict = udsmain.convert_string_to_type(udsmain.Dynamic_Game_Dict["Event Save Data"][current_map_name][name]["Local Variables"])


func set_initial_values():
#	if event_name != "":
	event_dict = get_event_dict()
	active_page = get_active_event_page()
	animation_group = event_dict[active_page]["Animation Group"]
	var DBENGINE :DatabaseEngine = DatabaseEngine.new()
	
	loop_animation = DBENGINE.convert_string_to_type(event_dict[active_page]["Loop Animation"])
	attack_player = DBENGINE.convert_string_to_type(event_dict[active_page]["Attack Player?"])
	does_event_move = DBENGINE.convert_string_to_type(event_dict[active_page]["Does Event Move?"])
	draw_shadow = DBENGINE.convert_string_to_type(event_dict[active_page]["Draw Shadow?"])
	event_trigger = event_dict[active_page]["Event Trigger"]
	max_speed = DBENGINE.convert_string_to_type(event_dict[active_page]["Max Speed"])
	acceleration = DBENGINE.convert_string_to_type(event_dict[active_page]["Acceleration"])
	friction = DBENGINE.convert_string_to_type(event_dict[active_page]["Friction"])
	DBENGINE.queue_free()


func _on_event_draw():
	if event_name != "":
		clear_event_children()
		event_dict = get_event_dict()
		active_page = get_active_event_page()
		var DBENGINE :DatabaseEngine = DatabaseEngine.new()
		loop_animation = DBENGINE.convert_string_to_type(event_dict[active_page]["Loop Animation"])
		DBENGINE.queue_free()
		add_sprite_and_collision()


func emit_refresh_event_signal():
	map_node.emit_signal("update_events")


func _physics_process(delta):
	if !is_queued_for_delete:
		if !is_in_editor:
			state_machine(delta)
			move_and_slide()


func state_machine(delta):
	if does_event_move :
		match state:
			"Idle":
				idle_movement(delta)

			"Move Towards Player":
				move_toward_player(delta)

			"Random Movement":
				random_movement(delta)

	else:
		static_movement(delta)


func static_movement(delta):
	if !is_updating_animations:
		var sprite_texture_data  :Dictionary = DBENGINE.convert_string_to_type(event_dict[active_page]["Default Animation"])
		if loop_animation:
			sprite_animation.play("Default Animation")
			if draw_shadow:
				shadow_sprite_animation.play("Default Animation")
		else:
			#var sprite_texture_data  :Dictionary = DBENGINE.convert_string_to_type(event_dict[active_page]["Default Animation"])
			var sprite_atlas_dict :Dictionary = sprite_texture_data["atlas_dict"]
			var sprite_advanced_dict :Dictionary = sprite_texture_data["advanced_dict"]
			var begin_frame :int = sprite_advanced_dict["frame_range"].x
			sprite_animation.play("Default Animation")
			sprite_animation.stop()
			sprite_animation.set_frame(begin_frame - 1)
			if draw_shadow:
				set_shadow("Default Animation", sprite_texture_data)
				shadow_sprite_animation.play("Default Animation")
				shadow_sprite_animation.stop()
				shadow_sprite_animation.set_frame(begin_frame - 1)
		call_deferred("enable_collision","Default Animation")
		udsmain.set_sprite_scale(sprite_animation,"Default Animation" , sprite_texture_data)
	velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

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
		play_sprite_animation(idle)
	velocity = velocity.move_toward(Vector2.ZERO, friction * delta)


func move_toward_player(delta):
	if player_node != null:
		direction = (player_node.global_position - global_position).normalized()
		move_event(delta)


func move_event(delta):

#		direction = (player_node.global_position - global_position).normalized()
	if direction.x < 0 and abs(direction.y) < abs(direction.x):
		play_sprite_animation(walk_left)
	elif direction.x > 0 and abs(direction.y) < abs(direction.x):
		play_sprite_animation(walk_right)
	elif direction.y < 0:
		play_sprite_animation(walk_up)
	elif direction.y > 0:
		play_sprite_animation(walk_down)
	velocity = velocity.move_toward(direction * max_speed, acceleration * delta)
#		sprite_animation.flip_h = velocity.x < 0 #useful and easy but will have to set animation based on 
												#event direction, using sprite group

func play_sprite_animation(animation_name: String):
	if !is_updating_animations and !is_queued_for_delete:
		sprite_animation.play(animation_name)
		enable_collision(animation_name)
		udsmain.set_sprite_scale(sprite_animation,animation_name , event_animation_dictionary)
		if draw_shadow:
			set_shadow(animation_name)

func play_sprite_animation_static_or_editor(sprite_texture_data: Dictionary):
	var sprite_atlas_dict :Dictionary = sprite_texture_data["atlas_dict"]
	var sprite_advanced_dict :Dictionary = sprite_texture_data["advanced_dict"]
	var begin_frame :int = sprite_advanced_dict["frame_range"].x
	sprite_animation.play("Default Animation")
	sprite_animation.stop()
	sprite_animation.set_frame(begin_frame - 1)
	if draw_shadow:
		shadow_sprite_animation.play("Default Animation")
		shadow_sprite_animation.stop()
		shadow_sprite_animation.set_frame(begin_frame - 1)


func set_shadow(animation_name :String, texture_data :Dictionary = event_animation_dictionary):
	shadow_sprite_animation.play(animation_name)
	udsmain.set_sprite_scale(shadow_sprite_animation,animation_name , texture_data)
	var scale_size = shadow_sprite_animation.get_scale()
	shadow_sprite_animation.set_scale(Vector2(shadow_sprite_animation.scale.x * .90,shadow_sprite_animation.scale.y * .90))
	shadow_sprite_frames = shadow_sprite_animation.frames
	var frame_size = shadow_sprite_frames.get_frame(animation_name, 0).get_size()
	var final_frame_size :Vector2 = Vector2(scale_size.x * frame_size.x, scale_size.y * frame_size.y) * .75
	var skew_adjustment :Vector2 = Vector2(frame_size.x * .7 , frame_size.y * .4)
	shadow_sprite_animation.set_offset(skew_adjustment)


func remove_collisions():
	for child in get_children():
		if child is CollisionShape2D:
			child.queue_free()
#	await get_tree().create_timer(0.02).timeout


func enable_collision(collision_name :String):
	if !is_queued_for_delete:
		if get_node(collision_name + " Collision").disabled == true:
			disable_all_collisions()
			get_node(collision_name + " Collision").disabled = false
			get_node(collision_name + " Collision").visible = true


func disable_all_collisions():
	for i in get_children():
		if i is CollisionShape2D:
			i.disabled = true
			i.visible = false

func _input(event):
	if Input.is_action_just_pressed("action_pressed"):
		if is_interaction_in_progress:
			udsmain.EVENTS.DIALOG.next_message()

		elif can_interact and !action_button_pressed and character_is_in_interaction_area:
			action_button_pressed = true


func _process(delta):
	if is_inside_tree() and get_tree().get_edited_scene_root() == null:
		if character_is_in_interaction_area:
			match event_trigger:
				"2": #Touch and "action_pressed" 
					if action_button_pressed and !is_interaction_in_progress:
						await run_commands()
		if event_trigger == "4": #loop continuosly while conditions are true
			await run_commands()


func update_event_data():
	var current_map_name : String = udsmain.current_map_name
	var pos :Vector2 = get_global_position()
	if !udsmain.Dynamic_Game_Dict["Event Save Data"][current_map_name].has(name):
		udsmain.Dynamic_Game_Dict["Event Save Data"][current_map_name][name] = {}
		udsmain.Dynamic_Game_Dict["Event Save Data"][current_map_name][name]["Position"] =  pos
		udsmain.Dynamic_Game_Dict["Event Save Data"][current_map_name][name]["Local Variables"] = event_dict["1"]["Local Variables"]
		udsmain.Dynamic_Game_Dict["Event Save Data"][current_map_name][name]["Attached Event"] = event_name
	udsmain.Dynamic_Game_Dict["Event Save Data"][current_map_name][name]["Position"] =  pos


func interaction_area_entered(area): #Player touch
	if !is_interaction_in_progress:
#		if area == player_interaction_area and !character_is_in_interaction_area:
#			character_is_in_interaction_area = true

		if event_trigger == "1" and character_is_in_interaction_area and can_interact: #Player Touch
			await run_commands()
#			is_interaction_in_progress = true
#			await call_commands()#Run script
#			emit_refresh_event_signal()
#			is_interaction_in_progress = false

		elif area.get_parent().get_class() == get_class() and can_interact:
			if event_trigger == "5": #another event touches this event
				await run_commands()



func run_commands():
	can_interact = false
	is_interaction_in_progress = true
	await call_commands()#Run script
	emit_refresh_event_signal()
	action_button_pressed = false
	is_interaction_in_progress = false
	can_interact = true


#func interaction_area_exited(area):
#	if character_is_in_interaction_area and area == player_interaction_area:
#		interaction_area.monitoring = true
#		character_is_in_interaction_area = false


func attack_player_area_exited(area):
	print(area.name)
	state = previous_state


func attack_player_area_entered(area): #Player touch
	print(area.name)
	if !is_interaction_in_progress and state != "Move Towards Player":
		previous_state = state
		state = "Move Towards Player"



func call_commands():
	var command_dict = udsmain.convert_string_to_type(event_dict[active_page]["Commands"])
	if command_dict != {}:
		for command_index in command_dict:
			var function_name :String = command_dict[command_index].keys()[0]
			var variable_array: Array = command_dict[command_index][function_name]
			var temp_variable_array :Array
			for index in variable_array:
				var variable_with_type = udsmain.convert_string_to_type(index)
				temp_variable_array.append(variable_with_type)
			temp_variable_array.append(name)
			temp_variable_array.append(self)
			variable_array = temp_variable_array
			await udsmain.EVENTS.callv(function_name, variable_array)


func get_event_dict():
	var selected_dict
	var table_dict :Dictionary = DBENGINE.import_data(DBENGINE.table_save_path + "Table Data" + DBENGINE.file_format)
	event_list = {}
	for table_name in table_dict:
		var is_event = DBENGINE.convert_string_to_type(table_dict[table_name]["Is Event"])
		if is_event:
			event_list[table_name] = table_dict[table_name]["Display Name"]
	selected_dict = DBENGINE.import_data(DBENGINE.table_save_path + event_name + DBENGINE.file_format)
	return selected_dict


func get_active_event_page() -> String:
	var active_page :String = "" #This sets the active page to 1 even if the conditions for page 1 have not been met
	var conditions_met :bool = true
	if !is_in_editor:
		current_map_name  = udsmain.current_map_name
		local_variables_dict = udsmain.convert_string_to_type(udsmain.Dynamic_Game_Dict["Event Save Data"][current_map_name][name]["Local Variables"])
		for page in range(event_dict.size(),0,-1):
			var page_string :String = str(page)
			var conditions_dict :Dictionary = DBENGINE.convert_string_to_type(event_dict[page_string]["Conditions"])
			if conditions_dict != {}:
				for condition in conditions_dict:
					for key in conditions_dict[condition]:
						var condition_key_value = conditions_dict[condition][key]["value"]
						var current_condition_list :Array
						match condition_key_value:
							"Event Variable":
								var event_variable_value
								var event_required_variable_value :bool
								for line in conditions_dict[condition]:
									current_condition_list.append(conditions_dict[condition][line]["value"])
								event_required_variable_value = udsmain.convert_string_to_type(current_condition_list[3])
								for variable in local_variables_dict:
									if local_variables_dict[variable]["Value 1"] == current_condition_list[1]:
										event_variable_value = udsmain.convert_string_to_type(local_variables_dict[variable]["Value 2"])
										break
								if event_required_variable_value != event_variable_value:
									conditions_met = false
								else:
									conditions_met = true
							"Inventory Item":
								#Check if selected item is in player inventory
								var player_inventory :Dictionary = udsmain.Dynamic_Game_Dict["Inventory"]
								var inventory_item :String = conditions_dict[condition]["If_Key_Name_DropDown"]["value"]
								if player_inventory.has(inventory_item):
									var item_count :int = player_inventory[inventory_item]["ItemCount"]
									if player_inventory[inventory_item]["ItemCount"] > 0:
										conditions_met = true
									else:
										conditions_met = false

							"Global Variable":
								var global_variable_dict :Dictionary = udsmain.Dynamic_Game_Dict["Global Variables"]
								#Check if global variable conditions are met
								var If_Key_Name_DropDown = conditions_dict[condition]["If_Key_Name_DropDown"]["value"]
								var if_Value_Name_DropDown = conditions_dict[condition]["if_Value_Name_DropDown"]["value"]
								var global_variable_conditions_met :bool = false
								var id = get_global_variable_index_name_from_display_name(If_Key_Name_DropDown)
								
								match if_Value_Name_DropDown:
									"True or False":
										var global_variable_bool = udsmain.convert_string_to_type(conditions_dict[condition]["Is_Value_Bool"]["value"])
										var Is_Value_Bool :bool = global_variable_dict[id]["True or False"]
										if Is_Value_Bool == global_variable_bool:
											global_variable_conditions_met = true

									"Display Name":
										var global_variable_text = udsmain.convert_string_to_type(conditions_dict[condition]["Is_Value_Text"]["value"])
										var Is_Value_Text = global_variable_dict[id]["Text"]
										if Is_Value_Text == global_variable_text:
											global_variable_conditions_met = true
										
									"Text":
										var global_variable_text = udsmain.convert_string_to_type(conditions_dict[condition]["Is_Value_Text"]["value"])
										var Is_Value_Text = global_variable_dict[id]["Text"]
										if Is_Value_Text == global_variable_text:
											global_variable_conditions_met = true
											
									"Decimal Number":
										var Is_Text = conditions_dict[condition]["Is_DropDown"]["value"]
										var global_variable_float = udsmain.convert_string_to_type(conditions_dict[condition]["Is_Value_Float"]["value"], "3")
										var Is_Value_Float = udsmain.convert_string_to_type(global_variable_dict[id][if_Value_Name_DropDown], "3")
										match Is_Text:
											"Greater Than":
												if Is_Value_Float > global_variable_float:
													global_variable_conditions_met = true
											"Less Than":
												if Is_Value_Float < global_variable_float:
													global_variable_conditions_met = true
											"Equal To":
												if Is_Value_Float == global_variable_float:
													global_variable_conditions_met = true
											"NOT Equal To":
												if Is_Value_Float != global_variable_float:
													global_variable_conditions_met = true
											"Greater Than OR Equal To":
												if Is_Value_Float >= global_variable_float:
													global_variable_conditions_met = true
											"Less Than OR Equal To":
												if Is_Value_Float <= global_variable_float:
													global_variable_conditions_met = true
												
									"Whole Number":
										var Is_Text = conditions_dict[condition]["Is_DropDown"]["value"]
										var global_variable_float = udsmain.convert_string_to_type(conditions_dict[condition]["Is_Value_Int"]["value"], "2")
										var Is_Value_Float = udsmain.convert_string_to_type(global_variable_dict[id][if_Value_Name_DropDown], "2")
										match Is_Text:
											"Greater Than":
												if Is_Value_Float > global_variable_float:
													global_variable_conditions_met = true
											"Less Than":
												if Is_Value_Float < global_variable_float:
													global_variable_conditions_met = true
											"Equal To":
												if Is_Value_Float == global_variable_float:
													global_variable_conditions_met = true
											"NOT Equal To":
												if Is_Value_Float != global_variable_float:
													global_variable_conditions_met = true
											"Greater Than OR Equal To":
												if Is_Value_Float >= global_variable_float:
													global_variable_conditions_met = true
											"Less Than OR Equal To":
												if Is_Value_Float <= global_variable_float:
													global_variable_conditions_met = true
								
								conditions_met = global_variable_conditions_met
						break
			else:
				conditions_met = true
			if conditions_met == true:
				active_page = str(page)
				break
	else:
		active_page = "1"
	return active_page


func get_global_variable_index_name_from_display_name(If_Key_Name_DropDown):
	var global_variable_dict :Dictionary = udsmain.Dynamic_Game_Dict["Global Variables"]
	var index
	for id in global_variable_dict:
		if str(global_variable_dict[id]["Display Name"]) == If_Key_Name_DropDown:
			index = id
	return index


func refresh_event_data():
	if is_queued_for_delete:
		call_deferred("queue_free")
	else:
		var current_active_page := active_page
		event_dict = get_event_dict()
		active_page = get_active_event_page()
		if active_page != "":
			event_trigger = event_dict[active_page]["Event Trigger"]
			
			if current_active_page != active_page:
				does_event_move = udsmain.convert_string_to_type(event_dict[active_page]["Does Event Move?"])
				attack_player = DBENGINE.convert_string_to_type(event_dict[active_page]["Attack Player?"])
				animation_group = event_dict[active_page]["Animation Group"]
				loop_animation = udsmain.convert_string_to_type(event_dict[active_page]["Loop Animation"])
				max_speed = DBENGINE.convert_string_to_type(event_dict[active_page]["Max Speed"])
				acceleration = DBENGINE.convert_string_to_type(event_dict[active_page]["Acceleration"])
				friction = DBENGINE.convert_string_to_type(event_dict[active_page]["Friction"])
				draw_shadow = DBENGINE.convert_string_to_type(event_dict[active_page]["Draw Shadow?"])
				is_updating_animations = true
				clear_event_children()
#				await get_tree().create_timer(0.2).timeout
				await add_sprite_and_collision()
				is_updating_animations = false
				autorun_complete = false
			if !autorun_complete:
				autorun_commands()
		else:
			clear_event_children()


func autorun_commands():
	if !is_in_editor:
		match event_trigger:
			"3": #Immediately
				await call_commands()
				autorun_complete = true
				emit_refresh_event_signal()


func add_sprite_and_collision():
	var active_page_data :Dictionary = DBENGINE.convert_string_to_type(event_dict[active_page])
	var sprite_texture_data :Dictionary = DBENGINE.convert_string_to_type(active_page_data["Default Animation"])
	does_event_move = DBENGINE.convert_string_to_type(event_dict[active_page]["Does Event Move?"])

	if is_in_editor or !does_event_move:
		set_editor_or_static_animation(sprite_texture_data)
		if draw_shadow:
			set_editor_or_static_shadow()
			set_shadow_animation()

		if loop_animation:
			sprite_animation.play("Default Animation")
			if draw_shadow:
				shadow_sprite_animation.play("Default Animation")

		else:
			play_sprite_animation_static_or_editor(sprite_texture_data)

	else :
		add_and_play_animation_group()
		if draw_shadow:
			set_shadow_animation()

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
	sprite_animation = AnimatedSprite2D.new()
	sprite_texture_data  = DBENGINE.convert_string_to_type(event_dict[active_page]["Default Animation"])
	set_default_animation(sprite_texture_data, sprite_animation)
	var sprite_atlas_dict :Dictionary = sprite_texture_data["atlas_dict"]
	var sprite_advanced_dict :Dictionary = sprite_texture_data["advanced_dict"]
	add_child(sprite_animation)

func set_editor_or_static_shadow():
	shadow_sprite_animation = AnimatedSprite2D.new()
	var shadow_sprite_texture_data :Dictionary = DBENGINE.convert_string_to_type(event_dict[active_page]["Default Animation"])
	set_default_animation(shadow_sprite_texture_data, shadow_sprite_animation)

func set_collision_area(sprite_texture_data:Dictionary):
	collision_node = DBENGINE.get_collision_shape("Default Animation", sprite_texture_data)
	call_deferred("add_child", collision_node)
	collision_node.disabled = false


func set_interaction_area(sprite_texture_data:Dictionary):
	interaction_area  = DBENGINE.create_event_interaction_area("Default Animation", sprite_texture_data)
	call_deferred("add_child", interaction_area)

	interaction_area.set_collision_layer_value(1, false)
	interaction_area.set_collision_layer_value(2, false)
	interaction_area.set_collision_layer_value(3, true)
	interaction_area.set_collision_mask_value(1, false)
	interaction_area.set_collision_mask_value(2, false)
	interaction_area.set_collision_mask_value(3, true)
#	interaction_area.set_position(Vector2(0,-10))
	interaction_area.monitoring = true

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

func set_default_animation(sprite_texture_data, animation_player):
	var sprite_atlas_dict :Dictionary = sprite_texture_data["atlas_dict"]
	var sprite_advanced_dict :Dictionary = sprite_texture_data["advanced_dict"]
	var sprite_texture = load(DBENGINE.table_save_path + DBENGINE.icon_folder + sprite_atlas_dict["texture_name"])
	var sprite_frame_size = sprite_atlas_dict["frames"]
	var sprite_final_size = sprite_advanced_dict["sprite_size"]
	var sprite_cell_size := Vector2(sprite_texture.get_size().x / sprite_frame_size.y ,sprite_texture.get_size().y / sprite_frame_size.x)
	var modified_sprite_size_y = sprite_final_size.x
	var modified_sprite_size_x = sprite_final_size.y
	var y_scale_value = modified_sprite_size_y / sprite_cell_size.y
	var x_scale_value = modified_sprite_size_x / sprite_cell_size.x
	sprite_animation.set_scale(Vector2(x_scale_value, y_scale_value))
	DBENGINE.add_animation_to_animatedSprite("Default Animation", sprite_texture_data, true,animation_player)


func set_shadow_animation():
	shadow_sprite_animation.set_name("ShadowSprite")
	shadow_sprite_frames = shadow_sprite_animation.frames
	shadow_sprite_animation.show_behind_parent = true
	shadow_sprite_animation.set_material(preload("res://addons/UDSEngine/Character_Manager/ShadowMaterial.tres"))
	shadow_sprite_animation.set_skew(deg_to_rad(50))
	add_child(shadow_sprite_animation)

func clear_event_children():
	if root_node.get_child_count() != 0:
		for child in root_node.get_children():
			var childname :String = child.name
			child.name = childname + "1"
			child.queue_free()


func show_toolbar_in_editor(selected_node_name):
	event_node_name = selected_node_name


func is_new_event_object() -> void:
	print("Event Added")
