extends VBoxContainer
tool


export var main_tab_group = ""
export var selection_table_name = ""

onready var dropdown = preload("res://addons/Database_Manager/Scenes and Scripts/Inventory/DropDown_Template.tscn")

var selection_table = {}
var main_scene : Node
var selected_item_index


func _on_Button_button_up():
	main_scene = get_main_tab(get_parent())
	selection_table = main_scene.import_data(main_scene.save_path + selection_table_name +".json" )

	
	#load popup from main page and populate itemlist with table values
	var dropNew = dropdown.instance()
	dropNew.original_parent = self
	for n in selection_table:
		var t = selection_table[n]["TypeID"]
		dropNew.get_node("Popups/popup_item_type/PanelContainer/VBoxContainer/Itemlist").add_item (t,null,true )
	main_scene.add_child(dropNew)


func set_label():
	var selected_item_name = selection_table[str(selected_item_index + 1)]["TypeID"]
	print(selected_item_name)
	$Hbox1/ColorRect/ItemTypeText.set_text(selected_item_name)

func get_main_tab(par):
	#Get main tab scene which should have the popup container and necessary script
	#Might me a more efficient way to do this that does not require the popup to be already added to scene.  That would give this scene more flexibility
	while !par.get_groups().has(main_tab_group):
		par = par.get_parent()
	return par

