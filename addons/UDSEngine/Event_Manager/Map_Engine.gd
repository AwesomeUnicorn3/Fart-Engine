extends Node2D
signal update_events

var ysort_node
var player_node
var player_interaction_area
var event_array :Array = []

func _ready():

	ysort_node = Node2D.new()
	add_child(ysort_node)
	ysort_node.y_sort_enabled = true
	event_array = find_children("*", "EventHandler", true)
	var map_event_dict :Dictionary = {}
	udsmain.set_current_map(self)
	player_node = await udsmain.get_player_node()
	player_interaction_area = await udsmain.get_player_interaction_area()
	for event_node in event_array:
		map_event_dict[event_node.name] = event_node
		update_events.connect(event_node.refresh_event_data)
		event_node.map_node = self
		event_node.player_node = player_node
		event_node.player_interaction_area = player_interaction_area
		remove_child(event_node)
		ysort_node.add_child(event_node)

	
	#Create map dictionary in event save files if none exist
	var current_map_name : String = udsmain.current_map_name
	if !udsmain.Dynamic_Game_Dict["Event Save Data"].has(current_map_name):
			udsmain.Dynamic_Game_Dict["Event Save Data"][current_map_name] = {}
	else:
		#check for deleted events
		var event_save_dict :Dictionary = udsmain.Dynamic_Game_Dict["Event Save Data"][current_map_name].duplicate(true)
		for event in event_save_dict:
			if !map_event_dict.has(event):
				udsmain.Dynamic_Game_Dict["Event Save Data"][current_map_name].erase(event)

#	player_node = await udsmain.get_player_node()
	var newgame :bool = udsmain.convert_string_to_type(udsmain.Dynamic_Game_Dict["Global Data"][udsmain.global_settings]["NewGame"])
	if newgame == true:
		var starting_position = udsmain.convert_string_to_vector(udsmain.Static_Game_Dict["Global Data"][udsmain.global_settings]["Player Starting Position"])
		player_node.set_position(starting_position)
	
	await udsmain.move_player_to_map_node(self)
	udsmain.emit_signal("map_loaded")


func save_event_data():
	for event_node in event_array:
		event_node.update_event_data()
