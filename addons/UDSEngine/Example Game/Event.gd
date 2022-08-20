@tool
extends CharacterBody2D
class_name EventHandler

@onready var DBENGINE :DatabaseEngine = DatabaseEngine.new()
@export var event_name :String = ""

enum {STATIC, IDLE, RANDOM, MOVE_TOWARD_PLAYER, CUSTOM}
var root_node : EventHandler
var collision_node :CollisionShape2D
var sprite_animation :AnimatedSprite2D
var event_animation_dictionary :Dictionary = {}
var interaction_area :Area2D
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

var state :int = MOVE_TOWARD_PLAYER
var max_speed :int = 100
var acceleration :int = 100
var friction :int = 50
var sprite_group :String = "Link"
var idle = "Idle"
var walk_left = "Walk Left"
var walk_right ="Walk Right"
var walk_up = "Walk Up"
var walk_down ="Walk Down"


func _ready() -> void:
	set_collision_layer_value(1, false)
	set_collision_layer_value(2, true)
	set_collision_mask_value(2, true)

	add_to_group("Events")
	if get_tree().get_edited_scene_root() != null:
		is_in_editor = true
		root_node = get_tree().get_edited_scene_root().get_child(get_index())
		connect("draw",_on_event_draw)
	else:
		await udsmain.map_loaded
		root_node = self
		event_dict = get_event_dict()
		current_map_name = udsmain.current_map_name
		var pos :Vector2 = get_global_position()
		if !name in udsmain.Dynamic_Game_Dict["Event Save Data"][current_map_name]:
			update_event_data()
			var attached_event_editor :String = event_name
			var attached_event_save_file :String = udsmain.Dynamic_Game_Dict["Event Save Data"][current_map_name][name]["Attached Event"]
			if attached_event_editor != attached_event_save_file:
				udsmain.Dynamic_Game_Dict["Event Save Data"][current_map_name][name]["Position"] =  pos
				udsmain.Dynamic_Game_Dict["Event Save Data"][current_map_name][name]["Local Variables"] = event_dict["1"]["Local Variables"]
				udsmain.Dynamic_Game_Dict["Event Save Data"][current_map_name][name]["Attached Event"] = event_name
			else:
				var event_position = udsmain.Dynamic_Game_Dict["Event Save Data"][current_map_name][name]["Position"]
				var posvect :Vector2 = udsmain.convert_string_to_vector(str(event_position))
				set_global_position(posvect)
		local_variables_dict = udsmain.convert_string_to_type(udsmain.Dynamic_Game_Dict["Event Save Data"][current_map_name][name]["Local Variables"])
		clear_event_children()
	if event_name != "":
		event_dict = get_event_dict()
		active_page = get_active_event_page()
		add_sprite_and_collision()
		if active_page != "":
			event_trigger = event_dict[active_page]["Event Trigger"]
			autorun_commands()
			interaction_area.monitoring = true
		else:
			clear_event_children()
	event_info_loaded = true


func _on_event_draw():
	if event_name != "":
		clear_event_children()
		event_dict = get_event_dict()
		active_page = get_active_event_page()
		add_sprite_and_collision()


func emit_refresh_event_signal():
	map_node.emit_signal("update_events")

func _physics_process(delta):
	state_machine(delta)
	move_and_slide()

func state_machine(delta):
	match state:
		IDLE:
			idle_movement(delta)

		MOVE_TOWARD_PLAYER:
			move_toward_player(delta)



func idle_movement(delta):
	sprite_animation.play(idle)
	enable_collision(idle)
	udsmain.set_sprite_scale(sprite_animation,idle , event_animation_dictionary)
	velocity = velocity.move_toward(Vector2.ZERO, friction * delta)


func move_toward_player(delta):
	if player_node != null:
		var dir = (player_node.global_position - global_position).normalized()
		if dir.x < 0 and abs(dir.y) < abs(dir.x):
			sprite_animation.play(walk_left)
			enable_collision(walk_left)
			udsmain.set_sprite_scale(sprite_animation,walk_left , event_animation_dictionary)

		elif dir.x > 0 and abs(dir.y) < abs(dir.x):
			sprite_animation.play(walk_right)
			udsmain.set_sprite_scale(sprite_animation,walk_right , event_animation_dictionary)
			enable_collision(walk_right)

		elif dir.y < 0:
			sprite_animation.play(walk_up)
			udsmain.set_sprite_scale(sprite_animation,walk_up , event_animation_dictionary)
			enable_collision(walk_up)

		elif dir.y > 0:
			sprite_animation.play(walk_down)
			udsmain.set_sprite_scale(sprite_animation,walk_down , event_animation_dictionary)
			enable_collision(walk_down)

		velocity = velocity.move_toward(dir * max_speed, acceleration * delta)
#		sprite_animation.flip_h = velocity.x < 0 #useful and easy but will have to set animation based on 
												#event direction, using sprite group

func enable_collision(collision_name :String):
	if get_node(collision_name + " Collision").disabled == true:
		disable_all_collisions()
		get_node(collision_name + " Collision").disabled = false
		get_node(collision_name + " Collision").visible = true

func disable_all_collisions():
	for i in get_children():
		if i is CollisionShape2D:
			i.disabled = true
			i.visible = false


func _process(delta):
	if is_inside_tree() and get_tree().get_edited_scene_root() == null:
		if character_is_in_interaction_area:
			match event_trigger:
				"2": #Touch and "action_pressed" 
					if Input.is_action_just_pressed("action_pressed"):
						await call_commands()#Run script
						emit_refresh_event_signal()
		if event_trigger == "4": #loop continuosly while conditions are true
			await call_commands()#Run script
			emit_refresh_event_signal()


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
		if area == player_interaction_area and !character_is_in_interaction_area:
			character_is_in_interaction_area = true

		if event_trigger == "1" and character_is_in_interaction_area: #Player Touch
			is_interaction_in_progress = true
			await call_commands()#Run script
			emit_refresh_event_signal()
			is_interaction_in_progress = false

		elif area.get_parent().get_class() == get_class():
			if event_trigger == "5": #another event touches this event
				is_interaction_in_progress = true
				await call_commands()#Run script
				emit_refresh_event_signal()
				is_interaction_in_progress = false
				

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
			await udsmain.callv(function_name, variable_array)


func interaction_area_exited(area):
	if character_is_in_interaction_area and area == player_interaction_area:
#		interaction_area.monitoring = true
		character_is_in_interaction_area = false

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
		queue_free()
	else:
		var current_active_page := active_page
		event_dict = get_event_dict()
		active_page = get_active_event_page()
		if active_page != "":
			event_trigger = event_dict[active_page]["Event Trigger"]
			if current_active_page != active_page:
				await clear_event_children()
				await add_sprite_and_collision()
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

	event_animation_dictionary = DBENGINE.add_sprite_group_to_animatedSprite(self, sprite_group)
	sprite_animation = event_animation_dictionary["animated_sprite"]
	add_child(sprite_animation)
	
	
	
#	sprite_animation  = DBENGINE.create_sprite_animation()
	var active_page_data :Dictionary = DBENGINE.convert_string_to_type(event_dict[active_page])
	var sprite_texture_data :Dictionary = DBENGINE.convert_string_to_type(active_page_data["Default Animation"])


	DBENGINE.set_sprite_scale(sprite_animation, "Idle", event_animation_dictionary)
#	var sprite_texture = load(DBENGINE.table_save_path + DBENGINE.icon_folder + sprite_texture_data["atlas_dict"]["texture_name"])
#	var sprite_frame_size = sprite_texture_data["atlas_dict"]["frames"]
#	var sprite_final_size = sprite_texture_data["advanced_dict"]["sprite_size"]
#	var sprite_cell_size := Vector2(sprite_texture.get_size().x / sprite_frame_size.y ,sprite_texture.get_size().y / sprite_frame_size.x)
#	var modified_sprite_size_y = sprite_final_size.x
#	var modified_sprite_size_x = sprite_final_size.y
#	var y_scale_value = modified_sprite_size_y / sprite_cell_size.y
#	var x_scale_value = modified_sprite_size_x / sprite_cell_size.x
#	sprite_animation.set_scale(Vector2(x_scale_value, y_scale_value))
#	DBENGINE.add_animation_to_animatedSprite("Default Animation", sprite_texture_data, false,sprite_animation)
	
	sprite_animation.play("Idle")



	collision_node = DBENGINE.get_collision_shape(event_name, sprite_texture_data)
	call_deferred("add_child",collision_node)
	collision_node.disabled = false
	interaction_area  = DBENGINE.create_event_interaction_area(event_name, sprite_texture_data)
	call_deferred("add_child",interaction_area)
	interaction_area.monitoring = false
	interaction_area.area_entered.connect(interaction_area_entered)
	interaction_area.area_exited.connect(interaction_area_exited)
	interaction_area.set_collision_layer_value(1, false)
	interaction_area.set_collision_layer_value(3, true)
	interaction_area.set_collision_mask_value(3, true)


func clear_event_children():
	if root_node.get_child_count() != 0:
		for child in root_node.get_children():
			child.queue_free()


func show_toolbar_in_editor(selected_node_name):
	event_node_name = selected_node_name


func is_new_event_object() -> void:
	print("Event Added")
