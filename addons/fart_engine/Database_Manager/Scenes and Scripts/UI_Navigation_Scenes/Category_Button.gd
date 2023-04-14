@tool
extends Button

var root :Node = self


func _ready():
	var Par = get_parent()


func get_main_tab(par :Node = self):
	var grps := par.get_groups()
	while grps.has(&"UDS_Root") == false:
		par = par.get_parent()
		grps = par.get_groups()
	return par


func _on_Navigation_Button_button_up():
	root.category_button_click(name, self)
