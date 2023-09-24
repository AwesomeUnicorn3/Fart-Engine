@tool
extends InputEngine

@export var show_advanced_options_node:bool = false
#@onready var advanced_options_node := $Input_Node/AdvancedControlsVBox
var show_advanced_options: bool = false


func _init() -> void:
	type = "1"


#func startup():
#	inputNode.set_fit_content_height_enabled(true)
#	input_child.visible = show_input_node
#	display_child.visible = !show_input_node   


func get_text_value() -> String:
	return _get_input_value()["text"]


func show_advanced_node(show_node:bool = show_advanced_options_node):
	#print("SHOW ADVANCED NODE: ", show_advanced_options_node, " ",advanced_options_node.visible)
	if !get_tree():
		show_node = false
	else:
		await get_tree().process_frame
		if labelNode.text == "Display Name":
			show_node = false
	$Input_Node/AdvancedControlsVBox.set_visible(show_node)


func set_display_value(node_value):
	#IN-GAME DISPLAY
	if input_child == null:
		input_child = await get_input_child()
	input_child.visible = false
	var display_node = await get_display_node()
	display_node.visible = true
	node_value = DBENGINE.convert_string_to_type(str(node_value))

	if typeof(node_value) == TYPE_DICTIONARY:
		display_node.get_node("Display").parse_bbcode(node_value["text"])
	else:
		display_node.get_node("Display").parse_bbcode(node_value)


func _set_input_value(node_value):
	var text: String
	if typeof(node_value) == 4:
		node_value = str_to_var(node_value)
	text = str(node_value["text"])

	input_data = node_value
	if inputNode == null:
		inputNode = await get_input_node()
	inputNode.set_text(text)
	
	if !node_value.has("show_advanced_options"):
		node_value["show_advanced_options"] = show_advanced_options
	show_advanced_options = node_value["show_advanced_options"]
	
	
	_on_input_text_changed(text)

	show_advanced_node()
	display_advanced_options(show_advanced_options)


func _get_input_value():
	var text_dict :Dictionary
	var text_input :String = inputNode.text
	text_dict["text"] = text_input
	text_dict["show_advanced_options"] = show_advanced_options
	return text_dict


func _on_input_text_changed(new_text):
	if display_child == null:
		display_child = await get_display_child()
	display_child.get_node("display").parse_bbcode(new_text)


func _on_input_caret_changed():
	if display_child == null:
		display_child = await get_display_child()
	display_child.get_node("display").parse_bbcode(inputNode.text)


func _on_hide_advanced_button_up():
#	set_hide_advanced()
	display_advanced_options(!show_advanced_options)


func display_advanced_options(show:bool):
#	print(show_advanced_options)
	var showhide_dict := {true : "Hide", false : "Show"}
#	$Input_Node/AdvancedControlsVBox/AdvancedControlsHBox.visible = show
	$Input_Node/AdvancedControlsVBox/Display_Child.visible = show
	$Input_Node/AdvancedControlsVBox/Label/HBox1/Hide_Button.set_text(showhide_dict[show])
	set_hide_advanced(show)

func set_hide_advanced(show:bool):
	show_advanced_options = show


func _on_underline_toggled(button_pressed):
	if button_pressed:
		inputNode.insert_text_at_caret("[u]")
	else:
		inputNode.insert_text_at_caret("[/u]")


func _on_italics_toggled(button_pressed):
	if button_pressed:
		inputNode.insert_text_at_caret("[i]")
	else:
		inputNode.insert_text_at_caret("[/i]")


func _on_bold_toggled(button_pressed):
	if button_pressed:
		inputNode.insert_text_at_caret("[b]")
	else:
		inputNode.insert_text_at_caret("[/b]")

#func _on_visibility_changed():
#	if visible:
#
#		var display :RichTextLabel = display_child.get_node("display")
##		display.set_text("")
#		display.clear()
##		display.newline()
##		display.push_strikethrough()
#
#		display.parse_bbcode("")
#		display.push_color(Color(1,1,0,1))
#		display.append_text('ciao ')
#		display.push_strikethrough()
#
#		display.push_color(Color(.5,.5,.5,1))
#		display.push_bgcolor(Color(1,1,0,1))
#		display.append_text(' ciao ')
#
#		display.pop()
#		display.pop()
#		display.pop()
##		display.pop()
##		display.push_bold()
#		display.push_fgcolor(Color(.2,.4,.5,.2))
#		display.push_font_size(50)
#		display.append_text('[i] ciao [/i]')
#
#
#		print(display.get_parsed_text())
#		display.set_text(display.get_parsed_text())
