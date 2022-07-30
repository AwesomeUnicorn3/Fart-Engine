@tool
extends Button
var btn_moved := false
var btn_pressed := false
var parent
var grandparent
var main_page = null

func set_label_text(labelText :String):
	$Label.set_text(labelText)

func _on_TextureButton_button_up():
	if !btn_moved:
		var name = $Label.get_text()
		main_page.refresh_data(name)

	modulate = Color(1,1,1,1)

	btn_moved = false
	btn_pressed = false
	main_page.button_movement_active = false
	

func _process(delta):
	if btn_moved:
		var mouse_postion :Vector2 = get_viewport().get_mouse_position()
		set_position(Vector2(mouse_postion.x + 25, mouse_postion.y - 20))


func _on_texture_button_pressed():

	if main_page.button_movement_active:
		main_page.rearrange_table_keys()
		main_page._on_Save_button_up()

	elif main_page.name != "Event_Manager":
		btn_pressed = true
#		print("Button Down")
		
		await get_tree().create_timer(.25).timeout
		if btn_pressed:
#			print("Pressed")
			modulate = Color(1,1,1,.25)
			btn_moved = true
			parent = get_parent()
			grandparent = main_page.get_node("Button_Float")
			var current_index := get_index()
			parent.remove_child(self)
			grandparent.add_child(self)
			main_page.button_movement_active = true
			main_page.button_selected = name
#			print(current_index ," removed from " , parent.name)
#			print("Child added to " , grandparent.name, " at index ", get_index())



func _on_texture_button_mouse_entered():
	main_page.button_focus_index = name
