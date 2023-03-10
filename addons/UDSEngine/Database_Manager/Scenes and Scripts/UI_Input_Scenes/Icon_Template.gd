@tool
extends InputEngine


var fileSelectedNode :Node
var popupDialog : FileDialog

func _init() -> void:
	type = "6"


func _on_TextureButton_button_up():
	on_text_changed(true)
	var FileSelectDialog = load("res://addons/UDSEngine/Database_Manager/Scenes and Scripts/UI_Navigation_Scenes/FileSelectDialog.tscn")
	fileSelectedNode = FileSelectDialog.instantiate()
	var par = get_main_tab(self)
	par.get_node("Popups").visible = true
	par.get_node("Popups/FileSelect").visible = true
	par.get_node("Popups/FileSelect").add_child(fileSelectedNode)
	var popupDialog : Node = fileSelectedNode.get_node("FileSelectDialog")
	popupDialog = fileSelectedNode.get_node("FileSelectDialog")
	popupDialog.show_hidden_files = true
	popupDialog.set_access(2)
	popupDialog.set_filters(Array(["*.png"]))
	popupDialog.file_selected.connect(_on_FileDialog_file_selected)
	popupDialog.canceled.connect(remove_dialog)


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
	var new_file_name = path.get_file() #
	var new_file_path = par.table_save_path + par.icon_folder + new_file_name #
	var curr_icon_path : Node = inputNode #
	var does_selected_file_exist = par.is_file_in_folder(par.table_save_path + par.icon_folder, new_file_name)
	if does_selected_file_exist: # #Check if selected folder is Icon folder and has selected file
		curr_icon_path.set_texture_normal(load(str(new_file_path)))
	else:
		var dir :DirAccess = DirAccess.open(par.table_save_path + par.icon_folder)
		await dir.copy(path, new_file_path)
		if par.is_file_in_folder(par.icon_folder, new_file_name):
			print("File Not Added")
		else:
			print("File Added")
			var editor  = load("res://addons/UDSEngine/EditorEngine.gd").new()
			editor.refresh_editor(self)
			await editor.Editor_Refresh_Complete
			curr_icon_path.set_texture_normal(load(str(new_file_path)))


func _get_input_value() -> String:
	var return_value :String
	return_value = inputNode.get_texture_normal().get_path().get_file()
	return return_value


func _set_input_value(node_value):
	var texture_path:String = node_value
	if texture_path == "empty":
		texture_path = default
	var tempBtn :TextureButton = inputNode
	tempBtn.set_texture_normal(load(DBENGINE.table_save_path + DBENGINE.icon_folder + texture_path))
