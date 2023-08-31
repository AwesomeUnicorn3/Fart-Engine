extends GDScript
class_name AudioEngine

signal start_audio
signal audio_finished
signal next_message_pressed


var AudioParent :Node
var selected_group_dictionary :Dictionary
var game_audio_dict:Dictionary


func _ready():
	add_audio_players("SFX", 10)
	add_audio_players("BGM", 1)
	start_audio.connect(audio_begin)


func add_audio_players( bus:String, how_many:int = 1):
	var audio_nodes_added:int = 1
	var parent = FARTENGINE.get_root_node().get_node(bus)
	while audio_nodes_added <= how_many:
		var audio_player = AudioStreamPlayer2D.new()
		audio_player.set_bus(bus)
		audio_player.set_name(str(audio_nodes_added))
		parent.add_child(audio_player)
		game_audio_dict[audio_nodes_added] = {"Audio Node": audio_player, "Player Type" : bus}
		audio_nodes_added += 1


func get_next_audio_player(player_type:String = "SFX") -> AudioStreamPlayer2D:
	var next_player :AudioStreamPlayer2D
	var player_found:bool = false
	
	while player_found == false:
		for playerID in game_audio_dict:
			if game_audio_dict[playerID]["Player Type"] == player_type:
				if !game_audio_dict[playerID]["Audio Node"].is_playing():
					next_player = game_audio_dict[playerID]["Audio Node"]
					player_found = true
		await FARTENGINE.get_root_node().get_tree().process_frame
	#GET NEXT AVAILABLE AUDIO PLAYER FROM DICTIONARY
	#IF NONE ARE AVAIALBE, WAIT UNTIL ONE IS
	#RETURN SELECTED PLAYER
	return next_player



func is_audio_player_available(audio_player: AudioStreamPlayer2D)-> bool:
	var is_player_available:bool  = !audio_player.is_playing()
	return is_player_available


func get_current_player_dict(function_dict:Dictionary)-> Dictionary:
	var current_audio_dictionary:Dictionary
	if function_dict.has("audio_data"):
		current_audio_dictionary = function_dict["audio_data"]
	else:
		current_audio_dictionary = function_dict
	return current_audio_dictionary


func set_variable_data(index, audio_player:AudioStreamPlayer2D, current_audio_dict:Dictionary):
	var index_dict :Dictionary = FARTENGINE.convert_string_to_type(current_audio_dict)
	var stream = index_dict["stream"]
	var volume = index_dict["volume"].to_float()
	var pitch = index_dict["pitch"].to_float()
	var max_distance = index_dict["max_distance"]

	audio_player.set_stream(load(FARTENGINE.table_save_path + FARTENGINE.sfx_folder + stream ))
	audio_player.set_volume_db(volume)
	audio_player.set_pitch_scale(pitch)
	audio_player.set_max_distance(max_distance)
	if is_instance_valid(AudioParent):
		audio_player.set_position(AudioParent.position)


#FOR PROCESSING AUDIO FILES STORES AS FIELDS IN A TABLE-----------------------------
func audio_begin(audio_dict, event_node :EventHandler):
	AudioParent = event_node#

	
	var is_group :bool = false
	var repeat_amount :int = 1
	var repeat_audio : bool = false
	var wait :bool = false
	
	if audio_dict.has("is_group"):
		is_group = audio_dict["is_group"]
	if audio_dict.has("repeat_amount"):
		repeat_amount = audio_dict["repeat_amount"]
	if audio_dict.has("repeat_audio"):
		repeat_audio = audio_dict["repeat_audio"]
	if audio_dict.has("wait"):
		wait = audio_dict["wait"]
	
	set_selected_group_dict_data(audio_dict, is_group)
	if wait:
		await iterate_through_audio(repeat_audio, repeat_amount)
	else:
		iterate_through_audio(repeat_audio, repeat_amount)

	audio_end()


func iterate_through_audio(repeat:bool, repeat_amount:int):

	if !repeat:
		repeat_amount = 1
	for run_index in repeat_amount:
		for audio_index in selected_group_dictionary:
			var current_audio_dictionary :Dictionary 
			if typeof(selected_group_dictionary[audio_index]) == TYPE_STRING:
				current_audio_dictionary = str_to_var(selected_group_dictionary[audio_index])
			else:
				current_audio_dictionary = selected_group_dictionary[audio_index]
			var audio_player :AudioStreamPlayer2D
			audio_player = await get_next_audio_player()
			set_variable_data(audio_index, audio_player, current_audio_dictionary)
			await FARTENGINE.root.get_tree().process_frame
			audio_player.play()
			await audio_player.finished


func set_selected_group_dict_data(audio_dict, is_group:bool):
	selected_group_dictionary = {}
	var group_name :String = ""
	var static_audio_group_dictionary :Dictionary = FARTENGINE.Static_Game_Dict["SFX Groups"]
	var static_audio_group_data_dictionary :Dictionary = FARTENGINE.import_data("SFX Groups", true)
	if is_group:
		group_name = audio_dict["audio_data"]["Group Name"]
		var group_index = FARTENGINE.get_id_from_display_name(static_audio_group_dictionary, group_name)
		var index = 1
		for field in static_audio_group_data_dictionary["Column"]:
			var field_name = static_audio_group_data_dictionary["Column"][field]["FieldName"]
			if field_name != "Display Name":
				selected_group_dictionary[str(index)] = static_audio_group_dictionary[group_name][field_name]
				index += 1
	else:
		if audio_dict.has("audio_data"):
			selected_group_dictionary["1"] = audio_dict["audio_data"]["Single"]
		else:
			selected_group_dictionary["1"] = audio_dict


func audio_end():
	if is_instance_valid(AudioParent):
		await AudioParent.get_tree().create_timer(.1).timeout
		emit_signal("audio_finished")
	else:
		emit_signal("audio_finished")


func stop_all_audio():
	for audioID in game_audio_dict:
		if game_audio_dict[audioID]["Audio Node"].is_playing():
			game_audio_dict[audioID]["Audio Node"].stop()

#-------------------------------------------------------------------------------------------------
#func audio_player_cleanup():
#	for child in AudioParent.get_children():
#		if child.get_class() == "AudioStreamPlayer2D":
#			if child.is_playing():
#				await child.finished
#			child.queue_free()
