extends Control
tool

onready var btn_TableSelect = preload("res://addons/Database_Manager/Scenes and Scripts/Database_Browser/Btn_TableSelect.tscn")
onready var table_list = $VBoxContainer/HBoxContainer/ScrollContainer/Table_Buttons
onready var data = $VBoxContainer/HBoxContainer/ScrollContainer2/TableViewer
onready var btn_save = $VBoxContainer/HBoxContainer2/Save
onready var btn_newTable = $VBoxContainer/HBoxContainer2/New_Table
onready var btn_editKey = $VBoxContainer/HBoxContainer2/Change_Row_Order
onready var btn_editValue = $VBoxContainer/HBoxContainer2/Change_Column_Order
onready var btn_newValue = $VBoxContainer/HBoxContainer2/New_Value
onready var btn_newKey = $VBoxContainer/HBoxContainer2/New_Key
onready var btn_deleteValue = $VBoxContainer/HBoxContainer2/Delete_Value
onready var btn_deleteKey = $VBoxContainer/HBoxContainer2/Delete_Key
onready var btn_deleteTable = $VBoxContainer/HBoxContainer2/Delete_Table
onready var btn_closeTable =  $VBoxContainer/HBoxContainer2/Close_Table
onready var lbl_tableName = $VBoxContainer/HBoxContainer2/CenterContainer2/Label
onready var dlg_newTableName = $Popups/popup_newTable
onready var dlg_tblNameInput = $Popups/popup_newTable/PanelContainer/VBoxContainer/LineEdit
onready var dlg_tblfirstKeyInput = $Popups/popup_newTable/PanelContainer/VBoxContainer/LineEdit2
onready var dlg_tblfirstValueInput = $Popups/popup_newTable/PanelContainer/VBoxContainer/LineEdit3
onready var dlg_newKey = $Popups/popup_newKey
onready var dlg_keyInput = $Popups/popup_newKey/PanelContainer/VBoxContainer/LineEdit
onready var dlg_keyDelete = $Popups/popup_deleteKey
onready var dlg_keySelect = $Popups/popup_deleteKey/PanelContainer/VBoxContainer/Itemlist
onready var pop_error = $Popups/popup_error
onready var save_path_label = $VBoxContainer/CenterContainer/Label3
var accept = false
var delete_name
var deleteKey
var files
var save_path = ""
var tbl_name = ""
var file_format = ".json"
var data_type = ""
var horizontal
var vertical
var array_load_savefiles = []
var array_load_files = []
var save_game_path = "user://"
var load_game_path = ""
var save_format = ".sav"
var dbmanData_save_path = "res://addons/Database_Manager/Data/"


func _process(_delta):
	#Allows user to scroll table while keeping column and row headers in line with data
	if is_instance_valid(horizontal) :
		horizontal.set_h_scroll(data.h) 
	if is_instance_valid(vertical):
		vertical.set_v_scroll(data.v) 

func _ready():
	clear_frozenLines()
	save_path = dbmanData_save_path
	save_path_label.set_text(save_path)
	files = list_files_in_directory(save_path, file_format)
	if table_list.get_child_count() != 0:
		for n in table_list.get_children():
			table_list.remove_child(n)
			n.queue_free()
	create_table_buttons()
	reset_buttons()
	print("Main_scene loaded")


func create_table_buttons():
	#Create button for Table Data Table.  The values on this table are the connection between the database and save functions
	var tabledata = btn_TableSelect.instance()
	table_list.add_child(tabledata)
	var tbllabel = "Table Data.json"
	var tblarray = tbllabel.rsplit(".")
	tbllabel = tblarray[0]
	tabledata.set_name(tbllabel)
	tabledata.get_node("Label").set_text(tbllabel)
	
	 #Loop through the files array and add a button for each table in the array
	for i in files.size():
		var newbtn = btn_TableSelect.instance()
		table_list.add_child(newbtn)
		var label = files[i]
		var array = label.rsplit(".")
		label = array[0]
		newbtn.set_name(label)
		newbtn.get_node("Label").set_text(label)


func list_files_in_directory(sve_path, file_type):
	array_load_savefiles = []
	var files = []
	var dir = Directory.new()
	dir.open(sve_path)
	dir.list_dir_begin()
	if sve_path == save_game_path and file_type == save_format:
		while true:
			var file = dir.get_next()
			if file == "":
				break
			elif file.ends_with(save_format):
				files.append(file)
				array_load_savefiles.append(file)
		
		
	else:
		while true:
			var file = dir.get_next()
			if file == "":
				break
			elif not file.begins_with(".") and file != "Table Data.json":
				if file.ends_with(file_type):
					files.append(file)
					array_load_files.append(file)
	dir.list_dir_end()
	return files

func refresh_data(name):
	$Popups.visible = true
	clear_frozenLines()
	var RCT = "T"
	lbl_tableName.set_text(name)
	var name_array = name.rsplit(".")
	data.update_sheet(name_array[0], RCT)
	datatype(RCT)
	tbl_name = name
	data.visible = true
	if tbl_name == "Table Data":
		btn_save.visible = true
		btn_editKey.visible = false
		btn_editValue.visible = false
		btn_newTable.visible = false
		btn_deleteTable.visible = false
		btn_newValue.visible = false
		btn_newKey.visible = false
		btn_deleteKey.visible = false
		btn_deleteValue.visible = false
		btn_closeTable.visible = true

	else:
		btn_save.visible = true
		btn_editKey.visible = true
		btn_editValue.visible = true
		btn_newTable.visible = false
		btn_deleteTable.visible = true
		btn_newValue.visible = false
		btn_newKey.visible = false
		btn_deleteKey.visible = false
		btn_deleteValue.visible = false
		btn_closeTable.visible = true

	var t = Timer.new()
	t.set_one_shot(true)
	self.add_child(t)
	t.set_wait_time(.5)
	t.start()
	yield(t, "timeout")
	t.queue_free()
	set_header_size()

func _on_Row_button_up():
	clear_frozenLines()
	var RCT = "R"
	var tbl_name = lbl_tableName.get_text()
	var name_array = tbl_name.rsplit(".")
	datatype(RCT)
	tbl_name = name_array[0]
	btn_save.visible = true
	btn_editKey.visible = false
	btn_editValue.visible = false
	btn_newTable.visible = false
	btn_deleteTable.visible = false
	btn_newValue.visible = false
	btn_newKey.visible = true
	btn_deleteKey.visible = true
	btn_deleteValue.visible = false
	btn_closeTable.visible = true
	data.update_sheet(tbl_name, RCT)

func _on_Change_Column_Order_button_up():
	clear_frozenLines()
	var RCT = "C"
	var tbl_name = lbl_tableName.get_text()
	datatype(RCT)
	var name_array = tbl_name.rsplit(".")
	tbl_name = name_array[0]
	btn_save.visible = true
	btn_editKey.visible = false
	btn_editValue.visible = false
	btn_newTable.visible = false
	btn_deleteTable.visible = false
	btn_newValue.visible = true
	btn_newKey.visible = false
	btn_deleteKey.visible = false
	btn_deleteValue.visible = true
	btn_closeTable.visible = true
	data.update_sheet(tbl_name, RCT)

func _on_save_button_up():
	data.update_dict()

func _on_Delete_Table_button_up():
	#Deletes selected table
	pop_error.set_text("Are you sure you wish to delete this table?")
	pop_error.visible = true
	yield(pop_error, "confirmed")
	if accept == true:
		var del_tbl_name = tbl_name
		var key = tbl_name
		var key_index
		refresh_data("Table Data")
		_on_Row_button_up()
		var temp = data.table_data[data.data_type]
		for i in temp:
			if temp[i] == key:
				key_index = i
		data.deleteKeys(key_index, key)
		refresh_data(del_tbl_name)
		var dir = Directory.new()
		var file_delete = save_path + tbl_name + file_format
		dir.remove(file_delete)
		file_delete = save_path + tbl_name + "_Row"
		dir.remove(file_delete)
		file_delete = save_path + tbl_name + "_Column"
		dir.remove(file_delete)
		_ready()
		data.clear_cells()
		lbl_tableName.set_text("")
	accept = false

func _on_new_key_Accept_button_up():
	var new_key = dlg_keyInput.get_text()
	data.add_key(new_key)
	dlg_keyInput.set_text("")
	dlg_newKey.visible = false
	popupBkg(false)

func _on_New_Key_button_up():
	dlg_newKey.visible = true
	popupBkg(true)

func _on_Newkey_Cancel_button_up():
	dlg_keyInput.set_text("")
	dlg_newKey.visible = false
	popupBkg(false)

func _on_DeleteKey_Accept_button_up():
	data.deleteKeys(deleteKey, delete_name)
	dlg_keySelect.clear()
	dlg_keyDelete.visible = false
	popupBkg(false)

func _on_DeleteKey_Itemlist_item_selected(index):
	delete_name = data.table_data[data_type][str(index + 1)]
	deleteKey = str(index + 1)

func _on_Delete_Key_button_up():
	dlg_keySelect.clear()
	var row_header_values = []
	var column_header_orderA = []
	for n in data.table_data[data_type].size():
		var t = str(n + 1)
		column_header_orderA +=  [t]
	for n in column_header_orderA:
		row_header_values += [data.table_data[data_type][n]]
	for n in data.table_data[data_type].size():
		var t = row_header_values[n]
		dlg_keySelect.add_item (t,null,true )
	dlg_keyDelete.visible = true
	popupBkg(true)

func _on_DeleteKey_Cancel_button_up():
	deleteKey = ""
	dlg_keyDelete.visible = false
	dlg_keySelect.clear()
	popupBkg(false)

func _on_New_Value_button_up():
	dlg_newKey.visible = true
	popupBkg(true)

func _on_Delete_Value_button_up():
	dlg_keySelect.clear()
	for n in data.table_data[data_type]:
		var t = data.table_data[data_type][n]
		dlg_keySelect.add_item (t,null,true )
	dlg_keyDelete.visible = true
	popupBkg(true)

func datatype(RCT):
	match RCT:
		"R":
			data_type = "Row"
		"C":
			data_type = "Column"
		"T":
			data_type = "Table"

func _on_New_Table_button_up():
	dlg_newTableName.visible = true
	popupBkg(true)
	$Popups/popup_newTable/PanelContainer/VBoxContainer/LineEdit.grab_focus()

func _on_new_table_Accept_button_up():
	tbl_name = dlg_tblNameInput.get_text()
	var dir = Directory.new()
	var file_add
	var newTable_Dict = {}
	var newRow_Dict = {}
	var newColumn_Dict = {}
	var tableName = dlg_tblNameInput.get_text()
	var keyName = dlg_tblfirstKeyInput.get_text()
	var valueName = dlg_tblfirstValueInput.get_text()
	var dup_check = tableName + file_format
	if dlg_tblNameInput.get_text() == "" or dlg_tblfirstKeyInput.get_text() == "" or dlg_tblfirstKeyInput.get_text() == "":
		data.error = 4
	elif files.has(dup_check):
		data.error = 5
	else:
		data.error = 0
	match data.error:
		0:
			newTable_Dict[keyName] = {valueName : "empty"}
			newRow_Dict["Row"] = {1 : keyName}
			newColumn_Dict["Column"] = {1 : valueName}
			file_add = save_path + tbl_name + file_format
			save_data(file_add, newTable_Dict)
			file_add = save_path + tbl_name + "_Row"
			save_data(file_add, newRow_Dict)
			file_add = save_path + tbl_name + "_Column"
			save_data(file_add, newColumn_Dict)
			_ready()
			data.clear_cells()
			lbl_tableName.set_text("")
			_on_newtable_Cancel_button_up()
			refresh_data("Table Data")
			_on_Row_button_up()
			data.add_key(tableName)
			_ready()
			data.clear_cells()
		4:
			data.error_display()
		5:
			data.error_display()
	data.error = 0

func _on_newtable_Cancel_button_up():
	dlg_tblNameInput.set_text("")
	dlg_tblfirstKeyInput.set_text("")
	dlg_tblfirstValueInput.set_text("")
	dlg_newTableName.visible = false
	popupBkg(false)

func save_data(sv_path, tbl_data):
#Save dictionary to .json upon user confirmation
	var save_file = File.new()
	if save_file.open(sv_path, File.WRITE) != OK:
		print("Error Could not update file")
	else:
		var save_d = tbl_data
		save_file.open(sv_path, File.WRITE)
		save_d = to_json(save_d)
		save_file.store_line(save_d)
		save_file.close()

func _on_Close_Table_button_up():
	clear_frozenLines()
	reset_buttons()
#	_ready()
	data.clear_cells()
	lbl_tableName.set_text("")


func reset_buttons():
	#Set button states
	btn_save.visible = false
	btn_editKey.visible = false
	btn_editValue.visible = false
	btn_newTable.visible = true
	btn_deleteTable.visible = false
	btn_newValue.visible = false
	btn_newKey.visible = false
	btn_deleteKey.visible = false
	btn_deleteValue.visible = false
	btn_closeTable.visible = false
	popupBkg(false)


func popupBkg(visible : bool):
	$Popups.visible = visible

func clear_frozenLines():
	var n = $VBoxContainer/HBoxContainer/ScrollContainer2.get_children()
	for i in n:
		var nm = i.get_name()
		if nm != "TableViewer":
			$VBoxContainer/HBoxContainer/ScrollContainer2.remove_child(i)
			i.queue_free()

func set_header_size():
	var main = get_node("VBoxContainer/HBoxContainer/ScrollContainer2/TableViewer")
	main.get_node("ScrollContainer").set_h_scroll(0)
	main.get_node("ScrollContainer").set_v_scroll(0)
	var e = main.duplicate()
	$VBoxContainer/HBoxContainer/ScrollContainer2.add_child(e)
	var d = main.duplicate()
	$VBoxContainer/HBoxContainer/ScrollContainer2.add_child(d)
	var f = main.duplicate()
	$VBoxContainer/HBoxContainer/ScrollContainer2.add_child(f)
	var scrolld = d.get_node("ScrollContainer")
	var scrolle = e.get_node("ScrollContainer")
	var scrollf = f.get_node("ScrollContainer")
	var theme = Theme.new()
	theme = load("res://addons/Database_Manager/Theme and Style/NoScrollTheme.tres")
	scrolld.set_theme(theme)
	scrolle.set_theme(theme)
	scrollf.set_theme(theme)
	var t = Timer.new()
	t.set_one_shot(true)
	self.add_child(t)
	t.set_wait_time(.25)
	t.start()
	yield(t, "timeout")
	t.queue_free()
	var dx = data.get_x()
	var dp = d.get_size().y - 12
	d._set_size(Vector2(dx, dp))
	var ep = data.get_y()
	var ex = e.get_size().x - 12
	e._set_size(Vector2(ex, ep))
	f._set_size(Vector2(dx, ep))
	vertical = scrolld
	horizontal = scrolle
	#resume input
	$Popups.visible = false

func _on_popup_error_confirmed():
	accept = true
	pop_error.visible = false
	pop_error.set_text("")


func _on_Database_Manager_visibility_changed():
	if visible:
		pass
	else:
		_on_Close_Table_button_up()
