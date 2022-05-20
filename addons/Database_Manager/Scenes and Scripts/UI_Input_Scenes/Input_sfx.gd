extends InputEngine
tool

onready var sfx_name := $HBoxContainer/VBoxContainer2/sfx_name
onready var volumne_slider := $HBoxContainer/VBoxContainer/HBoxContainer/HSlider
onready var pitch_slider := $HBoxContainer/VBoxContainer/HBoxContainer2/HSlider

var fileSelectedNode :Node

func _init() -> void:
	type = "13"

func remove_dialog():
	var par = get_main_tab(self)
	var list_node :Node = par.get_node("Popups/ListInput")
	if list_node.get_child_count() == 0:
		par.get_node("Popups").visible = false
	par.get_node("Popups/FileSelect").visible = false
	fileSelectedNode.queue_free()
	


func _on_FileDialog_file_selected(path):
	remove_dialog()
	var par = get_main_tab(self)
#	par.popup_main.visible = false
	var dir = Directory.new() #
	var new_file_name = path.get_file() #
	var new_file_path = par.table_save_path + par.sfx_folder + new_file_name #
	var curr_sfx_path : Node = inputNode #
#	var file_dialog_signal = "file_selected"
	if par.is_file_in_folder(par.table_save_path + par.sfx_folder, new_file_name): # #Check if selected folder is sfx folder and has selected file
		curr_sfx_path.set_stream(load(str(new_file_path)))
		sfx_name.set_text(new_file_path.get_file())
#		save_all_db_files(current_table_name)
	else:
		dir.copy(path, new_file_path)
		if !par.is_file_in_folder(par.table_save_path + par.sfx_folder, new_file_name):
			print("File Not Added")
		else:
			print("File Added")
			par.refresh_editor()
			
			var tr = Timer.new()
			tr.set_one_shot(true)
			add_child(tr)
			tr.set_wait_time(.25)
			tr.start()
			yield(tr, "timeout")
			tr.queue_free()
			curr_sfx_path.set_stream(load(str(new_file_path)))
			sfx_name.set_text(new_file_path.get_file())



func _on_Input_button_up() -> void:
	on_text_changed(true)
	var FileSelectDialog = load("res://addons/Database_Manager/Scenes and Scripts/UI_Navigation_Scenes/FileSelectDialog.tscn")
	fileSelectedNode = FileSelectDialog.instance()
	var par = get_main_tab(self)
	par.get_node("Popups").visible = true
	par.get_node("Popups/FileSelect").visible = true
	par.get_node("Popups/FileSelect").add_child(fileSelectedNode)
	var popupDialog : Node = fileSelectedNode.get_node("FileSelectDialog")
	popupDialog.show_hidden_files = true
	popupDialog.set_access(2)
	popupDialog.set_filters(PoolStringArray(["*.wav"]))
	popupDialog.connect("file_selected", self, "_on_FileDialog_file_selected")
	popupDialog.connect("hide", self, "remove_dialog")


func _on_Button_button_up() -> void:
	inputNode.play()
	yield(inputNode,"finished")
	inputNode.stop()
#	print("Finished")


func _on_Volume_value_changed(value: float) -> void:
	inputNode.set_volume_db(value)
	var volume_label : Label = $HBoxContainer/VBoxContainer/HBoxContainer/Volume
	var min_value = volumne_slider.min_value
	var max_value = volumne_slider.max_value
	var total_volume_option_value = max_value - min_value
	var volume_percent = round(((value + abs(min_value))/total_volume_option_value) * 100)
	volume_label.set_text(str(volume_percent)  + "%")


func _on_pitch_value_changed(value: float) -> void:
	inputNode.set_pitch_scale(value)
	var pitch_label : Label = $HBoxContainer/VBoxContainer/HBoxContainer2/Pitch
	var min_value = pitch_slider.min_value
	var max_value = pitch_slider.max_value
	var total_pitch_option_value = max_value - min_value
#	print(total_pitch_option_value,  " " , ((value - abs(min_value))/total_pitch_option_value) * 100)
	var pitch_percent = round(((value - abs(min_value))/total_pitch_option_value) * 100)
	pitch_label.set_text(str(pitch_percent)  + "%")


func _on_Stop_button_up() -> void:
	inputNode.stop()
