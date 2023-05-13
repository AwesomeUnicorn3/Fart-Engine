@tool
extends VBoxContainer




func get_index_to_dialog_options():
#	print("START ADVANCED CONTROLS SET INDEX DIALOG OPTIONS")
	$Input_Array/Control/ActionSelection.populate_list()
#	await get_tree().create_timer(0.1).timeout
	var sorted_table: Dictionary = $Input_Array/Control/ActionSelection.sorted_table
	var dialog_options_key: String
	for index in sorted_table:
#		print("SORTED TABLE INDEX: ", sorted_table[index])
		if sorted_table[index][1] == "18":
			dialog_options_key = index
			break
#			print("DIALOG OPTIONS KEY: ", dialog_options_key)
	$Input_Array/Control/ActionSelection.select_index(int(dialog_options_key) - 1)
	
	return dialog_options_key


func set_input_value(node_value):
	if typeof(node_value) == TYPE_STRING:
		node_value = str_to_var(node_value)
	print("ADVANCED CONTROLS SET INPUT: ", node_value)
	$Input_Array._set_input_value(node_value["event_buttons"])
	$Checkbox_Template._set_input_value(node_value["show_event_options_buttons"])
	





func get_input_value():
	var return_value:Dictionary
	
	return_value["event_buttons"] = $Input_Array.get_input_value()
	return_value["show_event_options_buttons"] = $Checkbox_Template.get_input_value()
	
#	print("ADVANCED CONTROLS GET INPUT: ", return_value)
	
	
	return return_value


func _on_checkbox_template_checkbox_pressed(show):
	$Label.visible = show
	$Input_Array.visible  = show
