extends Control


func _ready() -> void:
	$VBox1/VBox1/GameTitle.set_text(await udsmain.get_game_title())
	udsmain.set_root_node()



func _on_NewGame_button_up() -> void:
	udsmain.new_game()
	visible = false


func _on_LoadGame_button_up() -> void:
	var LoadGameMenu : Node = load("res://addons/UDSEngine/Example Game/LoadGameMenu.tscn").instantiate()
	udsmain.root.get_node("UI").add_child(LoadGameMenu)


func _on_LoadGame2_button_up() -> void: #EXIT BUTTON
	udsmain.root.get_tree().quit()
