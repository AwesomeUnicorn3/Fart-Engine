@tool
extends EventDisplayManager
#
#signal buttons_enabled
#signal table_buttons_created
#signal clear_buttons_complete
#signal reload_buttons_complete



@onready var btn_cancel = $VBox1/HBox1/Cancel

var field_dict1 = {}
#var field_dict2 = {}
#var field_dict3 = {}
var table_name = null
var is_event_ready_running:bool = false


func _ready():
#	event_editor_panel = $VBox1/HBox2/Scroll2/Panel1
	table_list_node = $VBox1/HBox2/Scroll1/Table_Buttons
	is_event_ready_running = false
#		print("EVENT MANAGER - READY - END")




func _on_visibility_changed():
	if visible:
		pass
#		popup_main = $Popups
#		if popup_main.visible:
#			hide_all_popups()
	else:
		pass
#		hide_all_popups()


func does_key_contain_invalid_characters(key):
	var value = false
	#loop through invalid characters and compare to item name, if any match, return error
	var array = [":", "/", "."]
	for i in array:
		if i in key:
			value = true
			print("'",i,"' is an invalid character. Please remove and try again")
			break
	return value


func clear_buttons():
	#Removes all item name buttons from table_list
	print("EVENT MANAGER - CLEAR BUTTONS - BEGIN")

	for i in table_list_node.get_children():
		#print("TABLE NAME: ", i)
#		table_list.remove_child(i)
		i.queue_free()
		await get_tree().process_frame
#	await get_tree().process_frame
#	clear_buttons_complete.emit()
#	emit_signal("clear_buttons_complete")
	print("EVENT MANAGER - CLEAR BUTTONS - END")


func has_empty_fields():
	#loop through input fields (need a better way to identify them and pull automatically instead of hard code)
	#if any of the fields are blank, return error
	var value = false
	#Iterate through input fields and verify that they values are not empty
	for i in field_dict1:
		#Remove blank spaces (so that you can't have an item name that is just spaces
		i = remove_special_char(i)
		if i == "":
			value = true
			print("ERROR! One or more fields are blank")
			break
	#return array of empty fields
	return value


func delete_event(delete_tbl_name):
	var dir :DirAccess = DirAccess.open(table_save_path)
	var file_delete = table_save_path + event_folder + delete_tbl_name + table_file_format
	dir.remove(file_delete)
	file_delete = table_save_path + event_folder + delete_tbl_name + table_info_file_format
	dir.remove(file_delete)


#func remove_special_char(text : String):
#	var array = [" "]
#	var result = text
#	for i in array:
#		result = result.replace(i, "")
#	return result


func input_node_changed(value):
	$VBox1/HBox1/Center1/Label.visible = true
#	input_changed = true


func _on_scroll_2_scroll_ended():
	print("SCROLL ENDED EVENT MANAGER")




func _on_refresh_events_button_up()-> void:
	#pass
	print("EVENT MANAGER - REFRESH BUTTON UP - BEGIN")
	clear_datachange_warning()
	reload_data_without_saving()
	print("EVENT MANAGER - REFRESH BUTTON UP - END")


func _on_Save_button_up():
	print("SAVE EVENT PAGE PRESSED")
	#save_event_data()


func reload_buttons():
#	print("EVENT MANAGER - RELOAD BUTTONS - BEGIN")
	if !is_button_reloading:
		is_button_reloading = true
#		print("EVENT MANAGER- RELAOD BUTTONS- CLEAR BUTTONS START")
		await clear_buttons()
		#print("CLEAR BUTTONS COMPLETE- WIAT COMTINUE")
#		while table_list.get_child_count() != 0:
#			await get_tree().process_frame
#		await clear_buttons_complete
#		print("EVENT MANAGER- RELAOD BUTTONS- CLEAR BUTTONS END")
		await create_table_buttons()

#		reload_buttons_complete.emit()
#		await get_tree().create_timer(2.5).timeout
		is_button_reloading = false
#	else: #REMOVE WHEN DONE TESTING
#		await get_tree().create_timer(5.0).timeout
#		is_button_reloading = false
	return true


func enable_all_buttons(value : bool = true):
	#Enables user to interact with all item buttons on table_list
	for i in table_list_node.get_children():
		i.disabled = !value
		i.reset_self_modulate()
#	await get_tree().process_frame
#	buttons_enabled.emit()


func refresh_data(item_name:String ):
	enable_all_buttons()

	var current_page = "1"
	await clear_event_table_display(event_name)

	#print("ITEM NAME: ", item_name)
	event_name = item_name
#	Table_Name = event_name
	current_page = tab_number
	current_event_editor_input.event_name = event_name
#	event_display_name = event_name
#	selected_event_ID = event_name

	var page_button_node = current_event_editor_input.get_node("VBoxContainer/Hbox4").get_node_or_null(current_page)
	if page_button_node != null:
		page_button_node.on_Button_button_up()
#		await get_tree().create_timer(0.1).timeout
#		current_event_editor_input.set_v_scroll(event_page_scroll_position)

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
#
#
func reload_data_without_saving():
#	print("EVENT MANAGER - RELOAD DATA NO SAVE - BEGIN")
	@warning_ignore("unused_variable")
	var reload:bool = await reload_buttons()
#	await get_tree().create_timer(0.25).timeout
#	print(selected_event_ID)
#	while table_list.get_node(selected_event_ID) == null:
#		await get_tree().process_frame

	$VBox1/HBox2/Scroll1/Table_Buttons.get_node(selected_event_ID)._on_Navigation_Button_button_up()
