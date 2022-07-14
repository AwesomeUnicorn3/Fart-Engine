@tool
extends InputEngine

@export var increment = 1

var control_node #= $HBox1/Control
var height_node #:= $HBox1

var fileSelectedNode :Node
var num_value
var sprite_player : AnimatedSprite2D
var control_rect_height = 64
var control_position :Vector2 = Vector2.ZERO
var popupDialog : FileDialog

func _init() -> void:
	type = "8"
	await input_load_complete
	control_node = $HBox1/Control
	height_node = $Label
#func _ready():
#	inputNode = $HBox1/Input
#	labelNode = $Label/HBox1/Label_Button

func startup():
	set_process(false)
#	par = get_main_tab(self)
	$AnimatedSprite.visible = false
#	yield(get_tree().create_timer(.1),"timeout")
#	var t = Timer.new()
#	t.set_one_shot(true)
#	self.add_child(t)
#	t.set_wait_time(.25)
#	t.start()
#	yield(t, "timeout")
#	t.queue_free()
	await get_tree().create_timer(.25).timeout

	if show_field:
		$AnimatedSprite.visible = true
#		yield(get_tree().create_timer(.1),"timeout")

	if typeof(input_data) != TYPE_ARRAY: #Should only be false when called from event
#		parent_node = get_main_tab(self)
#		control_node = $HBox1/Control
		
		input_data = parent_node.get_default_value(type)
#		input_data = get_input_data()
#		print(input_data)

	create_sprite_animation()
	set_process(true)


func _process(delta: float) -> void:
	if show_field:
		if !$AnimatedSprite.visible:
			$AnimatedSprite.visible = true
			create_sprite_animation()
#			print("Visible")
		elif control_node.get_size().y != control_rect_height:
			create_sprite_animation()
		control_position = control_node.get_rect().position
#		print(control_position, " ",height_node.size.y )
		control_position.y += height_node.size.y

		$AnimatedSprite.set_position(control_position)

	else:
		if $AnimatedSprite.visible:
			$AnimatedSprite.visible = false
			$AnimatedSprite.stop()
#			print("Not Visible")


func _on_TextureButton_button_up():
	on_text_changed(true)
	var FileSelectDialog = load("res://addons/UDSEngine/Database_Manager/Scenes and Scripts/UI_Navigation_Scenes/FileSelectDialog.tscn")
	fileSelectedNode = FileSelectDialog.instantiate()
	
	parent_node.get_node("Popups").visible = true
	parent_node.get_node("Popups/FileSelect").visible = true
	parent_node.get_node("Popups/FileSelect").add_child(fileSelectedNode)

	popupDialog = fileSelectedNode.get_node("FileSelectDialog")
	popupDialog.show_hidden_files = true
	popupDialog.set_access(2)
	popupDialog.set_filters(Array(["*.png"]))
#	popupDialog.connect("file_selected", self, "_on_FileDialog_file_selected")
	popupDialog.file_selected.connect(_on_FileDialog_sprite_file_selected)
#	popupDialog.connect("hide", self, "remove_dialog")
	popupDialog.cancelled.connect(remove_dialog)

func create_sprite_animation():
	control_rect_height = control_node.get_size().y
	control_node.set_size(Vector2(control_rect_height, control_rect_height))

	sprite_player = $AnimatedSprite
	if sprite_player.is_playing():
		sprite_player.stop()
	sprite_player.get_sprite_frames().remove_animation(labelNode.get_text())

	parent_node.add_animation_to_animatedSprite(labelNode.get_text(), input_data, false,  sprite_player)
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
#			var tr = Timer.new()
#			tr.set_one_shot(true)
#			add_child(tr)
#			tr.set_wait_time(.25)
#			tr.start()
#			yield(tr, "timeout")
#			tr.queue_free()
			await get_tree().create_timer(.25).timeout
			curr_icon_path.set_normal_texture(load(str(new_file_path)))
	input_data = get_input_data()
	create_sprite_animation()
#	refresh_data(Item_Name)

func get_input_data():
	var vframe : int = get_node("HBox1/VBox1/VBox1/VInput").get_text().to_int()
	var hframe :int = get_node("HBox1/VBox1/VBox1/HInput").get_text().to_int()
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
	num_value = numInputNode.get_text().to_int()
	num_value += increment
	numInputNode.set_text(str(num_value))
	on_text_changed(true)
	input_data = get_input_data()
	create_sprite_animation()


func _on_Sub_ButtonV_button_up() -> void:
	var numInputNode = $HBox1/VBox1/VBox1/VInput
	num_value = numInputNode.get_text().to_int()
	num_value -= increment
	if num_value >= 1:
		numInputNode.set_text(str(num_value))
		on_text_changed(true)
		input_data = get_input_data()
		create_sprite_animation()


func _on_Add_ButtonH_button_up() -> void:
	var numInputNode = $HBox1/VBox1/VBox1/HInput
	num_value = numInputNode.get_text().to_int()
	num_value += increment
	numInputNode.set_text(str(num_value))
	on_text_changed(true)
	input_data = get_input_data()
	create_sprite_animation()


func _on_Sub_ButtonH_button_up() -> void:
	var numInputNode = $HBox1/VBox1/VBox1/HInput
	num_value = numInputNode.get_text().to_int()
	num_value -= increment
	if num_value >= 1:
		numInputNode.set_text(str(num_value))
		on_text_changed(true)
		input_data = get_input_data()
		create_sprite_animation()


func _on_HInput_text_changed(new_text: String) -> void:
	on_text_changed(true)


func _on_VInput_text_changed(new_text: String) -> void:
	on_text_changed(true)



func _on_Sprite_Template_resized() -> void:
	if is_processing():
		if show_field:
			create_sprite_animation()
