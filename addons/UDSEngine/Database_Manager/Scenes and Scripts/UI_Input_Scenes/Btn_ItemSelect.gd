@tool
extends Button

var btn_moved := false
var btn_pressed := false
var parent
var grandparent
var main_page = null
var bufferSize :int = 10


func set_label_text(keyName :String, displayName :String = "", displayNameVisible :bool = true):
	$Label.set_text(keyName) #must be set no matter what is displayed
	#print(displayName, " Visible : ", displayNameVisible)
	if displayNameVisible and displayName != "":
		$DisplayLabel.set_text(displayName)
#		visibleNode = $DisplayLabel
		$DisplayLabel.visible = true
		$Label.visible = false
		
	else:
#		visibleNode = $Label
		$DisplayLabel.visible = false
		$Label.visible = true
		#print("Key Name: ", keyName, " ", displayName, " Visible : ", displayNameVisible)
	change_button_size()


func change_button_size():

	var visibleNode :Label = get_visible_label()
	var labelSize :Vector2 = visibleNode.size
	var buttonSize :Vector2 = self.size
	if labelSize.y + bufferSize != buttonSize.y:
		custom_minimum_size = Vector2(labelSize.x,labelSize.y + bufferSize)
		set_size(Vector2(labelSize.x,labelSize.y + bufferSize))
		labelSize = visibleNode.size
		buttonSize = self.size

func get_visible_label() -> Label:
	var labelNode :Label
	for child in get_children():
		if child.visible:
			labelNode = child
			break
	return labelNode

func _on_TextureButton_button_up():
	if !btn_moved:
		var name = $Label.get_text()
		main_page.refresh_data(name)

	modulate = Color(1,1,1,1)

	btn_moved = false
	btn_pressed = false
	main_page.button_movement_active = false
	

func _process(delta):
	var visibleNode :Label = get_visible_label()
	var labelSize :Vector2 = visibleNode.size
	var buttonSize :Vector2 = self.size
	if labelSize.y + bufferSize != buttonSize.y:
		change_button_size()

	if btn_moved:
		var mouse_postion :Vector2 = get_viewport().get_mouse_position()
		set_position(Vector2(mouse_postion.x + 25, mouse_postion.y - 20))


func _on_pressed():

	if main_page.button_movement_active:
		main_page.rearrange_table_keys()
		main_page._on_Save_button_up()

	elif main_page.name != "Event_Manager":
		btn_pressed = true
		await get_tree().create_timer(.25).timeout
		if btn_pressed:
			modulate = Color(1,1,1,.25)
			btn_moved = true
			parent = get_parent()
			grandparent = main_page.get_node("Button_Float")
			var current_index := get_index()
			parent.remove_child(self)
			grandparent.add_child(self)
			main_page.button_movement_active = true
			main_page.button_selected = name


func _on_mouse_entered():
	main_page.button_focus_index = name
