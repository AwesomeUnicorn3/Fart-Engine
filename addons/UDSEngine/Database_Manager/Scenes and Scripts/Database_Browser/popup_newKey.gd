@tool
extends Control

#var tableName = $PanelContainer/VBox1/Input_Text.inputNode
@onready var keyNode = $PanelContainer/VBoxContainer/Input_Text


func _ready() -> void:
	var accept = $PanelContainer/VBoxContainer/HBoxContainer/Accept 
	var cancel = $PanelContainer/VBoxContainer/HBoxContainer/Cancel
	accept.button_up.connect(get_node("../..")._on_new_key_Accept_button_up)
	cancel.button_up.connect(get_node("../..")._on_new_key_Cancel_button_up)

func reset_values():
	#tableName.set_text("")
	keyNode._set_input_value({"text": ""})

func get_new_key_value():
	var newValue_dict :Dictionary = keyNode._get_input_value()
	var newValue :String = newValue_dict["text"]
	return newValue


#func _on_visibility_changed():
#	if visible:
#		if is_instance_valid(tableName):
#			tableName.grab_focus()
