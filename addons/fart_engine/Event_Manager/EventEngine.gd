extends Node
class_name EventEngine

var DIALOG :DialogEngine = DialogEngine.new()
var AUDIO : AudioEngine = AudioEngine.new()

##############################EVENT SCRIPTS#####################################3


func change_local_variable(which_var:String, to_what:bool, _event_name :String, event_node_name :String, _event_node):
	var local_variable_dict  = FARTENGINE.convert_string_to_type(FARTENGINE.Dynamic_Game_Dict["Event Save Data"][FARTENGINE.current_map_key][event_node_name]["Local Variables"])
	local_variable_dict[which_var] = to_what
#	for Variable in local_variable_dict:
#		if local_variable_dict[Variable]["Value 1"] == which_var:
#			local_variable_dict[Variable]["Value 2"] = to_what
	FARTENGINE.Dynamic_Game_Dict["Event Save Data"][FARTENGINE.current_map_key][event_node_name]["Local Variables"] = local_variable_dict



func change_global_variable(which_var, which_field:String,  to_what, _event_name :String, _event_node_name :String, _event_node):
	var global_variable_dict  = FARTENGINE.convert_string_to_type(FARTENGINE.Dynamic_Game_Dict["Global Variables"])
	FARTENGINE.Dynamic_Game_Dict["Global Variables"][str(which_var)][which_field] = to_what


func remove_event(_event_name :String, _event_node_name:String, event_node):
#	event_node.update_event_data()
	event_node.is_queued_for_delete = true


func print_to_console(input_text :String ,_event_name :String, _event_node_name:String, _event_node):
	print(input_text)


func wait(how_long: float, _event_name :String, _event_node_name:String, _event_node):
	await FARTENGINE.root.get_tree().create_timer(how_long).timeout


func transfer_player(which_map :String, what_coordinates, _event_name :String, _event_node_name:String, _event_node):
	var currGameState = FARTENGINE.gameState
	FARTENGINE.set_game_state("7")
	FARTENGINE.call_deferred("remove_player_from_map_node" ,FARTENGINE.current_map_node)
	var map_path :String = FARTENGINE.get_mappath_from_displayname(which_map)
	if FARTENGINE.current_map_name != which_map:
		FARTENGINE.call_deferred("load_and_set_map",map_path)
	await FARTENGINE.get_tree().create_timer(.25).timeout
	FARTENGINE.player_node = await FARTENGINE.get_player_node()
	FARTENGINE.player_node.set_player_position(FARTENGINE.convert_string_to_vector(what_coordinates))
	remove_unused_maps()
	FARTENGINE.set_game_state(currGameState)


func remove_unused_maps():
	var maps_node = FARTENGINE.root.get_node("map")
	for child in maps_node.get_children():
		if child != FARTENGINE.current_map_node:
			for event in child.event_array:
				event.is_queued_for_delete = true
			child.queue_free()


func modify_player_inventory(what , how_many , increase_value :bool, _event_name :String, _event_node_name:String, _event_node ):
	what = str(what)
	var dict_static_items = FARTENGINE.Static_Game_Dict["Items"]
	var modify_amount :int = int(abs(how_many))
	if !increase_value:
		modify_amount = int(-abs(modify_amount))
#	for key in dict_static_items:
#		if dict_static_items[key].has("Display Name"):
#			if str_to_var(dict_static_items[key]["Display Name"])["text"] == what:
#				what = key
#				break
	if dict_static_items.has(what):
		if !FARTENGINE.is_item_in_inventory(what):
			FARTENGINE.Dynamic_Game_Dict["Inventory"][what]["ItemCount"] = {"ItemCount" : 0}
		var inv_count = int(FARTENGINE.Dynamic_Game_Dict["Inventory"][what]["ItemCount"])
		FARTENGINE.Dynamic_Game_Dict["Inventory"][what]["ItemCount"] =  inv_count + how_many
	else:
		print(what, " needs to be added to Item Table")
	print(what, ": ", how_many, " added to Inventory")
#	print(FARTENGINEDynamic_Game_Dict["Inventory"][what]["ItemCount"])
	return FARTENGINE.Dynamic_Game_Dict["Inventory"][what]["ItemCount"]


func start_dialog(dialog_data :Dictionary, _event_name :String, _event_node_name:String, _event_node):
	var previousGameState : String = FARTENGINE.gameState
	FARTENGINE.set_game_state("4")
	DIALOG.dialog_begin(dialog_data)
	await DIALOG.dialog_ended
	FARTENGINE.set_game_state(previousGameState)


func sfx(audio_data :Dictionary, _event_name :String, _event_node_name:String, _event_node):
	AUDIO.audio_begin(audio_data, _event_node)
	await AUDIO.audio_finished


func change_game_state(to_what:String, _event_name :String, _event_node_name:String, _event_node):
	var gameState_dict :Dictionary = FARTENGINE.Static_Game_Dict["Game State"]
	for key in gameState_dict:
		if str_to_var(gameState_dict[key]["Display Name"])["text"] == to_what:
			to_what = key
			break
	FARTENGINE.set_game_state(to_what)
