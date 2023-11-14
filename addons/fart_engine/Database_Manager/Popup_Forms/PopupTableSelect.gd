@tool
extends PopupManager

signal closed
var selectedTable = ""
#var par_node
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	_on_popup_newValue_visibility_changed()
#	$PanelContainer/VBox1/HBox1/Table_Selection/Input.select(0)

#	selectedTable = $PanelContainer/VBox1/HBox1/Table_Selection.selection_table_name

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_popup_newValue_visibility_changed():
	if visible:
#		$PanelContainer/VBox1/HBox1/VBox2/ItemType_Selection.populate_list()
		$VBox1/HBox1/Table_Selection.populate_list()
		_on_Input_item_selected(1)




func _on_Input_item_selected(index: int) -> void:
	selectedTable = $VBox1/HBox1/Table_Selection._on_Input_item_selected(str(index))
#	parent_node.table = selectedTable


func _on_accept_button_up():
	_on_cancel_button_up()


func _on_cancel_button_up():
		emit_signal("closed")


func _on_accept_btn_pressed(btn_name):
	pass # Replace with function body.


func _on_cancel_btn_pressed(btn_name):
	pass # Replace with function body.
