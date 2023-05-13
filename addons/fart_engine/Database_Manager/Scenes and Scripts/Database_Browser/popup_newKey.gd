@tool
extends Control

@onready var keyNode = $PanelContainer/VBoxContainer/Input_Text


func _ready() -> void:
	var accept = $PanelContainer/VBoxContainer/HBoxContainer/Accept 
	var cancel = $PanelContainer/VBoxContainer/HBoxContainer/Cancel
	accept.button_up.connect(get_node("../..")._on_new_key_Accept_button_up)
	cancel.button_up.connect(get_node("../..")._on_new_key_Cancel_button_up)

func reset_values():
	keyNode._set_input_value({"text": ""})

func get_new_key_value():
	var newValue :String = keyNode.get_text()
	return newValue
