@tool
extends Button

var root :Node = self


func _ready():
	#print("Navigation Button Ready Begin")
	var Par = get_parent()
	root = get_main_tab(Par)
	#print(root.name)
	#print("Navigation Button Ready End")
	
func get_main_tab(par :Node = self):
	#Get main tab scene which should have the popup container and necessary script
	#THE METHOD IS NOT ABLE TO FIND &"UDS_Root" WHICH IS THE GROUP THAT UDS_Main BELONGS TO
	var grps := par.get_groups()
	while grps.has(&"UDS_Root") == false:
		par = par.get_parent()
		grps = par.get_groups()
	return par

func _on_Navigation_Button_button_up():
	root.nav_button_click(name, self)
