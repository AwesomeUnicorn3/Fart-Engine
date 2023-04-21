@tool
extends TextureButton
signal button_size_changed
@export var button_text: String = ""
@export var auto_connect_signals: bool = true
@export var auto_set_minimum_size: bool = true
var root 
var text: String = ""
var bufferSize :int = 30
var default_button_texture:Texture2D = preload("res://addons/fart_engine/Editor_Icons/Default_Editor_Button_Texture.png")
var minimum_size: Vector2 = Vector2(175,25)

var btn_moved := false
var btn_pressed := false
var parent
var grandparent
var main_page = null

var button_base_color: Color = Color(0.25,0.75,0.45,1.0)

func _ready():
	var Par = get_parent()
	root = get_main_tab(Par)
	set_label_text()
	create_button()
	connect_signals()

#func connect_signals():
#	if auto_connect_signals:
#		connect("button_up", _on_Navigation_Button_button_up)

func get_main_tab(par :Node = self):
	var grps := par.get_groups()
	while grps.has(&"UDS_Root") == false:
		par = par.get_parent()
		grps = par.get_groups()
	return par


func _on_Navigation_Button_button_up():
#	print("Name: ", name)
	set_self_modulate_selected()
	if self.is_in_group("Key"):
		if !btn_moved:
			var Name = name
			main_page.refresh_data(Name)
			self.disabled = true
#		modulate = Color(1,1,1,1)
		btn_moved = false
		btn_pressed = false
		main_page.button_movement_active = false
	else:
		root.navigation_button_click(name, self)


func get_visible_label() -> Label:
	var labelNode :Label
	for child in get_children():
		if child.visible:
			labelNode = child
			break
	return labelNode

func get_text()-> String:
	return text

func set_text(textString: String):
	get_visible_label().set_text(textString)
	text = textString


func set_label_text(key_ID: String = "", displayName :String = "", displayNameVisible :bool = true):
	if self.is_in_group("Key"):
		$Label.set_text(key_ID) #must be set no matter what is displayed
		if displayNameVisible == true and displayName != "":
#			print("SHOW DISPLAY NAME")
			$DisplayLabel.set_text(displayName)
			$DisplayLabel.visible = true
			$Label.visible = false
		else:
#			print("SHOW KEY NAME")
			$DisplayLabel.visible = false
			$Label.visible = true
#		print($Label.visible)
		change_button_size()
#		$DisplayLabel.visible = true
#		$Label.visible = true
	else:
		if button_text != "":
			text = button_text
			$Label.set_text(text)
		elif key_ID != "":
			$Label.set_text(key_ID)
			text = key_ID


func connect_signals():
	
#	if self.is_in_group("Key"):
#		connect("pressed",_on_pressed)
#	connect("button_up",_on_Navigation_Button_button_up)
	connect("button_down",_on_texture_button_down)
	
	connect("mouse_entered",_on_mouse_entered)
	connect("mouse_exited",_on_mouse_exited)

	connect("focus_entered",_on_mouse_entered)
	connect("focus_exited",_on_mouse_exited)

	connect("pressed",_on_texture_pressed)

	if auto_connect_signals:
		connect("button_up", _on_Navigation_Button_button_up)

#	connect("button_down",_on_texture_button_down)





func _on_pressed():
#	print("PRESSED")
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
			main_page.enable_all_buttons()

func reset_self_modulate():
	if !self.disabled:
#		print("SET TO WHITE")
		set_self_modulate(button_base_color)
	else:
#		print("DISABLED")button_base_color
		_on_texture_disabled()


func set_self_modulate_selected():
	set_self_modulate(button_base_color.darkened(.7))

func set_self_modulate_hover():
	if !self.disabled:
		set_self_modulate(button_base_color.lightened(.6))

func _on_texture_disabled():
	set_self_modulate_selected()


func _on_mouse_entered():
	set_self_modulate_hover()
	if self.is_in_group("Key"):
		main_page.button_focus_index = name


func _on_mouse_exited():
	reset_self_modulate()


func _on_texture_button_up():
	reset_self_modulate()

func _on_texture_button_down():
	set_self_modulate_selected()


func _on_texture_pressed():
	set_self_modulate_selected()
	if self.is_in_group("Key"):
		_on_pressed()


func set_texture(buttonTexture:Texture2D=null, textureLayer:String = "Normal"):
	if buttonTexture == null:
		buttonTexture = default_button_texture #preload("res://Data/png/AwesomeUnicorn (copy).png")
	
	self.ignore_texture_size = true
	self.set_stretch_mode(TextureButton.STRETCH_SCALE)
	
	match textureLayer:
		"Normal":
			if self.get_texture_normal() == null:
				self.set_texture_normal(buttonTexture)
		"Pressed":
				if self.get_texture_pressed() == null:
					self.set_texture_pressed(buttonTexture)
		"Hover":
				if self.get_texture_pressed() == null:
					self.set_texture_pressed(buttonTexture)
		"Disabled":
				if self.get_texture_pressed() == null:
					self.set_texture_pressed(buttonTexture)
		"Focused":
				if self.get_texture_pressed() == null:
					self.set_texture_pressed(buttonTexture)

func create_button():
	if auto_set_minimum_size:
		set_custom_minimum_size(minimum_size)
	reset_self_modulate()
	set_texture(default_button_texture, "Normal")
	set_texture(default_button_texture, "Pressed")
	set_texture(default_button_texture, "Hover")
	set_texture(default_button_texture, "Disabled")
	set_texture(default_button_texture, "Focused")


func _process(delta):
#	if self.is_in_group("key") and self.is_inside_tree():
#		var visibleNode :Label = get_visible_label()
#		var labelSize :Vector2 = visibleNode.size
#		var buttonSize :Vector2 = self.size
#		if labelSize.y + bufferSize != buttonSize.y:
#			change_button_size()
	if btn_moved:
		var mouse_postion :Vector2 = get_viewport().get_mouse_position()
		set_position(Vector2(mouse_postion.x + 25, mouse_postion.y - 20))


func change_button_size():
	var visibleNode :Label = get_visible_label()
	var labelSize :Vector2 = visibleNode.size
	set_custom_minimum_size(Vector2(minimum_size.x,minimum_size.y + bufferSize))
#	visibleNode.set_custom_minimum_size(minimum_size)
	var buttonSize :Vector2 = self.size
#	set_size(Vector2(minimum_size.x, labelSize.y))
	if labelSize.y != buttonSize.y:
		labelSize = visibleNode.size
		set_size(Vector2(minimum_size.x,labelSize.y + bufferSize))
		labelSize = visibleNode.size
		buttonSize = self.size
		
	if !self.is_in_group("Key"):
		await root.get_tree().process_frame
		emit_signal("button_size_changed")
#	print(self.name, " RESIZED")
#		print("Label Size: ", labelSize)
#		print("Button Size: ", buttonSize)


