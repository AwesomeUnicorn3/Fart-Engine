class_name UIEngine extends Control

func do_nothing():
	pass


func save_game():
	var save_id = await FARTENGINE.save_game()

##HELPFUL HINT
func close_in_game_menu():
	FARTENGINE.set_game_state("2")

func open_in_game_menu():
	FARTENGINE.set_game_state("6")


func new_game():
	FARTENGINE.new_game()


func close_current_menu(current_menu:Object):
	pass
	#What do i need to to when closing a menu?
	#How do i get the current menu?
	#Each menu could have a "close" function so it can handle it's own business before closing
	


func quit_game():
	FARTENGINE.quit_game()


func open_menu(menu_name:String):
	pass
	#What do i need to do to display menu?


func load_game():
	FARTENGINE.set_game_state("9")
#	var LoadGameMenu : Node = load("res://addons/fart_engine/Example Game/LoadGameMenu.tscn").instantiate()
#	FARTENGINE.root.get_node("UI").add_child(LoadGameMenu)


func exit_program():
	FARTENGINE.root.get_tree().quit()

##HINT MESSAGE
#func return_to_title_Screen():
#	pass
	#set state
	#close map
	#display title screen
