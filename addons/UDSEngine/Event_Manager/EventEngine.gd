extends Node
class_name EventEngine

var DIALOG :DialogEngine = DialogEngine.new()
var AUDIO : AudioEngine = AudioEngine.new()

##############################EVENT SCRIPTS#####################################3


func change_local_variable(which_var:String, to_what:bool, _event_name :String, event_node_name :String, _event_node):
	var local_variable_dict  = AU3ENGINE.convert_string_to_type(AU3ENGINE.Dynamic_Game_Dict["Event Save Data"][AU3ENGINE.current_map_key][event_node_name]["Local Variables"])
	local_variable_dict[which_var] = to_what
#	for Variable in local_variable_dict:
#		if local_variable_dict[Variable]["Value 1"] == which_var:
#			local_variable_dict[Variable]["Value 2"] = to_what
	AU3ENGINE.Dynamic_Game_Dict["Event Save Data"][AU3ENGINE.current_map_key][event_node_name]["Local Variables"] = local_variable_dict



func change_global_variable(which_var, which_field:String,  to_what, _event_name :String, _event_node_name :String, _event_node):
	var global_variable_dict  = AU3ENGINE.convert_string_to_type(AU3ENGINE.Dynamic_Game_Dict["Global Variables"])
	AU3ENGINE.Dynamic_Game_Dict["Global Variables"][str(which_var)][which_field] = to_what


func remove_event(_event_name :String, _event_node_name:String, event_node):
#	event_node.update_event_data()
	event_node.is_queued_for_delete = true


func print_to_console(input_text :String ,_event_name :String, _event_node_name:String, _event_node):
	print(input_text)


func wait(how_long: float, _event_name :String, _event_node_name:String, _event_node):
	await AU3ENGINE.root.get_tree().create_timer(how_long).timeout


func transfer_player(which_map :String, what_coordinates, _event_name :String, _event_node_name:String, _event_node):
	var currGameState = AU3ENGINE.gameState
	AU3ENGINE.set_game_state("7")
	AU3ENGINE.call_deferred("remove_player_from_map_node" ,AU3ENGINE.current_map_node)
	var map_path :String = AU3ENGINE.get_mappath_from_displayname(which_map)
	if AU3ENGINE.current_map_name != which_map:
		AU3ENGINE.call_deferred("load_and_set_map",map_path)
	await AU3ENGINE.get_tree().create_timer(.25).timeout
	AU3ENGINE.player_node = await AU3ENGINE.get_player_node()
	AU3ENGINE.player_node.set_player_position(AU3ENGINE.convert_string_to_vector(what_coordinates))
	remove_unused_maps()
	AU3ENGINE.set_game_state(currGameState)


func remove_unused_maps():
	var maps_node = AU3ENGINE.root.get_node("map")
	for child in maps_node.get_children():
		if child != AU3ENGINE.current_map_node:
			for event in child.event_array:
				event.is_queued_for_delete = true
			child.queue_free()


func modify_player_inventory(what , how_many , increase_value :bool, _event_name :String, _event_node_name:String, _event_node ):
	what = str(what)
	var dict_static_items = AU3ENGINE.Static_Game_Dict["Items"]
	var modify_amount :int = int(abs(how_many))
	if !increase_value:
		modify_amount = int(-abs(modify_amount))
#	for key in dict_static_items:
#		if dict_static_items[key].has("Display Name"):
#			if str_to_var(dict_static_items[key]["Display Name"])["text"] == what:
#				what = key
#				break
	if dict_static_items.has(what):
		if !AU3ENGINE.is_item_in_inventory(what):
			AU3ENGINE.Dynamic_Game_Dict["Inventory"][what]["ItemCount"] = {"ItemCount" : 0}
		var inv_count = int(AU3ENGINE.Dynamic_Game_Dict["Inventory"][what]["ItemCount"])
		AU3ENGINE.Dynamic_Game_Dict["Inventory"][what]["ItemCount"] =  inv_count + how_many
	else:
		print(what, " needs to be added to Item Table")
	print(what, ": ", how_many, " added to Inventory")
#	print(AU3ENGINE.Dynamic_Game_Dict["Inventory"][what]["ItemCount"])
	return AU3ENGINE.Dynamic_Game_Dict["Inventory"][what]["ItemCount"]


func start_dialog(dialog_data :Dictionary, _event_name :String, _event_node_name:String, _event_node):
	var previousGameState : String = AU3ENGINE.gameState
	AU3ENGINE.set_game_state("4")
	DIALOG.dialog_begin(dialog_data)
	await DIALOG.dialog_ended
	AU3ENGINE.set_game_state(previousGameState)


func sfx(audio_data :Dictionary, _event_name :String, _event_node_name:String, _event_node):
	AUDIO.audio_begin(audio_data, _event_node)
	await AUDIO.audio_finished


func change_game_state(to_what:String, _event_name :String, _event_node_name:String, _event_node):
	var gameState_dict :Dictionary = AU3ENGINE.Static_Game_Dict["Game State"]
	for key in gameState_dict:
		if str_to_var(gameState_dict[key]["Display Name"])["text"] == to_what:
			to_what = key
			break
	AU3ENGINE.set_game_state(to_what)
