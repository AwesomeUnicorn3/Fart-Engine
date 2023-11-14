@tool
extends FartDatatype

var fileSelectedNode :Node
var popupDialog : FileDialog
var current_path :String = ""

func _init() -> void:
	type = "7"


func _on_TextureButton_button_up():
	on_text_changed(true)
	var FileSelectDialog  := preload("res://addons/fart_engine/Database_Manager/Scenes and Scripts/UI_Navigation_Scenes/FileSelectDialog.tscn")
	fileSelectedNode = FileSelectDialog.instantiate()
	var par = get_main_tab(self)
	par.get_node("Popups").visible = true
	par.get_node("Popups/FileSelect").visible = true
	par.get_node("Popups/FileSelect").add_child(fileSelectedNode)
	
	popupDialog = fileSelectedNode.get_node("FileSelectDialog")
	popupDialog.show_hidden_files = true
	popupDialog.set_access(0)
	popupDialog.set_filters(Array(["*.tscn"]))
	current_path = inputNode.get_text()
	current_path = current_path.get_base_dir()
	popupDialog.set_current_dir(current_path)
	popupDialog.file_selected.connect(_on_FileDialog_file_selected)
	popupDialog.canceled.connect(remove_dialog)
	popupDialog.dir_selected.connect(_on_FileDialog_file_selected)


func remove_dialog():
	var par = get_main_tab(self)
	var list_node :Node = par.get_node("Popups/ListInput")
	if list_node.get_child_count() == 0:
		par.get_node("Popups").visible = false
	par.get_node("Popups/FileSelect").visible = false
	fileSelectedNode.queue_free()


func _on_FileDialog_file_selected(path):
	current_path = path.get_base_dir() #necessary to navigate filedialog to correct directory
	inputNode.set_text(path)
	$HBoxContainer/Display.set_text(get_filename_from_path(path))
	is_scenepath(path)
	remove_dialog()


func _on_input_text_changed(new_text):
	$HBoxContainer/Display.set_text(get_filename_from_path(new_text))


func get_filename_from_path(path:String):
	var filename :String
	filename = path.get_file().trim_suffix("." + path.get_extension())
	$HBoxContainer/Display.set_tooltip_text(path) 
	return filename


func _on_open_scene_button_up():
	#IF PATH IS A SCENE, OPEN THIS WAY
	var editor := EditorScript.new().get_editor_interface()
	current_path = inputNode.text
	var open_scenes = editor.get_open_scenes()
	if open_scenes.has(current_path):
		editor.reload_scene_from_path(current_path)
	else:
		editor.open_scene_from_path(current_path)


func _get_input_value() -> String:
	var return_value :String
	return_value = inputNode.get_text()
	return return_value


func _set_input_value(node_value):
	inputNode.set_text(node_value)
	is_scenepath(node_value)
	_on_input_text_changed(node_value)


func is_scenepath(path:String) -> bool:
	var is_tscn :bool = false
	if path.get_extension() == "tscn":
		is_tscn = true
		$HBoxContainer/OpenScene.visible = true
	else:
		$HBoxContainer/OpenScene.visible = false
	return is_tscn
