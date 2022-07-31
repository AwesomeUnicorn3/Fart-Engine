@tool
extends Control
signal closed
var CommandInputForm
var local_variable_dictionary :Dictionary


func _open_selected_form(btn_name):
	print(btn_name)
	match btn_name:
		"ModifyLocalVariables":
#			print("open local variable selection")
			_on_local_variables_button_up()

		"RemoveEvent":
#			print("Remove event selected")
			var function_dict :Dictionary = {"remove_event" : [CommandInputForm.source_node.parent_node.event_name]}
			CommandInputForm.function_dict = function_dict
			_on_close_button_up()
		
		"PrintToConsole":
			_on_print_to_console_button_up()


func _on_close_button_up():
	queue_free()
	emit_signal("closed")


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
	
func _on_print_to_console_button_up():
	var PrintToConsole_EventInputForm = load("res://addons/UDSEngine/Event_Manager/Command_List_Forms/PrintToConsole_EventInputForm.tscn").instantiate()
	add_child(PrintToConsole_EventInputForm)
	PrintToConsole_EventInputForm.commandListForm = self
