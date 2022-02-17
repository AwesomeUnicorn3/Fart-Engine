extends Button
tool
onready var keyselect : PackedScene = load("res://addons/Database_Manager/Scenes and Scripts/UI_Input_Scenes/KeySelect.tscn")
onready var parent = get_parent()

var action_string_button
var action_control
var key_id 


func _ready():
	parent = get_parent().get_main_tab(get_parent())
	key_id = get_parent().get_name()



func _on_button_up():
	parent.popup_main.visible = true
	var i = keyselect.instance()
	i.key_number = key_id
#	i.connect("accept", self, "_on_accept")
#	i.connect("exit", self, "_on_cancel")
	#set the action key text to keyselect label 2

	var action_key = $Input.get_text()
#	parent.action_string = action_string_button
	i.get_node("DropPanelContainer/MainNodes/Label2").set_text((parent.Item_Name))
	i.label_name = get_parent().labelNode.text
	i.key_select_action_string = action_control
	#Add the node to the 'parent'node and disable input for all button on the options menu
	parent.add_child(i)
	i.get_node("DropPanelContainer/MainNodes/Buttons/Accept").disabled = true
#	on_text_changed(true)
#	yield(i, "exit")


#func _on_accept(key):
#	$Input_Label.set_text(key)
#	_on_disable_button(false)
#
#
#func _on_cancel():
#	_on_disable_button(false)
#
#
#func _on_disable_button(value: bool):
#	#disable/enable using 'value' all action key buttons on the options menu
#	var gui = parent.get_node("../../..")
#	if value == true:
#		gui.set_pause_mode(PAUSE_MODE_STOP)
#	else:
#		gui.set_pause_mode(PAUSE_MODE_PROCESS)


