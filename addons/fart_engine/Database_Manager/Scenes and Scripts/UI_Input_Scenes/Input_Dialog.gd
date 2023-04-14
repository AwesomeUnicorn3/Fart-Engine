@tool
extends InputEngine

@onready var CharacterName_Checkbox := $CharacterName_HBox/CharacterName_Checkbox
@onready var CharacterName_Dropdown := $CharacterName_HBox/CharacterName_Dropdown
@onready var CharacterName_Text := $CharacterName_HBox/CharacterName_Text
@onready var Dialog_Text := $Dialog_Text
@onready var IconSelection_Checkbox := $IconSelection_HBox/IconSelection_Checkbox
@onready var IconSelection_Sprite := $IconSelection_HBox/IconSelection_Sprite
@onready var IconSelection_Icon := $IconSelection_HBox/IconSelection_Icon
@onready var SceneSelection_Checkbox := $SceneSelection_HBox/SceneSelection_Checkbox
@onready var Scene_Selection_ScenePath := $SceneSelection_HBox/Scene_Selection_ScenePath

func _init() -> void:
	type = "16"
	await input_load_complete


func startup():
	CharacterName_Dropdown.populate_list()
	CharacterName_Dropdown.input_selection_changed.connect(character_name_changed)
	CharacterName_Checkbox.inputNode.toggled.connect(character_input_toggle)
	IconSelection_Checkbox.inputNode.toggled.connect(icon_selection_toggled)
	SceneSelection_Checkbox.inputNode.toggled.connect(scene_selection_toggled)



func character_name_changed():
	pass
	#CharacterName_Dropdown.selectedItemName)


func character_input_toggle(button_pressed:bool):
	CharacterName_Dropdown.visible = button_pressed
	CharacterName_Text.visible = !button_pressed
	if button_pressed:
		CharacterName_Dropdown.populate_list()
		CharacterName_Text.inputNode.set_text("N/A")

func icon_selection_toggled(button_pressed:bool):
	IconSelection_Sprite.visible = button_pressed
	IconSelection_Icon.visible = !button_pressed
	IconSelection_Sprite.show_field = button_pressed

func scene_selection_toggled(button_pressed:bool):
	Scene_Selection_ScenePath.visible = !button_pressed



func _get_input_value():
	var return_value :Dictionary

	return_value["character_name_checkbox"] = CharacterName_Checkbox._get_input_value()
	return_value["character_name_text"] = CharacterName_Text._get_input_value()
	return_value["character_name_dropdown"] = CharacterName_Dropdown.inputNode.get_text()
	return_value["dialog_text"] = Dialog_Text._get_input_value()
	return_value["icon_selection_checkbox"] = IconSelection_Checkbox._get_input_value()
	return_value["icon_selection_sprite"] = IconSelection_Sprite._get_input_value()
	return_value["scene_selection_checkbox"] = SceneSelection_Checkbox._get_input_value()
	return_value["scene_selection_scenepath"] = Scene_Selection_ScenePath.inputNode.get_text()
	return_value["icon_selection_icon"] = IconSelection_Icon.inputNode.texture_normal.get_path()
	return return_value


func _set_input_value(node_value):
#	var temp_var = node_value
	input_data = node_value
	if typeof(node_value) == TYPE_STRING:
		input_data = str_to_var(node_value)
#	if node_value == null:
#		node_value = temp_var

	var use_character_dropdown :bool = input_data["character_name_checkbox"]
	CharacterName_Checkbox.inputNode.button_pressed = use_character_dropdown
	CharacterName_Checkbox.inputNode.emit_signal("toggled",use_character_dropdown )
	CharacterName_Dropdown.inputNode.set_text(input_data["character_name_dropdown"])
	CharacterName_Text.inputNode.set_text(input_data["character_name_text"]["text"])
	Dialog_Text.inputNode.set_text(input_data["dialog_text"]["text"])
	var use_animation :bool = input_data["icon_selection_checkbox"]
	IconSelection_Checkbox.inputNode.button_pressed = use_animation
	IconSelection_Checkbox.inputNode.emit_signal("toggled",use_animation)
	var animation_data :Dictionary = input_data["icon_selection_sprite"]
	IconSelection_Sprite._set_input_value(animation_data)
	IconSelection_Icon.inputNode.set_texture_normal(load(input_data["icon_selection_icon"]))
	var use_default_scene :bool = input_data["scene_selection_checkbox"]
	SceneSelection_Checkbox.inputNode.button_pressed = use_default_scene
	SceneSelection_Checkbox.inputNode.emit_signal("toggled",use_default_scene )
	Scene_Selection_ScenePath._set_input_value(input_data["scene_selection_scenepath"])
