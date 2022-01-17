extends Control
tool
export var label_text = ""
var labelNode
var inputNode
var itemName = ""
var default
var type = ""


func _ready():
	itemName = self.name
	for i in self.get_children():
		if i.name == "Label":
			labelNode = $Label
		elif i.name == "Input":
			inputNode = $Input

	if label_text == "":
		labelNode.set_text(itemName)
	else:
		labelNode.set_text(label_text)
