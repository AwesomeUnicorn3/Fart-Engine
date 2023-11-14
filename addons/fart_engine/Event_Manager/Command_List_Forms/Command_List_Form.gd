@tool
extends CommandManager
signal closed
signal set_input


#var edit_state :bool = false
#var function_dict :Dictionary

func _on_cancel_button_up():
	if edit_state:
		get_parent()._on_close_button_up()
	else:
		queue_free()



func _open_selected_form(btn_name, for_edit:bool):
	match btn_name:
		"change_game_state":
			load_form("res://addons/fart_engine/Event_Manager/Command_List_Forms/GameState_EventInputForm.tscn", for_edit)
		"change_local_variable":
			load_form("res://addons/fart_engine/Event_Manager/Command_List_Forms/LocalVariables_EventInputForm.tscn", for_edit)
		"change_global_variable":
			_on_global_variables_button_up()
		"remove_event":
			_on_remove_event_button_up()
		"print_to_console":
			load_form("res://addons/fart_engine/Event_Manager/Command_List_Forms/PrintToConsole_EventInputForm.tscn", for_edit)
		"wait":
			load_form("res://addons/fart_engine/Event_Manager/Command_List_Forms/Wait_EventInputForm.tscn", for_edit)
		"transfer_player":
			_on_player_transfer_button_up()
		"modify_player_inventory":
			load_form("res://addons/fart_engine/Event_Manager/Command_List_Forms/ModifyInventory_EventInputForm.tscn", for_edit)
		"start_dialog":
			load_form("res://addons/fart_engine/Event_Manager/Command_List_Forms/Dialog_EventInputForm.tscn", for_edit)
		"sfx":
			load_form("res://addons/fart_engine/Event_Manager/Command_List_Forms/sfx_EventInputForm.tscn", for_edit)
		"change_dialog_options":
			load_form("res://addons/fart_engine/Event_Manager/Command_List_Forms/DialogOptions_EventInputForm.tscn", for_edit)
		"set_camera_speed":
			load_form("res://addons/fart_engine/Event_Manager/Command_List_Forms/SetCameraSpeed_EventInputForm.tscn", for_edit)
		"set_camera_follow_player":
			load_form("res://addons/fart_engine/Event_Manager/Command_List_Forms/SetCameraFollowPlayer_EventInputForm.tscn", for_edit)
		"move_camera":
			load_form("res://addons/fart_engine/Event_Manager/Command_List_Forms/move_camera_EventInputForm.tscn", for_edit)
		"move_camera_to_event":
			load_form("res://addons/fart_engine/Event_Manager/Command_List_Forms/moveCameraToEvent_EventInputForm.tscn", for_edit)
		"change_player_health":
			load_form("res://addons/fart_engine/Event_Manager/Command_List_Forms/Change_Player_Health_EventInputForm.tscn", for_edit)


func _connect_signals(new_node):
#	print("Connect new node to set input values")
	set_input.connect(new_node.set_input_values)


func _on_close_button_up():
	emit_signal("closed")
	queue_free()


func load_form(new_form_path:String, for_edit:bool):
	var new_form = load(new_form_path).instantiate()
	new_form.edit_state = for_edit
	add_child(new_form)
	_connect_signals(new_form)


#-------------------------------------------------
func _on_player_transfer_button_up():
	var PlayerTransfer_EventInputForm = preload("res://addons/fart_engine/Event_Manager/Command_List_Forms/PlayerTransfer_EventInputForm.tscn").instantiate()
	add_child(PlayerTransfer_EventInputForm)
#	PlayerTransfer_EventInputForm.event_name = source_node.parent_node.event_name
	_connect_signals(PlayerTransfer_EventInputForm)


func _on_global_variables_button_up():
	#instatiate and add local var inp as "localVariables_EventInputForm"
	var global_variables_dictionary = all_tables_merged_dict["10029"]
	var globalVariables_EventInputForm = preload("res://addons/fart_engine/Event_Manager/Command_List_Forms/GlobalVariables_EventInputForm.tscn").instantiate()
	add_child(globalVariables_EventInputForm)
	_connect_signals(globalVariables_EventInputForm)


func _on_remove_event_button_up():
	var function_dict :Dictionary = {"remove_event" : [source_node.parent_node.event_name]}
	function_dict = function_dict
	_on_close_button_up()

