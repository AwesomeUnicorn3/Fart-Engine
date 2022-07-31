extends Node2D


func _ready():

	await udsmain.DbManager_loaded
	var event_array = find_children("*", "EventHandler", true)
	var map_event_dict :Dictionary = {}
	
	for node in event_array:
		map_event_dict[node.name] = node
	#Create map dictionary in event save files if none exist
	var current_map_name : String = udsmain.get_map_name(udsmain.current_map_path) 
	if !udsmain.Dynamic_Game_Dict["Event Save Data"].has(current_map_name):
			udsmain.Dynamic_Game_Dict["Event Save Data"][current_map_name] = {}
	else:
		#check for deleted events
		var event_save_dict :Dictionary = udsmain.Dynamic_Game_Dict["Event Save Data"][current_map_name].duplicate(true)
		for event in event_save_dict:
			if !map_event_dict.has(event):
				udsmain.Dynamic_Game_Dict["Event Save Data"][current_map_name].erase(event)

	udsmain.emit_signal("map_loaded")

func _process(delta):
	pass
