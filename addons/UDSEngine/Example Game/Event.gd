@tool
extends RigidDynamicBody2D
class_name EventHandler

@onready var DBENGINE :DatabaseEngine = DatabaseEngine.new()
@export var event_name :String = ""
var root_node : EventHandler
var collision_node :CollisionShape2D
var interaction_area :Area2D

var event_list :Dictionary = {}
var event_dict :Dictionary = {}
var event_node_name := ""
var event_trigger := ""
#var tab_number := "1"
#var selected_event_table :Dictionary = {}
var active_page := ""
var is_in_editor = false
var local_variables_dict :Dictionary = {}
var current_map_name : String 
var is_queued_for_delete :bool = false
var character_is_in_interaction_area :bool = false


func _ready() -> void:
	freeze = true
	add_to_group("Events")
	if get_tree().get_edited_scene_root() != null:
		is_in_editor = true
		root_node = get_tree().get_edited_scene_root().get_child(get_index())
	else:
		await udsmain.map_loaded
		root_node = self
		event_dict = get_event_dict()
		current_map_name = udsmain.current_map_name
		var pos :Vector2 = get_global_position()
		if !udsmain.Dynamic_Game_Dict["Event Save Data"][current_map_name].has(name):
			udsmain.Dynamic_Game_Dict["Event Save Data"][current_map_name][name] = {}
			udsmain.Dynamic_Game_Dict["Event Save Data"][current_map_name][name]["Position"] =  pos
			udsmain.Dynamic_Game_Dict["Event Save Data"][current_map_name][name]["Local Variables"] = event_dict["1"]["Local Variables"]
			udsmain.Dynamic_Game_Dict["Event Save Data"][current_map_name][name]["Attached Event"] = event_name
		else:
			#Check if attached event has changed
			var attached_event_editor :String = event_name
			var attached_event_save_file :String = udsmain.Dynamic_Game_Dict["Event Save Data"][current_map_name][name]["Attached Event"]
			if attached_event_editor != attached_event_save_file:
				udsmain.Dynamic_Game_Dict["Event Save Data"][current_map_name][name]["Position"] =  pos
				udsmain.Dynamic_Game_Dict["Event Save Data"][current_map_name][name]["Local Variables"] = event_dict["1"]["Local Variables"]
				udsmain.Dynamic_Game_Dict["Event Save Data"][current_map_name][name]["Attached Event"] = event_name
			else:
				var event_position = udsmain.Dynamic_Game_Dict["Event Save Data"][current_map_name][name]["Position"]
				var posvect :Vector2 = udsmain.convert_string_to_Vector(event_position)
				set_global_position(posvect)
		#Get local variables
		local_variables_dict = udsmain.convert_string_to_type(udsmain.Dynamic_Game_Dict["Event Save Data"][current_map_name][name]["Local Variables"])

		clear_event_children()

	if event_name != "":
		event_dict = get_event_dict()
		active_page = get_active_event_page()
		event_trigger = event_dict[active_page]["Event Trigger"]
		autorun_commands()
		add_sprite_and_collision()
		interaction_area.monitoring = true

 

func _process(delta): #NEED TO SET THIS TO ONLY RUN AT SET INTERVALS OR ONLY WHEN THE EVENT MOVES
	if is_inside_tree() and get_tree().get_edited_scene_root() == null:
		var current_map_name : String = udsmain.get_map_name(udsmain.current_map_path)
		var pos :Vector2 = get_global_position()
		udsmain.Dynamic_Game_Dict["Event Save Data"][current_map_name][name]["Position"] =  pos
		
		if character_is_in_interaction_area:
			match event_trigger:
				"2":
					if Input.is_action_just_pressed("action_pressed"):
						character_is_in_interaction_area = false
						await call_commands()#Run script
						refresh_event_data()

func interaction_area_entered(body): #Player touch
	character_is_in_interaction_area = true
	match event_trigger:
		"1": #Player Touch
			print(body.owner.name , " Touched ", event_name)
			await call_commands()#Run script
			print("Begin Refresh event data")
			refresh_event_data()


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
#				print("Waiting for event_function_complete Signal")
#				await udsmain.event_function_complete
			print("Function: ", command_index, " complete")

func interaction_area_exited(body):
#	await get_tree().create_timer(.1).timeout
	interaction_area.monitoring = true
	character_is_in_interaction_area = false
#	if is_queued_for_delete:
#		queue_free()

func get_event_dict():
	var selected_dict
	var table_dict :Dictionary = DBENGINE.import_data(DBENGINE.table_save_path + "Table Data" + DBENGINE.file_format)
	event_list = {}
	for table_name in table_dict:
		var is_event = DBENGINE.convert_string_to_type(table_dict[table_name]["Is Event"])
		if is_event:
			event_list[table_name] = table_dict[table_name]["Display Name"]
	selected_dict = DBENGINE.import_data(DBENGINE.table_save_path + event_name + DBENGINE.file_format)

	if !is_in_editor:
		pass

	return selected_dict


func get_active_event_page() -> String:
	var active_page :String = "1"
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
								var event_required_variable_value
								for line in conditions_dict[condition]:
									current_condition_list.append(conditions_dict[condition][line]["value"])
	#							var local_var_dict :Dictionary = DBENGINE.convert_string_to_type(event_dict["1"]["Local Variables"])
								event_required_variable_value = current_condition_list[3]
								for variable in local_variables_dict:
									if local_variables_dict[variable]["Value 1"] == current_condition_list[1]:
										event_variable_value = str(local_variables_dict[variable]["Value 2"])
										break
								
								if event_required_variable_value != event_variable_value:
									conditions_met = false
								else:
									conditions_met = true
						break
						
			if conditions_met == true:
				active_page = str(page)
				break
	return active_page


func refresh_event_data():
	#Reload event
	if is_queued_for_delete:
		queue_free()
	else:
		event_dict = get_event_dict()
		active_page = get_active_event_page()
		event_trigger = event_dict[active_page]["Event Trigger"]
		autorun_commands()
		await clear_event_children()
		await add_sprite_and_collision()

func autorun_commands():
	if !is_in_editor:
		match event_trigger:
			"3": #Immediately
				await call_commands()
				refresh_event_data()

func add_sprite_and_collision():
	var sprite_animation :AnimatedSprite2D = DBENGINE.create_sprite_animation()
	var sprite_texture_data :Array = DBENGINE.convert_string_to_type(event_dict[active_page]["Default Animation"])
	var event_animation_array :Array = DBENGINE.add_animation_to_animatedSprite("Default Animation", sprite_texture_data, false, sprite_animation)
	root_node.add_child(sprite_animation)
	var sprite_texture = load(DBENGINE.table_save_path + DBENGINE.icon_folder + sprite_texture_data[0])
	var sprite_count = DBENGINE.convert_string_to_Vector(sprite_texture_data[1])
	var sprite_cell_size := Vector2(sprite_texture.get_size().x / sprite_count.y ,sprite_texture.get_size().y / sprite_count.x)
	var sprite_cell_ratio : float = sprite_cell_size.y / sprite_cell_size.x
	var modified_sprite_size_y = sprite_cell_size.y
	var y_scale_value = modified_sprite_size_y / sprite_cell_size.y
	var x_scale_value = y_scale_value * sprite_cell_ratio
	sprite_animation.set_scale(Vector2(x_scale_value, y_scale_value))
	sprite_animation.play("Default Animation")
	collision_node = DBENGINE.get_collision_shape(event_name, sprite_texture_data)
	call_deferred("add_child",collision_node)
	collision_node.disabled = false
	interaction_area  = DBENGINE.create_player_interaction_area(event_name, sprite_texture_data)
	call_deferred("add_child",interaction_area)
	interaction_area.monitoring = false
	interaction_area.area_entered.connect(interaction_area_entered)
	interaction_area.area_exited.connect(interaction_area_exited)


func clear_event_children():
	if root_node.get_child_count() != 0:
		for child in root_node.get_children():
			child.queue_free()


func show_toolbar_in_editor(selected_node_name):
	event_node_name = selected_node_name


func is_new_event_object() -> void:
	print("Event Added")
