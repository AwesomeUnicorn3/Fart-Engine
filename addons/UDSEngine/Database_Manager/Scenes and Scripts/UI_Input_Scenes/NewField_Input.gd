@tool
extends Control

func _ready():

	$ItemType_Selection/Input.item_selected.connect(item_selected)

func item_selected(index):
	$Table_Selection.visible = false
	match $ItemType_Selection.get_selected_value(index):
		"Dropdown List":
			$Table_Selection.visible = true
