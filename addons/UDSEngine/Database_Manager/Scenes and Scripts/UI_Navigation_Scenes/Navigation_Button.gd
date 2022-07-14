@tool
extends Button

var root


# Called when the node enters the scene tree for the first time.
func _ready():
	var Par = get_parent()
	root = get_main_tab(Par)


func get_main_tab(par :Node = self):
	#Get main tab scene which should have the popup container and necessary script
#	print(par.name)
	var grps := par.get_groups()
	
	while grps.has(&"UDS_Root") == false:
		par = par.get_parent()
#		print(par.name)
		grps = par.get_groups()
#		print(grps)
#		print(grps.has(&"UDS_Root"))
	return par

func _on_Navigation_Button_button_up():
#	print(name, " Clicked")

	root.nav_button_click(name, self)
