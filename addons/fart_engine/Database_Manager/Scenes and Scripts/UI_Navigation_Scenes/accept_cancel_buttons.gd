@tool
extends EditorManager

@export var AcceptText:String = "Accept"
@export var CancelText:String = "Cancel"


func _ready():
	$Accept.custom_text = AcceptText
	$Cancel.custom_text = CancelText

#func _on_accept_button_up():
#	print(AcceptText)
#
#
#func _on_cancel_button_up():
#	print(CancelText)
