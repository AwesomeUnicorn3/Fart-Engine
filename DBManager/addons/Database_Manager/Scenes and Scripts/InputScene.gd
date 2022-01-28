extends Control
tool
export var label_text = ""
var labelNode
var inputNode
var itemName = ""
var default
var type = ""

func get_all_nodes(node):
	var node_array = []
	var input = false
	var label = false


	for i in get_children():
		if i.name == "Label":
			label = true
			node_array.append(i)
		elif i.name == "Input":
			node_array.append(i)
			input = true
	
		if i.get_child_count() > 0:
			for j in i.get_children():
				if j.name == "Label":
					label = true
					node_array.append(j)
				elif j.name == "Input":
					node_array.append(j)
					input = true
				if j.get_child_count() > 0:
					for k in j.get_children():
						if k.name == "Label":
							label = true
							node_array.append(k)
						elif k.name == "Input":
							node_array.append(k)
							input = true

	return node_array


func _ready():
	itemName = self.name
	var node_array = get_all_nodes(self)
	for i in node_array:
		if i.name == "Label":
			labelNode = i
#			print(itemName, " ", i.name)
		elif i.name == "Input":
			inputNode = i
#			print(itemName, " ", i.name)
#		else:
#			print(itemName, " ", i.name)

	if label_text == "":
		labelNode.set_text(itemName)
	else:
		labelNode.set_text(label_text)
