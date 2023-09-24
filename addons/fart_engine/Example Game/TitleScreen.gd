extends Control


func _ready() -> void:
	$VBox1/VBox1/GameTitle.set_text(await FART.get_game_title())
#	FART.set_root_node()



#func _on_NewGame_button_up() -> void:
#	FART.new_game()
#	visible = false


#func _on_LoadGame_button_up() -> void:
#	var LoadGameMenu : Node = load("res://addons/fart_engine/Example Game/LoadGameMenu.tscn").instantiate()
#	FART.fart_root.get_node("UI").add_child(LoadGameMenu)
#
#
#func _on_LoadGame2_button_up() -> void: #EXIT BUTTON
#	FART.fart_root.get_tree().quit()
