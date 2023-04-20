@tool
extends TextureButton
signal button_size_changed
@export var button_text: String = ""
@export var auto_connect_signals: bool = true

var root 
var text_label
var bufferSize :int = 15
var default_button_texture:Texture2D = preload("res://fart_data/png/AU3Button.png")
var minimum_size: Vector2 = Vector2(175,25)

func _ready():
	var Par = get_parent()
	root = get_main_tab(Par)
	set_label_text()
	connect_signals()
	create_button()

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
	root.navigation_button_click(name, self)
	set_self_modulate_selected()


func set_label_text(label_text: String = ""):
	if button_text != "":
		text_label = button_text
		$Label.set_text(text_label)
	elif label_text != "":
		$Label.set_text(label_text)

		


func connect_signals():
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


func reset_self_modulate():
	if !self.disabled:
#		print("SET TO WHITE")
		set_self_modulate(Color.WHITE)
	else:
#		print("DISABLED")
		_on_texture_disabled()


func set_self_modulate_selected():
	set_self_modulate(Color.BLUE)

func set_self_modulate_hover():
	set_self_modulate(Color.YELLOW)

func _on_texture_disabled():
	set_self_modulate(Color.DARK_GREEN)

func _on_mouse_entered():
	set_self_modulate_hover()


func _on_mouse_exited():
	reset_self_modulate()


func _on_texture_button_up():
	reset_self_modulate()

func _on_texture_button_down():
	set_self_modulate_selected()


func _on_texture_pressed():
	set_self_modulate_selected()


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
	set_custom_minimum_size(Vector2(100, 25))
	reset_self_modulate()
	set_texture(default_button_texture, "Normal")
	set_texture(default_button_texture, "Pressed")
	set_texture(default_button_texture, "Hover")
	set_texture(default_button_texture, "Disabled")
	set_texture(default_button_texture, "Focused")


#func _process(delta):
#	var visibleNode :Label = $Label
#	var labelSize :Vector2 = visibleNode.size
#	var buttonSize :Vector2 = self.size
##	print("Label Size: ", labelSize.y)
##	print("Button Size: ", buttonSize.y)
#	if labelSize.y + bufferSize != buttonSize.y:
##		print("Label Size: ", labelSize.y)
##		print("Button Size: ", buttonSize.y)
#		change_button_size()
#	else:
#		print("Label Size: ", labelSize.y)
#		print("Button Size: ", buttonSize.y)
#		print("CALL CHANGE BUTTON SIZZE")
#	change_button_size()
#
#
#
func change_button_size():
	
	var visibleNode :Label = $Label
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
	await root.get_tree().process_frame
	emit_signal("button_size_changed")
	print(self.name, " RESIZED")
#		print("Label Size: ", labelSize)
#		print("Button Size: ", buttonSize)
