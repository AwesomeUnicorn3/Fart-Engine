extends Node
class_name EventEngine

var DIALOG :DialogEngine = DialogEngine.new()

##############################EVENT SCRIPTS#####################################3


func change_local_variable(which_var:String, to_what:bool, _event_name :String, event_node_name :String, _event_node):
	var local_variable_dict  = udsmain.convert_string_to_type(udsmain.Dynamic_Game_Dict["Event Save Data"][udsmain.current_map_name][event_node_name]["Local Variables"])
	for Variable in local_variable_dict:
		if local_variable_dict[Variable]["Value 1"] == which_var:
			local_variable_dict[Variable]["Value 2"] = to_what
			udsmain.Dynamic_Game_Dict["Event Save Data"][udsmain.current_map_name][event_node_name]["Local Variables"] = local_variable_dict
			break


func change_global_variable(which_var:String, what_type: String,  to_what, _event_name :String, _event_node_name :String, _event_node):
	var global_variable_dict  = udsmain.convert_string_to_type(udsmain.Dynamic_Game_Dict["Global Variables"])
	for id in global_variable_dict:
		if global_variable_dict[id]["Display Name"] == which_var:
			udsmain.Dynamic_Game_Dict["Global Variables"][id][what_type] = to_what
			break


func remove_event(_event_name :String, _event_node_name:String, event_node):
	event_node.update_event_data()
	event_node.is_queued_for_delete = true


func print_to_console(input_text :String ,_event_name :String, _event_node_name:String, _event_node):
	print(input_text)


func wait(how_long: float, _event_name :String, _event_node_name:String, _event_node):
	await get_tree().create_timer(how_long).timeout


func transfer_player(which_map :String, what_coordinates, _event_name :String, _event_node_name:String, _event_node):
	call_deferred("remove_player_from_map_node" ,udsmain.current_map_node)
	var map_path :String = udsmain.get_mappath_from_displayname(which_map)
	if udsmain.current_map_name != which_map:
		udsmain.call_deferred("load_and_set_map",map_path)
	await get_tree().create_timer(.25).timeout
	udsmain.player_node = await udsmain.get_player_node()
	udsmain.player_node.set_player_position(udsmain.convert_string_to_vector(what_coordinates))
	remove_unused_maps()


func remove_unused_maps():
	var maps_node = udsmain.root.get_node("map")
	for child in maps_node.get_children():
		if child != udsmain.current_map_node:
			for event in child.event_array:
				event.is_queued_for_delete = true
			child.queue_free()


func modify_player_inventory(what :String, how_many , increase_value :bool, _event_name :String, _event_node_name:String, _event_node ):
	var dict_static_items = udsmain.Static_Game_Dict["Items"]
	var modify_amount :int = int(abs(how_many))

	if !increase_value:
		modify_amount = int(-abs(modify_amount))

	if dict_static_items.has(what):
		if !udsmain.is_item_in_inventory(what):
			udsmain.Dynamic_Game_Dict["Inventory"][what] = {"ItemCount" : 0}
		var inv_count = int(udsmain.Dynamic_Game_Dict["Inventory"][what]["ItemCount"])
		udsmain.Dynamic_Game_Dict["Inventory"][what]["ItemCount"] =  inv_count + how_many
	else:
		print(what, " needs to be added to Item Table")
	
	print(udsmain.Dynamic_Game_Dict["Inventory"][what]["ItemCount"])
	return udsmain.Dynamic_Game_Dict["Inventory"][what]["ItemCount"]


func start_dialog(dialog_data :Dictionary, _event_name :String, _event_node_name:String, _event_node):
	#Player cannot move
	#user cannot navigate to menu
	#event cannot move
	#face event toward player
	
	DIALOG.dialog_begin(dialog_data)
	await DIALOG.dialog_ended

	#Player can move
	#user can navigate to menu
	#event cann move
	#event resume previous state
