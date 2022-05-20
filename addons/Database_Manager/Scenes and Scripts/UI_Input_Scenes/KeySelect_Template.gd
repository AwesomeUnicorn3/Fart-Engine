extends InputEngine
tool

onready var keyselect : PackedScene = load("res://addons/Database_Manager/Scenes and Scripts/UI_Input_Scenes/KeySelect.tscn")
var parent
var action_string_button
var action_control
var key_id 


func _init() -> void:
	type = "11"

#func _ready():
#
#	default = ""


func startup():
	parent = get_parent()
	key_id = parent.name


func _on_button_up():
	parent_node.popup_main.visible = true
	var i = keyselect.instance()
	i.key_number = key_id
	i.parent_node = self
#	i.connect("accept", self, "_on_accept")
#	i.connect("exit", self, "_on_cancel")
	#set the action key text to keyselect label 2

	var action_key = inputNode.get_text()
#	parent.action_string = action_string_button
	i.get_node("DropPanelContainer/MainNodes/Label2").set_text((parent_node.Item_Name))
	i.label_name = labelNode.text
	i.key_select_action_string = action_control
	#Add the node to the 'parent'node and disable input for all button on the options menu
	parent_node.add_child(i)
	i.get_node("DropPanelContainer/MainNodes/Buttons/Accept").disabled = true
	on_text_changed(true)
