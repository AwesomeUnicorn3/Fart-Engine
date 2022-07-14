@tool
extends DatabaseEngine

@onready var fileButton = preload("res://addons/UDSEngine/SaveFile_Manager/Navigation_Button_File.tscn")
@onready var tableButton = preload("res://addons/UDSEngine/SaveFile_Manager/Navigation_Button_table.tscn")
@onready var keyButton = preload("res://addons/UDSEngine/SaveFile_Manager/Navigation_Button_Key.tscn")

@onready var value_input = preload("res://addons/UDSEngine/Database_Manager/Scenes and Scripts/UI_Input_Scenes/Input_Text.tscn")

@onready var fileContainer = $VBox1/HBox1/Scroll1/VBox1
@onready var tableContainer = $VBox1/HBox1/Scroll2/VBox1
@onready var keyContainer = $VBox1/HBox1/Scroll3/VBox1
@onready var valueContainer = $VBox1/HBox1/Scroll4/VBox1


var saveFile = {} #Current working dictionary
var FileSelected
var TableSelected
var KeySelected
var ValueSelected
var input_changed = false

func _ready() -> void:
	var files = list_files_with_param(save_game_path, save_format)
	var save_name
	clear_single_container(fileContainer)
	clear_single_container(tableContainer)
	clear_single_container(keyContainer)
	clear_single_container(valueContainer)
	for i in files:
		i = str(i).trim_suffix(save_format)
		create_button(i , fileContainer, fileButton)
		save_name = str(i)


func _on_file_button_up(saveName):
	var fileLocation = save_game_path + saveName + save_format
	clear_single_container(tableContainer)
	clear_single_container(keyContainer)
	clear_single_container(valueContainer)
	FileSelected = saveName
	$VBox1/Hbox2/DeleteFile.disabled = false
	saveFile = import_data(fileLocation)
	get_saveFile_data("table")
	input_node_changed("", false)

func _on_table_button_up(Name):
	clear_single_container(keyContainer)
	clear_single_container(valueContainer)
	TableSelected = Name
	get_saveFile_data("key")
	input_node_changed("", false)

func _on_key_button_up(Name):
	clear_single_container(valueContainer)
	KeySelected = Name
	get_saveFile_data("value")
	input_node_changed("", false)

func get_saveFile_data(get_value):
	wait_timer(.2)
	await Timer_Complete
#	var tr = Timer.new()
#	tr.set_one_shot(true)
#	add_child(tr)
#	tr.set_wait_time(.2)
#	tr.start()
#	yield(tr, "timeout")
#	tr.queue_free()
	if  get_value == "table":
		for i in saveFile:# i = Table Name
			TableSelected = i
			create_button(TableSelected, tableContainer, tableButton)

	if get_value == "key":
		for j in saveFile[TableSelected]:  #j = Key Name
			KeySelected = j
			create_button(KeySelected, keyContainer,keyButton)

	if get_value == "value":
		for k in saveFile[TableSelected][KeySelected]: # k = field Name
			ValueSelected = saveFile[TableSelected][KeySelected][k]
			var input = create_input(ValueSelected, valueContainer,value_input)
			input.inputNode.set_text(str(ValueSelected))
			input.labelNode.set_text(k)
			input.is_label_button = false


func clear_single_container(container):
	for i in container.get_children():
		if i.name != "Label":
			i.queue_free()

func create_input(valueName, container, button):
	var data = button.instantiate()
	valueName = str(valueName)
	container.add_child(data)
	return data


func create_button(valueName, container, button):
	#Create button for Table Data Table.  The values on this table are the connection between the database and save functions
	var data = button.instantiate()
	valueName = str(valueName)
	container.add_child(data)
	data.set_name(valueName)
	data.set_text(valueName)


func _on_DisplaySaveFile_visibility_changed() -> void:
	if visible:
		#PUT SCRIPT HERE IF YOU WANT A FUNCTION TO RUN WHEN TAB BECOMES VISIBLE TO USER
		_ready()


func _on_Save_button_up() -> void:
	#CODE TO SAVE CHANGES TO SAVEfILE
	#loop through input column, get all values
	$Popups.visible = true
	for i in valueContainer.get_children():
		if "inputNode" in i:
			var curr_value = i.inputNode.text
			var curr_field = i.labelNode.text
			saveFile[TableSelected][KeySelected][curr_field] = curr_value
	var fileName = save_game_path + FileSelected + save_format
	save_file(fileName, saveFile)
	#Reset input_changed and hide notification
	input_node_changed("", false)
	$Popups.visible = false


func _on_DeleteFile_button_up() -> void:
	$Popups.visible = true
	$Popups/popup_delete_confirm.visible = true
	var popup_label = $Popups/popup_delete_confirm/PanelContainer/VBoxContainer/Label
	var popup_label2 = $Popups/popup_delete_confirm/PanelContainer/VBoxContainer/Label2
	var lbl_text : String = popup_label2.get_text()
	lbl_text = lbl_text.replace("%", FileSelected.to_upper())
	popup_label.set_text(lbl_text)


func input_node_changed(value, hidden = true):
	$VBox1/Hbox2/CenterContainer2/Label.visible = hidden
	input_changed = hidden
	$VBox1/Hbox2/Save.disabled = !hidden


func _on_Delete_Accept_button_up() -> void:
	var fileName = save_game_path + FileSelected + save_format
	var dir = Directory.new()
	dir.remove(fileName)
	_ready()
	$VBox1/Hbox2/DeleteFile.disabled = true
	_on_Delete_Cancel_button_up()


func _on_Delete_Cancel_button_up() -> void:
	$Popups.visible = false
	$Popups/popup_delete_confirm.visible = false
