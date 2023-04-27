@tool
extends TextureButton

@export var selected_method_key :String = "1":
	set = set_selected_method_key
@export var label_text_override: String = ""
@export var minimum_size: Vector2 = Vector2(150,50)

var label :Label
#NEED TO ADD THIS TO DATABASE AND PULL FROM THERE 
var default_button_texture:Texture2D = preload("res://fart_data/png/Fart_UI_Button.png")
var ui_navigation_dict :Dictionary 



func _ready():

	connect_signals()
	create_button()


func connect_signals():
	connect("button_up",_on_texture_button_up)
	connect("button_down",_on_texture_button_down)
	
	connect("mouse_entered",_on_mouse_entered)
	connect("mouse_exited",_on_mouse_exited)

	connect("focus_entered",_on_mouse_entered)
	connect("focus_exited",_on_mouse_exited)

	connect("pressed",_on_texture_pressed)
#	connect("button_down",_on_texture_button_down)


func reset_self_modulate():
	set_self_modulate(Color.ORANGE)


func set_self_modulate_selected():
	set_self_modulate(Color.ORANGE.darkened(0.5))


func set_self_modulate_hover():
	set_self_modulate(Color.ORANGE.lightened(.5))


func _on_mouse_entered():
	set_self_modulate_hover()


func _on_mouse_exited():
	reset_self_modulate()


func _on_texture_button_up():
	var function_name :String = FARTENGINE.convert_string_to_type(ui_navigation_dict[str(selected_method_key)]["Function Name"])["text"]
	FARTENGINE.UIENGINE.callv(function_name, [])
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





func show_UIMethod_selection_in_editor():
	pass

func set_selected_method_key(selectedKey:String):
	selected_method_key = selectedKey
	create_button()


func create_button():
	set_custom_minimum_size(minimum_size)
	reset_self_modulate()
	set_texture(default_button_texture, "Normal")
	set_texture(default_button_texture, "Pressed")
	set_texture(default_button_texture, "Hover")
	set_texture(default_button_texture, "Disabled")
	set_texture(default_button_texture, "Focused")


	for child in self.get_children():
		if child.get_class() == "Label":
			child.queue_free()

	label = Label.new()
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	label.set_horizontal_alignment(HORIZONTAL_ALIGNMENT_CENTER)
	label.set_vertical_alignment(VERTICAL_ALIGNMENT_CENTER)
	add_child(label)
	
	
	if is_inside_tree():
#	if is_instance_valid(get_tree()):
		var displayName = label_text_override
#		if displayName == "":
		if !get_tree().get_edited_scene_root():
			ui_navigation_dict = FARTENGINE.Static_Game_Dict["UI Script Methods"]
			if displayName == "":
				displayName= FARTENGINE.convert_string_to_type(ui_navigation_dict[str(selected_method_key)]["Button Label"])["text"]
#			label.set_text(displayName)
		else:
			var DBENGINE: DatabaseEngine = DatabaseEngine.new()
			ui_navigation_dict = DBENGINE.import_data("UI Script Methods")
			if displayName == "":
				displayName = DBENGINE.convert_string_to_type(ui_navigation_dict[str(selected_method_key)]["Button Label"])["text"]
		
		label.set_text(displayName)
