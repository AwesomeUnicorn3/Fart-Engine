@tool
extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func get_eventID():
	var eventID
	eventID = $PanelContainer/VBox1/HBox1/Existing_Events_Dropdown._get_input_value()

	var event_name =  $PanelContainer/VBox1/HBox1/Existing_Events_Dropdown.get_dropdown_index_from_displayName(eventID)
	print("Event Name: ", event_name)
	print("Event ID: ", eventID)
	
	return eventID
#func _on_popup_newValue_visibility_changed():
#	if visible:
#		$PanelContainer/VBox1/HBox1/VBox2/ItemType_Selection.populate_list()
#		$PanelContainer/VBox1/HBox1/Table_Selection.populate_list()

func populate_events_dropdown(event_list:Dictionary):
	#populate event list to dropdown
	#convert array to dictionary
	print("Event list: ", event_list)
	var event_selection_dropdown := $PanelContainer/VBox1/HBox1/Existing_Events_Dropdown
	event_selection_dropdown.populate_list(false, true, true, event_list)
#	event_selection_dropdown.populate_list(false)
	
