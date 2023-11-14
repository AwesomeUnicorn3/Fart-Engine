@tool
extends PopupManager

func get_eventID():
	var eventID
	eventID = $PanelContainer/VBox1/HBox1/Existing_Events_Dropdown._get_input_value()

	var event_name =  $PanelContainer/VBox1/HBox1/Existing_Events_Dropdown.get_dropdown_index_from_displayName(eventID)
#	print("Event Name: ", event_name)
#	print("Event ID: ", eventID)
	
	return eventID
#func _on_popup_newValue_visibility_changed():
#	if visible:
#		$PanelContainer/VBox1/HBox1/VBox2/ItemType_Selection.populate_list()
#		$PanelContainer/VBox1/HBox1/Table_Selection.populate_list()

func populate_events_dropdown(event_list:Dictionary):
	#populate event list to dropdown
	#convert array to dictionary
#	print("Event list: ", event_list)
	var event_selection_dropdown := $PanelContainer/VBox1/HBox1/Existing_Events_Dropdown
	event_selection_dropdown.populate_list(false, true, true, event_list)
#	event_selection_dropdown.populate_list(false)
	


func _on_accept_btn_pressed(btn_name):
	pass # Replace with function body.


func _on_cancel_btn_pressed(btn_name):
	print("EVENT SELECTION CANCEL")
