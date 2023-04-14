@tool
extends Button

#var root
#

## Called when the node enters the scene tree for the first time.
#func _ready():
#	root = get_main_tab(get_parent())
#
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
##func _process(delta):
##	pass
#func get_main_tab(par):
#	#Get main tab scene which should have the popup container and necessary script
#	while !par.get_groups().has("UDS_Root"):
#		par = par.get_parent()
#	return par

func _on_Navigation_Button_button_up():
	get_node("../../../../..")._on_key_button_up(text)
