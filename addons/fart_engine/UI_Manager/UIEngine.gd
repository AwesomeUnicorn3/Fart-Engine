class_name UIEngine extends GDScript

func do_nothing():
	pass


func save_game():
	var save_id = await FART.save_game()

##HELPFUL HINT
func close_in_game_menu():
	FART.set_game_state("2")

func open_in_game_menu():
	FART.set_game_state("6")


func new_game():
	FART.new_game()


func close_current_menu(current_menu:Object):
	pass
	#What do i need to to when closing a menu?
	#How do i get the current menu?
	#Each menu could have a "close" function so it can handle it's own business before closing
	


func quit_game():
	FART.quit_game()


func open_menu(menu_name:String):
	pass
	#What do i need to do to display menu?


func load_game():
	FART.set_game_state("9")
#	var LoadGameMenu : Node = load("res://addons/fart_engine/Example Game/LoadGameMenu.tscn").instantiate()
#	FART.root.get_node("UI").add_child(LoadGameMenu)


func exit_program():
	FART.root.get_tree().quit()


func move_camera():
	FART.CAMERA.set_camera_smooth_speed(10.0)
	FART.CAMERA.move_camera_to_event("Fart Event", true, 5.0)
	
#	FART.CAMERA.move_camera(Vector2(0,50), 200.00, 1.25, false)

##HINT MESSAGE
#func return_to_title_Screen():
#	pass
	#set state
	#close map
	#display title screen
