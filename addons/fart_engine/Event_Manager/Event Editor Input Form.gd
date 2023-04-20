@tool
extends DatabaseEngine

signal event_selection_popup_closed
signal event_editor_input_form_closed

@onready var commands_node := $Scroll1/VBox1/VBox1
@onready var conditions_node := $Scroll1/VBox1/HBox1/HBox1
@onready var event_name_label := $Scroll1/VBox1/HBox3/Input_Text
@onready var event_trigger_display := $Scroll1/VBox1/HBox1/VBox1
@onready var popup_main := $Popups
@onready var event_selection_popup := $Popups/popup_Event_Selection
@onready var event_selection_dropdown_input := $Popups/popup_Event_Selection/PanelContainer/VBox1/HBox1/Existing_Events_Dropdown
@onready var event_page_button_list := $Scroll1/VBox1/Hbox4

var parent_node
var event_dict :Dictionary 
var event_name :String = ""
var event_node :EventHandler
var tab_number :String = "1"
var initial_event_display_name :String = ""
var input_node_dict :Dictionary = {}
var selectedPageNode : Node
var event_data_dict:Dictionary

func _ready():
	if event_name != "":
		load_event_from_dbmanager()
		event_data_dict = import_event_data(event_name, true)


func match_fields_to_template():
	var event_template_dict :Dictionary = import_data("Event Table Template")
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
	event_name_label.set_input_value(event_dict["0"]["Display Name"] )
	match_fields_to_template()
	for child in event_page_button_list.get_children():
		child.queue_free()
	load_page_buttons()


func load_page_buttons():
	var page_button = load("res://addons/fart_engine/Event_Manager/Event_Page_Button.tscn")
	var event_size : int = event_dict.size() - 1 #This is to account for the display name
	for index in event_size:
		var index_text :String = str(index + 1)
		var new_button = page_button.instantiate()
		new_button.set_text("Page " + index_text)
		new_button.set_name(index_text)
		event_page_button_list.add_child(new_button)
		new_button.event_page_number = index_text
		if new_button.event_page_number == tab_number:
			new_button.on_Button_button_up()


func load_event_notes(event_tab):#updated
	if event_data_dict == {}:
		event_data_dict = import_event_data(event_name, true)
	var input_value = event_dict[event_tab]["Notes"]
#	print(input_value)
	var notes_container = create_input_node("Notes", event_name, event_dict, event_data_dict)
	event_trigger_display.add_child(notes_container)
	notes_container.set_input_value(input_value)
	input_node_dict["Notes"] = notes_container


func load_event_trigger_input(event_tab):#updated
	var input_value = event_dict[event_tab]["Event Trigger"]
	var trigger_selection_container  = create_input_node("Event Trigger", event_name, event_dict, event_data_dict)
	trigger_selection_container.selection_table_name = "Event Triggers"
	event_trigger_display.add_child(trigger_selection_container)
	trigger_selection_container.set_input_value(input_value)
	input_node_dict["Event Trigger"] = trigger_selection_container


func load_event_animation_state_input(event_tab):#updated
	var input_value = event_dict[event_tab]["Does Event Move?"]
	var new_input_container =  create_input_node("Does Event Move?", event_name, event_dict, event_data_dict)
	event_trigger_display.add_child(new_input_container)
	input_node_dict["Does Event Move?"] = new_input_container
	new_input_container.true_text = "Yes"
	new_input_container.false_text = "No"
	new_input_container.checkbox_pressed.connect(animation_state_selected)
	new_input_container.set_input_value(input_value)


func load_attack_player_input(event_tab):#updated
	var input_value = event_dict[event_tab]["Attack Player?"]
	var new_input_container =  create_input_node("Attack Player?", event_name, event_dict, event_data_dict)
	conditions_node.add_child(new_input_container)
	input_node_dict["Attack Player?"] = new_input_container
	new_input_container.true_text = "Yes"
	new_input_container.false_text = "No"
#	new_input_container.checkbox_pressed.connect(animation_state_selected)
	new_input_container.set_input_value(input_value)


func load_draw_shadow_input(event_tab):#updated
	var input_value = event_dict[event_tab]["Draw Shadow?"]
	var new_input_container =  create_input_node("Draw Shadow?", event_name, event_dict, event_data_dict)
	conditions_node.add_child(new_input_container)
	input_node_dict["Draw Shadow?"] = new_input_container
	new_input_container.true_text = "Yes"
	new_input_container.false_text = "No"
#	new_input_container.checkbox_pressed.connect(animation_state_selected)
	new_input_container.set_input_value(input_value)


func animation_state_selected(event_moves :bool):
	show_animation_movement_options(event_moves)


func animation_group_selected(selected_index):
	var group_name :String = input_node_dict["Animation Group"].get_selected_value(selected_index)
	var default_anim_node = input_node_dict["Default Animation"]
	var sprite_group_dict :Dictionary = import_data("Sprite Groups")
	var idle_anim_dict :Dictionary = {}
	for sprite_name in sprite_group_dict:
		if str_to_var(sprite_group_dict[sprite_name]["Display Name"])["text"] == group_name:
			var current_group_dict :Dictionary = sprite_group_dict[sprite_name]
			idle_anim_dict = str_to_var(current_group_dict["Idle"])
	default_anim_node.set_input_value(idle_anim_dict)
	default_anim_node.get_data_and_create_sprite()


func show_animation_movement_options(show:bool = true):
	await get_tree().process_frame
	input_node_dict["Loop Animation"].visible = !show
	input_node_dict["Attack Player?"].visible = show
	input_node_dict["Animation Group"].visible = show
	input_node_dict["Max Speed"].visible = show
	input_node_dict["Acceleration"].visible = show
	input_node_dict["Friction"].visible = show


func load_event_animation_group_input(event_tab):#updated
	var input_value = event_dict[event_tab]["Animation Group"]
	var trigger_selection_container  = create_input_node("Animation Group", event_name, event_dict, event_data_dict)
	trigger_selection_container.selection_table_name = "Sprite Groups"
	event_trigger_display.add_child(trigger_selection_container)
	trigger_selection_container.set_input_value(input_value)
	input_node_dict["Animation Group"] = trigger_selection_container


func load_event_conditions_input(event_tab):#updated
	var input_value = event_dict[event_tab]["Conditions"]
	var conditions_container  = create_input_node("Conditions", event_name, event_dict, event_data_dict)
	commands_node.add_child(conditions_container)
	conditions_container.parent_node = self
	conditions_container.set_input_value(input_value)
	input_node_dict["Conditions"] = conditions_container


func load_event_animation_input(event_tab):
	var input_value = event_dict[event_tab]["Default Animation"]
	var new_input_container  =create_input_node("Default Animation", event_name, event_dict, event_data_dict) 
	input_node_dict["Default Animation"] = new_input_container
	event_trigger_display.add_child(new_input_container)
	input_node_dict["Default Animation"] = new_input_container
	new_input_container.set_input_value(input_value)
	new_input_container.show_field = true


func load_loop_animation_input(event_tab):#updated
	var input_value = event_dict[event_tab]["Loop Animation"]
	var new_input_container  =create_input_node("Loop Animation", event_name, event_dict, event_data_dict) 
	input_node_dict["Loop Animation"] = new_input_container
	conditions_node.add_child(new_input_container)
	input_node_dict["Loop Animation"] = new_input_container
	new_input_container.set_input_value(input_value)


func load_collide_with_player_input(event_tab):#updated
	var input_value = event_dict[event_tab]["Collide with Player?"]
	var new_input_container  = create_input_node("Collide with Player?", event_name, event_dict, event_data_dict)
	conditions_node.add_child(new_input_container)
	input_node_dict["Collide with Player?"] = new_input_container
	new_input_container.set_input_value(input_value)


func load_max_speed_input(event_tab):#updated
	var input_value = event_dict[event_tab]["Max Speed"]
	var new_input_container  =create_input_node("Max Speed", event_name, event_dict, event_data_dict) 
	conditions_node.add_child(new_input_container)
	input_node_dict["Max Speed"] = new_input_container
	new_input_container.set_input_value(input_value)


func load_acceleration_input(event_tab):#updated
	var input_value = event_dict[event_tab]["Acceleration"]
	var new_input_container  =create_input_node("Acceleration", event_name, event_dict, event_data_dict) 
	conditions_node.add_child(new_input_container)
	input_node_dict["Acceleration"] = new_input_container
	new_input_container.set_input_value(input_value)


func load_friction_input(event_tab):#updated
	var input_value = event_dict[event_tab]["Friction"]
	var new_input_container  =create_input_node("Friction", event_name, event_dict, event_data_dict) 
	conditions_node.add_child(new_input_container)
	input_node_dict["Friction"] = new_input_container
	new_input_container.set_input_value(input_value)


#func display_condition_list():
#	var list_display = load("res://addons/UDSEngine/Event_Manager/Condition_input_form.tscn").instantiate()
##	list_display.local_variable_dictionary = get_local_variables()
#	add_child(list_display)
#	list_display._ready() 


func load_event_commands_input(event_tab):
	var input_value = event_dict[event_tab]["Commands"]
	var container  = create_input_node("Commands", event_name, event_dict, event_data_dict)
	commands_node.add_child(container)
	container.parent_node = self
	container.set_input_value(input_value)
	input_node_dict["Commands"] = container


func on_page_button_pressed(event_page_number :String):
	selectedPageNode = event_page_button_list.get_child(int(event_page_number) - 1)
	if event_page_number == "1":
		$Scroll1/VBox1/HBox3/HBox1/Delete_Page_Button.disabled = true
	else:
		$Scroll1/VBox1/HBox3/HBox1/Delete_Page_Button.disabled = false
	await clear_all_input_forms()
	tab_number = event_page_number
	input_node_dict = {}
	
	
	load_event_notes(event_page_number)
	load_event_trigger_input(event_page_number)
	load_loop_animation_input(event_page_number)
	load_attack_player_input(event_page_number)
	load_max_speed_input(event_page_number)
	load_collide_with_player_input(event_page_number)
	load_draw_shadow_input(event_page_number)
	load_friction_input(event_page_number)
	load_acceleration_input(event_page_number)
	load_event_animation_state_input(event_page_number)
	load_event_animation_group_input(event_page_number)
	load_event_animation_input(event_page_number)

	var does_event_move_node = input_node_dict["Does Event Move?"]
	does_event_move_node._on_input_toggled(does_event_move_node.inputNode.button_pressed)

	load_event_conditions_input(event_page_number)
	load_event_commands_input(event_page_number)

	for node_name in input_node_dict:
		input_node_dict[node_name].is_label_button = false


#func get_table_data_key(table_name := "", return_display_name := false):
#	var key_name :String
#	var display_name :String
#	var table_list :Dictionary = import_data("Table Data")
#	for tableName in table_list:
#		if tableName == table_name:
#			key_name = tableName
#			display_name = str_to_var(table_list[tableName]["Display Name"])["text"]
#			break
#		elif convert_string_to_type(table_list[tableName]["Display Name"])["text"] == table_name:
#			key_name = tableName
#			display_name = table_list[tableName]["Display Name"]
#			break
#
#	if return_display_name:
#		return display_name
#	else:
#		return key_name


func set_table_data_display_name(event_key :String , displayName :String):
	var display_name :String
	var table_list :Dictionary = import_data("Table Data")
	for tableName in table_list:
		if tableName == event_key:
			table_list[tableName]["Display Name"] = displayName
			break
		elif table_list[tableName]["Display Name"] == event_key:
			table_list[tableName]["Display Name"] = displayName
			break
	
	save_file(table_save_path + "Table Data" + table_file_format, table_list)
#	print("set table data event Name: ", event_name)
	event_node.event_name = event_name
	update_editor()


func set_table_data_display_name_from_dbmanager(event_key :String , displayName :String):
	var tableData_dict :Dictionary = import_data("Table Data")
	for tableName in tableData_dict:
		var tableName_dict :Dictionary = str_to_var(tableData_dict[tableName]["Display Name"])
		var tblDisplayName :String = tableName_dict["text"]
		if tableName == event_key:
			tableData_dict[tableName]["Display Name"] = var_to_str({"text" : displayName})
	save_file(table_save_path + "Table Data" + table_file_format, tableData_dict)
	tableData_dict  = import_data("Table Data")
	return displayName


func update_editor():
	var editor = EditorScript.new()
	var selected_nodes :Array = editor.get_editor_interface().get_selection().get_selected_nodes()
	editor.get_editor_interface().get_selection().clear()
	editor.get_editor_interface().get_selection().add_node(event_node)


func get_next_event_key():
	# Set event_name based on event_dict.size() + 1
	#if that key exists, add 1 and try again until key does not exist
	var next_key :String = ""
	var event_list:Array = get_list_of_events()
	if event_list == []:
		next_key = "1"
	else:
		var event_number
		var event_number_array := []
		for displayName in event_list:
			var event_array = displayName.rsplit(" ")
			event_number = event_array[1]
			event_number_array.append(event_number)
		var event_size = event_number_array.size() + 2
		for index in range(1,event_size):
			if !event_number_array.has(str(index)):
				next_key = str(index)
				break

	return next_key





func set_initial_values(tabNumber := tab_number):
	current_table_name = event_name
#	update_dictionaries()
#	print("Intitial event Name: ", event_name)
	event_dict = import_event_data(event_name)
	load_event_data(tabNumber)



func load_event_from_dbmanager():
	set_initial_values()


func load_event(EventName:String) -> void:
#	var editor := EditorScript.new()
#	var selection_array = editor.get_editor_interface().get_selection().get_selected_nodes()
#	if selection_array.size() != 0:
#		if selection_array.size() == 1:
#			event_node = editor.get_editor_interface().get_selection().get_selected_nodes()[0]
#	print("Load event Name: ", EventName)
	event_name = EventName
#			if event_name == "":
#				popup_main.visible = true
#				event_selection_dropdown_input.selection_table = get_list_of_events()
#				event_selection_dropdown_input.selection_table_name = "Events"
#				if event_selection_dropdown_input.selection_table.size()!= 0:
#					event_selection_dropdown_input.populate_list(false)
#					event_selection_dropdown_input.select_index()
#					event_selection_dropdown_input.visible = true
#				else:
#					event_selection_dropdown_input.visible = false
#				event_selection_popup.visible = true
#				await event_selection_popup_closed
#				if event_name != "":
#					set_initial_values()
#			else:
	get_node("Scroll1/VBox1/HBox2").visible = true
	set_name("EventInputForm")
	set_initial_values()


func _on_Button_button_up() -> void: #close form - event node
	emit_signal("event_editor_input_form_closed")
#	var editor = EditorPlugin.new()
#	editor.remove_control_from_container(EditorPlugin.CONTAINER_CANVAS_EDITOR_BOTTOM, self)
#	queue_free()


func close_event_input_form_in_dbmanager():
	queue_free()


func _on_Save_Close_Button_button_up() -> void:
	save_event_data()
	var udsplugin = await get_AU3ENGINE_main_scene()
	udsplugin._ready()
	call_deferred("_on_Button_button_up")


func save_event_data(is_dbmanager :bool = false):
	var this_event_dict:Dictionary = {}
	event_dict["0"] = {"Display Name": event_name_label._get_input_value()}
	
	for child in input_node_dict:
		var node = input_node_dict[child]
#		print(child)
		this_event_dict[node.labelNode.get_text()] =  node.get_input_value()
	event_dict[tab_number] = this_event_dict

	save_file(table_save_path + event_folder + event_name + table_file_format, event_dict)
	selectedPageNode = event_page_button_list.get_child(int(tab_number) - 1)
	selectedPageNode.on_Button_button_up()
	var eventNode = get_node("../../../../..")
	if eventNode.has_method("clear_datachange_warning"): eventNode.clear_datachange_warning()

	return event_name


func clear_all_input_forms():
	for child in input_node_dict:
		var node = input_node_dict[child]
		node.queue_free()
		await get_tree().process_frame
	#await get_tree().process_frame





func enable_all_page_buttons():
	for child in event_page_button_list.get_children():
		child.set_disabled(false)
		child.release_focus()


func input_node_changed(value):
	var eventNode = get_node("../../../../..")
	if eventNode.has_method("input_node_changed"): eventNode.input_node_changed(value)


func _on_Delete_Page_Button_button_up() -> void:

	event_dict.erase(tab_number)
	print("EVENT DICT SIZZE: ", event_dict.size())

	for index in event_dict.size() - 1:
		index += 1
		print(index)
		if !event_dict.has(str(index)):
			var next_page_number = str(index + 1)
			var next_line = event_dict[next_page_number]
			event_dict[index] = next_line
			event_dict.erase(next_page_number)

	var data_dict = import_event_data(event_name, true)
	data_dict["Row"].erase(str(data_dict["Row"].size()))
	
	event_dict["0"] = {"Display Name": event_name_label._get_input_value()}
	save_file(table_save_path + event_folder + event_name + table_file_format, event_dict)
	save_file(table_save_path + event_folder + event_name + table_info_file_format, data_dict)
	tab_number = "1"
	_ready()




#	set_initial_values()
#	tab_number = "1"
#	on_page_button_pressed(tab_number)

func _on_Save_Page_Button_button_up() -> void:
	save_event_data()
#	save_all_db_files()


func _on_Copy_Page_Button_button_up() -> void:
	var new_page_dict :Dictionary = event_dict[tab_number].duplicate(true)
	var new_tab_number = str(event_dict.size())
	var new_data_dict = import_event_data(event_name, true)
	var new_data_row:Dictionary = new_data_dict["Row"][tab_number]
	event_dict[new_tab_number] = new_page_dict.duplicate(true)
	new_data_dict["Row"][new_tab_number] = new_data_row
	tab_number = new_tab_number
	event_dict["0"] = {"Display Name": event_name_label._get_input_value()}
	save_file(table_save_path + event_folder + event_name + table_file_format, event_dict)
	save_file(table_save_path + event_folder + event_name + table_info_file_format, new_data_dict)
	set_initial_values()


func add_new_event_page():
	var event_page_template = import_data("Event Table Template")
	var event_page_data_template = import_data("Event Table Template", true)["Row"]["1"]
	var data_dict = import_event_data(event_name, true)
	var new_tab_number: String = str(event_dict.size())
	print("NEW TAB NUMBER: ", new_tab_number)
	event_dict[new_tab_number] = event_page_template.duplicate(true)
	data_dict["Row"][new_tab_number] = event_page_data_template
	tab_number = new_tab_number
	event_dict["0"] = {"Display Name": event_name_label._get_input_value()}
	save_file(table_save_path + event_folder + event_name + table_file_format, event_dict)
	save_file(table_save_path + event_folder + event_name + table_info_file_format, data_dict)
	set_initial_values()


func show_event_selection_popup():
	var event_selection = popup_main.get_node("popup_Event_Selection")
	popup_main.visible = true
	event_selection.visible = true
	var event_list: Dictionary = get_list_of_events(true)
	event_selection.populate_events_dropdown(event_list)
	#populate 
	await event_selection_popup_closed


func _on_Create_New_Event_Button_button_up(change_event_name_in_node := true):
	event_name = "Event " + get_next_event_key()
	var new_table_dict = import_data("Event Table Template")
	var new_table_data_dict = import_data("Event Table Template",true)
	var text_dict:Dictionary = {"Display Name" :{"text" : event_name}}
	
	new_table_dict["0"] = text_dict
	save_file(table_save_path + event_folder + event_name + table_file_format, new_table_dict)
	save_file(table_save_path + event_folder + event_name +  table_info_file_format, new_table_data_dict)
	event_selection_popup.visible = false
	popup_main.visible = false
	emit_signal("event_selection_popup_closed")
	return event_name


func _on_event_selection_Accept_button_up() -> void:
	event_selection_popup.visible = false
	popup_main.visible = false
	event_name = event_selection_popup.get_eventID()
#	print("Selected Event Name: ", event_name)
	event_node.event_name = event_name
	emit_signal("event_selection_popup_closed")


func _on_event_selection_Cancel_button_up() -> void:
	event_selection_popup.visible = false
	popup_main.visible = false
	event_name = ""
	emit_signal("event_selection_popup_closed")
	_on_Button_button_up()
