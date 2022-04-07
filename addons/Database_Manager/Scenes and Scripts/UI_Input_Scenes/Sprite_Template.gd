extends InputEngine
tool

export var increment = 1

onready var control_node = $HBox1/Control
onready var height_node := $HBox1

var fileSelectedNode :Node
var num_value
var sprite_player : AnimatedSprite
var control_rect_height = 64


func _init() -> void:
	type = "TYPE_SPRITEDISPLAY"

func _ready():
#	type = "SpriteDisplay"
#	default = ["addons/Database_Manager/Data/Icons/Default.png", Vector2(1, 1)]
#	par = get_main_tab(self)
	$AnimatedSprite.visible = false
	yield(get_tree().create_timer(.1),"timeout")
	create_sprite_animation()
	$AnimatedSprite.visible = true


func _process(delta: float) -> void:
	var control_position :Vector2 = control_node.get_rect().position
	control_position.y += height_node.margin_top
	$AnimatedSprite.set_position(control_position)
	

func _on_TextureButton_button_up():
	on_text_changed(true)
	var FileSelectDialog = load("res://addons/Database_Manager/Scenes and Scripts/UI_Navigation_Scenes/FileSelectDialog.tscn")
	fileSelectedNode = FileSelectDialog.instance()
	
	parent_node.get_node("Popups").visible = true
	parent_node.get_node("Popups/FileSelect").visible = true
	parent_node.get_node("Popups/FileSelect").add_child(fileSelectedNode)
	var popupDialog : Node = fileSelectedNode.get_node("FileSelectDialog")
	popupDialog.show_hidden_files = true
	popupDialog.connect("file_selected", self, "_on_FileDialog_sprite_file_selected")
	popupDialog.connect("hide", self, "remove_dialog")

func create_sprite_animation():
	control_rect_height = control_node.get_size().y
	#I CANT FIGURE OUT WHY BUT FOR SOME REASON WHEN THE TAB LOADS FOR THE FIRST TIME, IT IS SETTING
	#THE CONTROL_RECT_HEIGHT TO THE DEFAULT INPUT SIZE INSTEAD OF THE SIZE AFTER ADJUSTING TO THE FORM
	if control_rect_height > 124:
		control_rect_height = 124

	sprite_player = $AnimatedSprite
	if sprite_player.is_playing():
		sprite_player.stop()
	sprite_player.get_sprite_frames().remove_animation(labelNode.get_text())

	parent_node.add_animation_to_animatedSprite(labelNode.get_text(), input_data, sprite_player)
	sprite_player.play(labelNode.get_text())

	
	var sprite_texture = load(parent_node.table_save_path + parent_node.icon_folder + get_input_data()[0])
	var sprite_count = parent_node.convert_string_to_Vector(get_input_data()[1])
	var sprite_cell_size := Vector2(sprite_texture.get_size().x / sprite_count.y ,sprite_texture.get_size().y / sprite_count.x)
	var sprite_cell_ratio : float = sprite_cell_size.y / sprite_cell_size.x

	
	var modified_sprite_size_y = control_rect_height
	var y_scale_value = modified_sprite_size_y / sprite_cell_size.y
	var x_scale_value = y_scale_value * sprite_cell_ratio
	$AnimatedSprite.set_scale(Vector2(x_scale_value, y_scale_value))

func _on_FileDialog_sprite_file_selected(path: String) -> void:
	remove_dialog()

#	par.popup_main.visible = false
	var dir = Directory.new() #
	var new_file_name = path.get_file() #
	var new_file_path = parent_node.table_save_path + parent_node.icon_folder + new_file_name #
	var curr_icon_path : Node = inputNode #
	#Get frame values
#	var sprite_path = curr_icon_path.get_text()[0]

	if parent_node.is_file_in_folder(parent_node.table_save_path + parent_node.icon_folder, new_file_name): #Check if selected folder is Icon folder and has selected file
		curr_icon_path.set_normal_texture(load(str(new_file_path)))
#		save_all_db_files(current_table_name)
	else:
		dir.copy(path, new_file_path)
		if !parent_node.is_file_in_folder(parent_node.table_save_path + parent_node.icon_folder, new_file_name):
			print("File Not Added")
		else:
			print("File Added")
			#trigger the import process for it to load to texture rect
			parent_node.refresh_editor()
			var tr = Timer.new()
			tr.set_one_shot(true)
			add_child(tr)
			tr.set_wait_time(.25)
			tr.start()
			yield(tr, "timeout")
			tr.queue_free()
			curr_icon_path.set_normal_texture(load(str(new_file_path)))
	input_data = get_input_data()
	create_sprite_animation()
#	refresh_data(Item_Name)

func get_input_data():
	var vframe = get_node("HBox1/VBox1/VBox1/VInput").get_text()
	var hframe = get_node("HBox1/VBox1/VBox1/HInput").get_text()
	var frames = Vector2(vframe,hframe)
	var sprite_data := [str(inputNode.get_normal_texture().get_path()).get_file() , str(frames)]
	return sprite_data

func remove_dialog():
	var par = get_main_tab(self)
	var list_node :Node = par.get_node("Popups/ListInput")
	if list_node.get_child_count() == 0:
		par.get_node("Popups").visible = false
	par.get_node("Popups/FileSelect").visible = false
	fileSelectedNode.queue_free()

func _on_Add_ButtonV_button_up() -> void:
	var numInputNode = $HBox1/VBox1/VBox1/VInput
	num_value = int(numInputNode.get_text())
	num_value += increment
	numInputNode.set_text(str(num_value))
	on_text_changed(true)
	input_data = get_input_data()
	create_sprite_animation()


func _on_Sub_ButtonV_button_up() -> void:
	var numInputNode = $HBox1/VBox1/VBox1/VInput
	num_value = int(numInputNode.get_text())
	num_value -= increment
	numInputNode.set_text(str(num_value))
	on_text_changed(true)
	input_data = get_input_data()
	create_sprite_animation()


func _on_Add_ButtonH_button_up() -> void:
	var numInputNode = $HBox1/VBox1/VBox1/HInput
	num_value = int(numInputNode.get_text())
	num_value += increment
	numInputNode.set_text(str(num_value))
	on_text_changed(true)
	input_data = get_input_data()
	create_sprite_animation()


func _on_Sub_ButtonH_button_up() -> void:
	var numInputNode = $HBox1/VBox1/VBox1/HInput
	num_value = int(numInputNode.get_text())
	num_value -= increment
	numInputNode.set_text(str(num_value))
	on_text_changed(true)
	input_data = get_input_data()
	create_sprite_animation()


func _on_HInput_text_changed(new_text: String) -> void:
	on_text_changed(true)


func _on_VInput_text_changed(new_text: String) -> void:
	on_text_changed(true)

