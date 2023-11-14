@tool

class_name NavigationManager extends TextureButton
signal button_size_changed
signal btn_pressed(btn_name:String)


@export var custom_text: String = ""
@export var auto_connect_signals: bool = true
@export var auto_set_minimum_size: bool = true
@export var auto_set_button_color:bool = true
@export var auto_set_font_color:bool = true
@export var is_sticky:bool = false


var root 
var current_text: String = ""
var btn_moved := false
var _pressed := false
var parent
var grandparent
var main_page
var key_id:String = "0"
var key_display_name:String = "Default"

var bufferSize :int = 10
var default_button_texture:Texture2D #= preload("res://addons/fart_engine/Editor_Icons/Default_Editor_Button_Texture.png")
var default_label_texture: Texture2D #= preload("res://addons/fart_engine/Editor_Icons/Default_Editor_Label_Texture.png")
var minimum_size: Vector2 = Vector2(150,35)

var button_base_color: Color = Color.WHITE
var font_base_color: Color = Color.BLACK


func _ready():
#	print("NAV BUTTON READY FOR: ", self.name)
	default_button_texture = preload("res://fart_data/png/Navigation_Button.png")
	default_label_texture = preload("res://addons/fart_engine/Editor_Icons/Default_Editor_Label_Texture.png")
##	var Par = get_parent()
#	root = DatabaseManager.fart_root
	
	#if key_id != "0" or key_display_name != "Default":
	if custom_text != "":
		set_text_value(custom_text)
	set_label_text(key_id, key_display_name)

	await create_button()
	connect_signals()
	set_button_theme()

	set_toggle_mode(is_sticky)


func set_button_theme():
	if auto_set_button_color == true:
		set_button_base_color(await get_button_base_color())
	if auto_set_font_color == true:
		set_font_base_color(await get_font_base_color())

func set_key_id(KeyID: String):
	key_id = KeyID


func set_key_display_name(DisplayName: String):
	key_display_name = DisplayName


func set_text_value(textString: String):
	#print("SET TEXT VALUE: ", textString)
	set_label_text(textString, textString)
#	current_text = textString


func set_label_text(key_ID: String , displayName :String, displayNameVisible :bool = true):
	set_key_id(key_ID)
	set_key_display_name(displayName)
	
	if self.is_in_group("Key"):
#		$Label.set_text(key_ID)
		current_text = str(key_ID)
		if displayNameVisible == true and displayName != "":
			$DisplayLabel.set_text(displayName)
			$DisplayLabel.visible = true
			$Label.visible = false

		else:
			$DisplayLabel.visible = false
			$Label.visible = true
		
	else:
		
		if custom_text != "":
			#print("custom_text: ", custom_text)
			current_text = custom_text
			#print("CUSTOM TEXT: ", custom_text)
			#$Label.set_text(text)
#			key_ID = custom_text
		elif displayName != "":
			#$Label.set_text(key_ID)
			#print("DISPLAY NAME: ", displayName)
			current_text = displayName
			
		else:
			#print("CURRENT KEYID: ", key_ID)
			current_text = str(key_ID)
			
	
	$Label.set_text(current_text)
	if auto_set_minimum_size:
		change_button_size()





func get_button_base_color()-> Color:
	#print(project_settings_dict)
	var fart_editor_themes_table: Dictionary = DatabaseManager.import_data("10025")
	var theme_profile: String = DatabaseManager.project_settings_dict[await DatabaseManager.get_global_settings_profile()]["Fart Editor Theme"]
	var category_color = null
	var group
	var groups = get_groups()
	var index: int = groups.size() - 1
	
	while category_color == null:
		if index < 0:
			print(name, " DOES NOT HAVE A GROUP")
			category_color = Color.WHITE
		else:
			group = groups[index]
			if fart_editor_themes_table[theme_profile].has(group + " Button"):
				category_color = str_to_var(fart_editor_themes_table[theme_profile][group + " Button"])
#				print(group)
			else:
				index -= 1
		await get_tree().process_frame

	return category_color


func get_font_base_color():
	var fart_editor_themes_table: Dictionary =   await DatabaseManager.import_data("10025")
	var theme_profile: String = DatabaseManager.project_settings_dict["1"]["Fart Editor Theme"]
	var font_color = str_to_var(fart_editor_themes_table[theme_profile]["Font Base Color"])
	return font_color

func set_button_base_color(color: Color):
	#print("BASE COLOR: ", color)
	button_base_color = color
	reset_self_modulate()

func set_font_base_color(color: Color):
	#print("FONT BASE COLOR: ", color)
	font_base_color = color
	reset_self_modulate()

#func _on_command_list_button_button_up():
#	emit_signal("btn_pressed", str(name), false)


func _on_Navigation_Button_button_up():
	if self.is_in_group("Key"):
		if !btn_moved:
			#print("NAVIGATION BUTTON NAME: ", name)
#			print("MAIN PAGE: ", main_page.name)
			if main_page.has_method("key_button_pressed"):
#				print("HAS REFRESH DATA", main_page.name)
				main_page.key_button_pressed(key_id)
				self.disabled = true
				
		btn_moved = false
		_pressed = false
		#main_page.button_movement_active = false
#		DatabaseManager.display_form_dict[main_page.name]["Selected Key"] = str(self.name)
	elif self.is_in_group("Table Action"):
		self.disabled = false
		reset_self_modulate()
	else:
		root.navigation_button_click(name, self)

	emit_signal("btn_pressed", str(name), false)
	reset_self_modulate()


func get_visible_label() -> Label:
	var labelNode :Label
	for child in get_children():
		if child.visible:
			labelNode = child
			break
	return labelNode


func get_label_text()-> String:
	return current_text





func connect_signals():

	connect("button_down",_on_texture_button_down)
	
	connect("mouse_entered",_on_mouse_entered)
	connect("mouse_exited",_on_mouse_exited)

	connect("focus_entered",_on_mouse_entered)
	connect("focus_exited",_on_mouse_exited)

	connect("pressed",_on_texture_pressed)

	if auto_connect_signals:
		connect("button_up", _on_Navigation_Button_button_up)





#func _on_pressed():
#	if main_page.button_movement_active:
#		main_page.rearrange_table_keys()
#		main_page._on_Save_button_up()
#
#	elif main_page.name != "Event_Manager" or null:
#		_pressed = true
#		await get_tree().create_timer(.25).timeout
#		if btn_pressed:
#			modulate = Color(1,1,1,.25)
#			btn_moved = true
#			parent = get_parent()
#			grandparent = main_page.get_node("Button_Float")
#			var current_index := get_index()
#			parent.remove_child(self)
#			grandparent.add_child(self)
#			main_page.button_movement_active = true
#			main_page.button_selected = name
#			main_page.enable_all_buttons()


func reset_self_modulate():

	set_self_modulate(button_base_color)
	$Label.set_self_modulate(font_base_color)
	$DisplayLabel.set_self_modulate(font_base_color)
	
	if self.disabled:
		_on_texture_disabled()


func set_self_modulate_selected():
	set_self_modulate(button_base_color.darkened(.7))
	$Label.set_self_modulate(font_base_color.lightened(0.7))
	$DisplayLabel.set_self_modulate(font_base_color.lightened(0.7))


func set_self_modulate_hover():
	if !self.disabled:
		set_self_modulate(button_base_color.lightened(.6))
		$Label.set_self_modulate(font_base_color.darkened(0.6))
		$DisplayLabel.set_self_modulate(font_base_color.darkened(0.6))


func _on_texture_disabled():
	set_self_modulate_selected()


func _on_mouse_entered():
	set_self_modulate_hover()
	if self.is_in_group("Key"):
		DatabaseManager.BTN_focus_index = name


func _on_mouse_exited():
	reset_self_modulate()


func _on_texture_button_up():
	reset_self_modulate()

func _on_texture_button_down():
	set_self_modulate_selected()


func _on_texture_pressed():
	set_self_modulate_selected()


#func set_text_display_node():
#	if display_label == null:
#		display_label = $Label

func set_font_color():
	$Label.set_self_modulate(font_base_color)
	$DisplayLabel.set_self_modulate(font_base_color)

func set_texture(buttonTexture:Texture2D=null, textureLayer:String = "Normal"):
	if buttonTexture == null:
		buttonTexture = default_button_texture
	
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
	var selected_texture: Texture2D = default_button_texture
	if self.is_in_group("Node_Label"):
		selected_texture = default_label_texture

	if auto_set_minimum_size:
		set_custom_minimum_size(minimum_size)
	set_font_color()
	set_texture(selected_texture, "Normal")
	set_texture(selected_texture, "Pressed")
	set_texture(selected_texture, "Hover")
	set_texture(selected_texture, "Disabled")
	set_texture(selected_texture, "Focused")
	reset_self_modulate()


func _process(delta):
	if btn_moved:
		var mouse_postion :Vector2 = get_viewport().get_mouse_position()
		set_position(Vector2(mouse_postion.x + 25, mouse_postion.y - 20))


func change_button_size():
	if auto_set_minimum_size:
		var visibleNode :Label = get_visible_label()
		var labelSize :Vector2 = visibleNode.size
		set_custom_minimum_size(Vector2(minimum_size.x,minimum_size.y + bufferSize))
		var buttonSize :Vector2 = self.size
		if labelSize.y != buttonSize.y:
			labelSize = visibleNode.size
			set_size(Vector2(minimum_size.x,labelSize.y + bufferSize))
			labelSize = visibleNode.size
			buttonSize = self.size
		
#	if !self.is_in_group("Key"):
#		await root.get_tree().process_frame
#		emit_signal("button_size_changed")


func _on_cancel_button_up():
	pass # Replace with function body.
