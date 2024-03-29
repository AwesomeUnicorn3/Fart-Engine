@tool
extends PopupManager


@onready var tableName = $VBox1/Input_Text.inputNode
@onready var isList = $VBox1/List_Checkbox.inputNode
@onready var keyName = $VBox1/Key_Input.inputNode
@onready var fieldName = $VBox1/Field_Input.inputNode
@onready var refName = $VBox1/Table_RefName.inputNode
@onready var in_saveFile = $VBox1/Incl_inSavefile.inputNode
@onready var createTab = $VBox1/DB_Tab.inputNode


func _ready() -> void:
#	var accept = $PanelContainer/VBox1/HBox2/Accept
#	var cancel = $PanelContainer/VBox1/HBox2/Cancel
#	accept.connect("button_up", get_node("../.."), "_on_new_table_Accept_button_up")
#	cancel.connect("button_up", get_node("../.."), "_on_newtable_Cancel_button_up")
	reset_values()


func _on_popup_newTable_visibility_changed():
	if visible:
		if is_instance_valid(tableName):
			tableName.grab_focus()


func _on_Input_toggled(button_pressed: bool) -> void:
#	$PanelContainer/VBox1/Key_Input.visible = !button_pressed
	$VBox1/Field_Input.visible = !button_pressed

func reset_values():
	tableName.set_text("")
	isList.set_pressed(false)
	keyName.set_text("")
	fieldName.set_text("")
	refName.set_text("")
	in_saveFile.set_pressed(false)
	createTab.set_pressed(true)



func _on_accept_btn_pressed(btn_name):
	pass # Replace with function body.


func _on_cancel_btn_pressed(btn_name):
	pass # Replace with function body.
