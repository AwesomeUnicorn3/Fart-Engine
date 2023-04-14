extends Control


func _ready() -> void:
	$VBox1/VBox1/GameTitle.set_text(await FARTENGINE.get_game_title())
	FARTENGINE.set_root_node()



func _on_NewGame_button_up() -> void:
	FARTENGINE.new_game()
	visible = false


func _on_LoadGame_button_up() -> void:
	var LoadGameMenu : Node = load("res://addons/fart_engine/Example Game/LoadGameMenu.tscn").instantiate()
	FARTENGINE.root.get_node("UI").add_child(LoadGameMenu)


func _on_LoadGame2_button_up() -> void: #EXIT BUTTON
	FARTENGINE.root.get_tree().quit()
