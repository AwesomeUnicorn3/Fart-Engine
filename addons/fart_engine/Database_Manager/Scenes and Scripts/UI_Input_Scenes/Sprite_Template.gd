@tool
extends InputEngine

@export var increment = 1


var fileSelectedNode :Node
#var num_value
var control_position :Vector2 = Vector2.ZERO
var popupDialog : FileDialog
var sprite_cell_size := Vector2.ZERO
var sprite_scale := Vector2.ZERO
var hide_advanced_options :bool = false

var texture_path :String
var frame_vector :Vector2
var frame_range :Vector2
var speed :int
var sprite_size :Vector2


var atlas_dict :Dictionary
var advanced_dict :Dictionary

@onready var atlas_h_input := $StandardControlsHBox/SpriteAtlasHBox/SpriteAtlasVBox/VBox1/VBox1/HInput
@onready var atlas_v_input := $StandardControlsHBox/SpriteAtlasHBox/SpriteAtlasVBox/VBox1/VBox1/VInput
@onready var sprite_animation := $AnimatedSprite
@onready var preview_window := $StandardControlsHBox/PreviewVBox/Control/PreviewWindow

@onready var vframe := $AdvancedControlsVBox/AdvancedControlsHBox/FrameRangeVBox/VBox1/VFrame
@onready var hframe :=$AdvancedControlsVBox/AdvancedControlsHBox/FrameRangeVBox/VBox1/HFrame
@onready var speed_input :=$AdvancedControlsVBox/AdvancedControlsHBox/SpeedVBox/VBox1/SpeedInput
@onready var height_sprite_size :=$AdvancedControlsVBox/AdvancedControlsHBox/SpriteSizeVBox/VBox1/HeightSpriteSize
@onready var width_sprite_size :=$AdvancedControlsVBox/AdvancedControlsHBox/SpriteSizeVBox/VBox1/WidthSpriteSize

func _init() -> void:
	type = "8"
	await input_load_complete


func startup():
	sprite_animation.visible = false
	if show_field:
		sprite_animation.visible = true


func set_preview_position() -> void:
	if show_field:
		if !sprite_animation.visible:
			sprite_animation.visible = true
		control_position = $StandardControlsHBox/SpriteAtlasHBox/SpriteAtlasVBox.get_rect().size
		control_position.x += (preview_window.size.x - (sprite_cell_size.x * sprite_scale.x)) / 2
		control_position.y = $StandardControlsHBox/PreviewVBox/Label3.size.y + $Label.size.y + 5
		sprite_animation.set_position(control_position)
	else:
		if sprite_animation.visible:
			sprite_animation.visible = false
			sprite_animation.stop()


func _on_TextureButton_button_up():
	on_text_changed(true)

#	if !parent_node.has_node("Popups"):
#		var new_child = load("res://addons/UDSEngine/Database_Manager/Scenes and Scripts/UI_Navigation_Scenes/Popups.tscn").instantiate()
#		parent_node.add_child(new_child)
#		new_child.set_name("Popups")

	var FileSelectDialog = load("res://addons/fart_engine/Database_Manager/Scenes and Scripts/UI_Navigation_Scenes/FileSelectDialog.tscn")
	fileSelectedNode = FileSelectDialog.instantiate()
	parent_node.get_node("Popups").visible = true
	parent_node.get_node("Popups/FileSelect").visible = true
	parent_node.get_node("Popups/FileSelect").add_child(fileSelectedNode)
	popupDialog = fileSelectedNode.get_node("FileSelectDialog")
	popupDialog.show_hidden_files = true
	popupDialog.set_access(2)
	popupDialog.set_filters(Array(["*.png"]))
	popupDialog.file_selected.connect(_on_FileDialog_sprite_file_selected)
	popupDialog.canceled.connect(remove_dialog)


func create_sprite_animation():
	if sprite_animation.is_playing():
		sprite_animation.stop()
	sprite_animation.get_sprite_frames().remove_animation(labelNode.get_text())
	DBENGINE.add_animation_to_animatedSprite(labelNode.get_text(), input_data, false,  sprite_animation)
	sprite_animation.play(labelNode.get_text())


func set_preview_animation_size():
	var sprite_texture = load(DBENGINE.table_save_path + DBENGINE.icon_folder + atlas_dict["texture_name"])
	var sprite_count = frame_vector
	sprite_cell_size = Vector2(sprite_texture.get_size().x / sprite_count.y ,sprite_texture.get_size().y / sprite_count.x)
	var sprite_cell_ratio : float = sprite_cell_size.y / sprite_cell_size.x
	var modified_sprite_size_y = preview_window.get_size().y
	var y_scale_value = modified_sprite_size_y / sprite_cell_size.y
	var x_scale_value = y_scale_value * sprite_cell_ratio
	sprite_scale = Vector2(x_scale_value, y_scale_value)
	sprite_animation.set_scale(Vector2(x_scale_value, y_scale_value))
	
	if sprite_size.x and sprite_size.y == 1:
		set_sprite_default_size()


func set_sprite_default_size():
	var sprite_texture = load(DBENGINE.table_save_path + DBENGINE.icon_folder + atlas_dict["texture_name"])
	var sprite_height = sprite_texture.get_size().y / frame_vector.x
	var sprite_width = sprite_texture.get_size().x / frame_vector.y
	sprite_cell_size = Vector2(sprite_height ,sprite_width)
	height_sprite_size.set_text(str(sprite_height))
	width_sprite_size.set_text(str(sprite_width))
	_set_input_value(_get_input_value())


func _on_FileDialog_sprite_file_selected(path: String) -> void:
	remove_dialog()
	
	var new_file_name = path.get_file() #
	var new_file_path = DBENGINE.table_save_path + DBENGINE.icon_folder + new_file_name #
	var curr_icon_path : Node = inputNode #
	if parent_node.is_file_in_folder(parent_node.table_save_path + parent_node.icon_folder, new_file_name): #Check if selected folder is Icon folder and has selected file
		set_sprite_atlas(new_file_path)
	else:
		var dir :DirAccess = DirAccess.open(path.get_base_dir()) #
		#dir.open(path.get_base_dir())
		dir.copy(path, new_file_path)
		if !parent_node.is_file_in_folder(parent_node.table_save_path + parent_node.icon_folder, new_file_name):
			print("File Not Added")
		else:
			print("File Added")
			#trigger the import process for it to load to texture rect
			var editor  = load("res://addons/fart_engine/EditorEngine.gd").new()
			editor.refresh_editor(self)
			await editor.Editor_Refresh_Complete

			set_sprite_atlas(new_file_path)
	get_data_and_create_sprite()


func set_sprite_atlas(atlas_path :String):
	inputNode.set_texture_normal(load(atlas_path))

func get_data_and_create_sprite():
	input_data = _get_input_value()
	await create_sprite_animation()
	set_preview_animation_size()
	set_preview_position()


func remove_dialog():
	var par = get_main_tab(self)
	var list_node :Node = par.get_node("Popups/ListInput")
	if list_node.get_child_count() == 0:
		par.get_node("Popups").visible = false
	par.get_node("Popups/FileSelect").visible = false
	fileSelectedNode.queue_free()


func is_below_min(value:String, minimum :int = 1) -> String:
	if value == "" or value.contains("-"):
		value = str(minimum)
	else:
		if value.to_int() < minimum:
			value = str(minimum)
	return value


func modify_value(value:String, increase:bool = true) -> String:
	var num_value = value.to_int()
	if increase:
		num_value += increment
	else:
		num_value -= increment
	return str(num_value)


func _get_input_value():
	var return_value :Dictionary
	atlas_dict = {}
	atlas_dict["frames"] = Vector2(atlas_v_input.get_text().to_int(),atlas_h_input.get_text().to_int())
	atlas_dict["texture_name"] = str(inputNode.texture_normal.get_path().get_file())
	return_value["atlas_dict"] = atlas_dict
	advanced_dict = {}
	advanced_dict["frame_range"] = Vector2(vframe.get_text().to_int(),hframe.get_text().to_int())
	advanced_dict["sprite_size"] = Vector2(height_sprite_size.get_text().to_float(),width_sprite_size.get_text().to_float())
	advanced_dict["speed"] = speed_input.get_text().to_int()
	advanced_dict["show_advanced"] = hide_advanced_options
	return_value["advanced_dict"] = advanced_dict
	return return_value


func _set_input_value(node_value):
	if typeof(node_value) == 4:
		node_value = str_to_var(node_value)
	input_data = node_value
	set_atlas_data()
	set_advanced_data()


func set_atlas_data():
	atlas_dict = {}
	atlas_h_input = $StandardControlsHBox/SpriteAtlasHBox/SpriteAtlasVBox/VBox1/VBox1/HInput
	atlas_v_input = $StandardControlsHBox/SpriteAtlasHBox/SpriteAtlasVBox/VBox1/VBox1/VInput
	get_input_node()
	atlas_dict = input_data["atlas_dict"]
	frame_vector = DBENGINE.convert_string_to_vector(str(atlas_dict["frames"]))
	atlas_v_input.set_text(str(frame_vector.x))
	atlas_h_input.set_text(str(frame_vector.y))
	var sprite_path = DBENGINE.table_save_path + DBENGINE.icon_folder + atlas_dict["texture_name"]
	inputNode.set_texture_normal(load(str(sprite_path))) 


func set_advanced_data():
	vframe = $AdvancedControlsVBox/AdvancedControlsHBox/FrameRangeVBox/VBox1/VFrame
	hframe =$AdvancedControlsVBox/AdvancedControlsHBox/FrameRangeVBox/VBox1/HFrame
	speed_input =$AdvancedControlsVBox/AdvancedControlsHBox/SpeedVBox/VBox1/SpeedInput
	height_sprite_size =$AdvancedControlsVBox/AdvancedControlsHBox/SpriteSizeVBox/VBox1/HeightSpriteSize
	width_sprite_size =$AdvancedControlsVBox/AdvancedControlsHBox/SpriteSizeVBox/VBox1/WidthSpriteSize
	advanced_dict = {}
	advanced_dict = input_data["advanced_dict"]
	frame_range = DBENGINE.convert_string_to_vector(str(advanced_dict["frame_range"]))
	speed = advanced_dict["speed"]
	sprite_size = DBENGINE.convert_string_to_vector(str(advanced_dict["sprite_size"]))
	vframe.set_text(str(frame_range.x))
	hframe.set_text(str(frame_range.y))
	speed_input.set_text(str(speed))
	height_sprite_size.set_text(str(sprite_size.x))
	width_sprite_size.set_text(str(sprite_size.y))
	hide_advanced_options = advanced_dict["show_advanced"]
	show_advanced_options()


func _on_hide_advanced_button_up():
	set_hide_advanced()
	show_advanced_options()

func show_advanced_options():
	var showhide_dict := {false : "Show", true : "Hide"}
	$AdvancedControlsVBox/AdvancedControlsHBox.visible = hide_advanced_options
	$AdvancedControlsVBox/Label/HBox1/Hide_Button.set_text(showhide_dict[hide_advanced_options])


func set_hide_advanced():
	hide_advanced_options = !hide_advanced_options
	advanced_dict["show_advanced"] = hide_advanced_options
#	_on_hide_advanced_button_up()


func _on_preview_window_resized():
	if show_field:
		get_data_and_create_sprite()
		set_preview_animation_size()


func _on_v_frame_button_up(increase):
	var input_value :String = modify_value(vframe.get_text(), increase)
	input_value = input_value_clamp(input_value)
	vframe.set_text(input_value)
	on_text_changed(true)
	get_data_and_create_sprite()


func _on_h_frame_button_up(increase):
	var input_value :String = modify_value(hframe.get_text(), increase)
	input_value = input_value_clamp(input_value)
	hframe.set_text(input_value)
	on_text_changed(true)
	get_data_and_create_sprite()


func _on_speed_button_up(increase):
	var input_value :String = modify_value(speed_input.get_text(), increase)
	input_value = input_value_clamp(input_value)
	speed_input.set_text(input_value)
	on_text_changed(true)
	get_data_and_create_sprite()


func HeightSpriteSizeDown(increase):
	var input_value :String = modify_value(height_sprite_size.get_text(), increase)
	input_value = input_value_clamp(input_value)
	height_sprite_size.set_text(input_value)
	on_text_changed(true)
	get_data_and_create_sprite()

func _on_width_sprite_size_button_up(increase):
	var input_value :String = modify_value(width_sprite_size.get_text(), increase)
	input_value = input_value_clamp(input_value)
	width_sprite_size.set_text(input_value)
	on_text_changed(true)
	get_data_and_create_sprite()


func _on_atlasVFrame_button_up(increase) -> void:
	var input_value :String = modify_value(atlas_v_input.get_text(), increase)
	input_value = input_value_clamp(input_value)
	atlas_v_input.set_text(input_value)
	atlas_dict["frames"].x = input_value.to_int()
	frame_vector.x = atlas_dict["frames"].x
	on_text_changed(true)
	frame_vector = atlas_dict["frames"]
	set_sprite_default_size()
	get_data_and_create_sprite()


func _on_atlasHFrame_button_up(increase) -> void:
	var input_value :String = modify_value(atlas_h_input.get_text(), increase)
	input_value = input_value_clamp(input_value)
	atlas_h_input.set_text(input_value)
	atlas_dict["frames"].y = input_value.to_int()
	frame_vector.y = atlas_dict["frames"].y
	on_text_changed(true)
	set_sprite_default_size()
	get_data_and_create_sprite()


func _on_VInput_text_changed(new_text: String) -> void:
	var input_value :String = is_below_min(new_text)
	input_value = input_value_clamp(new_text)
	atlas_v_input.set_text(input_value)
	atlas_v_input.set_caret_column(input_value.length())
	set_sprite_default_size()
	get_data_and_create_sprite()
	on_text_changed(true)


func _on_HInput_text_changed(new_text: String) -> void:
	var input_value :String = is_below_min(new_text)
	input_value = input_value_clamp(new_text)
	atlas_h_input.set_text(input_value)
	atlas_h_input.set_caret_column(input_value.length())
	set_sprite_default_size()
	get_data_and_create_sprite()
	on_text_changed(true)


func _on_h_frame_text_changed(new_text):
	var input_value :String = is_below_min(new_text)
	input_value = input_value_clamp(new_text)
	hframe.set_text(input_value)
	hframe.set_caret_column(input_value.length())
	get_data_and_create_sprite()
	on_text_changed(true)


func _on_v_frame_text_changed(new_text):
	var input_value :String = is_below_min(new_text)
	input_value = input_value_clamp(new_text)
	vframe.set_text(input_value)
	vframe.set_caret_column(input_value.length())
	get_data_and_create_sprite()
	on_text_changed(true)


func _on_speed_input_text_changed(new_text):
	var input_value :String = is_below_min(new_text)
	input_value = input_value_clamp(new_text)
	speed_input.set_text(input_value)
	speed_input.set_caret_column(input_value.length())
	get_data_and_create_sprite()
	on_text_changed(true)


func _on_height_sprite_size_text_changed(new_text):
	var input_value :String = is_below_min(new_text)
	input_value = input_value_clamp(new_text)
	height_sprite_size.set_text(input_value)
	height_sprite_size.set_caret_column(input_value.length())
	get_data_and_create_sprite()
	on_text_changed(true)


func _on_width_sprite_size_text_changed(new_text):
	var input_value :String = is_below_min(new_text)
	input_value = input_value_clamp(new_text)
	width_sprite_size.set_text(input_value)
	width_sprite_size.set_caret_column(input_value.length())
	get_data_and_create_sprite()
	on_text_changed(true)
