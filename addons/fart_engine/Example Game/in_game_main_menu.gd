extends Control


func _on_hidden():
	FART.emit_signal("in_game_menu_closed")


func _on_close_in_game_menu():
	FART.show_in_game_main_menu(false)


func _on_au_3_ui_button_visibility_changed():
	pass # Replace with function body.
