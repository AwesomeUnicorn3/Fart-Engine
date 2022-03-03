extends Control
tool
signal closed
var selectedTable = ""
var par_node
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
		$PanelContainer/VBox1/HBox1/Table_Selection.populate_list()
		_on_Input_item_selected(1)




func _on_Input_item_selected(index: int) -> void:
	selectedTable = $PanelContainer/VBox1/HBox1/Table_Selection._on_Input_item_selected(index)
#	print(selectedTable)
	par_node.table = selectedTable


func _on_Cancel_button_up() -> void:
	emit_signal("closed")
	self.queue_free()


func _on_Accept_button_up() -> void:
	_on_Cancel_button_up()
