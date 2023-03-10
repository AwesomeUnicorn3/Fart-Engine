extends Control


func _on_hidden():
	AU3ENGINE.emit_signal("in_game_menu_closed")


func _on_close_in_game_menu():
	AU3ENGINE.show_in_game_main_menu(false)


func _on_au_3_ui_button_visibility_changed():
	pass # Replace with function body.
