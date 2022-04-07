extends Control
class_name InputEngine
tool

export var label_text = ""
export var is_label_button = true

var labelNode
var inputNode
var itemName = ""
var default = null
var type = ""
var table_name = ""
var table_ref = ""
var parent_node
var input_data = ""


func _ready():
	var me = self
	itemName = self.name
	var node_array = get_all_nodes(self)
	for i in node_array:
		if i.name == "Label":
			labelNode = i
		elif i.name == "Input":
			inputNode = i

	if label_text == "":
		labelNode.set_text(itemName)
	else:
		labelNode.set_text(label_text)
	connect_signals()
	if me.has_method("startup"):
		me.startup()
	parent_node = get_main_tab(get_parent())
	set_default_value()

func get_all_nodes(node):
	var node_array = []
	var input = false
	var label = false

#THIS CAN BE IMPROVED WITH 
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

func set_default_value():
	default = parent_node.get_default_value(type)
#	if default == null:
#		print(type)



func label_pressed():
	if is_label_button:
		var keyName = get_main_tab(self).Item_Name
		var fieldName = labelNode.text
		if fieldName == "Key": 
			OS.set_clipboard("udsmain.Static_Game_Dict['" + table_ref + "']['" + keyName + "']")
		else:
			OS.set_clipboard("udsmain.Static_Game_Dict['" + table_ref + "']['" + keyName + "']['" + fieldName + "']")
		labelNode.release_focus()


func get_main_tab(par):
	#Get main tab scene which should have the popup container and necessary script
	while !par.get_groups().has("Tab"):
		par = par.get_parent()
	return par

func on_mouse_entered():
	var parent = get_main_tab(self)
	if parent.get("selected_field_name") != null:
		parent.selected_field_name = labelNode.text

func on_text_changed(new_text = "Blank"):
	var parent = get_main_tab(self)
	if parent.has_method("input_node_changed"):
		parent.input_node_changed(new_text)
#	print(new_text)


func connect_signals():
	labelNode.connect("pressed", self, "label_pressed")
#	connect("mouse_entered", self, "on_mouse_entered")

	if inputNode.has_signal("text_changed"):
		inputNode.connect("text_changed", self, "on_text_changed")
	
	if inputNode.has_signal("pressed"):
		inputNode.connect("pressed", self, "on_text_changed", [inputNode.pressed])
	
	labelNode.connect("mouse_entered", self, "on_mouse_entered")
	self.connect("mouse_entered", self, "on_mouse_entered")
	
