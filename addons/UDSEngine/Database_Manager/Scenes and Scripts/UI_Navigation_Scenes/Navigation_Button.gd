@tool
extends Button

var root 


func _ready():
	var Par = get_parent()
	root = get_main_tab(Par)


func get_main_tab(par :Node = self):
	var grps := par.get_groups()
	while grps.has(&"UDS_Root") == false:
		par = par.get_parent()
		grps = par.get_groups()
	return par


func _on_Navigation_Button_button_up():
	root.navigation_button_click(name, self)
