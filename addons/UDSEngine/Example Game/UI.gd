extends Control
signal next_message_pressed



#func _input(event):
#	if Input.is_action_just_pressed("action_pressed"):
#		emit_signal("next_message_pressed")


func _on_Menu_button_down():
	AU3ENGINE.show_in_game_main_menu()
