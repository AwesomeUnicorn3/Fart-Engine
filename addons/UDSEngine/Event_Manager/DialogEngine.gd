extends Node
class_name DialogEngine

signal start_dialog
signal dialog_ended
signal next_message_pressed

#@onready var UI :Control = AU3ENGINE.get_ui()
var dialog_scene
var current_dialog_dictionary :Dictionary
var selected_group_dictionary :Dictionary
var dialog_dictionary :Dictionary
var character_name_checkbox :bool
var character_name_text :String
var character_name_dropdown :String
var dialog_text :String
var icon_selection_checkbox :bool
var icon_selection_icon :Texture2D
var icon_selection_sprite :Dictionary
var scene_selection_checkbox :bool
var scene_selection_scenepath :String

var waiting_for_user_input :bool = false
var dialog_window :Control 



func _ready():
	start_dialog.connect(dialog_begin)
	dialog_window = AU3ENGINE.get_ui().get_node("Dialog")

	

func next_message():
	if waiting_for_user_input:
		emit_signal("next_message_pressed")



func load_dialog_scene():
	var scene
	var scene_path :String = ""
	if scene_selection_checkbox:
		scene_path = await AU3ENGINE.get_default_dialog_scene_path()
	else:
		scene_path = scene_selection_scenepath
	
	if scene_path != "":
		scene = load(scene_path).instantiate()
	#UI.visible = true
	dialog_window = AU3ENGINE.get_UI_window().get_node("Dialog")
	dialog_window.visible = true
	dialog_window.add_child(scene)
	scene.set_name("Dialog")
	return scene


func get_variables():
	character_name_checkbox = current_dialog_dictionary["character_name_checkbox"]
	character_name_text = current_dialog_dictionary["character_name_text"]["text"]
	character_name_dropdown = current_dialog_dictionary["character_name_dropdown"]
	dialog_text = current_dialog_dictionary["dialog_text"]["text"]
	icon_selection_checkbox = current_dialog_dictionary["icon_selection_checkbox"]
	icon_selection_icon = load(current_dialog_dictionary["icon_selection_icon"])
	icon_selection_sprite = current_dialog_dictionary["icon_selection_sprite"]
	scene_selection_checkbox = current_dialog_dictionary["scene_selection_checkbox"]
	scene_selection_scenepath = current_dialog_dictionary["scene_selection_scenepath"]


func set_variables():
	set_dialog_text()
	set_speaker_name()
	set_icon()


func dialog_begin(dialog_dict):
	#UI = AU3ENGINE.get_gui()
	set_selected_group_dict_data(dialog_dict)
	await iterate_through_dialog()
	waiting_for_user_input = false
	dialog_end()


func iterate_through_dialog():
	for dialog_index in selected_group_dictionary:
		if typeof(selected_group_dictionary[dialog_index]) == TYPE_STRING:
			current_dialog_dictionary = str_to_var(selected_group_dictionary[dialog_index])
		else:
			current_dialog_dictionary = selected_group_dictionary[dialog_index]
		
		get_variables()
		dialog_scene = await load_dialog_scene()
		dialog_scene.name = "dialog " + dialog_index
		set_variables()
		waiting_for_user_input = true
		await next_message_pressed
		dialog_scene.queue_free()


func set_selected_group_dict_data(dialog_dict):
	selected_group_dictionary = {}
	var group_name :String = ""
	var static_dialog_group_dictionary :Dictionary = AU3ENGINE.Static_Game_Dict["Dialog Groups"]
	var static_dialog_group_data_dictionary :Dictionary = AU3ENGINE.import_data("Dialog Groups", true)
	if dialog_dict.has("Group Name"):
		group_name = dialog_dict["Group Name"]
		#Get Group dict
		var group_index = AU3ENGINE.get_id_from_display_name(static_dialog_group_dictionary, group_name)
		var index = 1
		for field in static_dialog_group_data_dictionary["Column"]:
			var field_name = static_dialog_group_data_dictionary["Column"][field]["FieldName"]
			if field_name != "Display Name":
				selected_group_dictionary[str(index)] = static_dialog_group_dictionary[group_index][field_name]
				index += 1
	else:
		selected_group_dictionary["1"] = dialog_dict


func set_dialog_text():
	var text_node = dialog_scene.find_child("DialogText")
	text_node.set_text(dialog_text)

func set_speaker_name():
	var speaker_node = dialog_scene.find_child("SpeakerNode")
	var speaker_name = dialog_scene.find_child("SpeakerName")
	if !character_name_checkbox:
		if character_name_text == "":
			speaker_node.visible = false
		speaker_name.set_text(character_name_text)
	else:
		speaker_name.set_text(character_name_dropdown)

func set_icon():
	var speaker_icon :TextureRect = dialog_scene.find_child("SpeakerIcon")
	var animation_buffer :Label = dialog_scene.find_child("AnimationBuffer")
	var dialog_text_background :TextureRect = dialog_scene.find_child("DialogTextBackground")

	var empty_space_container :VBoxContainer = dialog_scene.find_child("EmptySpaceContainer")
	if !icon_selection_checkbox:
		speaker_icon.set_texture(icon_selection_icon)

	else:
		var animated_sprite :AnimatedSprite2D = dialog_scene.find_child("SpriteAnimationIcon")
		var animation_array :Array = AU3ENGINE.add_animation_to_animatedSprite("Default Animation", icon_selection_sprite, false, animated_sprite)
		var anim_sprite_size :Vector2 = AU3ENGINE.convert_string_to_vector(str(icon_selection_sprite["advanced_dict"]["sprite_size"]))
		var left_buffer_size_x :int = dialog_scene.find_child("LeftBuffer").size.x
		animation_buffer.visible = true
		animation_buffer.custom_minimum_size.x = anim_sprite_size.x
		AU3ENGINE.set_sprite_scale(animated_sprite,"Default Animation", icon_selection_sprite)
		speaker_icon.visible = false
		animated_sprite.centered = true
		animated_sprite.play("Default Animation")
		await dialog_scene.get_tree().process_frame
		var animated_sprite_position_x :int = dialog_text_background.position.x + (anim_sprite_size.x/2) + left_buffer_size_x
		var animated_sprite_position_y :int = dialog_text_background.global_position.y - (anim_sprite_size.x/2)
		animated_sprite.set_position(Vector2(animated_sprite_position_x, animated_sprite_position_y))


func dialog_end():
	dialog_window.visible = false
	emit_signal("dialog_ended")
