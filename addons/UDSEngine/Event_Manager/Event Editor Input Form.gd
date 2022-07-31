@tool
extends DatabaseEngine

signal event_selection_popup_closed
signal event_editor_input_form_closed

@onready var conditions_node := $Scroll1/VBox1/HBox1/HBox1
@onready var event_name_label := $Scroll1/VBox1/HBox3/Input_Text
@onready var event_trigger_display := $Scroll1/VBox1/HBox1/VBox1
@onready var popup_main := $Popups
@onready var event_selection_popup := $Popups/popup_Event_Selection
@onready var event_selection_dropdown_input := $Popups/popup_Event_Selection/PanelContainer/VBox1/HBox1/Existing_Events_Dropdown
@onready var event_page_button_list := $Scroll1/VBox1/Hbox4
@onready var commands_node := $Scroll1/VBox1/VBox1
var parent_node
var event_dict :Dictionary 
var event_name :String = ""
var event_node :EventHandler
var tab_number :String = "1"
var initial_event_display_name :String = ""
var input_node_array :Array = []


func match_fields_to_template():
	var event_template_dict :Dictionary = import_data(table_save_path + "Event Table Template" + file_format)
	for key in event_template_dict:
		for field in event_template_dict[key]:
				for tab in event_dict:
					if !event_dict[tab].has(field):
						event_dict[tab][field] = event_template_dict[key][field]
#
	var remove_field_array = []
	for tab in event_dict:
		for field in event_dict[tab]:
			if !event_template_dict["1"].has(field):
				remove_field_array.append(field)

	if remove_field_array.size() != 0:
		for field in remove_field_array:
			for tab in event_dict:
				event_dict[tab].erase(field)

	
func load_event_data(event_tab := tab_number):
	#load data
	match_fields_to_template()
	for child in event_page_button_list.get_children():
		child.queue_free()
	load_page_buttons()


	initial_event_display_name = get_table_data_key(event_name, true)
	event_name_label.inputNode.set_text(initial_event_display_name)

func load_page_buttons():
	var page_button = load("res://addons/UDSEngine/Event_Manager/Event_Page_Button.tscn")
	var event_size : int = event_dict.size()
	for index in event_size:
		var index_text :String = str(index + 1)
		var new_button = page_button.instantiate()
		new_button.set_text("Page " + index_text)
		new_button.set_name(index_text)
		event_page_button_list.add_child(new_button)
		new_button.event_page_number = index_text
		if new_button.event_page_number == tab_number:
			new_button.on_Button_button_up()

func load_event_notes(event_tab):
	var input_value = event_dict[event_tab]["Notes"]
	var notes_container = await add_input_node(1, 1, "Notes", event_dict[event_tab], event_trigger_display, null, input_value, "1", "")
	input_node_array.append(notes_container)
#	return notes_container

func load_event_trigger_input(event_tab):
	var input_value = event_dict[event_tab]["Event Trigger"]
	var trigger_selection_container  = await add_input_node(1, 1, "Event Trigger", event_dict[event_tab], event_trigger_display, null, input_value, "5", "Event Triggers")
	input_node_array.append(trigger_selection_container)

func load_event_conditions_input(event_tab):
	var input_value = event_dict[event_tab]["Conditions"]
	var conditions_container  = await add_input_node(1, 1, "Conditions", event_dict[event_tab], conditions_node, null, input_value, "14", "")
	conditions_container.parent_node = self
	input_node_array.append(conditions_container)

func load_event_animation_input(event_tab):
	var input_value = event_dict[event_tab]["Default Animation"]
	var event_animation_container  = await add_input_node(1, 1, "Default Animation", event_dict[event_tab], event_trigger_display, null, input_value, "8")
	input_node_array.append(event_animation_container)

func display_condition_list():
	var list_display = load("res://addons/UDSEngine/Event_Manager/Condition_input_form.tscn").instantiate()
	list_display.local_variable_dictionary = get_local_variables()
	add_child(list_display)
	list_display._ready() 
	
func load_event_commands_input(event_tab):
	var input_value = event_dict[event_tab]["Commands"]
	var commands_container  = await add_input_node(1, 1, "Commands", event_dict[event_tab], commands_node, null, input_value, "15", "")
	commands_container.parent_node = self
	commands_container.local_variable_dictionary = get_local_variables()
	input_node_array.append(commands_container)

func get_local_variables() -> Dictionary:
	var local_variable_dictionary:Dictionary
	var var_list : Dictionary= convert_string_to_type(event_dict["1"]["Local Variables"])
	for key in var_list:
		local_variable_dictionary[var_list[key]["Value 1"]] = var_list[key]["Value 2"]
	return local_variable_dictionary


func _on_event_selection_Accept_button_up() -> void:
	event_selection_popup.visible = false
	popup_main.visible = false
	event_name = get_table_data_key(event_selection_dropdown_input.selectedItemName)
	event_node.event_name = event_name
	emit_signal("event_selection_popup_closed")

func on_page_button_pressed(event_page_number :String):
	if event_page_number == "1":
		$Scroll1/VBox1/HBox3/HBox1/Delete_Page_Button.disabled = true
	else:
		$Scroll1/VBox1/HBox3/HBox1/Delete_Page_Button.disabled = false
	clear_all_input_forms()
	tab_number = event_page_number
	input_node_array = []
	load_event_notes(event_page_number)
	load_event_trigger_input(event_page_number)
	load_event_animation_input(event_page_number)
	load_event_conditions_input(event_page_number)
	load_event_commands_input(event_page_number)
	
	
func get_table_data_key(table_name := "", return_display_name := false):
	var key_name :String
	var display_name :String
	var table_list :Dictionary = import_data(table_save_path + "Table Data" + file_format)
	for tableName in table_list:
		if tableName == table_name:
			key_name = tableName
			display_name = table_list[tableName]["Display Name"]
			break
		elif table_list[tableName]["Display Name"] == table_name:
			key_name = tableName
			display_name = table_list[tableName]["Display Name"]
			break
	if return_display_name:
		return display_name
	else:
		return key_name

func set_table_data_display_name(event_key :String , displayName :String):
	var display_name :String
	print("Begin set tabel data")
	var table_list :Dictionary = import_data(table_save_path + "Table Data" + file_format)
	for tableName in table_list:
		if tableName == event_key:
			table_list[tableName]["Display Name"] = displayName
			break
		elif table_list[tableName]["Display Name"] == event_key:
			table_list[tableName]["Display Name"] = displayName
			break
	
	save_file(table_save_path + "Table Data" + file_format, table_list)

	event_node.event_name = displayName
	update_editor()

func set_table_data_display_name_from_dbmanager(event_key :String , displayName :String):
	var display_name :String
	var table_list :Dictionary = import_data(table_save_path + "Table Data" + file_format)
	for tableName in table_list:
		if tableName == event_key:
			table_list[tableName]["Display Name"] = displayName
			break
		elif table_list[tableName]["Display Name"] == event_key:
			table_list[tableName]["Display Name"] = displayName
			break

	save_file(table_save_path + "Table Data" + file_format, table_list)
	return displayName

func update_editor():
	var editor = EditorPlugin.new()
	var selected_nodes :Array = editor.get_editor_interface().get_selection().get_selected_nodes()
	editor.get_editor_interface().get_selection().clear()
	editor.get_editor_interface().get_selection().add_node(event_node)

#	var main_node = get_main_node()
#	main_node.get_node("Tabs/Database")._on_Refresh_Data_button_up()

func _on_event_selection_Cancel_button_up() -> void:
	event_selection_popup.visible = false
	popup_main.visible = false
	event_name = ""
#	event_node.event_name = event_name
	emit_signal("event_selection_popup_closed")
	_on_Button_button_up()



func get_next_event_key():
	# Set event_name based on event_dict.size() + 1
	#if that key exists, add 1 and try again until key does not exist
	var next_key :String = ""
	event_dict = get_list_of_events(true)
	if event_dict == {}:
		next_key = "1"

	else:
		var event_number
		var event_number_array := []
		for displayName in event_dict:
			var event_array = event_dict[displayName].rsplit(" ")
			event_number = event_array[1]
			event_number_array.append(event_number)
		var event_size = event_number_array.size() + 2
		for index in range(1,event_size):
			if !event_number_array.has(str(index)):
				next_key = str(index)
				break

	return next_key


func _on_Create_New_Event_Button_button_up(change_event_name_in_node := true):
	event_name = "Event " + get_next_event_key()
	#copy event table template and save as current event
	current_table_name = "Event Table Template"
	update_dictionaries()
	save_all_db_files(event_name)

	#Add current event to table data Table
	current_table_name = "Table Data"
	data_type = "Row"
	update_dictionaries()
	add_key(event_name, "1", true, true, "")

	#Input data for table list
	current_dict[event_name]["Display Name"] = event_name
	current_dict[event_name]["Create Tab"] = false
	current_dict[event_name]["Is Dropdown Table"] = false
	current_dict[event_name]["Include in Save File"] = false
	current_dict[event_name]["Can Delete"] = true
	current_dict[event_name]["Is Event"] = true
	save_all_db_files(current_table_name)
	
	
	event_selection_popup.visible = false
	popup_main.visible = false

	emit_signal("event_selection_popup_closed")
	if change_event_name_in_node:
		event_node.event_name = event_name
		update_editor()

	return event_name


func set_initial_values(tabNumber := tab_number):
	current_table_name = event_name
	update_dictionaries()
	event_dict = current_dict
	load_event_data(tabNumber)

func load_event_from_dbmanager():
	set_initial_values()


func load_event() -> void:
	var editor := EditorPlugin.new()
	var selection_array = editor.get_editor_interface().get_selection().get_selected_nodes()
	if selection_array.size() != 0:
		if selection_array.size() == 1:
			event_node = editor.get_editor_interface().get_selection().get_selected_nodes()[0]
			event_name = get_table_data_key(event_node.event_name)
			if event_name == "":
				popup_main.visible = true
				event_selection_dropdown_input.selection_table = get_list_of_events(true)
				event_selection_dropdown_input.selection_table_name = "Events"
				if event_selection_dropdown_input.selection_table.size()!= 0:
					event_selection_dropdown_input.populate_list(false)
					event_selection_dropdown_input.select_index()
					event_selection_dropdown_input.visible = true
				else:
					event_selection_dropdown_input.visible = false
				event_selection_popup.visible = true
				await event_selection_popup_closed
#				yield(self, "event_selection_popup_closed")
				if event_name != "":
					set_initial_values()
			else:
				set_initial_values()

func _on_Button_button_up() -> void: #close form - event node
	emit_signal("event_editor_input_form_closed")
	var editor = EditorPlugin.new()
	editor.remove_control_from_container(EditorPlugin.CONTAINER_CANVAS_EDITOR_BOTTOM, self)
	queue_free()

func close_event_input_form_in_dbmanager():
	queue_free()

func _on_Save_Close_Button_button_up() -> void:
	#Save Data to currDict
#	var root = event_node.root_node
#	print(root.name)
#	var event_node = DBENGINE.get_events_tab(self)
	save_event_data()
	#GET UDS ENGINE EVENT TAB AND REFRESH
	#REFRESH EVENT TAB
	var editor := EditorPlugin.new()
	var udsplugin = editor.get_editor_interface().get_editor_main_control().get_node("UDSENGINE")
	udsplugin.get_node("Tabs/Event_Manager")._on_RefreshData_button_up()
	save_all_db_files()
	event_node._ready()
	call_deferred("_on_Button_button_up")


func save_event_data(is_dbmanager :bool = false):
	for child in input_node_array:
		update_match(child, child.labelNode.get_text(), tab_number)
	var displayName :String = event_name_label.inputNode.get_text()
	var display :String = displayName
	if displayName != initial_event_display_name:

		if is_dbmanager == true:
			display = set_table_data_display_name_from_dbmanager(event_name , displayName)
		else:
			set_table_data_display_name(event_name , displayName)
	save_all_db_files()

	var selected_page_button = event_page_button_list.get_node(tab_number)
	selected_page_button.on_Button_button_up()

	var eventNode = get_node("../../../../..")
	if eventNode.has_method("clear_datachange_warning"): eventNode.clear_datachange_warning()
	
	return display


func clear_all_input_forms():
	for child in input_node_array:
		child.queue_free()

func add_new_event_page():
	var event_page_template = import_data(table_save_path + "Event Table Template" + file_format)
	var new_tab_number = str(current_dict.size() + 1)
	add_key(new_tab_number, "1", true, true, false, false,event_page_template["1"])
	tab_number = new_tab_number
	save_all_db_files()
	set_initial_values()
	


func enable_all_page_buttons():
	for child in event_page_button_list.get_children():
		child.set_disabled(false)
		child.release_focus()

func input_node_changed(value):
	var eventNode = get_node("../../../../..")
	if eventNode.has_method("input_node_changed"): eventNode.input_node_changed(value)


func _on_Delete_Page_Button_button_up() -> void:
	data_type = "Row"
	Delete_Key(tab_number)
	#RENAME ALL PAGE KEYS THAT ARE GREATER THAN THE DELETED KEY
	for index in event_dict.size():
		index += 1
		if !event_dict.has(str(index)):
			var next_page_number = str(index + 1)
			var next_line = event_dict[next_page_number]
			event_dict[index] = next_line
			event_dict.erase(next_page_number)
			#copy the next line and save as "page"
			#delete the next line in event dict
	
	
	
	save_all_db_files()
	tab_number = "1"
	set_initial_values()
	


func _on_Save_Page_Button_button_up() -> void:
	save_event_data()
	save_all_db_files()


func _on_Copy_Page_Button_button_up() -> void:
	var new_page_dict :Dictionary = current_dict[tab_number].duplicate(true)
	#Copy current page dictionary
	#save current page dictionary as temp dict
	#Select new page tab
	var new_tab_number = str(current_dict.size() + 1)
	add_key(new_tab_number, "1", true, true, false, false,new_page_dict)
	tab_number = new_tab_number
	save_all_db_files()
	set_initial_values()
