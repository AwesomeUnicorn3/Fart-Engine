@tool
extends Button

@onready var keyselect : PackedScene = load("res://addons/fart_engine/Database_Manager/Scenes and Scripts/UI_Input_Scenes/KeySelect.tscn")
@onready var parent = get_parent()

var action_string_button
var action_control
var key_id 


func _ready():
	parent = get_parent().get_main_tab(get_parent())
	key_id = get_parent().get_name()


func _on_button_up():
	parent.popup_main.visible = true
#	var i = keyselect.instantiate()
#	i.key_number = key_id
#	#set the action key text to keyselect label 2
#	var action_key = $Input.get_text()
#	i.get_node("DropPanelContainer/MainNodes/Label2").set_text((parent.Item_Name))
#	i.label_name = get_parent().labelNode.text
#	i.key_select_action_string = action_control
#	#Add the node to the 'parent'node and disable input for all button on the options menu
#	parent.add_child(i)
#	i.get_node("DropPanelContainer/MainNodes/Buttons/Accept").disabled = true
