@tool
extends TextureButton
#@onready var DBENGINE: DatabaseEngine
@export var selected_method_key :String = "1":
	set = set_selected_method_key
@export var label_text_override: String = ""
@export var minimum_size: Vector2 = Vector2(150,50)

var label :Label
#NEED TO ADD THIS TO DATABASE AND PULL FROM THERE 
var default_button_texture:Texture2D #= preload("res://fart_data/png/Fart_UI_Button.png")
var ui_navigation_dict :Dictionary 
var texture_background_color:Color


func _init():
#	DBENGINE = DatabaseEngine.new()
	default_button_texture = load(get_default_button_texture())
	texture_background_color = get_default_background_color()
	
func _ready():
	connect_signals()
	create_button()
#	FARTENGINE.get_root_node().print_orphan_nodes()


func get_default_button_texture() -> String:
	var UI_scenes_table:Dictionary
	if Engine.is_editor_hint():
		UI_scenes_table= DatabaseEngine.new().import_data("UI Scenes")
	else:
		UI_scenes_table= FARTENGINE.import_data("UI Scenes")
	var return_texture_path:String = UI_scenes_table["11"]["Path"]
	return return_texture_path


func get_default_background_color() -> Color:
	var UI_scenes_table:Dictionary
	if Engine.is_editor_hint():
		UI_scenes_table= DatabaseEngine.new().import_data("UI Scenes")
	else:
		UI_scenes_table = FARTENGINE.import_data("UI Scenes")
	var return_color:Color = str_to_var(UI_scenes_table["11"]["Background Color"])
	return return_color



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
	set_self_modulate(texture_background_color)


func set_self_modulate_selected():
	set_self_modulate(texture_background_color.darkened(0.5))


func set_self_modulate_hover():
	set_self_modulate(texture_background_color.lightened(.5))


func _on_mouse_entered():
	set_self_modulate_hover()


func _on_mouse_exited():
	reset_self_modulate()


func _on_texture_button_up():
	var function_name :String = FARTENGINE.get_text(ui_navigation_dict[str(selected_method_key)]["Function Name"])
	FARTENGINE.UIENGINE.callv(function_name, [])
	reset_self_modulate()

func _on_texture_button_down():
	set_self_modulate_selected()


func _on_texture_pressed():
	set_self_modulate_selected()


func set_texture(buttonTexture:Texture2D=null, textureLayer:String = "Normal"):
	if buttonTexture == null:
		buttonTexture = load(get_default_button_texture()) #preload("res://Data/png/AwesomeUnicorn (copy).png")
	
	self.ignore_texture_size = true
	self.set_stretch_mode(TextureButton.STRETCH_SCALE)
	
	match textureLayer:
		"Normal":
				#if self.get_texture_normal() == null:
			self.set_texture_normal(buttonTexture)
		"Pressed":
				#if self.get_texture_pressed() == null:
			self.set_texture_pressed(buttonTexture)
		"Hover":
				#if self.get_texture_hover() == null:
			self.set_texture_hover(buttonTexture)
		"Disabled":
				#if self.get_texture_disabled() == null:
			self.set_texture_disabled(buttonTexture)
		"Focused":
				#if self.get_texture_focused() == null:
			self.set_texture_focused(buttonTexture)





func show_UIMethod_selection_in_editor():
	pass

func set_selected_method_key(selectedKey:String):
	selected_method_key = selectedKey
	create_button()


func create_button():
	for child in self.get_children():
		if child.get_class() == "Label":
			child.name = child.name + "1"
			child.queue_free()
	set_custom_minimum_size(minimum_size)
	reset_self_modulate()
	set_texture(default_button_texture, "Normal")
	set_texture(default_button_texture, "Pressed")
	set_texture(default_button_texture, "Hover")
	set_texture(default_button_texture, "Disabled")
	set_texture(default_button_texture, "Focused")

	label = Label.new()
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	label.set_horizontal_alignment(HORIZONTAL_ALIGNMENT_CENTER)
	label.set_vertical_alignment(VERTICAL_ALIGNMENT_CENTER)
	add_child(label)
	
	
#	await get_tree().process_frame
#	pass
	
	if is_inside_tree():
#	if is_instance_valid(get_tree()):
		var displayName = label_text_override
#		if displayName == "":
		if !Engine.is_editor_hint():
			ui_navigation_dict = FARTENGINE.Static_Game_Dict["UI Script Methods"]
			if displayName == "":
				displayName= FARTENGINE.get_text(ui_navigation_dict[str(selected_method_key)]["Button Label"])
#			label.set_text(displayName)
		else:
			var DBENGINE: DatabaseEngine = DatabaseEngine.new()
			ui_navigation_dict = DBENGINE.import_data("UI Script Methods")
			if displayName == "":
				displayName = DBENGINE.get_text(ui_navigation_dict[str(selected_method_key)]["Button Label"])
		
		label.set_text(displayName)
		label.name = displayName
		print("NAME: ", displayName)
		
