@tool
extends DatabaseEngine

@onready var Navigation_Button: PackedScene = preload("res://addons/fart_engine/Database_Manager/Scenes and Scripts/UI_Navigation_Scenes/Navigation_Button.tscn")
#@onready var tableButton = preload("res://addons/fart_engine/SaveFile_Manager/Navigation_Button_table.tscn")
#@onready var keyButton = preload("res://addons/fart_engine/SaveFile_Manager/Navigation_Button_Key.tscn")

@onready var value_input = preload("res://addons/fart_engine/Database_Manager/Scenes and Scripts/UI_Input_Scenes/Input_Text.tscn")

@onready var fileContainer = $Main_VBox/Display_HBox/File_Scroll/VBox1
@onready var tableContainer = $Main_VBox/Display_HBox/Table_Scroll/VBox1
@onready var keyContainer = $Main_VBox/Display_HBox/Key_Scroll/VBox1
@onready var eventContainer = $Main_VBox/Display_HBox/Key_Scroll_Event/VBox1
@onready var valueContainer = $Main_VBox/Display_HBox/Field_Scroll/VBox1


var saveFile = {} #Current working dictionary
var FileSelected
var TableSelected
var KeySelected
var ValueSelected
var EventSelected
var input_changed = false


func _ready() -> void:
	var files = list_files_with_param(save_game_path, save_format)
	var save_name
	clear_single_container(fileContainer)
	clear_single_container(tableContainer)
	clear_single_container(keyContainer)
	clear_single_container(valueContainer)
	clear_single_container(eventContainer)
	_input_node_changed(false)
	for i in files:
		i = str(i).trim_suffix(save_format)
		create_button(i , fileContainer, Navigation_Button, "File_Button")
		save_name = str(i)


func navigation_button_up(button: TextureButton):
#	print("NAVIGATION BUTTON UP", button.text)
	
	if button.is_in_group("File_Button"):
		_on_file_button_up(button.text)
		
	elif button.is_in_group("Table_Button"):
		_on_table_button_up(button.text)
		
	elif button.is_in_group("Key_Button"):
		_on_key_button_up(button.text)
		
	elif button.is_in_group("Event_Button"):
		_on_event_button_up(button.text)
	
	button.disabled = true
	button.reset_self_modulate()
#	elif button.is_in_group("Field"):
#		pass

	

func _on_file_button_up(saveName):
	var fileLocation = saveName + save_format
	clear_single_container(tableContainer)
	clear_single_container(keyContainer)
	clear_single_container(valueContainer)
	clear_single_container(eventContainer)
	FileSelected = saveName
	$Main_VBox/Header_Button_HBox/DeleteFile.disabled = false
	saveFile = load_save_file(fileLocation)
	set_saveFile_data("table")
	_input_node_changed(false)
	enable_buttons(fileContainer)


func _on_table_button_up(Name):
	clear_single_container(keyContainer)
	clear_single_container(valueContainer)
	clear_single_container(eventContainer)
	TableSelected = Name
	set_saveFile_data("key")
	_input_node_changed(false)
	enable_buttons(tableContainer)


func _on_key_button_up(Name):
	clear_single_container(valueContainer)
	clear_single_container(eventContainer)
	KeySelected = Name
	set_saveFile_data("value")
#	_input_node_changed()
	enable_buttons(keyContainer)

func _on_event_button_up(Name):
	clear_single_container(valueContainer)
	EventSelected = Name
	set_saveFile_data("event")
#	_input_node_changed()
	enable_buttons(eventContainer)


func set_saveFile_data(get_value: String):
#	get_tree().create_timer(.2).timeout
	match get_value:
		"table":
			for i in saveFile:# i = Table Name
				TableSelected = i
				create_button(TableSelected, tableContainer, Navigation_Button, "Table_Button")

		"key":

			for j in saveFile[TableSelected]:  #j = Key Name
				KeySelected = j
				create_button(KeySelected, keyContainer,Navigation_Button, "Key_Button")

		"value":
			ValueSelected = ""
			var modified_table_name = TableSelected
			if modified_table_name == "Inventory":
				modified_table_name = "Items"
#			print("MODIFIED TABLE NAME: ", modified_table_name)
			if modified_table_name == "Event Save Data":
				load_save_data(modified_table_name)
			else:
				for k in saveFile[TableSelected][KeySelected]: # k = field Name
					ValueSelected = saveFile[TableSelected][KeySelected][k]
					var input = create_input_node(k, modified_table_name)
					valueContainer.add_child(input)
					if input.has_method("populate_list"):
						var reference_table = get_reference_table(modified_table_name, KeySelected, k)
						input.selection_table_name = reference_table
					input._set_input_value(ValueSelected)
					input.labelNode.set_text(k)
					input.is_label_button = false
		"event":
				ValueSelected = ""
#				print("VALUE SELECTED: ", KeySelected)
				for value_dict in saveFile[TableSelected][KeySelected][EventSelected]: # k = field Name
#					print(value_dict)
					ValueSelected = saveFile[TableSelected][KeySelected][EventSelected][value_dict]
					var input = create_input_node(value_dict, TableSelected)
					valueContainer.add_child(input)
					if input.has_method("populate_list"):
						var reference_table = get_reference_table(TableSelected, KeySelected, value_dict)
						input.selection_table_name = reference_table
					input._set_input_value(ValueSelected)
					input.labelNode.set_text(value_dict)
					input.is_label_button = false


func load_save_data(modified_table_name: String):
	clear_single_container(eventContainer)
	for event in saveFile[TableSelected][KeySelected]:
		create_button(event, eventContainer,Navigation_Button, "Event_Button")


func clear_single_container(container: VBoxContainer):
	for i in container.get_children():
		if i.name != "Label":
			i.queue_free()


func enable_buttons(container:VBoxContainer):
	for i in container.get_children():
		if i.name != "Label":
			i.disabled = false
			i.reset_self_modulate()


#func create_input(valueName, container: VBoxContainer, input_scene):
#	var input_node = input_scene.instantiate()
#	valueName = str(valueName)
#	container.add_child(input_node)
#	return input_node




func create_button(valueName:String, container: VBoxContainer, button: PackedScene, group_name: String):
	#Create button for Table Data Table.  The values on this table are the connection between the database and save functions
	var Button_Scene = button.instantiate()
#	print(valueName)
	Button_Scene.main_page = self
	Button_Scene.add_to_group(group_name)
	Button_Scene.add_to_group("Key")
	Button_Scene.auto_connect_signals = false
#	Button_Scene.auto_set_minimum_size = false
#	Button_Scene.set_custom_minimum_size(Vector2(50,50))
	Button_Scene.button_up.connect(navigation_button_up.bind(Button_Scene))
	valueName = str(valueName)
	container.add_child(Button_Scene)
	Button_Scene.set_name(valueName)
	Button_Scene.set_text(valueName)
	Button_Scene.change_button_size()


func _on_DisplaySaveFile_visibility_changed() -> void:
	if visible:
		pass
		#PUT SCRIPT HERE IF YOU WANT A FUNCTION TO RUN WHEN TAB BECOMES VISIBLE TO USER
#		_ready()


func _on_Save_button_up() -> void:
	#CODE TO SAVE CHANGES TO SAVEfILE
	#loop through input column, get all values
	$Popups.visible = true
	if TableSelected != "Event Save Data":
		if valueContainer.get_children().size() >= 2:
			for i in valueContainer.get_children():
				if "inputNode" in i:
					var curr_value = i._get_input_value()
					var curr_field = i.labelNode.text
					saveFile[TableSelected][KeySelected][curr_field] = curr_value
		var fileName = save_game_path + FileSelected + save_format
		save_file(fileName, saveFile)
	else:
		if valueContainer.get_children().size() >= 2:
			for i in valueContainer.get_children():
				if "inputNode" in i:
					var curr_value = i._get_input_value()
					var curr_field = i.labelNode.text
					saveFile[TableSelected][KeySelected][EventSelected][curr_field] = curr_value
		var fileName = save_game_path + FileSelected + save_format
		save_file(fileName, saveFile)
	
	emit_signal("table_save_complete")
	#Reset input_changed and hide notification
	_input_node_changed(false)
	$Popups.visible = false
#	print("DISPLAY SAVE FILE: ON_SAVE_BUTTON_UP- END")
	


func _on_DeleteFile_button_up() -> void:
	$Popups.visible = true
	$Popups/Popup_Delete_Confirm.visible = true
	var popup_label = $Popups/Popup_Delete_Confirm/PanelContainer/VBoxContainer/Label
	var popup_label2 = $Popups/Popup_Delete_Confirm/PanelContainer/VBoxContainer/Label2
	var lbl_text : String = popup_label2.get_text()
	lbl_text = lbl_text.replace("%", FileSelected.to_upper())
	popup_label.set_text(lbl_text)

func input_node_changed(text):
	_input_node_changed()

func _input_node_changed(hidden = true):
	$Main_VBox/Header_Button_HBox/CenterContainer2/Label.visible = hidden
	input_changed = hidden
	$Main_VBox/Header_Button_HBox/Save.disabled = !hidden
	$Main_VBox/Header_Button_HBox/Save.reset_self_modulate()

func _on_Delete_Accept_button_up() -> void:
	var fileName = save_game_path + FileSelected + save_format
	var dir :DirAccess = DirAccess.open(save_game_path)
	dir.remove(fileName)
	_ready()
	$Main_VBox/Header_Button_HBox/DeleteFile.disabled = true
	_on_Delete_Cancel_button_up()


func _on_Delete_Cancel_button_up() -> void:
	$Popups.visible = false
	$Popups/Popup_Delete_Confirm.visible = false
