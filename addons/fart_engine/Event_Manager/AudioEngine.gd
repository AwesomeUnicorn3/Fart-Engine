extends Node
class_name AudioEngine

signal start_audio
signal audio_finished
signal next_message_pressed

@onready var AudioParent :Node
var audio_player
var current_audio_dictionary :Dictionary
var selected_group_dictionary :Dictionary
var audio_dictionary :Dictionary

var is_group :bool
var wait :bool
var repeat_audio :bool
var repeat_amount :int

var stream:String
var volume:float
var pitch :float
var max_distance :float

func _ready():
	start_audio.connect(audio_begin)


func load_audio_player():
	var scene = AudioStreamPlayer2D.new()
	AudioParent.add_child(scene)
	
	scene.finished.connect(audio_player_cleanup)
	scene.set_name("audio")
	return scene


func set_audio_player_variables(function_dict:Dictionary):
	current_audio_dictionary = function_dict["audio_data"]


func set_variable_data(index):
	var index_dict :Dictionary = FARTENGINE.convert_string_to_type(selected_group_dictionary[index])
	stream = index_dict["stream"]
	volume = index_dict["volume"].to_float()
	pitch = index_dict["pitch"].to_float()
	max_distance = index_dict["max_distance"]
	#MAX DISTANCE VARIABLE SHOULD BE SET HERE
	audio_player.set_stream(load(FARTENGINE.table_save_path + FARTENGINE.sfx_folder + stream ))
	audio_player.set_volume_db(volume)
	audio_player.set_pitch_scale(pitch)
	audio_player.set_max_distance(max_distance) #THIS SHOULD BE SET WITH VARIABLE IN AUDIO INPUT NODE


func audio_begin(audio_dict, event_node :EventHandler):
	AudioParent = event_node#FARTENGINEget_gui().get_parent().get_node("EventAudio")
	audio_dictionary = audio_dict
	is_group = audio_dictionary["is_group"]
	repeat_amount = audio_dictionary["repeat_amount"]
	repeat_audio = audio_dictionary["repeat_audio"]
	wait = audio_dictionary["wait"]
	
	set_selected_group_dict_data(audio_dict)
	if wait:
		await iterate_through_audio()
	else:
		iterate_through_audio()

	audio_end()


func iterate_through_audio():
	if !repeat_audio:
		repeat_amount = 1
	for run_index in repeat_amount:
		for audio_index in selected_group_dictionary:
			if typeof(selected_group_dictionary[audio_index]) == TYPE_STRING:
				current_audio_dictionary = str_to_var(selected_group_dictionary[audio_index])
			else:
				current_audio_dictionary = selected_group_dictionary[audio_index]
			
			set_audio_player_variables(audio_dictionary)
			audio_player = load_audio_player()
			audio_player.name = "audio " + audio_index
			set_variable_data(audio_index)
			audio_player.play()
	#		waiting_for_user_input = true
			await audio_player.finished
#			audio_player.queue_free()


func set_selected_group_dict_data(audio_dict):
	selected_group_dictionary = {}
	var group_name :String = ""
	var static_audio_group_dictionary :Dictionary = FARTENGINE.Static_Game_Dict["SFX Groups"]
	var static_audio_group_data_dictionary :Dictionary = FARTENGINE.import_data("SFX Groups", true)
	if is_group: #GET IS GROUP VALUE
		group_name = audio_dict["audio_data"]["Group Name"]
		#Get Group dict
		var group_index = FARTENGINE.get_id_from_display_name(static_audio_group_dictionary, group_name)
		var index = 1
		for field in static_audio_group_data_dictionary["Column"]:
			var field_name = static_audio_group_data_dictionary["Column"][field]["FieldName"]
			if field_name != "Display Name":
				selected_group_dictionary[str(index)] = static_audio_group_dictionary[group_name][field_name]
				index += 1
	else:
		selected_group_dictionary["1"] = audio_dict["audio_data"]["Single"]

func audio_end():
	await AudioParent.get_tree().create_timer(.1).timeout
	emit_signal("audio_finished")


func audio_player_cleanup():
	for child in AudioParent.get_children():
		if child.get_class() == "AudioStreamPlayer2D":
			if child.is_playing():
				await child.finished
			child.queue_free()
