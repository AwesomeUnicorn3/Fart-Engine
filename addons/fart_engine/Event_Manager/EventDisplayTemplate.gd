@tool
extends EventDisplayManager
#signal event_selection_popup_closed
#signal event_editor_input_form_closed
#signal event_editor_input_form_loaded
#signal input_forms_cleared
#signal match_fields_to_template_complete
#signal page_button_load_complete

#@onready var btn_cancel = $VBox1/HBox1/Cancel
#@onready var popup_newField = $Popups/popup_newValue
#@onready var event_editor_panel := $VBox1/HBox2/Scroll2/Panel1


@onready var bottom_node := $VBoxContainer/VBoxContainer/Scroll1/VBox1/Bottom
@onready var top_a_node := $VBoxContainer/VBoxContainer/Scroll1/VBox1/Top/A
@onready var top_b_node := $VBoxContainer/VBoxContainer/Scroll1/VBox1/Top/B
@onready var top_c_node := $VBoxContainer/VBoxContainer/Scroll1/VBox1/Top/C
@onready var middle_a_node := $VBoxContainer/VBoxContainer/Scroll1/VBox1/Middle/A
@onready var middle_b_node := $VBoxContainer/VBoxContainer/Scroll1/VBox1/Middle/B
@onready var middle_c_node := $VBoxContainer/VBoxContainer/Scroll1/VBox1/Middle/C

@onready var event_name_label := $VBoxContainer/HBox3/Input_Text
#@onready var popup_main := $Popups
#@onready var event_selection_popup := $Popups/popup_Event_Selection
#@onready var event_selection_dropdown_input := $Popups/popup_Event_Selection/PanelContainer/VBox1/HBox1/Existing_Events_Dropdown
@onready var event_page_button_list := $VBoxContainer/Hbox4



#var parent_node
var default_event_dict: Dictionary = {}
var default_event_data_dict: Dictionary = {}
var event_dict :Dictionary 
#var current_event_editor_input = null
#var event_name :String = ""
#var event_node :EventHandler
#var tab_number :String = "1"
var initial_event_display_name :String = ""
var input_node_dict :Dictionary = {}
var selectedPageNode : Node
var event_data_dict:Dictionary
var v_scroll :int = 0
var scroll_position:int = 0
#var event_display_name :String = ""
var popup_deleteConfirm
var popup_deleteKey
var datatype
#var event_name:String
var currentData_dict:Dictionary
var current_dict: Dictionary
var table_name:String
var table_ref
var current_table_ref
#var is_button_reloading: bool = false
#var btn_itemselect
var is_event_ready_running:bool = false
#var table_list
#var event_page_scroll_position


func _ready():
	#able_Name = event_name
	print("EVENT EDITOR INPUT FORM - EVENT NAME: ", event_name)
	if event_name != "":
		set_initial_values(event_name)
#	event_editor_panel = $VBox1/HBox2/Scroll2/Panel1
	set_background_theme($Background)
	is_event_ready_running = true
	await reload_buttons()
#	parent_node = get_node("..")
#	table_list = parent_node.table_list_node
	event_page_scroll_position = Event_Page_Scroll_Position
	is_event_ready_running = false
	#table_list_node.get_child(0)._on_Navigation_Button_button_up()
#	print("EVENT EDITOR INPUT FORM - READY - END")

#func refresh_data(item_name:String = Item_Name):
#
#	enable_all_buttons()
#
#	var current_page = "1"
#
#	if current_event_editor_input != null:
#		event_page_scroll_position = current_event_editor_input.scroll_position
#		current_page = current_event_editor_input.tab_number
#
#		current_event_editor_input.queue_free()
##		current_event_editor_input = null
##
#	current_event_editor_input = event_editor_input_form.instantiate()
#	current_event_editor_input.event_name = event_name
#	event_editor_panel.add_child(current_event_editor_input)
##
#	event_display_name = event_name
#	selected_event_ID = event_name
#
#	var page_button_node = current_event_editor_input.get_node("VBoxContainer/Hbox4").get_node_or_null(current_page)
#	if page_button_node != null:
#		page_button_node.on_Button_button_up()
#		await get_tree().create_timer(0.1).timeout
#		current_event_editor_input.set_v_scroll(event_page_scroll_position)



func show_control_buttons():
	if table_name == "Controls":
		$VBox1/HBox2/Panel1/VBox1/HBox2/AddField.visible = false
		$VBox1/HBox2/Panel1/VBox1/HBox2/DeleteField.visible = false
	else:
		$VBox1/HBox2/Panel1/VBox1/HBox2/AddField.visible = true
		$VBox1/HBox2/Panel1/VBox1/HBox2/DeleteField.visible = true


func set_table_dict():
	var tbl_ref_dict = all_tables_merged_dict["10000"]
	table_ref = tbl_ref_dict[table_name]["Display Name"]
	current_table_ref = table_ref
	return table_ref


#func _on_RefreshData_button_up() -> void:
##	print("EVENT MANAGER - REFRESH BUTTON UP - BEGIN")
#	clear_datachange_warning()
#	reload_data_without_saving()
##	print("EVENT MANAGER - REFRESH BUTTON UP - END")


func reload_buttons():
#	print("EVENT MANAGER - RELOAD BUTTONS - BEGIN")
	if !is_button_reloading:
		is_button_reloading = true
#		print("EVENT MANAGER- RELAOD BUTTONS- CLEAR BUTTONS START")
		await clear_buttons()
		print("CLEAR BUTTONS COMPLETE- WIAT COMTINUE")
#		print("EVENT MANAGER- RELAOD BUTTONS- CLEAR BUTTONS END")
		await create_table_buttons()
#		reload_buttons_complete.emit()
#		await get_tree().create_timer(2.5).timeout
		is_button_reloading = false

	return true

func create_table_buttons():
#Loop through the item_list dictionary and add a button for each item
#	print("EVENT MANAGER - CREATE TABLE BUTTONS - BEGIN")
	@warning_ignore("static_called_on_instance")
	var event_list_dict :Dictionary = await get_list_of_events()

	for Event_Name in event_list_dict:
#		print("EVENT NAME: ", Event_Name)
		@warning_ignore("static_called_on_instance")
		var event_dict:Dictionary = import_event_data(Event_Name)
		@warning_ignore("static_called_on_instance", "shadowed_variable")
		var event_display_name:String =  get_value_as_text(event_dict["0"]["Display Name"])
		var label :String = event_display_name

		var newbtn: TextureButton = btn_itemselect.instantiate() #Create new instance of item button
		newbtn.main_page = self
		newbtn.add_to_group("Key")
		table_list_node.add_child(newbtn) #Add new item button to table_list
		#Use the row_dict key (item_number) to set the button label as the item name
		newbtn.set_name(Event_Name) #Set the name of the new button as the item name
#		newbtn.main_page = self
#		var labelNode :Label = newbtn.get_node("Label")
		newbtn.set_label_text(Event_Name, label, true)

func clear_buttons():
	#Removes all item name buttons from table_list
#	print("EVENT MANAGER - CLEAR BUTTONS - BEGIN")
	for i in table_list_node.get_children():
		print("TABLE NAME: ", i)
#		table_list.remove_child(i)
		i.queue_free()
	while table_list_node.get_child_count() != 0:
		print("CHILD COUNT IN TABLE LIST NODE IS EMPTY")
		await get_tree().process_frame
#	await get_tree().process_frame
#	clear_buttons_complete.emit()
#	emit_signal("clear_buttons_complete")
	print("EVENT MANAGER - CLEAR BUTTONS - END")


#func clear_datachange_warning():
#	$VBox1/HBox1/Center1/Label.visible = false
#	input_changed = false


func add_entry_row(entry_value):
	var item_name_dict = currentData_dict[KEY]
	var item_name_dict_size = item_name_dict.size()
	currentData_dict[KEY][str(item_name_dict_size)] = entry_value


func add_table_key(key):
	var new_entry = current_dict["Default"].duplicate(true)
	current_dict[key] = new_entry


func is_data_updated():
	var is_updated := false
	var old_data_dict :Dictionary = currentData_dict.duplicate(true)
#	reset_dictionaries(table_name)
#	for i in current_dict:
#		if !old_data_dict.keys().has(i):
#			is_updated = true
#			break
	return is_updated


var delete_field_name = ""
func _on_Itemlist_item_selected(index):
	delete_field_name = currentData_dict[datatype][str(index + 1)]["FieldName"]

func _on_DeleteField_Cancel_button_up():
	PopupManager.hide_all_popups()
#	popup_main.visible = false
#	popup_deleteKey.visible = false

func display_options():
	var values_in_order_dict = {}
	var dlg_keySelect = $Popups/popup_deleteKey/PanelContainer/VBoxContainer/Itemlist
	dlg_keySelect.clear()
	datatype = FIELD
	for n in currentData_dict[datatype].size(): #Arrange row dict values by order number
		var t = n + 1
		values_in_order_dict[n + 1] =  currentData_dict[datatype][str(t)]["FieldName"]

	for n in values_in_order_dict: #Add values to options menu
		var t = values_in_order_dict[n]
		dlg_keySelect.add_item (t,null,true )
	PopupManager.show_popup("DeleteKeyConfirm", values_in_order_dict)
#	popup_main.visible = true
#	popup_deleteKey.visible = true

func _on_AddField_button_up():
	PopupManager.show_popup("NewValue", [event_dict])
#	popup_main.visible = true
#	$Popups/popup_newValue.visible = true

func _on_NewField_Cancel_button_up():
	PopupManager.hide_all_popups()
#	popup_main.visible = false
#	$Popups/popup_newValue.visible = false


func _on_DeleteSelectedItem_button_up():
	var popup_label = $Popups/popup_delete_confirm/PanelContainer/VBoxContainer/Label/HBox1/Label_Button
	#var popup_label2 = $Popups/popup_delete_confirm/PanelContainer/VBoxContainer/Label2
	var lbl_text : String = popup_label.get_text()
	lbl_text = lbl_text.replace("%", event_display_name.to_upper())
	popup_label.set_text(lbl_text)
	PopupManager.show_popup("DeleteConfirm", []) #Need event version of Key dict
#	popup_main.visible = true
#	popup_deleteConfirm.visible = true

func _on_AddNewItem_button_up():
	#input default item values to form
	event_display_name = await current_event_editor_input._on_Create_New_Event_Button_button_up(false)
	#reload_buttons()

#	get_main_node()._ready()
	await get_tree().process_frame
	parent_node.reload_buttons()
	await get_tree().process_frame
	parent_node.table_list_node.get_node(event_display_name)._on_Navigation_Button_button_up()


func delete_selected_item():
	parent_node.delete_event(current_event_editor_input.event_name)
#	get_main_node()._ready()
	parent_node.reload_buttons()
	parent_node.table_list_node.get_child(0)._on_Navigation_Button_button_up()


func _on_deletePopup_Accept_button_up():
	delete_selected_item()
	_on__deletePopup_Cancel_button_up()


func _on__deletePopup_Cancel_button_up():
#	popup_main.visible = false
#	popup_deleteConfirm.visible = false
	PopupManager.show_popup("DeleteConfirm", [])


var is_saving:bool = false
func _on_save_event_button_up():
#	print("EVENT MANAGER - SAVE BUTTON UP - BEGIN")
	if !is_saving:
		is_saving = true
		event_display_name = await current_event_editor_input.save_event_data()
		is_saving = false
		update_all_event_list(true)
#		EditorManager.new().when_editor_saved(self)
#		print("EVENT SAVE SUCCESSFULL")
#	print("EVENT MANAGER - SAVE BUTTON UP - END")

func _on_FileDialog_hide() -> void:
	hide_all_popups()


func _on_FileDialog_sprite_hide() -> void:
	hide_all_popups()


#func refresh_data():
##	print("EVENT MANAGER - REFRESH DATA - BEGIN")
#	parent_node.enable_all_buttons()
##	await buttons_enabled
#	var current_page = "1"
#	if current_event_editor_input != null:
#		event_page_scroll_position = current_event_editor_input.scroll_position
#		current_page = current_event_editor_input.tab_number
##		event_editor_panel.remove_child(current_event_editor_input)
#
#		current_event_editor_input.queue_free()
#		current_event_editor_input = null
#
#	current_event_editor_input = parent_node.event_editor_input_form.instantiate()
#	current_event_editor_input.event_name = event_name
#	event_editor_panel.add_child(current_event_editor_input)
##	print("START WIATING")
#
##	await current_event_editor_input.event_editor_input_form_loaded
##	print("END WIATING")
#	event_display_name = event_name
#	EventDisplayManager.selected_event_ID = event_name
#
##	await get_tree().create_timer(0.5).timeout
#	var page_button_node = current_event_editor_input.get_node("VBoxContainer/Hbox4").get_node_or_null(current_page)
#	if page_button_node != null:
#		page_button_node.on_Button_button_up()
#		await get_tree().create_timer(0.1).timeout
#		current_event_editor_input.set_v_scroll(event_page_scroll_position)
##	print("EVENT MANAGER - REFRESH DATA - END")
##		current_event_editor_input.set_v_scroll(event_page_scroll_position)



func match_fields_to_template(event_dict:Dictionary):
#	print("EVENT EDITOR INPUT FORM - MATCH FIELDS TO TEMPLATE - BEGIN")
	if default_event_dict == {}:
		default_event_dict = all_tables_merged_dict["10023"]
	if default_event_data_dict == {}:
		default_event_data_dict = all_tables_merged_data_dict["10023"]
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
#	match_fields_to_template_complete.emit()


func load_event_data(tab_number:String):
##	print("EVENT EDITOR INPUT FORM - LOAD EVENT DATA - BEGIN")
	event_name_label.set_input_value(event_dict["0"]["Display Name"] )

	match_fields_to_template(event_dict)
#	await match_fields_to_template_complete

	for child in event_page_button_list.get_children():
		child.queue_free()
	load_page_buttons()
##	print("EVENT EDITOR INPUT FORM - LOAD EVENT DATA - END")


func load_page_buttons():
##	print("EVENT EDITOR INPUT FORM - LOAD PAGE BUTTONS - BEGIN")	
	print("LOAD PAGE BUTTONS BEGIN")
	var page_button := preload("res://addons/fart_engine/Event_Manager/Event_Page_Button.tscn")
	var event_size : int = event_dict.size() - 1 #This is to account for the display name
	var selected_page_button

	for index in event_size:
		var index_text :String = str(index + 1)
		var new_button = page_button.instantiate()
		new_button.set_label("Page " + index_text)
		new_button.set_name(index_text)
		event_page_button_list.add_child(new_button)
		new_button.event_page_number = index_text
		if new_button.event_page_number == tab_number:
			selected_page_button = new_button
	selected_page_button.on_Button_button_up()
##	print("EVENT EDITOR INPUT FORM - LOAD PAGE BUTTONS - END")
	print("LOAD PAGE BUTTONS END")

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


func can_be_pushed(show:bool):
	input_node_dict["Being Pushed Speed"].visible = show
	input_node_dict["Friction"].visible = show


func animation_group_selected(selected_index):
	var group_name :String = input_node_dict["Animation Group"].get_selected_value(selected_index)
	var default_anim_node = input_node_dict["Default Animation"]
	var sprite_group_dict :Dictionary = all_tables_merged_dict["10040"]
	var idle_anim_dict :Dictionary = {}
	for sprite_name in sprite_group_dict:
		if get_value_as_text(sprite_group_dict[sprite_name]["Display Name"]) == group_name:
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
	"Damage Amount" :middle_c_node,
	"Knockback Power" :middle_c_node,
	"Damage Cooldown Time" :middle_c_node,
	"Event Trigger" :middle_a_node,
	"Does Event Move?" :middle_a_node,
	"Draw Shadow?" :middle_b_node,
	"Animation Group" :middle_a_node,
	"Conditions" :middle_a_node,
	"Default Animation" :bottom_node,
	"Loop Animation" :middle_b_node,
	"Collide with Player?" :middle_b_node,
	"Max Speed" :middle_b_node,
	"Acceleration" :middle_b_node,
	"Friction" :middle_c_node,
	"Commands" :middle_a_node,
	"Can Be Pushed" :middle_b_node,
	"Being Pushed Speed": middle_c_node
	}
	
	
	for index in default_event_data_dict[FIELD]:
		var field_name: String = default_event_data_dict[FIELD][index]["FieldName"]
		var input_value = event_dict[event_tab][field_name]
		var new_input_node
		var parent_container = display_category_dict[field_name]
		new_input_node = await create_input_node_custom_dict(index, event_name, default_event_dict, default_event_data_dict)
#		this_container.parent_node = self
		parent_container.add_child(new_input_node)
		input_node_dict[field_name] = new_input_node
#		this_container.parent_node = self
		if field_name == "Event Trigger":
			input_node_dict["Event Trigger"].selection_table_name = "10024"
			input_node_dict["Event Trigger"].populate_list(true)
		new_input_node.set_input_value(input_value)
		new_input_node.show_field = true

	input_node_dict["Can Be Pushed"].checkbox_pressed.connect(can_be_pushed)
	input_node_dict["Can Be Pushed"]._on_input_toggled(input_node_dict["Can Be Pushed"].inputNode.button_pressed)


	input_node_dict["Does Event Move?"].checkbox_pressed.connect(animation_state_selected)
	input_node_dict["Does Event Move?"]._on_input_toggled(input_node_dict["Does Event Move?"].inputNode.button_pressed)

	input_node_dict["Damage Player on Touch"].checkbox_pressed.connect(does_cause_damage)
	input_node_dict["Damage Player on Touch"]._on_input_toggled(input_node_dict["Damage Player on Touch"].inputNode.button_pressed)
	#REMOVE WHEN THE OPTIONS ARE WORKING AGAIN
	input_node_dict["Does Event Move?"].visible = false
	
	


func set_table_data_display_name(event_key :String , displayName :String):
	var display_name :String
	var table_list :Dictionary = all_tables_merged_dict["10000"]
	for tableName in table_list:
		if tableName == event_key:
			table_list[tableName]["Display Name"] = displayName
			break
		elif table_list[tableName]["Display Name"] == event_key:
			table_list[tableName]["Display Name"] = displayName
			break
	
	save_file(table_save_path + "10000" + table_file_format, table_list)
	event_node.event_name = event_name
	update_editor()
	



func set_table_data_display_name_from_dbmanager(event_key :String , displayName :String):
	var tableData_dict :Dictionary = all_tables_merged_data_dict["10000"]
	for tableName in tableData_dict:
		var tableName_dict :Dictionary = str_to_var(tableData_dict[tableName]["Display Name"])
		var tblDisplayName :String = get_value_as_text(tableName_dict)
		if tableName == event_key:
			tableData_dict[tableName]["Display Name"] = var_to_str({"text" : displayName})
	save_file(table_save_path + "10000" + table_file_format, tableData_dict)
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
	var event_list:Dictionary = await get_list_of_events()

	if event_list == {}:
		next_key = "1"
	else: 
		next_key = event_list.size + 100
#	else:
#		var event_number
#		var event_number_array := []
#		for displayName in event_list:
#			var event_array = displayName.rsplit(" ")
#			event_number = event_array[1]
#			event_number_array.append(event_number)
#		var event_size = event_number_array.size() + 2
#		for index in range(1,event_size):
#			if !event_number_array.has(str(index)):
#				next_key = str(index)
#				break

	return next_key





func set_initial_values(tabNumber :String):
#	table_name = event_name
	event_data_dict = import_event_data(event_name, true)
	event_dict = import_event_data(event_name)
	load_event_data(tabNumber)



#func load_event_from_dbmanager():
#	set_initial_values()


func load_event(EventName:String) -> void:
	event_name = EventName
	get_node("VBoxContainer/VBoxContainer/Scroll1/VBox1/HBox2").visible = true
	set_name("EventInputForm")
	set_initial_values(tab_number)
	


func _on_Button_button_up() -> void: #close form - event node
	emit_signal("event_editor_input_form_closed")


func close_event_input_form_in_dbmanager():
	queue_free()


func _on_Save_Close_Button_button_up() -> void:
	await save_event_data()
	fart_root._ready()

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
	update_all_event_list(true)
	return event_name


func clear_all_input_forms():
#	print("EVENT EDITOR INPUT FORM - CLEAR ALL INPUT FORMS - BEGIN")
	for child in input_node_dict:
		var node = input_node_dict[child]
		if is_instance_valid(node):
			node.get_parent().remove_child(node)
			node.queue_free()
#	await get_tree().create_timer(0.1).timeout
	
#	input_forms_cleared.emit()
#	print("EVENT EDITOR INPUT FORM - CLEAR ALL INPUT FORMS - END")
#		await get_tree().process_frame
#	await get_tree().process_frame





#func enable_all_page_buttons():
#	for child in event_page_button_list.get_children():
#		child.set_disabled(false)
##		child.release_focus()


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
	data_dict[KEY].erase(str(data_dict[KEY].size()))
	
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
	var new_data_row:Dictionary = new_data_dict[KEY][tab_number]
	event_dict[new_tab_number] = new_page_dict.duplicate(true)
	new_data_dict[KEY][new_tab_number] = new_data_row
	tab_number = new_tab_number
	event_dict["0"] = {"Display Name": event_name_label._get_input_value()}
	save_file(table_save_path + event_folder + event_name + table_file_format, event_dict)
	save_file(table_save_path + event_folder + event_name + table_info_file_format, new_data_dict)
	set_initial_values(tab_number)


func add_new_event_page():
	var event_page_template = all_tables_merged_dict["10023"]
	var event_page_data_template = all_tables_merged_data_dict["10023"][KEY]["1"]
	var data_dict = import_event_data(event_name, true)
	var new_tab_number: String = str(event_dict.size())
#	print("NEW TAB NUMBER: ", new_tab_number)
	event_dict[new_tab_number] = event_page_template.duplicate(true)
	data_dict[KEY][new_tab_number] = event_page_data_template
	tab_number = new_tab_number
	event_dict["0"] = {"Display Name": event_name_label._get_input_value()}
	save_file(table_save_path + event_folder + event_name + table_file_format, event_dict)
	save_file(table_save_path + event_folder + event_name + table_info_file_format, data_dict)
	set_initial_values(tab_number)


func show_event_selection_popup():
	var event_selection = PopupManager.get_popup("EventSelection").get_node("popup_Event_Selection")
#	popup_main.visible = true
#	event_selection.visible = true
	var event_list: Dictionary = await get_list_of_events()
	event_selection.populate_events_dropdown(event_list)
	#populate 
#	await event_selection_popup_closed

func _on_event_selection_Accept_button_up() -> void:
	PopupManager.hide_all_popups()
#	event_selection_popup.visible = false
#	popup_main.visible = false
	event_name = PopupManager.get_popup("EventSelection").get_eventID()
#	print("Selected Event Name: ", event_name)
	event_node.event_name = event_name
	emit_signal("event_selection_popup_closed")


func _on_event_selection_Cancel_button_up() -> void:
	PopupManager.hide_all_popups()
#	event_selection_popup.visible = false
#	popup_main.visible = false
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


func get_values_dict(req = false):
	var custom_dict = {}
	var currentDict_inOrder = {}
	for i in currentData_dict[FIELD].size():
		i = str(i + 1)
		currentDict_inOrder[i] = currentData_dict[FIELD][i]

	for i in currentDict_inOrder:
		var value_name = currentData_dict[FIELD][i]["FieldName"]
		var itemType = currentData_dict[FIELD][i]["DataType"]
		var tableRef = currentData_dict[FIELD][i]["TableRef"]
		var required  = convert_string_to_type(currentData_dict[FIELD][i]["RequiredValue"])
		var showValue  = convert_string_to_type(currentData_dict[FIELD][i]["ShowValue"])
		
		
			#THIS IS WHERE ALL VALUES SHO8LD BE SET TO DATATYPE DEFAULTS
			#DOING THIS WILL ALLOW ME TO DELETE ALL OF THE "DEFAULT" TABLES
		var item_value
		if event_name == "Default":
			item_value = get_default_value(itemType)
		else:

			item_value = current_dict[event_name][value_name]
		if required == req:# and showValue:
			custom_dict[value_name] = {"Value" : item_value, "DataType" : itemType, "TableRef" : tableRef, "Order" : i}

	return custom_dict


func _on_NewField_Accept_button_up():
	add_newField()
	_on_NewField_Cancel_button_up()


func _on_DeleteField_Accept_button_up(): #ADD DELETE EVENT TO EDITORMANAGER
#	Delete_Key(delete_field_name)
#	TableDisplayTemplate.new().save_all_db_files(table_name)
#	refresh_data(event_name)
	_on_DeleteField_Cancel_button_up()


#func _on_DeleteField_Cancel_button_up():
#	popup_main.visible = false
#	popup_deleteKey.visible = false
#
#func _on_NewField_Cancel_button_up():
#	popup_main.visible = false
#	$Popups/popup_newValue.visible = false

func add_newField(): 
	var datafield = $Popups/popup_newValue/PanelContainer/VBox1/HBox1/VBox2/ItemType_Selection
	var fieldName = $Popups/popup_newValue/PanelContainer/VBox1/HBox1/VBox1/Input_Text/Input_Node/Input.get_text()
	var selected_item_name = datafield.selectedItemName
	var datatype = datafield.get_dataType_ID(selected_item_name)
	var showField = $Popups/popup_newValue/PanelContainer/VBox1/HBox1/VBox3/LineEdit3.is_pressed()
	var required = $Popups/popup_newValue/PanelContainer/VBox1/HBox1/VBox4/LineEdit3.is_pressed()
	var tableName = $Popups/popup_newValue/PanelContainer/VBox1/HBox1/Table_Selection.selectedItemName

#	await add_field(event_name, fieldName, event_dict, false)
	#add_field(fieldName, datatype, showField, false, tableName)
#	refresh_data(Table_Name)




func navigation_button_click(key_name:String, button_node):
	print("KEY NAME: ", key_name)
	refresh_data(event_name)
	set_initial_values(tab_number)
#	await get_tree().create_timer(0.5).timeout
#	print(button_node.get_groups())
	selected_event_ID = key_name
	#$VBox1/HBox2/Scroll1/Table_Buttons.get_node(selected_event_ID)._on_Navigation_Button_button_up()
	button_node.reset_self_modulate()


func _on_Create_New_Event_Button_button_up(change_event_name_in_node := true):
	event_name = "Event " + await get_next_event_key()
	var new_table_dict = all_tables_merged_dict["10023"]
	var new_table_data_dict = all_tables_merged_data_dict["10023"]
	var text_dict:Dictionary = {"Display Name" :{"text" : event_name}}
	
	new_table_dict["0"] = text_dict
	save_file(table_save_path + event_folder + event_name + table_file_format, new_table_dict)
	save_file(table_save_path + event_folder + event_name +  table_info_file_format, new_table_data_dict)
	PopupManager.hide_all_popups()
#	event_selection_popup.visible = false
#	popup_main.visible = false
	emit_signal("event_selection_popup_closed")
	return event_name


func hide_all_popups():
	PopupManager.hide_all_popups()
