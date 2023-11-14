extends TextureButton

var label_text
var options_variable
var event_name
var texture_background_color:Color
var default_button_texture:Texture2D #= preload("res://fart_data/png/Fart_UI_Button.png")

@onready var label_node = $Label


func _init():
#	default_button_texture = load(get_default_button_texture())
	texture_background_color = get_default_background_color()
	


func _ready():
	
	connect_signals()


func set_input_values(btn_text:String, options_var:String, evnt_name:String):
	label_text = btn_text
	options_variable = options_var
	event_name = evnt_name
	label_node.parse_bbcode("[center]" + label_text)
#	print(label_text)


func _on_button_button_up():
	pass # Replace with function body.

func get_default_background_color() -> Color:

	var UI_scenes_table:Dictionary = DatabaseManager.all_tables_merged_dict["10044"]
	var return_color:Color = str_to_var(UI_scenes_table["10"]["Background Color"])
	return return_color


func connect_signals():
	$Button.connect("button_up",_on_texture_button_up)
	$Button.connect("button_down",_on_texture_button_down)
	
	$Button.connect("mouse_entered",_on_mouse_entered)
	$Button.connect("mouse_exited",_on_mouse_exited)

	$Button.connect("focus_entered",_on_mouse_entered)
	$Button.connect("focus_exited",_on_mouse_exited)

	$Button.connect("pressed",_on_texture_pressed)
#	connect("button_down",_on_texture_button_down)


func reset_self_modulate():
	set_self_modulate(texture_background_color)


func set_self_modulate_selected():
	set_self_modulate(texture_background_color.darkened(0.5))


func set_self_modulate_hover():
	set_self_modulate(texture_background_color.lightened(0.5))


func _on_mouse_entered():
	set_self_modulate_hover()


func _on_mouse_exited():
	reset_self_modulate()


func _on_texture_button_up():
#	var function_name :String = FART.get_text(ui_navigation_dict[str(selected_method_key)]["Function Name"])
#	FART.UIENGINE.callv(function_name, [])
	reset_self_modulate()

func _on_texture_button_down():
	set_self_modulate_selected()


func _on_texture_pressed():
	set_self_modulate_selected()
