@tool
extends Control
signal closed
signal set_input
var CommandInputForm
#var local_variable_dictionary :Dictionary
var DBENGINE = DatabaseEngine.new()


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


func connect_signals(new_node):
#	print("Connect new node to set input values")
	set_input.connect(new_node.set_input_values)


func _on_close_button_up():
	emit_signal("closed")
	queue_free()


func load_form(new_form_path:String, for_edit:bool):
	var new_form = load(new_form_path).instantiate()
	new_form.edit_state = for_edit
	add_child(new_form)
	new_form.commandListForm = self
	connect_signals(new_form)


#-------------------------------------------------
func _on_player_transfer_button_up():
	var PlayerTransfer_EventInputForm = preload("res://addons/fart_engine/Event_Manager/Command_List_Forms/PlayerTransfer_EventInputForm.tscn").instantiate()
	add_child(PlayerTransfer_EventInputForm)
	PlayerTransfer_EventInputForm.event_name = CommandInputForm.source_node.parent_node.event_name
	PlayerTransfer_EventInputForm.commandListForm = self
	connect_signals(PlayerTransfer_EventInputForm)


func _on_global_variables_button_up():
	#instatiate and add local var inp as "localVariables_EventInputForm"
	var global_variables_dictionary = DBENGINE.import_data("Global Variables")
	var globalVariables_EventInputForm = preload("res://addons/fart_engine/Event_Manager/Command_List_Forms/GlobalVariables_EventInputForm.tscn").instantiate()
	add_child(globalVariables_EventInputForm)
	globalVariables_EventInputForm.commandListForm = self
	connect_signals(globalVariables_EventInputForm)


func _on_remove_event_button_up():
	var function_dict :Dictionary = {"remove_event" : [CommandInputForm.source_node.parent_node.event_name]}
	CommandInputForm.function_dict = function_dict
	_on_close_button_up()

#func _on_local_variables_button_up():
#	var localVariables_EventInputForm = preload("res://addons/fart_engine/Event_Manager/Command_List_Forms/LocalVariables_EventInputForm.tscn").instantiate()
#	add_child(localVariables_EventInputForm)
#	localVariables_EventInputForm.commandListForm = self
#	connect_signals(localVariables_EventInputForm)

#
#func _on_change_dialog_options_button_up():
#	var EventInputForm = preload("res://addons/fart_engine/Event_Manager/Command_List_Forms/DialogOptions_EventInputForm.tscn").instantiate()
#	add_child(EventInputForm)
#	EventInputForm.commandListForm = self
#	connect_signals(EventInputForm)



#func _on_print_to_console_button_up():
#	var PrintToConsole_EventInputForm = preload("res://addons/fart_engine/Event_Manager/Command_List_Forms/PrintToConsole_EventInputForm.tscn").instantiate()
#	add_child(PrintToConsole_EventInputForm)
#	PrintToConsole_EventInputForm.commandListForm = self
#	connect_signals(PrintToConsole_EventInputForm)
	
#func _on_wait_button_up():
#	var Wait_EventInputForm = preload("res://addons/fart_engine/Event_Manager/Command_List_Forms/Wait_EventInputForm.tscn").instantiate()
#	add_child(Wait_EventInputForm)
#	Wait_EventInputForm.commandListForm = self
#	connect_signals(Wait_EventInputForm)
	


#func _on_modify_player_inventory_button_up():
#	var new_form = preload("res://addons/fart_engine/Event_Manager/Command_List_Forms/ModifyInventory_EventInputForm.tscn").instantiate()
#	add_child(new_form)
#	new_form.commandListForm = self
#	connect_signals(new_form)

#func _on_dialog_button_up():
#	var new_form = preload("res://addons/fart_engine/Event_Manager/Command_List_Forms/Dialog_EventInputForm.tscn").instantiate()
#	add_child(new_form)
#	new_form.commandListForm = self
#	connect_signals(new_form)

#func _on_sfx_button_up():
#	var new_form = preload("res://addons/fart_engine/Event_Manager/Command_List_Forms/sfx_EventInputForm.tscn").instantiate()
#	add_child(new_form)
#	new_form.commandListForm = self
#	connect_signals(new_form)
#
#func _on_change_game_state_button_up():
#	var new_form = preload("res://addons/fart_engine/Event_Manager/Command_List_Forms/GameState_EventInputForm.tscn").instantiate()
#	add_child(new_form)
#	new_form.commandListForm = self
#	connect_signals(new_form)


#func _on_set_camera_speed_button_up():
#	load_form("res://addons/fart_engine/Event_Manager/Command_List_Forms/SetCameraSpeed_EventInputForm.tscn")
#
#func _on_set_camera_follow_player_button_up():
#	load_form("res://addons/fart_engine/Event_Manager/Command_List_Forms/SetCameraFollowPlayer_EventInputForm.tscn")



