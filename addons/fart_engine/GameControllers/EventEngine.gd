extends GDScript
class_name EventEngine

var DIALOG :DialogEngine = DialogEngine.new()
var AUDIO : AudioEngine 

##############################EVENT SCRIPTS#####################################3

func _ready():
	AUDIO = FART.AUDIO
	AUDIO._ready()

func change_local_variable(which_var:Variant, to_what:bool, _event_name :String, event_node_name :String, _event_node):
	which_var = var_to_str(which_var)
	var local_variable_dict  = FART.convert_string_to_type(FART.Dynamic_Game_Dict["10022"][FART.current_map_key][event_node_name]["Local Variables"])
	local_variable_dict["input_dict"][which_var] = to_what
	FART.save_game_data_dict[FART.current_map_key][event_node_name]["Local Variables"] = local_variable_dict


func change_event_options_variable(which_var:String, _event_name :String, event_node_name :String, _event_node):
	var event_options_dict  = FART.convert_string_to_type(FART.Dynamic_Game_Dict["10022"][FART.current_map_key][event_node_name]["Event Dialog Variables"])
	event_options_dict["input_dict"][which_var] = true
	FART.Dynamic_Game_Dict["10022"][FART.current_map_key][event_node_name]["Event Dialog Variables"] = event_options_dict
#	print(FART.Dynamic_Game_Dict["Event Save Data"][FART.current_map_key][event_node_name]["Event Dialog Variables"])

func change_dialog_options(which_var:Variant,  to_what:bool, _event_name :String, event_node_name :String, _event_node):
	which_var = var_to_str(which_var)
	var event_options_dict  = FART.convert_string_to_type(FART.Dynamic_Game_Dict["10022"][FART.current_map_key][event_node_name]["Event Dialog Variables"])
	event_options_dict["input_dict"][which_var] = to_what
	FART.Dynamic_Game_Dict["10022"][FART.current_map_key][event_node_name]["Event Dialog Variables"] = event_options_dict
#	print(FART.Dynamic_Game_Dict["Event Save Data"][FART.current_map_key][event_node_name]["Event Dialog Variables"])




func change_global_variable(which_var, which_field:String,  to_what, _event_name :String, _event_node_name :String, _event_node):
	var global_variable_dict  = FART.convert_string_to_type(FART.Dynamic_Game_Dict["10029"])
	FART.Dynamic_Game_Dict["10029"][str(which_var)][which_field] = to_what


func remove_event(_event_name :String, _event_node_name:String, event_node):
	event_node.is_queued_for_delete = true
	event_node.visible = false


func print_to_console(input_text :String ,_event_name :String, _event_node_name:String, _event_node):
	print(input_text)


func wait(how_long: float, _event_name :String, _event_node_name:String, _event_node):
	await FART.fart_root.get_tree().create_timer(how_long).timeout


func transfer_player(which_map :int, what_coordinates, _event_name :String, _event_node_name:String, _event_node):
	var currGameState = FART.gameState
	FART.set_game_state("7")
	FART.call_deferred("remove_player_from_map_node")
	FART.CAMERA.remove_camera_from_map()
	var map_path :String = FART.get_mappath_from_key(str(which_map))
#	if FART.current_map_name != str(which_map):
	FART.call_deferred("load_and_set_map",map_path)
	await FART.get_tree().create_timer(.25).timeout
	FART.player_node = await FART.get_player_node()
	FART.player_node.set_player_position(FART.convert_string_to_vector(what_coordinates))
	remove_unused_maps()
	FART.set_game_state(currGameState)


func modify_player_inventory(what , how_many , increase_value :bool, _event_name :String, _event_node_name:String, _event_node ):
	what = str(what)
	var dict_static_items = FART.Static_Game_Dict["Items"]
	var modify_amount :int = int(abs(how_many))
	if !increase_value:
		modify_amount = int(-abs(modify_amount))

	if dict_static_items.has(what):
		if !FART.is_item_in_inventory(what):
			FART.Dynamic_Game_Dict["Inventory"][what]["ItemCount"] = {"ItemCount" : 0}
		var inv_count = int(FART.Dynamic_Game_Dict["Inventory"][what]["ItemCount"])
		FART.Dynamic_Game_Dict["Inventory"][what]["ItemCount"] =  inv_count + modify_amount
	else:
		print(what, " needs to be added to Item Table")
	
	if int(FART.Dynamic_Game_Dict["Inventory"][what]["ItemCount"]) < 0:
		FART.Dynamic_Game_Dict["Inventory"][what]["ItemCount"] = 0

#	print(what, ": ", modify_amount, " added to Inventory")
#	print(FART.Dynamic_Game_Dict["Inventory"][what]["ItemCount"])
	FART.emit_signal("inventory_updated")
	return FART.Dynamic_Game_Dict["Inventory"][what]["ItemCount"]


func start_dialog(dialog_data :Dictionary, _event_name :String, _event_node_name:String, _event_node):
	var previousGameState : String = FART.gameState
	FART.set_game_state("4")
	DIALOG.dialog_begin(dialog_data,_event_node_name)
	await DIALOG.dialog_ended
	FART.set_game_state(previousGameState)


func sfx(audio_data :Dictionary, _event_name :String, _event_node_name:String, _event_node):
	AUDIO.audio_begin(audio_data, _event_node)
	if audio_data["wait"]:
		await AUDIO.audio_finished


func change_game_state(to_what:String, _event_name :String, _event_node_name:String, _event_node):
	var gameState_dict :Dictionary = FART.Static_Game_Dict["10027"]
	for key in gameState_dict:
		if FART.get_text(gameState_dict[key]["Display Name"]) == to_what:
			to_what = key
			break
	FART.set_game_state(to_what)



#NO COMMAND YET AVAIALBLE
func remove_unused_maps():
	var maps_node = FART.fart_root.get_node("map")
	for child in maps_node.get_children():
		if child != FART.current_map_node:
			for event in child.event_array:
				if is_instance_valid(event):
					event.is_queued_for_delete = true
			child.queue_free()


func set_camera_speed(to_what:float, _event_name :String, _event_node_name:String, _event_node):
	FART.CAMERA.set_camera_smooth_speed(to_what)


func set_camera_follow_player(to_what:bool, _event_name :String, _event_node_name:String, _event_node):
	FART.CAMERA.set_is_following_player(to_what)


func move_camera(what_dir :String, how_fast :float, how_long :float, return_to_player :bool, _event_name :String, _event_node_name:String, _event_node):
	FART.CAMERA.move_camera(FART.convert_string_to_vector(what_dir), how_fast, how_long, return_to_player)
	
func move_camera_to_event(return_to_player :bool, how_long :float, use_this_event :bool, other_event_name:Dictionary,  _event_name :String, _event_node_name:String, _event_node):
	var return_event_name: String = _event_node_name
	if !use_this_event:
		return_event_name = other_event_name["text"]
	FART.CAMERA.move_camera_to_event(return_event_name, return_to_player, how_long)
	#[return_to_player, how_long, use_this_event, other_event_name, event_name]}


func change_player_health(health_change: float, knockback:float, custom_cooldown:float, use_default_cooldown:bool,  set_number:bool, operation :int, _event_name :String, _event_node_name:String, _event_node):
	FART.player_node.change_player_health(health_change, knockback, custom_cooldown, use_default_cooldown, set_number, operation, _event_node)



#	print("Current Player HP: ", FART.player_node.current_health.y)
#{ "change_player_health": [-50, 125, 0, true, "Event 3"] }
