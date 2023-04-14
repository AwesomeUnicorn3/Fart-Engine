class_name UIEngine extends Control

func do_nothing():
	pass


func save_game():
	var save_id = await FARTENGINE.save_game()

##HELPFUL HINT
func close_in_game_menu():
	FARTENGINE.show_in_game_main_menu(false)

func open_in_game_menu():
	FARTENGINE.show_in_game_main_menu(true)


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

##HINT MESSAGE
#func return_to_title_Screen():
#	pass
	#set state
	#close map
	#display title screen
