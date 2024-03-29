@tool
extends DatabaseManager

var table = "10017"
var relatedNodeName :String

@onready var Input_field = $Input_Text


func item_selected(value):
	pass


func swap_input_node(relatedNode, datatypeNode, itemType, tableName):
	var parent_node = get_node("../../../..")
	relatedNodeName = relatedNode.name
	relatedNode.name = "Clear"
	var pos :int = relatedNode.get_index()
	remove_child(relatedNode)
	call_deferred("removeNode",relatedNode)
	
	if itemType == "5":
		var tblSelect_tscn = all_popups_dict["TableSelect"]
		var tblSelect = tblSelect_tscn.instantiate()
		tblSelect.par_node = self
		parent_node.add_child(tblSelect)
		await tblSelect.closed
		tableName = table
		var key = get_children()[1].name
		var nodeNumber = relatedNodeName.rsplit(" ")[1]

		parent_node.mainDictionary[key]["TableName " + nodeNumber] = tableName

	#var dataType_Input = await add_input_node(1, 1, relatedNodeName, {}, self, null, "Default", itemType, tableName)
#	datatypeNode.relatedInputNode = dataType_Input
#	move_child(dataType_Input,pos)


func removeNode(relatedNode):
	relatedNode.queue_free()


func _on_DeleteButton_button_up() -> void:
	var parent_node = get_node("../../../..")
	var keyValue = Input_field.inputNode.text
	parent_node._delete_selected_list_item(keyValue)
