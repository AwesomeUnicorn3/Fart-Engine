@tool
extends InputEngine

var sfx_name
var volume_slider :Slider#= $HBoxContainer/VBoxContainer/HBoxContainer/HSlider
var pitch_slider :Slider#= $HBoxContainer/VBoxContainer/HBoxContainer2/HSlider

var fileSelectedNode :Node

func _init() -> void:
	type = "13"
	await input_load_complete
	pitch_slider = get_node("HBoxContainer/VBoxContainer/HBoxContainer2/HSlider")
	volume_slider = get_node("HBoxContainer/VBoxContainer/HBoxContainer/HSlider")
#func _ready():
#	inputNode = $Input
#	labelNode = $Label/HBox1/Label_Button


func remove_dialog():
	print("Remove dialog")
	var par = get_main_tab(self)
	var list_node :Node = par.get_node("Popups/ListInput")
	var child_count = list_node.get_child_count()
	if child_count <= 0:
		par.get_node("Popups").visible = false
#	par.get_node("Popups/FileSelect").visible = false
	par._on_FileDialog_hide()
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
		$HBoxContainer/VBoxContainer2/sfx_name.set_text(new_file_path.get_file())
#		save_all_db_files(current_table_name)
	else:
		dir.copy(path, new_file_path)
		if !par.is_file_in_folder(par.table_save_path + par.sfx_folder, new_file_name):
			print("File Not Added")
		else:
			print("File Added")
			par.refresh_editor()
			await get_tree().create_timer(.25).timeout
			curr_sfx_path.set_stream(load(str(new_file_path)))
			$HBoxContainer/VBoxContainer2/sfx_name.set_text(new_file_path.get_file())



func _on_Input_button_up() -> void:
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
	popupDialog.set_filters(Array(["*.wav"]))
#	popupDialog.connect("file_selected", self, "_on_FileDialog_file_selected")
	popupDialog.file_selected.connect(_on_FileDialog_file_selected)
#	popupDialog.connect("hide", self, "remove_dialog")
	popupDialog.cancelled.connect(remove_dialog)

func _on_Button_button_up() -> void:
	inputNode.play()
	await inputNode.finished
#	yield(inputNode,"finished")
	inputNode.stop()
#	print("Finished")


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
#	print(total_pitch_option_value,  " " , ((value - abs(min_value))/total_pitch_option_value) * 100)
	var pitch_percent = round(((value - abs(min_value))/total_pitch_option_value) * 100)
	pitch_label.set_text(str(pitch_percent)  + "%")


func _on_Stop_button_up() -> void:
	inputNode.stop()
