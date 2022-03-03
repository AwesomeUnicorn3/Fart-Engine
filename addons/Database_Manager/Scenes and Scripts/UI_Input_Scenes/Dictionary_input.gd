extends DatabaseEngine
tool

var table = "DataTypes"
var relatedNodeName

onready var Input_field = $Input_Text


func item_selected(value):
	pass


func swap_input_node(relatedNode, datatypeNode, itemType, tableName):
	var parent_node = get_node("../../../..")
	relatedNodeName = relatedNode.name
	relatedNode.name = "Clear"
	var pos = relatedNode.get_position_in_parent()
	remove_child(relatedNode)
	call_deferred("removeNode",relatedNode)
	
	if itemType == "TYPE_DROPDOWN":
		var tblSelect_tscn = load("res://addons/Database_Manager/Scenes and Scripts/UI_Input_Scenes/popup_TableSelect.tscn")
		var tblSelect = tblSelect_tscn.instance()
		tblSelect.par_node = self
		parent_node.add_child(tblSelect)
		yield(tblSelect, "closed")
		
		tableName = table
		var key = get_children()[0].name
		var nodeNumber = relatedNodeName.rsplit(" ")[1]
		parent_node.mainDictionary[key]["TableName " + nodeNumber] = tableName

	var dataType_Input = add_input_node(1, 1, relatedNodeName, {}, self, null, "Default", itemType, tableName)
	datatypeNode.relatedInputNode = dataType_Input
	move_child(dataType_Input,pos)


func removeNode(relatedNode):
	relatedNode.queue_free()


func _on_DeleteButton_button_up() -> void:
	var parent_node = get_node("../../../..")
	var keyValue = Input_field.inputNode.text
	parent_node._delete_selected_list_item(keyValue)
#	print(keyValue)
