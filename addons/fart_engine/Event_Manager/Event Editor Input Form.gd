@tool
extends DatabaseEngine

signal event_selection_popup_closed
signal event_editor_input_form_closed
signal event_editor_input_form_loaded
signal input_forms_cleared
signal match_fields_to_template_complete
signal page_button_load_complete

@onready var bottom_node := $VBoxContainer/VBoxContainer/Scroll1/VBox1/Bottom
@onready var top_a_node := $VBoxContainer/VBoxContainer/Scroll1/VBox1/Top/A
@onready var top_b_node := $VBoxContainer/VBoxContainer/Scroll1/VBox1/Top/B
@onready var top_c_node := $VBoxContainer/VBoxContainer/Scroll1/VBox1/Top/C
@onready var middle_a_node := $VBoxContainer/VBoxContainer/Scroll1/VBox1/Middle/A
@onready var middle_b_node := $VBoxContainer/VBoxContainer/Scroll1/VBox1/Middle/B
@onready var middle_c_node := $VBoxContainer/VBoxContainer/Scroll1/VBox1/Middle/C

@onready var event_name_label := $VBoxContainer/HBox3/Input_Text
@onready var popup_main := $Popups
@onready var event_selection_popup := $Popups/popup_Event_Selection
@onready var event_selection_dropdown_input := $Popups/popup_Event_Selection/PanelContainer/VBox1/HBox1/Existing_Events_Dropdown
@onready var event_page_button_list := $VBoxContainer/Hbox4

var parent_node
var default_event_dict: Dictionary = {}
var default_event_data_dict: Dictionary = {}
var event_dict :Dictionary 
var event_name :String = ""
var event_node :EventHandler
var tab_number :String = "1"
var initial_event_display_name :String = ""
var input_node_dict :Dictionary = {}
var selectedPageNode : Node
var event_data_dict:Dictionary
var v_scroll :int = 0
var scroll_position:int = 0

func _ready():
#	print("EVENT EDITOR INPUT FORM - READY - BEGIN")
	if event_name != "":
		set_initial_values()
	set_background_theme($Background)
#	print("EVENT EDITOR INPUT FORM - READY - END")


func match_fields_to_template():
#	print("EVENT EDITOR INPUT FORM - MATCH FIELDS TO TEMPLATE - BEGIN")
	if default_event_dict == {}:
		default_event_dict = import_data("Event Table Template")
	if default_event_data_dict == {}:
		default_event_data_dict = import_data("Event Table Template", true)
	for key in default_event_dict:
		for field in default_event_dict[key]:
				for tab in event_dict:
					if !event_dict[tab].has(field):
						event_dict[tab][field] = default_event_dict[key][field]
#	
	var remove_field_array = []
	for tab in event_dict:
		for field in event_dict[tab]:
			if !default_event_dict["1"].has(field):
				remove_field_array.append(field)
				await get_tree().process_frame

	if remove_field_array.size() != 0:
		for field in remove_field_array:
			for tab in event_dict:
				event_dict[tab].erase(field)
				await get_tree().process_frame
#	print("EVENT EDITOR INPUT FORM - MATCH FIELDS TO TEMPLATE - END")
	match_fields_to_template_complete.emit()


func load_event_data(event_tab := tab_number):
#	print("EVENT EDITOR INPUT FORM - LOAD EVENT DATA - BEGIN")
	tab_number = event_tab
	event_name_label.set_input_value(event_dict["0"]["Display Name"] )
	
	match_fields_to_template()
	await match_fields_to_template_complete
	
	for child in event_page_button_list.get_children():
		child.queue_free()
	load_page_buttons()
#	print("EVENT EDITOR INPUT FORM - LOAD EVENT DATA - END")


func load_page_buttons():
#	print("EVENT EDITOR INPUT FORM - LOAD PAGE BUTTONS - BEGIN")
	var page_button = preload("res://addons/fart_engine/Event_Manager/Event_Page_Button.tscn")
	var event_size : int = event_dict.size() - 1 #This is to account for the display name
	var selected_page_button
	
	for index in event_size:
		var index_text :String = str(index + 1)
		var new_button = page_button.instantiate()
		new_button.set_text("Page " + index_text)
		new_button.set_name(index_text)
		event_page_button_list.add_child(new_button)
		new_button.event_page_number = index_text
		if new_button.event_page_number == tab_number:
			selected_page_button = new_button
	selected_page_button.on_Button_button_up()
#	print("EVENT EDITOR INPUT FORM - LOAD PAGE BUTTONS - END")


#CALLED FROM SIGNAL
func animation_state_selected(show :bool):
	input_node_dict["Loop Animation"].visible = !show
	input_node_dict["Attack Player?"].visible = show
	input_node_dict["Animation Group"].visible = show
	input_node_dict["Max Speed"].visible = show
	input_node_dict["Acceleration"].visible = show
	input_node_dict["Friction"].visible = show


func does_cause_damage(show:bool):
	input_node_dict["Knockback Power"].visible = show
	input_node_dict["Damage Cooldown Time"].visible = show
	input_node_dict["Damage Amount"].visible = show


func animation_group_selected(selected_index):
	var group_name :String = input_node_dict["Animation Group"].get_selected_value(selected_index)
	var default_anim_node = input_node_dict["Default Animation"]
	var sprite_group_dict :Dictionary = import_data("Sprite Groups")
	var idle_anim_dict :Dictionary = {}
	for sprite_name in sprite_group_dict:
		if get_text(sprite_group_dict[sprite_name]["Display Name"]) == group_name:
			var current_group_dict :Dictionary = sprite_group_dict[sprite_name]
			idle_anim_dict = str_to_var(current_group_dict["Idle"])
	default_anim_node.set_input_value(idle_anim_dict)
	default_anim_node.get_data_and_create_sprite()


func on_page_button_pressed(event_page_number :String):
#	print("EVENT EDITOR INPUT FORM - PAGE BUTTON PRESSED - BEGIN - PAGE NUMBER: ", event_page_number)
	v_scroll = get_v_scroll()
	selectedPageNode = event_page_button_list.get_child(int(event_page_number) - 1)
	if event_page_number == "1":
		$VBoxContainer/HBox3/HBox1/Delete_Page_Button.disabled = true
	else:
		$VBoxContainer/HBox3/HBox1/Delete_Page_Button.disabled = false
	clear_all_input_forms()
	await get_tree().create_timer(.1)
	tab_number = event_page_number
	input_node_dict = {}
	if event_data_dict == {}:
		event_data_dict = import_event_data(event_name, true)
	load_event_page_inputs(event_page_number)
	for node_name in input_node_dict:
		input_node_dict[node_name].is_label_button = false
	if self.is_inside_tree():
		set_v_scroll(v_scroll)
#	print("EVENT EDITOR INPUT FORM - PAGE BUTTON PRESSED - END")



func load_event_page_inputs(event_tab):
	var display_category_dict: Dictionary = {
	"Notes" : top_a_node, 
	"Attack Player?" : middle_b_node,
	"Damage Player on Touch" :middle_b_node,
	"Damage Amount" :middle_b_node,
	"Knockback Power" :middle_b_node,
	"Damage Cooldown Time" :middle_b_node,
	"Event Trigger" :middle_a_node,
	"Does Event Move?" :middle_a_node,
	"Draw Shadow?" :middle_c_node,
	"Animation Group" :middle_a_node,
	"Conditions" :top_b_node,
	"Default Animation" :middle_c_node,
	"Loop Animation" :middle_c_node,
	"Collide with Player?" :middle_b_node,
	"Max Speed" :middle_b_node,
	"Acceleration" :middle_b_node,
	"Friction" :middle_b_node,
	"Commands" :middle_a_node
	}
	for index in default_event_data_dict["Column"]:
		var field_name: String = default_event_data_dict["Column"][index]["FieldName"]
		var input_value = event_dict[event_tab][field_name]
		var this_container
		var parent_container = display_category_dict[field_name]
		this_container = create_input_node(field_name, event_name, default_event_dict, default_event_data_dict)
		parent_container.add_child(this_container)
		input_node_dict[field_name] = this_container
		this_container.parent_node = self
		if field_name == "Event Trigger":
			input_node_dict["Event Trigger"].selection_table_name = "Event Triggers"
			input_node_dict["Event Trigger"].populate_list(true)
		this_container.set_input_value(input_value)

	

	input_node_dict["Does Event Move?"].checkbox_pressed.connect(animation_state_selected)
	input_node_dict["Does Event Move?"]._on_input_toggled(input_node_dict["Does Event Move?"].inputNode.button_pressed)

	input_node_dict["Damage Player on Touch"].checkbox_pressed.connect(does_cause_damage)
	input_node_dict["Damage Player on Touch"]._on_input_toggled(input_node_dict["Damage Player on Touch"].inputNode.button_pressed)
	#REMOVE WHEN THE OPTIONS ARE WORKING AGAIN
	input_node_dict["Does Event Move?"].visible = false
	
	


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
	event_node.event_name = event_name
	update_editor()
	



func set_table_data_display_name_from_dbmanager(event_key :String , displayName :String):
	var tableData_dict :Dictionary = import_data("Table Data")
	for tableName in tableData_dict:
		var tableName_dict :Dictionary = str_to_var(tableData_dict[tableName]["Display Name"])
		var tblDisplayName :String = get_text(tableName_dict)
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
	event_data_dict = import_event_data(event_name, true)
	event_dict = import_event_data(event_name)
	load_event_data(tabNumber)



#func load_event_from_dbmanager():
#	set_initial_values()


func load_event(EventName:String) -> void:
	event_name = EventName
	get_node("VBoxContainer/VBoxContainer/Scroll1/VBox1/HBox2").visible = true
	set_name("EventInputForm")
	set_initial_values()


func _on_Button_button_up() -> void: #close form - event node
	emit_signal("event_editor_input_form_closed")


func close_event_input_form_in_dbmanager():
	queue_free()


func _on_Save_Close_Button_button_up() -> void:
	save_event_data()
	var udsplugin = await get_AU3ENGINE_main_scene()
	udsplugin._ready()
	call_deferred("_on_Button_button_up")

var event_data_is_saving:bool = false
func save_event_data():
#	print("EVENT EDITOR INPUT FORM - SAVE EVENT DATA - BEGIN")
	if !event_data_is_saving:
		event_data_is_saving = true
		v_scroll = get_v_scroll()
		var this_event_dict:Dictionary = {}
		event_dict["0"] = {"Display Name": event_name_label._get_input_value()}
		
		for child in input_node_dict:
			var node = input_node_dict[child]
	#		print(child)
			this_event_dict[node.labelNode.get_text()] =  node.get_input_value()
		event_dict[tab_number] = this_event_dict
		
		save_file(table_save_path + event_folder + event_name + table_file_format, event_dict)
	#	selectedPageNode = event_page_button_list.get_child(int(tab_number) - 1)
	#	selectedPageNode.on_Button_button_up()
		var eventNode = get_node("../../../../..")
		if eventNode.has_method("clear_datachange_warning"): eventNode.clear_datachange_warning()
		await get_tree().process_frame
		event_data_is_saving = false
#	print("EVENT EDITOR INPUT FORM - SAVE EVENT DATA - BEGIN")
	return event_name


func clear_all_input_forms():
#	print("EVENT EDITOR INPUT FORM - CLEAR ALL INPUT FORMS - BEGIN")
	for child in input_node_dict:
		var node = input_node_dict[child]
		if is_instance_valid(node):
			node.get_parent().remove_child(node)
			node.queue_free()
#	await get_tree().create_timer(0.1).timeout
	
	input_forms_cleared.emit()
#	print("EVENT EDITOR INPUT FORM - CLEAR ALL INPUT FORMS - END")
#		await get_tree().process_frame
#	await get_tree().process_frame





func enable_all_page_buttons():
	for child in event_page_button_list.get_children():
		child.set_disabled(false)
#		child.release_focus()


func input_node_changed(value):
	var eventNode = get_node("../../../../..")
	if eventNode.has_method("input_node_changed"): eventNode.input_node_changed(value)


func _on_Delete_Page_Button_button_up() -> void:

	event_dict.erase(tab_number)
#	print("EVENT DICT SIZZE: ", event_dict.size())

	for index in event_dict.size() - 1:
		index += 1
#		print(index)
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
#	print("NEW TAB NUMBER: ", new_tab_number)
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

func set_v_scroll(scroll_pos: int):
	$VBoxContainer/VBoxContainer/Scroll1.set_v_scroll(scroll_pos)
	scroll_position = scroll_pos

func get_v_scroll():
	scroll_position = $VBoxContainer/VBoxContainer/Scroll1.get_v_scroll()
	return scroll_position
#func _process(delta):
#	scroll_position = $Scroll1.scroll_vertical
#	print(scroll_position)
