@tool
extends InputEngine


var fileSelectedNode :Node
var popupDialog : FileDialog

func _init() -> void:
	type = "6"


#func _ready():
#	inputNode = $HBoxContainer/ColorRect/Input
#	labelNode = $Label/HBox1/Label_Button


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
	popupDialog.cancelled.connect(remove_dialog)


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
		#dir.open(par.table_save_path + par.icon_folder)
		await dir.copy(path, new_file_path)
		
		if par.is_file_in_folder(par.icon_folder, new_file_name):
			print("File Not Added")
		else:
			print("File Added")
			await par.refresh_editor()
			print("Scan Complete")
			curr_icon_path.set_texture_normal(load(str(new_file_path)))
