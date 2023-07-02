extends Node
class_name DialogEngine

signal start_dialog
signal dialog_ended
signal next_message_pressed
signal option_button_pressed

#@onready var UI :Control = FARTENGINE.get_ui()
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
var use_option_buttons:bool
var event_option_buttons_dict:Dictionary

var waiting_for_user_input :bool = false
var dialog_window :Control 
var event_node_name:String


func _ready():
	start_dialog.connect(dialog_begin)
	dialog_window = FARTENGINE.get_ui().get_node("Dialog")

	

func next_message():
	if waiting_for_user_input:
		emit_signal("next_message_pressed")



func load_dialog_scene():
	var scene
	var scene_path :String = ""
	if scene_selection_checkbox:
		scene_path = await FARTENGINE.get_default_dialog_scene_path()
	else:
		scene_path = scene_selection_scenepath
	
	if scene_path != "":
		scene = load(scene_path).instantiate()
	#UI.visible = true
	dialog_window = FARTENGINE.get_UI_window().get_node("Dialog")
	dialog_window.visible = true
	dialog_window.add_child(scene)
	scene.set_name("Dialog")
	return scene


func get_variables():
	character_name_checkbox = current_dialog_dictionary["character_name_checkbox"]
	character_name_text = FARTENGINE.get_text(current_dialog_dictionary["character_name_text"])
	character_name_dropdown = current_dialog_dictionary["character_name_dropdown"]
	dialog_text = FARTENGINE.get_text(current_dialog_dictionary["dialog_text"])
	icon_selection_checkbox = current_dialog_dictionary["icon_selection_checkbox"]
	icon_selection_icon = load(current_dialog_dictionary["icon_selection_icon"])
	icon_selection_sprite = current_dialog_dictionary["icon_selection_sprite"]
	scene_selection_checkbox = current_dialog_dictionary["scene_selection_checkbox"]
	scene_selection_scenepath = current_dialog_dictionary["scene_selection_scenepath"]
	
	var event_options_dict: Dictionary = current_dialog_dictionary	["event_options_buttons"]
	use_option_buttons = event_options_dict["show_event_options_buttons"]
	event_option_buttons_dict = event_options_dict["event_buttons"]["input_dict"]


func set_variables():
	set_dialog_text()
	set_speaker_name()
	set_icon()


func dialog_begin(dialog_dict, event_ID:String):
	#UI = FARTENGINE.get_gui()
	event_node_name = event_ID
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


		if use_option_buttons:
			display_options_buttons()

			await option_button_pressed

		await next_message_pressed
		dialog_scene.queue_free()


func display_options_buttons():

	for btn_key in event_option_buttons_dict:
		var btn_text: String = FARTENGINE.get_text(event_option_buttons_dict[btn_key]["Button_Text"])
		var dialog_var: String = event_option_buttons_dict[btn_key]["Dialog_Option"]
		
		var newbtn: TextureButton = load(FARTENGINE.get_field_value("UI Scenes", "10", "Path")).instantiate()
		var btn_color: Color = FARTENGINE.get_field_value("UI Scenes", "10", "Background Color")
		newbtn.reset_self_modulate()
		dialog_scene.get_node("VBoxContainer/TopVBox/VBoxContainer/OptionScroll/OptionButtonParent").add_child(newbtn)
		newbtn.set_input_values(btn_text, dialog_var, "")
		newbtn.get_node("Button").button_up.connect(_on_option_button_pressed.bind(newbtn))
#
#		print(FARTENGINE.get_text(event_option_buttons_dict[btn_key]["Button_Text"]))


func _on_option_button_pressed(optbtn: TextureButton):
#	print(optbtn.options_variable)
	
	FARTENGINE.EVENTS.change_event_options_variable(optbtn.options_variable, "", event_node_name, null)
	emit_signal("option_button_pressed")
	emit_signal("next_message_pressed")



func set_selected_group_dict_data(dialog_dict):
	selected_group_dictionary = {}
	var group_name :String = ""
	var static_dialog_group_dictionary :Dictionary = FARTENGINE.Static_Game_Dict["Dialog Groups"]
	var static_dialog_group_data_dictionary :Dictionary = FARTENGINE.import_data("Dialog Groups", true)
	if dialog_dict.has("Group Name"):
		group_name = dialog_dict["Group Name"]
		#Get Group dict
		var group_index = FARTENGINE.get_id_from_display_name(static_dialog_group_dictionary, group_name)
		var index = 1
		for field in static_dialog_group_data_dictionary["Column"]:
			var field_name = static_dialog_group_data_dictionary["Column"][field]["FieldName"]
			if field_name != "Display Name":
				selected_group_dictionary[str(index)] = static_dialog_group_dictionary[group_index][field_name]
				index += 1
	else:
		selected_group_dictionary["1"] = dialog_dict


func set_dialog_text():
	var text_node = dialog_scene.find_child("DialogText")#CAN I SET THIS IN THE 
	#EDITOR?
	text_node.set_values(dialog_text)#(dialog_text)


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
		var animation_array :Array = FARTENGINE.add_animation_to_animatedSprite("Default Animation", icon_selection_sprite, false, animated_sprite)
		var anim_sprite_size :Vector2 = FARTENGINE.convert_string_to_vector(str(icon_selection_sprite["advanced_dict"]["sprite_size"]))
		var left_buffer_size_x :int = dialog_scene.find_child("LeftBuffer").size.x
		animation_buffer.visible = true
		animation_buffer.custom_minimum_size.x = anim_sprite_size.x
		FARTENGINE.set_sprite_scale(animated_sprite,"Default Animation", icon_selection_sprite)
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
