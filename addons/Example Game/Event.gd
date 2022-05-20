extends Area2D
class_name Event
tool

var event_dict :Dictionary = {}
var event_node_name := ""
var event_name := ""



#func _init() -> void:
#	print(new_event)
#	DBENGINE = DatabaseEngine.new()
#	var script_dict :Dictionary = DBENGINE.import_data(DBENGINE.table_save_path + "events" + DBENGINE.file_format)
#	var event_script :Object = load(script_dict[event_name]["Script Path"])
#	print(event_script)
#	for i in script_dict:
#		event_array.append(i)
#	event_number = event_array
#	property_list_changed_notify() 
#	print(get_property_list())



func _get_property_list():
	var properties = []
	if event_name != "":
		var DBENGINE :DatabaseEngine = DatabaseEngine.new()
		#EVENT DICT NEEDS TO BE THE TABLE DATA BUT ONLY THE TABLES THAT ARE DESIGNATED AS EVENTS
		var table_dict :Dictionary = DBENGINE.import_data(DBENGINE.table_save_path + "Table Data" + DBENGINE.file_format)
		event_dict = {}
		for table_name in table_dict:
			var is_event = DBENGINE.convert_string_to_type(table_dict[table_name]["Is Event"])
			if is_event:
				event_dict[table_name] = table_dict[table_name]["Display Name"]
	#	print(event_dict)
		var event_list :String = ""
		for i in event_dict:
			if event_list == "":
				event_list = event_dict[i]
			else:
				event_list = event_list + "," + event_dict[i]
#		print(event_list)
		
		# Same as "export(int) var my_property"
		properties.append({
			name = "event_name",
			type = TYPE_STRING,
			hint = 3,
			hint_string = event_list,
			usage = 8199
			})


#	if !event_dict.has(event_name):
#		event_name = str(event_dict.size() + 1)
		
		#Add new event popup
		#ask user if they want to add new event or use existing
		
		#if new event:
#		DBENGINE.current_table_name = "events"
#		DBENGINE.update_dictionaries()
#		DBENGINE.add_key(event_name, "1", true, true, false)
#		DBENGINE.save_all_db_files()
		#create new table for new event

#		DBENGINE.current_table_name = "Event Table Template"
#		DBENGINE.update_dictionaries()
#		DBENGINE.current_table_name = "Event " + event_name
		
#		DBENGINE.add_key(event_name, "1", true, true, false)
#		DBENGINE.save_all_db_files()
#		DBENGINE.update_dictionaries()
		
		
		#if select event
		#DBENGINE.current_table_name = "selected event name" #need to set this variable from popup
		#DBENGINE.update_dictionaries()
#		DBENGINE.add_key(event_name, "1", true, true, false)
		#DBENGINE.save_all_db_files()
	return properties

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Connect signals
	#Add Collision node
	#Set trigger data
	pass # Replace with function body.

func show_toolbar_in_editor(selected_node_name):
	event_node_name = selected_node_name
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass


func _on_Event_body_entered(body: Node) -> void:
	pass # Replace with function body.


func _on_Event_body_exited(body: Node) -> void:
	pass # Replace with function body.


func is_new_event_object() -> void:
	print("Event Added")

