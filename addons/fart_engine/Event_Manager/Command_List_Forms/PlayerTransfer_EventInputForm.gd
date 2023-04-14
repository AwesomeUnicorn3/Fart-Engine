@tool
extends CommandForm

@onready var map_node = $Control/VBoxContainer/DropDown_Template
@onready var vector_node = $Control/VBoxContainer/Input_Vector
@onready var DBENGINE : DatabaseEngine = DatabaseEngine.new()

var function_name :String = "transfer_player" #must be name of valid function
var which_map :String
var what_coordinates 
var event_name :String = ""
var transfer_node
var scene_name 


func _ready():
	$Control/VBoxContainer/DropDown_Template.populate_list()


func set_input_values(old_function_dict :Dictionary):
	edit_state = true
	map_node.inputNode.text = old_function_dict[function_name][0]
	vector_node.inputNode.text = old_function_dict[function_name][1]
	vector_node.set_user_input_value()


func get_input_values():
	which_map = map_node.inputNode.text
	what_coordinates = vector_node.inputNode.text
	var return_function_dict = {function_name : [which_map,what_coordinates , event_name]}
	return return_function_dict


func _on_accept_button_up():
	commandListForm.CommandInputForm.function_dict = get_input_values()
	delete_transfer_node()
	if DBENGINE.get_main_node(self).name == "FART ENGINE":
		DBENGINE.close_scene_in_editor(which_map)
		await get_tree().create_timer(.25).timeout
		DBENGINE.return_to_AU3Engine()

	get_parent()._on_close_button_up() 


func _on_open_map_button_button_up():
	var editor := EditorScript.new().get_editor_interface()
	var map_dict = DBENGINE.import_data("Maps")
	var map_path
	which_map = map_node.inputNode.text
	for map_index in map_dict:
		if map_dict[map_index]["Display Name"] == which_map:
			map_path = map_dict[map_index]["Path"]
			break
	Add_Starting_position_node_to_map(which_map)


func Add_Starting_position_node_to_map(selectedItemName):
	var editor = EditorScript.new().get_editor_interface()
	var maps_dict = DBENGINE.import_data("Maps")
	var new_map_path :String = DBENGINE.get_mappath_from_displayname(selectedItemName)
	var transfer_position_node = Sprite2D.new()
	var new_map_scene = load(new_map_path).instantiate()
	new_map_scene.add_child(transfer_position_node)
	transfer_position_node.set_owner(new_map_scene)
	transfer_position_node.set_name("TransferPositionNode")
	transfer_position_node.set_script(load("res://addons/fart_engine/Database_Manager/TransferPositionNode.gd"))
	var transfer_position_icon :Texture = load("res://fart_data/png/StartingPosition.png")
	transfer_position_node.set_texture(transfer_position_icon)
	var new_packed_scene = PackedScene.new()
	new_packed_scene.pack(new_map_scene)
	var dir :DirAccess = DirAccess.open(new_map_path.get_base_dir())
	#dir.open(new_map_path.get_base_dir())
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
	var editor = EditorScript.new().get_editor_interface()
	vector_node.inputNode.set_text(str(current_position))
	vector_node.x_input.set_text(str(current_position.x))
	vector_node.y_input.set_text(str(current_position.y))
	if typeof(current_position) == TYPE_VECTOR3:
		vector_node.z_input.set_text(str(current_position.z))
	what_coordinates = vector_node.inputNode.text
