@tool
extends CommandForm

@onready var group_checkbox := $Control/VBoxContainer/SFXGroupCheckbox
@onready var group_dropdown := $Control/VBoxContainer/HBoxContainer3/SFXGroupDropdown
@onready var single_audio_input := $Control/VBoxContainer/HBoxContainer3/SFXSingleAudioInput


@onready var repeat_sound_checkbox := $Control/VBoxContainer/HBoxContainer2/RepeatSoundCheckbox
@onready var repeat_sound_amount := $Control/VBoxContainer/HBoxContainer2/RepeatSoundAmount
@onready var wait_checkbox := $Control/VBoxContainer/WaitCheckbox


var function_name :String = "sfx" #must be name of valid function
var event_name :String = ""
var current_function_data :Dictionary
var audio_data :Dictionary
var repeat_audio : bool
var repeat_amount :int = 0
var wait :bool
var is_group :bool

func _ready():

	group_dropdown.populate_list()
	
	group_checkbox.inputNode.toggled.connect(set_group_checkbox)
	group_checkbox.inputNode.emit_signal("toggled", true)
	
	repeat_sound_checkbox.inputNode.toggled.connect(set_repeat_sound_checkbox)
	repeat_sound_checkbox.inputNode.emit_signal("toggled", false)
	
	wait_checkbox.inputNode.toggled.connect(set_wait_checkbox)
	wait_checkbox.inputNode.emit_signal("toggled", false)
	
	
func set_wait_checkbox(button_pressed):
	wait = button_pressed


func set_group_checkbox(button_pressed):
	single_audio_input.visible = !button_pressed
	group_dropdown.visible = button_pressed
	is_group = button_pressed

func set_repeat_sound_checkbox(button_pressed):
	repeat_sound_amount.visible = button_pressed
	repeat_audio = button_pressed
	repeat_amount = repeat_sound_amount._get_input_value()


func set_input_values(old_function_dict :Dictionary):
	edit_state = true
	current_function_data = old_function_dict[function_name][0]

	audio_data = current_function_data["audio_data"]
	single_audio_input._set_input_value(audio_data["Single"])
	group_dropdown.inputNode.set_text(audio_data["Group Name"])
	
	is_group = current_function_data["is_group"]
	group_checkbox._set_input_value(is_group)
	
	repeat_audio = current_function_data["repeat_audio"]
	repeat_sound_checkbox._set_input_value(repeat_audio)
	
	repeat_amount = current_function_data["repeat_amount"]
	repeat_sound_amount._set_input_value(repeat_amount)
	
	wait = current_function_data["wait"]
	wait_checkbox._set_input_value(wait)

func get_input_values():
	event_name = commandListForm.CommandInputForm.source_node.parent_node.event_name

	audio_data["Group Name"] = group_dropdown.inputNode.get_text()
	audio_data["Single"] = single_audio_input._get_input_value()
	
	current_function_data["audio_data"] = audio_data
	current_function_data["is_group"] = is_group
	current_function_data["repeat_audio"] = repeat_audio
	current_function_data["repeat_amount"] = repeat_sound_amount._get_input_value()
	current_function_data["wait"] = wait

	var return_function_dict = {function_name : [current_function_data, event_name]}
	return return_function_dict
	
func _on_accept_button_up():
	commandListForm.CommandInputForm.function_dict = get_input_values()
	get_parent()._on_close_button_up()
