@tool
extends HBoxContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
#	var connect_signal = Signal
#	$VBox2/ItemType_Selection/Input.connect("item_selected", self, "item_selected")
	$VBox2/ItemType_Selection/Input.item_selected.connect(item_selected)

func item_selected(index):
	$Table_Selection.visible = false
#	print($VBox2/ItemType_Selection.get_selected_value(index))
	match $VBox2/ItemType_Selection.get_selected_value(index):
		"Dropdown List":
			$Table_Selection.visible = true
#			print($VBox2/ItemType_Selection.get_selected_value(index))
