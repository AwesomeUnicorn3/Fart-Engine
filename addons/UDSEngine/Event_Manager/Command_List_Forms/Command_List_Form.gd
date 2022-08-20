@tool
extends Control
signal closed
var CommandInputForm
var local_variable_dictionary :Dictionary
var DBENGINE = DatabaseEngine.new()

func _open_selected_form(btn_name):
	match btn_name:
		"ModifyLocalVariables":
			_on_local_variables_button_up()
		"ModifyGlobalVariables":
			_on_global_variables_button_up()
		"RemoveEvent":
			_on_remove_event_button_up()
		"PrintToConsole":
			_on_print_to_console_button_up()
		"Wait":
			_on_wait_button_up()
		"PlayerTransfer":
			_on_player_transfer_button_up()
		"ModifyPlayerInventory":
			_on_modify_player_inventory_button_up()



func _on_close_button_up():
	queue_free()
	emit_signal("closed")


func _on_remove_event_button_up():
	var function_dict :Dictionary = {"remove_event" : [CommandInputForm.source_node.parent_node.event_name]}
	CommandInputForm.function_dict = function_dict
	_on_close_button_up()

func _on_local_variables_button_up():
	#instatiate and add local var inp as "localVariables_EventInputForm"
	var localVariables_EventInputForm = load("res://addons/UDSEngine/Event_Manager/Command_List_Forms/LocalVariables_EventInputForm.tscn").instantiate()
	add_child(localVariables_EventInputForm)
	#set variable dict as selection_node table
	localVariables_EventInputForm.selection_node.selection_table = local_variable_dictionary
	localVariables_EventInputForm.selection_node.selection_table_name = "" #REPLACE THIS WITH DICTIONARY INPUT IN EVENT TABLE???
	#populate list on seelction_node 
	localVariables_EventInputForm.selection_node.populate_list(false)
	localVariables_EventInputForm.commandListForm = self


func _on_global_variables_button_up():
	#instatiate and add local var inp as "localVariables_EventInputForm"
	var global_variables_dictionary = DBENGINE.import_data(DBENGINE.table_save_path + "Global Variables" + DBENGINE.file_format)
	var globalVariables_EventInputForm = load("res://addons/UDSEngine/Event_Manager/Command_List_Forms/GlobalVariables_EventInputForm.tscn").instantiate()
	add_child(globalVariables_EventInputForm)
	#set variable dict as selection_node table
	globalVariables_EventInputForm.global_var_node.selection_table = global_variables_dictionary
	globalVariables_EventInputForm.global_var_node.selection_table_name = "" #REPLACE THIS WITH DICTIONARY INPUT IN EVENT TABLE???
	globalVariables_EventInputForm.global_variables_dictionary = global_variables_dictionary
	
	await globalVariables_EventInputForm.global_var_node.populate_list(false)
	
	globalVariables_EventInputForm.commandListForm = self
	globalVariables_EventInputForm.global_var_node.select_index(0)


func _on_print_to_console_button_up():
	var PrintToConsole_EventInputForm = load("res://addons/UDSEngine/Event_Manager/Command_List_Forms/PrintToConsole_EventInputForm.tscn").instantiate()
	add_child(PrintToConsole_EventInputForm)
	PrintToConsole_EventInputForm.commandListForm = self
	
func _on_wait_button_up():
	var Wait_EventInputForm = load("res://addons/UDSEngine/Event_Manager/Command_List_Forms/Wait_EventInputForm.tscn").instantiate()
	add_child(Wait_EventInputForm)
	Wait_EventInputForm.commandListForm = self
	
func _on_player_transfer_button_up():
	var PlayerTransfer_EventInputForm = load("res://addons/UDSEngine/Event_Manager/Command_List_Forms/PlayerTransfer_EventInputForm.tscn").instantiate()
	add_child(PlayerTransfer_EventInputForm)
	PlayerTransfer_EventInputForm.event_name = CommandInputForm.source_node.parent_node.event_name
	PlayerTransfer_EventInputForm.commandListForm = self

func _on_modify_player_inventory_button_up():
	var new_form = load("res://addons/UDSEngine/Event_Manager/Command_List_Forms/ModifyInventory_EventInputForm.tscn").instantiate()
	add_child(new_form)
	new_form.commandListForm = self
