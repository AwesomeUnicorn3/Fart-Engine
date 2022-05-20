extends InputEngine
tool


var fileSelectedNode :Node

func _init() -> void:
	type = "7"

#func _ready():
#	type = "ScenePath"
#	default = "res://addons/Example Game/ExampleGame.tscn"
#	inputNode = $HBoxContainer/Input


func _on_TextureButton_button_up():
	on_text_changed(true)
	var FileSelectDialog = load("res://addons/Database_Manager/Scenes and Scripts/UI_Navigation_Scenes/FileSelectDialog.tscn")
	fileSelectedNode = FileSelectDialog.instance()
	var par = get_main_tab(self)
	par.get_node("Popups").visible = true
	par.get_node("Popups/FileSelect").visible = true
	par.get_node("Popups/FileSelect").add_child(fileSelectedNode)
	var popupDialog : FileDialog = fileSelectedNode.get_node("FileSelectDialog")
	popupDialog.show_hidden_files = true
	popupDialog.set_access(0)
	popupDialog.set_filters(PoolStringArray(["*.tscn"]))
	popupDialog.connect("file_selected", self, "_on_FileDialog_file_selected")
	popupDialog.connect("hide", self, "remove_dialog")


func remove_dialog():
	var par = get_main_tab(self)
	var list_node :Node = par.get_node("Popups/ListInput")
	if list_node.get_child_count() == 0:
		par.get_node("Popups").visible = false
	par.get_node("Popups/FileSelect").visible = false
	fileSelectedNode.queue_free()
	


func _on_FileDialog_file_selected(path):
	inputNode.set_text(path)
	remove_dialog()



#func _on_Input_mouse_entered() -> void:
#	print("Mouse Entered")

var click_index = 0
func _on_Input_gui_input(event: InputEvent) -> void:
	if event.is_pressed() and event is InputEventMouseButton and event.button_index == 1:
		double_click()
	if click_index >= 2:
		click_index == 0
		_on_TextureButton_button_up()


func double_click():
	click_index += 1
	yield(get_tree().create_timer(.2),"timeout")
	click_index -= 1
