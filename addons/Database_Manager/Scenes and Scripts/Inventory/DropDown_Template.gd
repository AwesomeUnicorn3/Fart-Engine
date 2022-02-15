extends Control
tool
var original_parent
var par
var selection

func _ready():
	$Popups/popup_item_type.visible = true


func _on_Accept_button_up():
	#need code to update item type input
	original_parent.selected_item_index = selection
	original_parent.set_label()
	queue_free() #close popup window


func _on_Cancel_button_up():

	queue_free()


func _on_Itemlist_item_selected(index):
	selection = index
