@tool
extends InputEngine

var sfx_name
var volume_slider :Slider#= $HBoxContainer/VBoxContainer/HBoxContainer/HSlider
var pitch_slider :Slider#= $HBoxContainer/VBoxContainer/HBoxContainer2/HSlider
var loop_audio_input
var fileSelectedNode :Node
var is_audio_playing :bool = false

func _init() -> void:
	type = "13"
	await input_load_complete
	pitch_slider = get_node("HBoxContainer/VBoxContainer/HBoxContainer2/HSlider")
	volume_slider = get_node("HBoxContainer/VBoxContainer/HBoxContainer/HSlider")
	loop_audio_input = $HBoxContainer/VBoxContainer/LoopAudio
	loop_audio_input.checkbox_pressed.connect(loop_changed)
	_set_input_value(DBENGINE.convert_string_to_type(DBENGINE.get_default_value(type)))

func loop_changed(value):
	input_data["loop_audio"] = value


func remove_dialog():
	var par = get_main_tab(self)
	var list_node :Node = par.get_node("Popups/ListInput")
	var child_count = list_node.get_child_count()
	if child_count <= 0:
		par.get_node("Popups").visible = false
	par._on_FileDialog_hide()
	fileSelectedNode.queue_free()


func _on_FileDialog_file_selected(path :String):
	remove_dialog()
	var par = get_main_tab(self)
	
	var new_file_name = path.get_file() #
	var new_file_path = par.table_save_path + par.sfx_folder + new_file_name #
	var curr_sfx_path : Node = inputNode #
	if par.is_file_in_folder(par.table_save_path + par.sfx_folder, new_file_name): # #Check if selected folder is sfx folder and has selected file
		print("IN SFX Folder")
		curr_sfx_path.set_stream(load(str(new_file_path)))
		$HBoxContainer/VBoxContainer2/sfx_name.set_text(new_file_path.get_file())
	else:
		print("Not in SFX Folder")
		var dir :DirAccess = DirAccess.open(path.get_base_dir())
		print(path)
		dir.copy(path, new_file_path)
		if !par.is_file_in_folder(par.table_save_path + par.sfx_folder, new_file_name):
			print("File Not Added")
		else:
			print("File Added")
			par.refresh_editor()
			await par.Editor_Refresh_Complete
			curr_sfx_path.set_stream(load(str(new_file_path)))
			$HBoxContainer/VBoxContainer2/sfx_name.set_text(new_file_path.get_file())


func edit_audio_file() -> void:
	on_text_changed(true)
	var FileSelectDialog = load("res://addons/UDSEngine/Database_Manager/Scenes and Scripts/UI_Navigation_Scenes/FileSelectDialog.tscn")
	fileSelectedNode = FileSelectDialog.instantiate()
	var par = get_main_tab(self)
	par.get_node("Popups").visible = true
	par.get_node("Popups/FileSelect").visible = true
	par.get_node("Popups/FileSelect").add_child(fileSelectedNode)
	
	var popupDialog : Node = fileSelectedNode.get_node("FileSelectDialog")
	popupDialog.show_hidden_files = true
	popupDialog.set_access(2)
	popupDialog.set_filters(Array(["*.wav", "*.ogg"]))
	popupDialog.file_selected.connect(_on_FileDialog_file_selected)
	popupDialog.cancelled.connect(remove_dialog)


func play_audio() -> void:
	var loop :bool = input_data["loop_audio"]
	if loop:
		is_audio_playing = true
		while is_audio_playing and loop:
			inputNode.play()
			await inputNode.finished
			loop = input_data["loop_audio"]
		
	else:
		inputNode.play()
		is_audio_playing = true
		await inputNode.finished

	is_audio_playing = false
	inputNode.stop()


func stop_audio_playback() -> void:
	inputNode.stop()
	is_audio_playing = false


func _on_Volume_value_changed(value: float) -> void:
	inputNode.set_volume_db(value)
	var volume_label : Label = $HBoxContainer/VBoxContainer/HBoxContainer/Volume
	var min_value = volume_slider.min_value
	var max_value = volume_slider.max_value
	var total_volume_option_value = max_value - min_value
	var volume_percent = round(((value + abs(min_value))/total_volume_option_value) * 100)
	volume_label.set_text(str(volume_percent)  + "%")


func _on_pitch_value_changed(value: float) -> void:
	inputNode.set_pitch_scale(value)
	var pitch_label : Label = $HBoxContainer/VBoxContainer/HBoxContainer2/Pitch
	var min_value = pitch_slider.min_value
	var max_value = pitch_slider.max_value
	var total_pitch_option_value = max_value - min_value
	var pitch_percent = round(((value - abs(min_value))/total_pitch_option_value) * 100)
	pitch_label.set_text(str(pitch_percent)  + "%")


#func load_audio_loop():
#	var input_value = event_dict[event_tab]["Loop Animation?"]
#	input_node_dict["Does Event Move?"] = new_input_container
#	new_input_container.true_text = "Yes"
#	new_input_container.false_text = "No"
#	new_input_container.checkbox_pressed.connect(animation_state_selected)


func _set_input_value(node_value):
	if typeof(node_value) == TYPE_STRING:
		node_value = str_to_var(node_value)
	input_data = node_value
	var stream :String = input_data["stream"]
	var stream_path :String = DBENGINE.table_save_path + DBENGINE.sfx_folder + stream
	var volume :float = input_data["volume"].to_float()
	var pitch :float = input_data["pitch"].to_float()
	var loop_audio :bool = input_data["loop_audio"]
	loop_changed(loop_audio)
	inputNode.set_stream(load(stream_path))
	inputNode.set_volume_db(volume)
	inputNode.set_pitch_scale(pitch)
	
	$HBoxContainer/VBoxContainer2/sfx_name.set_text(stream_path.get_file())
	$HBoxContainer/VBoxContainer/HBoxContainer/HSlider.set_value(volume)
	$HBoxContainer/VBoxContainer/HBoxContainer2/HSlider.set_value(pitch)
	$HBoxContainer/VBoxContainer/LoopAudio.inputNode.button_pressed = loop_audio
	$HBoxContainer/VBoxContainer/LoopAudio._on_input_toggled(loop_audio)


func _get_input_value():
	var return_value :Dictionary
	var stream : String = inputNode.get_stream().resource_path.get_file()
	var volume : String = str(inputNode.get_volume_db())
	var pitch : String = str(inputNode.get_pitch_scale())
	var loop : bool = $HBoxContainer/VBoxContainer/LoopAudio.inputNode.button_pressed
	
	return_value["stream"] = stream
	return_value["volume"] = volume
	return_value["pitch"] = pitch
	return_value["loop_audio"] = loop
	return return_value
