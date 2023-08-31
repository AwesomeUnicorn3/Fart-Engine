extends Node2D
signal update_events

var map_dict :Dictionary

var ysort_node
var player_node
var player_interaction_area
var event_array :Array = []
var BGM_Player 
var bgm_stream :String
var bgm_volume :float
var bgm_pitch :float
#var bgm_loop :bool

func _ready():
#	add_child(BGM_Player)
	ysort_node = Node2D.new()
	ysort_node.set_name("YSort")
	add_child(ysort_node)
	ysort_node.y_sort_enabled = true
	event_array = find_children("*", "EventHandler", true)
	var map_event_dict :Dictionary = {}
	#FARTENGINEset_current_map(self)
	
	player_node = await FARTENGINE.get_player_node()
	player_interaction_area = await FARTENGINE.get_player_interaction_area()

	for event_node in event_array:
		map_event_dict[event_node.name] = {}
		update_events.connect(event_node.refresh_event_data)
		event_node.map_node = self
		event_node.player_node = player_node
		event_node.player_interaction_area = player_interaction_area
		event_node.reparent(ysort_node)
#		remove_child(event_node)
#		ysort_node.add_child(event_node)
		
	await FARTENGINE.map_data_updated
	map_dict = await FARTENGINE.get_map_dict()
	map_dict = map_dict[FARTENGINE.current_map_key]
	get_bgm_values()
	set_bgm()
	#Create map dictionary in event save files if none exist
	var current_map_key : String = FARTENGINE.current_map_key
	FARTENGINE.get_event_save_dict()
	if !FARTENGINE.save_game_data_dict.has(current_map_key):
			FARTENGINE.save_game_data_dict[current_map_key] = map_event_dict
	else:
		#check for deleted events
		var event_save_dict_copy :Dictionary = FARTENGINE.save_game_data_dict[current_map_key].duplicate(true)
		for event in event_save_dict_copy:
			if !map_event_dict.has(event):
				FARTENGINE.save_game_data_dict[current_map_key].erase(event)

	var newgame  = FARTENGINE.get_field_value("Global Data",await FARTENGINE.get_global_settings_profile(), "NewGame")
	if newgame == true:
		var starting_position = FARTENGINE.convert_string_to_vector(FARTENGINE.Static_Game_Dict["Global Data"][await FARTENGINE.get_global_settings_profile()]["Player Starting Position"])
		player_node.set_position(starting_position)
		FARTENGINE.set_save_data_value("Global Data", await FARTENGINE.get_global_settings_profile(), "NewGame", false)

	await FARTENGINE.move_player_to_map_Ysort(self)
	FARTENGINE.CAMERA.add_camera_to_map(self)
#	if self.has_node("TileMap"):
#		await FARTENGINE.move_player_to_map_Ysort(self, $TileMap, self)
	FARTENGINE.emit_signal("map_loaded")


func get_bgm_values():
	var bgm_dict :Dictionary = str_to_var(map_dict["BGM"])
	bgm_stream = bgm_dict["stream"]
	bgm_volume = FARTENGINE.convert_string_to_type(bgm_dict["volume"])
	bgm_pitch = FARTENGINE.convert_string_to_type(bgm_dict["pitch"])


func set_bgm(BGM_path : String = bgm_stream, volume :float = bgm_volume, pitch :float = bgm_pitch):
	FARTENGINE.AUDIO.stop_all_audio()
	var bgm_dict :Dictionary = str_to_var(map_dict["BGM"])
	BGM_Player = await FARTENGINE.AUDIO.get_next_audio_player("BGM")
	FARTENGINE.AUDIO.audio_begin(bgm_dict, null)


var is_updating_events:bool = false
func refresh_events():
	if !is_updating_events:
		emit_signal("update_events")
		is_updating_events = true
		await get_tree().create_timer(0.1).timeout
		is_updating_events = false
