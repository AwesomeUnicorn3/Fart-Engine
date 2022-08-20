@tool
extends Control

@onready var map_node = $Control/VBoxContainer/DropDown_Template
@onready var vector_node = $Control/VBoxContainer/Input_Vector
@onready var DBENGINE : DatabaseEngine = DatabaseEngine.new()
var commandListForm :Control

var function_name :String = "transfer_player" #must be name of valid function
var which_map :String
var what_coordinates 
var event_name :String = ""
var transfer_node
var scene_name 

func _ready():
	map_node.populate_list()


func set_input_values():
	pass


func _on_accept_button_up():
	#Get input values as dictionary
	which_map = map_node.inputNode.text
	what_coordinates = vector_node.inputNode.text
	var function_dict :Dictionary = {function_name : [which_map,what_coordinates , event_name]}
	commandListForm.CommandInputForm.function_dict = function_dict
	delete_transfer_node()

	if DBENGINE.get_main_node(self).name == "UDSENGINE":
		#SHOULD CLOSE SCENE IF THE TRANSFER TO MAP IS NOT THE MAP THAT 
		#CONTAINS THE EVENT CURRENTLY BEING EDITTED
		DBENGINE.close_scene_in_editor(which_map)
	get_parent()._on_close_button_up()


func _on_cancel_button_up():
	queue_free()


func _on_open_map_button_button_up():
	var editor := EditorPlugin.new().get_editor_interface()
	var map_dict = DBENGINE.import_data(DBENGINE.table_save_path + "Maps" + DBENGINE.file_format)
	var map_path
	which_map = map_node.inputNode.text
	for map_index in map_dict:
		if map_dict[map_index]["Display Name"] == which_map:
			map_path = map_dict[map_index]["Path"]
			break
	add_starting_position_node_to_map(which_map)
	


func add_starting_position_node_to_map(selectedItemName):
	var editor = EditorPlugin.new().get_editor_interface()
	var maps_dict = DBENGINE.import_data(DBENGINE.table_save_path + "Maps" + DBENGINE.file_format)
	var new_map_path :String = DBENGINE.get_mappath_from_displayname(selectedItemName)

	var transfer_position_node = Sprite2D.new()
	var new_map_scene = load(new_map_path).instantiate()
	new_map_scene.add_child(transfer_position_node)
	transfer_position_node.set_owner(new_map_scene)
	transfer_position_node.set_name("TransferPositionNode")
	transfer_position_node.set_script(load("res://addons/UDSEngine/Database_Manager/TransferPositionNode.gd"))
	var transfer_position_icon :Texture = load("res://Data/png/StartingPosition.png")
	transfer_position_node.set_texture(transfer_position_icon)

	var new_packed_scene = PackedScene.new()
	new_packed_scene.pack(new_map_scene)
	var dir = Directory.new()
	dir.open(new_map_path.get_base_dir())
	dir.remove(selectedItemName)
	ResourceSaver.save(new_packed_scene, new_map_path)
	new_map_scene.queue_free()

	DBENGINE.open_scene_in_editor(new_map_path)
	var tabbar :TabBar = DBENGINE.get_editor_tabbar()
	var tabbar_dict :Dictionary = DBENGINE.get_open_scenes_in_editor()
	scene_name = new_map_path.get_file().get_basename()
	var scene_index :int = 0
	for index in tabbar_dict:
		if tabbar_dict[index] == scene_name:
			scene_index = index
			break

	tabbar.set_current_tab(scene_index)
	editor.get_edited_scene_root().get_node("TransferPositionNode").position_changed.connect(update_position)
	DBENGINE.select_node_in_editor("TransferPositionNode")

func delete_transfer_node():
	DBENGINE.delete_starting_position_from_old_map(scene_name, "TransferPositionNode")


func update_position(current_position):
	var editor = EditorPlugin.new().get_editor_interface()
	vector_node.inputNode.set_text(str(current_position))
	vector_node.x_input.set_text(str(current_position.x))
	vector_node.y_input.set_text(str(current_position.y))
	if typeof(current_position) == TYPE_VECTOR3:
		vector_node.z_input.set_text(str(current_position.z))
	what_coordinates = vector_node.inputNode.text
