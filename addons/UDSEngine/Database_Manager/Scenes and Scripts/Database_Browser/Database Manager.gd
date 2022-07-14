@tool
extends DatabaseEngine

signal popup_confirmed
#THIS SCRIPT SHOULD BE JUST FOR NAVIGATING AND LOADING DATA FOR THE DATABASE MANAGER TAB
@onready var btn_TableSelect = preload("res://addons/UDSEngine/Database_Manager/Scenes and Scripts/Database_Browser/Btn_TableSelect.tscn")
@onready var column = preload("res://addons/UDSEngine/Database_Manager/Scenes and Scripts/Database_Browser/Column.tscn")
@onready var row = preload("res://addons/UDSEngine/Database_Manager/Scenes and Scripts/Database_Browser/Row.tscn")
@onready var datainput = preload("res://addons/UDSEngine/Database_Manager/Scenes and Scripts/Database_Browser/DataInput.tscn")
@onready var table = $VBoxContainer/HBoxContainer/ScrollContainer2/TableViewer/ScrollContainer/GridConainer
@onready var tableDisplay = $VBoxContainer/HBoxContainer/ScrollContainer2/TableViewer

@onready var tableViewer_scroll = $VBoxContainer/HBoxContainer/ScrollContainer2/TableViewer/ScrollContainer
@onready var table_list = $VBoxContainer/HBoxContainer/ScrollContainer/Table_Buttons
@onready var popup_main = $Popups

@onready var btn_save = $VBoxContainer/HBoxContainer2/Save
@onready var btn_newTable = $VBoxContainer/HBoxContainer2/New_Table
@onready var btn_editKey = $VBoxContainer/HBoxContainer2/Change_Row_Order
@onready var btn_editValue = $VBoxContainer/HBoxContainer2/Change_Column_Order
@onready var btn_newValue = $VBoxContainer/HBoxContainer2/New_Value
@onready var btn_newKey = $VBoxContainer/HBoxContainer2/New_Key
@onready var btn_deleteValue = $VBoxContainer/HBoxContainer2/Delete_Value
@onready var btn_deleteKey = $VBoxContainer/HBoxContainer2/Delete_Key
@onready var btn_deleteTable = $VBoxContainer/HBoxContainer2/Delete_Table
@onready var btn_closeTable =  $VBoxContainer/HBoxContainer2/Close_Table
@onready var lbl_tableName = $VBoxContainer/HBoxContainer2/CenterContainer2/Label

@onready var newTable = $Popups/popup_newTable


@onready var newKey_popup = $Popups/popup_newKey
@onready var newKey_Name_Input = $Popups/popup_newKey/PanelContainer/VBox1/HBox1/VBox1/Input_Text/Input
@onready var newKey_dataType_Input = $Popups/popup_newKey/PanelContainer/VBox1/HBox1/VBox2/ItemType_Selection/Input
@onready var newKey_ShowHide_Input = $Popups/popup_newKey/PanelContainer/VBox1/HBox1/VBox3/LineEdit3

@onready var dlg_keyDelete = $Popups/popup_deleteKey
@onready var dlg_keySelect = $Popups/popup_deleteKey/PanelContainer/VBoxContainer/Itemlist
@onready var pop_error = $Popups/popup_error
@onready var save_path_label = $VBoxContainer/CenterContainer/Label3

@onready var dlg_newValue = $Popups/popup_newValue


#var udsEngine #Main engine script

var accept = false
var delete_name
var deleteKey
var files
#var tbl_name = "" #Name of table that is currently selected

var horizontal
var vertical
var error = 0


func _ready():
	clear_frozenLines()
	save_path_label.set_text(table_save_path)
	files = list_files_with_param(table_save_path, file_format, ["Table Data.json"])

	if table_list.get_child_count() != 0:
		for n in table_list.get_children():
			table_list.remove_child(n)
			n.queue_free()

	create_table_buttons()
	reset_buttons()
#	print("Database tables successfully loaded")


func _on_Database_Manager_visibility_changed():
	if visible:
		if current_table_name != "":
			refresh_table_data(current_table_name)
#	else:
#		_on_Close_Table_button_up()

func _process(_delta):
	if visible:
		#Allows user to scroll table while keeping column and row headers in line with data
		if is_instance_valid(horizontal) :
			horizontal.set_h_scroll(tableViewer_scroll.get_h_scroll()) 
		if is_instance_valid(vertical):
			vertical.set_v_scroll(tableViewer_scroll.get_v_scroll()) 




###Begin user interface changes########################

func create_table_buttons():
	#Create button for Table Data Table.  The values on this table are the connection between the database and save functions
	var tabledata = btn_TableSelect.instantiate()
	table_list.add_child(tabledata)
	var tbllabel = "Table Data.json"
	var tblarray = tbllabel.rsplit(".")
	tbllabel = tblarray[0]
	tabledata.set_name(tbllabel)
	tabledata.get_node("Label").set_text(tbllabel)
	
#Loop through the files array and add a button for each table in the array
	for i in files.size():
		var newbtn = btn_TableSelect.instantiate()
		table_list.add_child(newbtn)
		var label = files[i]
		var array = label.rsplit(".")
		label = array[0]
		newbtn.set_name(label)
		newbtn.get_node("Label").set_text(label)



func refresh_table_data(name):
	popup_main.visible = true
	clear_frozenLines()
	data_type = "table"
	lbl_tableName.set_text(name)
	var name_array = name.rsplit(".")
	update_sheet(name_array[0])
	current_table_name = name
	update_dictionaries()
	tableDisplay.visible = true
	if current_table_name == "Table Data":
		btn_save.visible = true
		btn_editKey.visible = true
		btn_editValue.visible = true
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
	await get_tree().create_timer(.5).timeout
#	timer(.5)
#	await Timer_Complete
#	var t = Timer.new()
#	t.set_one_shot(true)
#	self.add_child(t)
#	t.set_wait_time(.5)
#	t.start()
#	yield(t, "timeout")
#	t.queue_free()

	set_header_size()


func reset_buttons():
	#Set button states to default
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


func clear_frozenLines():
	var n = $VBoxContainer/HBoxContainer/ScrollContainer2.get_children()
	for i in n:
		var nm = i.get_name()
		if nm != "TableViewer":
			$VBoxContainer/HBoxContainer/ScrollContainer2.remove_child(i)
			i.queue_free()


func set_header_size():
	tableDisplay.get_node("ScrollContainer").set_h_scroll(0)
	tableDisplay.get_node("ScrollContainer").set_v_scroll(0)
	var e = tableDisplay.duplicate()
	$VBoxContainer/HBoxContainer/ScrollContainer2.add_child(e)
	var d = tableDisplay.duplicate()
	$VBoxContainer/HBoxContainer/ScrollContainer2.add_child(d)
	var f = tableDisplay.duplicate()
	$VBoxContainer/HBoxContainer/ScrollContainer2.add_child(f)
	var scrolld = d.get_node("ScrollContainer")
	var scrolle = e.get_node("ScrollContainer")
	var scrollf = f.get_node("ScrollContainer")
	var theme = Theme.new()
	theme = load("res://addons/UDSEngine/Database_Manager/Theme and Style/NoScrollTheme.tres")
	scrolld.set_theme(theme)
	scrolle.set_theme(theme)
	scrollf.set_theme(theme)

	await get_tree().create_timer(.25).timeout
#	timer(.25)
#	await Timer_Complete
#	var t = Timer.new()
#	t.set_one_shot(true)
#	self.add_child(t)
#	t.set_wait_time(.25)
#	t.start()
#	yield(t, "timeout")
#	t.queue_free()

	var dx = get_x()
	var dp = d.get_size().y - 12
	d._set_size(Vector2(dx, dp))
	var ep = get_y()
	var ex = e.get_size().x - 12
	e._set_size(Vector2(ex, ep))
	f._set_size(Vector2(dx, ep))
	vertical = scrolld
	horizontal = scrolle
	#resume input
	popup_main.visible = false


func get_x(): #Get gridcontainer rect size X
	var blankX = tableDisplay.get_node("ScrollContainer/GridConainer/Blank").rect_size
	return blankX.x


func get_y(): #Get gridcontainer rect size Y
	var blankY = tableDisplay.get_node("ScrollContainer/GridConainer/Blank").rect_size
	return blankY.y

func clear_cells():
	for n in table.get_children():
		if n.get_name() != "Blank":
			table.remove_child(n)
			n.queue_free()


func update_sheet(name):
	
	#Clear and reset arrays, dictionaries, and variables
	var row_header_order = {} #lists all keys by number
	var column_header_order = {} #lists all fields  by number
	currentData_dict["Row"] = {}
	currentData_dict["Column"] = {}
#	current_row_dict = {} #Clears the current selected key dictionary
#	current_column_dict = {} #Clears the current selected field dictionary
	current_table_name = name #*Scirpt Variable* Sets table name
	current_dict = {} #Clears the current selected table dictionary
	#remove all input nodes in the display area
	clear_cells()
	update_dictionaries()

	#Creates "row_header_order dictionary 
	#which gets the keys in the selected dictionary 
	#and puts them in number order with the table key as the row_header_order key
	for i in currentData_dict["Row"].size():
		var order_value = str(i + 1)
		row_header_order[currentData_dict["Row"][order_value]["FieldName"]] = order_value

	#Creates "column_header_order dictionary 
	#which gets the fields in the selected dictionary 
	#and puts them in number order with the table key as the column_header_order field name
	for n in currentData_dict["Column"].size():
		var order_value = str(n + 1)
		column_header_order[currentData_dict["Column"][order_value]["FieldName"]] = order_value


	match data_type:
		"table":
			table.columns = column_header_order.size() + 1 #set the number of columns in the grid Container
			data_type = "table"
			#create column header cells **Top Row
			for i in column_header_order:
				var newcell_field = column.instantiate()
				table.add_child(newcell_field)
				newcell_field.set_text(str(i))

			#create row header cells Left Row
			for i in row_header_order:
				var index = 1
				var newcell_key = row.instantiate()
				table.add_child(newcell_key)
				newcell_key.set_text(str(i))

				# for each row header cell, create data cells *Fields
				for n in currentData_dict["Column"].size():
					var Columnname = currentData_dict["Column"][str(index)]["FieldName"]
					var newcell_value = datainput.instantiate()
					var y = current_dict[i][Columnname]
					var keyname = remove_special_char(i)
					
					var columnname = remove_special_char(Columnname)
					newcell_value.set_name(keyname + "&" + columnname)
					
					table.add_child(newcell_value)
					newcell_value.get_node("input").set_text(str(y))
					newcell_value.initial_values()
					index += 1

		"Row":
			update_sheet_RC(row_header_order)
		"Column":
			update_sheet_RC(column_header_order)


func update_sheet_RC(selected_dict):
	#THIS WILL NEED TO BE SPLIT IN TO 2 SO THAT COLUMN CAN UPDATE MORE FIELDS THAT JUST "ORDER"
#Displays the key or field for the selected table
	#Add the "Order" Header to the display
	match data_type:
		"Row":
			var column_count = currentData_dict[data_type]["1"].size() + 1
			table.columns = column_count #set the number of columns in the grid Container
			#create column header cells **Top Row
			var newcolumn = column.instantiate()
			table.add_child(newcolumn)
			newcolumn.set_text("Order")

			for i in currentData_dict[data_type]["1"]:
				var text = str(i)
				if text != "FieldName":
					var newcell_field = column.instantiate()
					table.add_child(newcell_field)
					newcell_field.set_text(str(i))
				

			#create row header cells Left Row
			var row_header_order = {}
			for i in currentData_dict[data_type].size():
				var order_value = str(i + 1)
				row_header_order[currentData_dict[data_type][order_value]["FieldName"]] = order_value


			for i in row_header_order:
				var index = 1
				var newcell_key = datainput.instantiate()
				table.add_child(newcell_key)
				newcell_key.get_node("input").set_text(str(i))
				newcell_key.set_name(i + "&key")
				newcell_key.initial_values()

				var newcell_order = datainput.instantiate()
				table.add_child(newcell_order)
				newcell_order.set_name(i + "&Order")
				newcell_order.get_node("input").set_text(row_header_order[i])
				newcell_order.initial_values()
				# for each row header cell, create data cells *Values

				for n in currentData_dict[data_type][row_header_order[i]]:
					if n != "FieldName":
						var Columnname = n
						var newcell_value = datainput.instantiate()
						var field_value = currentData_dict[data_type][row_header_order[i]][n]
						var keyname = remove_special_char(i)

						var columnname = remove_special_char(Columnname)
						newcell_value.set_name(keyname + "&" + columnname)

						table.add_child(newcell_value)
						newcell_value.get_node("input").set_text(str(field_value))
						newcell_value.initial_values()
						index += 1
#			var newcolumn = column.instantiate()
#			table.add_child(newcolumn)
#			newcolumn.set_text("Order")
#			table.columns = 2 #set the number of columns in the grid Container
#
#			#for each row header cell, create row header cells (field or key) and  create "data "Order" cells
#			for i in selected_dict:
#				var node_name = remove_special_char(i)
#				var columnname = "Order"
#				var input_text = selected_dict[i]
#				var newcell_key = datainput.instantiate()
#				var newcell_order = datainput.instantiate()
#				#Create key for table - field name
#				newcell_key.get_node("input").set_text(str(i))
#				newcell_key.set_name(node_name + " key")
#				table.add_child(newcell_key)
#				newcell_key.initial_values()
#
#				newcell_order.set_name(node_name + " " + columnname)
#				table.add_child(newcell_order)
#				newcell_order.get_node("input").set_text(str(input_text))
#				newcell_order.initial_values()
		
		"Column":
			var column_count = currentData_dict[data_type]["1"].size() + 1
			table.columns = column_count #set the number of columns in the grid Container
			#create column header cells **Top Row
			var newcolumn = column.instantiate()
			table.add_child(newcolumn)
			newcolumn.set_text("Order")

			for i in currentData_dict[data_type]["1"]:
				var text = str(i)
				if text != "FieldName":
					var newcell_field = column.instantiate()
					table.add_child(newcell_field)
					newcell_field.set_text(str(i))
				

			#create row header cells Left Row
			var row_header_order = {}
			for i in currentData_dict[data_type].size():
				var order_value = str(i + 1)
				row_header_order[currentData_dict[data_type][order_value]["FieldName"]] = order_value


			for i in row_header_order:
				var index = 1
				var newcell_key = datainput.instantiate()
				table.add_child(newcell_key)
				newcell_key.get_node("input").set_text(str(i))
				newcell_key.set_name(i + "&key")
				newcell_key.initial_values()

				var newcell_order = datainput.instantiate()
				table.add_child(newcell_order)
				newcell_order.set_name(i + "&Order")
				newcell_order.get_node("input").set_text(row_header_order[i])
				newcell_order.initial_values()
				# for each row header cell, create data cells *Values

				for n in currentData_dict[data_type][row_header_order[i]]:
					if n != "FieldName":
						var Columnname = n
						var newcell_value = datainput.instantiate()
						var field_value = currentData_dict[data_type][row_header_order[i]][n]
						var keyname = remove_special_char(i)

						var columnname = remove_special_char(Columnname)
						newcell_value.set_name(keyname + "&" + columnname)

						table.add_child(newcell_value)
						newcell_value.get_node("input").set_text(str(field_value))
						newcell_value.initial_values()
						index += 1

	visible = true #Just to make sure the table is visible to user

func _on_Row_button_up():
	clear_frozenLines()
	data_type = "Row"
	var tbl_name = lbl_tableName.get_text()
	var name_array = tbl_name.rsplit(".")
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
	update_sheet(tbl_name)

func _on_Change_Column_Order_button_up():
	clear_frozenLines()
	data_type = "Column"
	var tbl_name = lbl_tableName.get_text()
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
	update_sheet(tbl_name)

func _on_save_button_up():
	update_dict()


func _on_Delete_Table_button_up():
	#Deletes selected table
	pop_error.get_node("PanelContainer/VBoxContainer/Label").set_text("Are you sure you wish to delete this table?")
	popupBkg(true)
	pop_error.visible = true
	await popup_confirmed
#	yield(self, "popup_confirmed")
	if accept == true:
		pop_error.visible = false
#		print(current_table_name)
		delete_table(current_table_name)
		accept = false
		
	else:
		pop_error.visible = false
		popupBkg(false)
	


func _on_new_key_Accept_button_up():
	#IF DATATYPE IS COLUMN NEED TO ADD ADDITIONAL INPUT VALUES FOR FIELD CUSTOM OPTIONS
	var keyName = newKey_Name_Input.get_text()
	var datatype = newKey_dataType_Input.get_parent().selectedItemName
	var showKey = newKey_ShowHide_Input.is_pressed()
	database_display_add_key(keyName, datatype, showKey)
	_on_Newkey_Cancel_button_up()

func _on_New_Key_button_up():
	newKey_popup.visible = true
	popupBkg(true)

func _on_Newkey_Cancel_button_up():
	newKey_Name_Input.set_text("")
	newKey_popup.visible = false
	popupBkg(false)


func _on_Delete_Key_button_up():
	display_options()

func _on_Delete_Value_button_up():
	display_options()


func display_options():
	var values_in_order_dict = {}
	dlg_keySelect.clear()
	match data_type:
		"Row":
			for n in currentData_dict[data_type].size(): #Arrange row dict values by order number
				var t = n + 1
				values_in_order_dict[n + 1] =  currentData_dict[data_type][str(t)]["FieldName"]

		"Column":
			for n in currentData_dict[data_type].size(): #Arrange row dict values by order number
				var t = n + 1
				values_in_order_dict[n + 1] =  currentData_dict[data_type][str(t)]["FieldName"]

	for n in values_in_order_dict: #Add values to options menu
		var t = values_in_order_dict[n]
		dlg_keySelect.add_item (t,null,true )


	dlg_keyDelete.visible = true
	popupBkg(true)


func _on_DeleteKey_Accept_button_up():
	deleteKeys(deleteKey, delete_name)
	popupBkg(false)

func _on_DeleteKey_Itemlist_item_selected(index):
	match data_type:
		"Row":
			delete_name = currentData_dict[data_type][str(index + 1)]["FieldName"]
		"Column":
			delete_name = currentData_dict[data_type][str(index + 1)]["FieldName"]

	deleteKey = str(index + 1)


func _on_DeleteKey_Cancel_button_up():
	deleteKey = ""
	dlg_keyDelete.visible = false
	dlg_keySelect.clear()
	popupBkg(false)

func _on_New_Value_button_up():
	#NEED TO ADD NEW INPUT TO THE FORM FOR CUSTOM OPTIONS
	dlg_newValue.visible = true
	popupBkg(true)

func _on_newValue_Accept_button_up():
	add_newField()
	_on_newValue_Cancel_button_up()

func _on_newValue_Cancel_button_up():
	dlg_newValue.visible = false
	popupBkg(false)

func _on_New_Table_button_up():
	newTable.visible = true
	popupBkg(true)
#	newTable_Name_Input.grab_focus()


func _on_new_table_Accept_button_up():
	add_table()


func _on_newtable_Cancel_button_up():
	newTable.reset_values()
	newTable.visible = false
	popupBkg(false)
#	update_dict()


func _on_Close_Table_button_up():
	clear_frozenLines()
	reset_buttons()
	clear_cells()
	lbl_tableName.set_text("")
	current_table_name = ""


func _on_popup_error_confirmed():
	accept = true
	emit_signal("popup_confirmed")
	
func _on_popupError_Cancel_button_up():
	emit_signal("popup_confirmed")


func popupBkg(visible : bool):
	popup_main.visible = visible


##Begin table modiification functions###################################

func update_dict():# input to file
	#pulls values and saves all tables associated with selected dictionary
# runs when save button pressed
	
#	add_line_to_currDataDict()
	match data_type:
		"table":
			update_table_values()
		"Row":
			update_row_values()
		"Column":
			update_column_values()
	
	get_node("../..").create_tabs()

#
func update_table_values(): #input to file
	#Creates a dictionary with the key and row values (creates main table dictionary) then saves it as a .json file
	var row_dict = {}
	var column_dict = {}

	for i in current_dict:
		var text = remove_special_char(i)
		row_dict[text] = i 
	#row_dict = #Dictioanry of key names {Key:Key, key2:key2} pulled from the selected table's dictionary (should be main, not row or column dicts)

	for i in row_dict:
		var key = row_dict[i]
		for u in current_dict[key]:
			column_dict[remove_special_char(u)] = u
	#column_dict = #Dictioanry of key names {field1:field1, ffield2:field2} pulled from the selected table's dictionary (should be main, not row or column dicts)

	for e in table.get_children(): #table is a reference to the input field, TableViewer/Gridcontainer
		if e.get_class() == "PanelContainer": #loop through all input PanelContainers and pull data from each node
			var Row = e.row
			var rowname = remove_special_char(Row)
			var Rowname = row_dict[rowname]
			var Column = e.column
			var Columnname = column_dict[Column]
			var temp = e.new_data

			if e.new_data != "" and e.new_data != null: #check if any of the newdata is blank
				current_dict[Rowname][Columnname] = e.new_data
	#table_data is the dictioary that saves the values for all fields and keys(main table)

	save_all_db_files(current_table_name)
	refresh_table_data(current_table_name)


func update_row_values(): #input to file Changes currently selected table Keys

	error_check()
	if error == 0:
		#This section only updates the "Key" if it has changed
		var index = 1
		for i in table.get_children():
			if i.get_class() == "PanelContainer": #look for all child nodes that are data input nodes
				var Row = i.row
				var new = i.new_data
				var prev = i.previous_data
				var Prevnodename = remove_special_char(prev) #in order to find the correct node, all special characters must be removed from the name
				var Newnodename =  remove_special_char(new)#in order to find the correct node, all special characters must be removed from the name
				var array = i.name
				array = array.rsplit("&")
				var type = array[1] #First part of node name for i
				if type == "key":
					if new == "" or new == null: #if input is blank or null
						pass
					else:
						var column_order = get_data_index(prev)
						var column_info = currentData_dict[data_type][column_order]
						column_info["FieldName"] = new
						currentData_dict[data_type][column_order] = column_info #Update the column dictionary key
						i.set_name(Newnodename + "&key") #Set new name for the current node
						i.update_values() #updates all the variables for current node
						i.new_data = ""

						#update and save main table with new key
						var main_tbl =  current_dict.duplicate(true)
						var key_dict = {}

						for k in main_tbl.keys():

							var test = {}
							test = main_tbl[k] #key dictionary

#							test2 = main_tbl[k][prev]
							current_dict.erase(prev)
#							test[new] = test2
#							main_tbl.erase(k)
#							main_tbl[k] = test
							current_dict[new] = test #update the current working dictionary with new data

		#This section only updates key order if changes are made
		var column_tbl = {}
		for i in table.get_children():
			if i.get_class() == "PanelContainer":
				var array = i.get_name()
				array = array.rsplit("&")
				var type = array[1]
				var nm = array[0]
				var Row = i.row
				var new = i.new_data
				var prev = i.previous_data
				if type == "Order":
					if new != "":
						var prev_data_dict = currentData_dict[data_type][prev] #get dict for previous data
						column_tbl[new] = prev_data_dict #replace with new data


		for i in column_tbl: #Remove fields that are going to change
			currentData_dict[data_type].erase(i)
		for i in column_tbl: #update row dictionary with new fields
			currentData_dict[data_type][i] = column_tbl[i]
		
		
		
		#This section will update the field information if any has changed
		for i in table.get_children():
			if i.get_class() == "PanelContainer":
				var array = i.get_name()
				array = array.rsplit("&")

				var type = array[1]
				var nm = array[0]
				var Row = i.row
				var new = i.new_data
				var prev = i.previous_data
				if type != "Order" and type != "key":
					if new != "":
						var column_order = get_data_index(nm)
						var column_info = currentData_dict[data_type][column_order]
						column_info[type] = new
						currentData_dict[data_type][column_order] = column_info
						i.update_values() #updates all the variables for current node
						i.new_data = ""

		save_all_db_files(current_table_name)
		update_sheet(current_table_name)
	else:
		error_display()



#	error_check()
#	if error == 0:
#		var index = 1
#		for i in table.get_children():
#			if i.get_class() == "PanelContainer": #look for all child nodes that are data input nodes
#				var Row = i.row
#				var new = i.new_data
#				var prev = i.previous_data
#				var Prevnodename = remove_special_char(prev) #in order to find the correct node, all special characters must be removed from the name
#				var Newnodename =  remove_special_char(new)#in order to find the correct node, all special characters must be removed from the name
#				var array = i.get_name().rsplit(" ") 
#				var type = array[1] #First part of node name for i
##				var nm = array[0]
#				if type == "key":
#					if new == "" or new == null: #if input is blank or null
#						pass
##						row_dict[str(index)] = prev #Set input value of i to previous value (reset value)
#					else:
#						var row_order = get_row_index(prev)
#						current_row_dict[row_order] = new #Update the row dictionary key
#						i.set_name(Newnodename + " key") #Set new name for the current node
#						i.update_values() #updates all the variables for current node
#						i.new_data = ""
#
#						#update and save main table with new key
#						var main_tbl =  current_dict.duplicate(true)
#						var key_dict = {}
#						key_dict = main_tbl[prev] #Creates a dictioary with only the data for the old key
#						main_tbl.erase(prev) #remove key dictionary from copy of selected table
#						main_tbl[new] = key_dict #Set the new key as a key in the copy of the main dict with the values from the old entry
#						current_dict = main_tbl #update the current working dictionary with new data
#						index += 1
#
#		#update key row order if changes are made
#		var row_tbl = {}
#		for i in table.get_children():
#			if i.get_class() == "PanelContainer":
#				var array = i.get_name().rsplit(" ")
#				var type = array[1]
#
#				var nm = array[0]
#				var Row = i.row
#				var new = i.new_data
#				var prev = i.previous_data
#				if type != "key":
#					if new != "":
#						var prev_data_dict = current_row_dict[prev] #get dict for previous data
#						row_tbl[new] = prev_data_dict #replace with new data
#
#		for i in row_tbl: #Remove fields that are going to change
#			current_row_dict.erase(i)
#		for i in row_tbl: #update row dictionary with new fields
#			current_row_dict[i] = row_tbl[i]
#		save_all_db_files(current_table_name)
#		update_sheet(current_table_name)
#	else:
#		error_display()


func update_column_values():
	error_check()
	if error == 0:
		#This section only updates the "Key" if it has changed
		var index = 1
		for i in table.get_children():
			if i.get_class() == "PanelContainer": #look for all child nodes that are data input nodes
				var Row = i.row
				var new = i.new_data
				var prev = i.previous_data
				var Prevnodename = remove_special_char(prev) #in order to find the correct node, all special characters must be removed from the name
				var Newnodename =  remove_special_char(new)#in order to find the correct node, all special characters must be removed from the name
				var array = i.get_name()
				array = array.rsplit("&") 
				var type = array[1] #First part of node name for i
				if type == "key":
					if new == "" or new == null: #if input is blank or null
						pass
					else:
						var column_order = get_data_index(prev)
						var column_info = currentData_dict[data_type][column_order]
						column_info["FieldName"] = new
						currentData_dict[data_type][column_order] = column_info #Update the column dictionary key
						i.set_name(Newnodename + "&key") #Set new name for the current node
						i.update_values() #updates all the variables for current node
						i.new_data = ""

						#update and save main table with new key
						var main_tbl =  current_dict.duplicate(true)
						var key_dict = {}
						for k in main_tbl.keys():
							var test = {}
							var test2
							test = main_tbl[k]
							test2 = main_tbl[k][prev]
							test.erase(prev)
							test[new] = test2
							main_tbl.erase(k)
							main_tbl[k] = test
						current_dict = main_tbl #update the current working dictionary with new data
						index += 1

		#This section only updates key order if changes are made
		var column_tbl = {}
		for i in table.get_children():
			if i.get_class() == "PanelContainer":
				var array = i.get_name()
				array = array.rsplit("&")
				var type = array[1]
				var nm = array[0]
				var Row = i.row
				var new = i.new_data
				var prev = i.previous_data
				if type == "Order":
					if new != "":
						var prev_data_dict = currentData_dict[data_type][prev] #get dict for previous data
						column_tbl[new] = prev_data_dict #replace with new data


		for i in column_tbl: #Remove fields that are going to change
			currentData_dict[data_type].erase(i)
		for i in column_tbl: #update row dictionary with new fields
			currentData_dict[data_type][i] = column_tbl[i]
		
		
		
		#This section will update the field information if any has changed
		for i in table.get_children():
			if i.get_class() == "PanelContainer":
				var array = i.get_name()
				array = array.rsplit("&")
				var type = array[1]
				var nm = array[0]
				var Row = i.row
				var new = i.new_data
				var prev = i.previous_data
				if type != "Order" and type != "key":
					if new != "":
						var column_order = get_data_index(nm)
						var column_info = currentData_dict[data_type][column_order]
						column_info[type] = new
						currentData_dict[data_type][column_order] = column_info
						i.update_values() #updates all the variables for current node
						i.new_data = ""

		save_all_db_files(current_table_name)
		update_sheet(current_table_name)
	else:
		error_display()

func deleteKeys(key, key_name):

	Delete_Key(key_name)
	save_all_db_files(current_table_name)
	update_sheet(current_table_name)
	dlg_keySelect.clear()
	dlg_keyDelete.visible = false


func database_display_add_key(keyName, datatype, showKey):
	var new_key_array = get_table_keys()
	var new_field_array = get_table_values()
	#Check for Errors
	error_check()
	if keyName == "": #If new key is blank
		error = 3
		error_display()

	elif new_key_array.count(keyName) >= 1: #if new key already exists in table
		error = 1
		error_display()

	elif new_field_array.has(keyName): #if value already exists in table
		error = 1
		error_display()

	elif error == 0:
		add_key(keyName, datatype, showKey, true, "")

		save_all_db_files(current_table_name)
		update_sheet(current_table_name)


func add_newField():
	var fieldName = $Popups/popup_newValue/PanelContainer/VBox1/HBox1/VBox1/Input_Text/Input.get_text()
	var datatype = $Popups/popup_newValue/PanelContainer/VBox1/HBox1/VBox2/ItemType_Selection.selectedItemName
	var showField = $Popups/popup_newValue/PanelContainer/VBox1/HBox1/VBox3/LineEdit3.is_pressed()
	var required = $Popups/popup_newValue/PanelContainer/VBox1/HBox1/VBox4/LineEdit3.is_pressed()
	var dropdown = $Popups/popup_newValue/PanelContainer/VBox1/HBox1/Table_Selection.selectedItemName
	#Get input values and send them to the editor functions add new value script
	#NEED TO ADD ERROR CHECKING
	add_field(fieldName, datatype, showField, required, dropdown)

	update_sheet(current_table_name)

func add_table():
	#Check for errors entered in to the form

	var tableName = newTable.tableName.text
	var keyName = newTable.keyName.text
	var keyDataType = "1"
	var keyVisible = true
	var fieldName = newTable.fieldName.text
	var fieldDatatype = "1"
	var fieldVisible = true
	var dropdown_table = "empty"
	var isDropdown = newTable.isList.pressed
	var RefName = newTable.refName.text
	var createTab = newTable.createTab.pressed
	var canDelete = true
	var add_toSaveFile = newTable.in_saveFile.pressed
	var dup_check = tableName + file_format
	
	
	if tableName == "":
		error = 4
	if keyName == "":
		if !isDropdown:
			error = 4
	elif files.has(dup_check):
		error = 5
	else:
		error = 0
	match error: 
		0: #if there are no errors detected
#			print(tableName)
			add_new_table(tableName, keyName, keyDataType, keyVisible, fieldName, fieldDatatype, fieldVisible, dropdown_table, RefName, createTab, canDelete, isDropdown, add_toSaveFile, false )
			_on_newtable_Cancel_button_up()
			_on_Close_Table_button_up()
			_ready()
			clear_cells()
			get_node("../..").create_tabs()

		4:
			error_display()
		5:
			error_display()
	error = 0


func delete_table(del_tbl_name):
	Delete_Table(del_tbl_name)
	#Clean up the display
#	_on_Close_Table_button_up()
	#Refresh the table list
	_ready()
#	update_dict()
	_on_Close_Table_button_up()
	get_node("../..").create_tabs()

###########Begin error checking functions ##########################


func error_check():
	var new_key_array = []
	error = 0
	var new_order_array = []


	for i in table.get_children():
		var id
		var array
		var temp
		var nm = i.get_name()


		if nm != "Blank" and nm != "Row" and !nm.begins_with("Column"):
			array = nm.rsplit("&")
			temp = array[1]

		if i.get_class() == "PanelContainer":
			var y = i.new_data
			if i.new_data == "" or i.new_data == null:
				id = i.previous_data
				if temp == "key":
					new_key_array += [id]
				if temp == "Order":
					new_order_array += [id]

			else:
				id = i.new_data
				if temp == "key":
					new_key_array += [id]
				if temp == "Order":
					new_order_array += [id]

	for i in new_key_array:
		var q = new_key_array.count(i)
		if q >= 2:
			error = 1
		else:
			pass

	for i in new_order_array:
		var q = new_order_array.count(i)
		if q >= 2:
			error = 2
		else:
			pass

#
func error_display(): #NEED TO UPDATE SO IT CAN BE MOVED TO ENGINE SCRIPT
	var popup = load("res://addons/UDSEngine/Database_Manager/Scenes and Scripts/UI_Input_Scenes/popup_error.tscn")
	var error_display = popup.instantiate()
	add_child(error_display)
	match error:
		1:
			print("Error 1 - Duplicate Key name")
			error_display.set_labeltext("Cannot have duplicate Key names. Values will be reset")
#			popup_error.visible = true
			update_sheet(current_table_name)
		2:
			print("Error 2 - duplicate order number")
			error_display.set_labeltext("Cannot have duplicate order numbers. Values will be reset")
#			popup_error.visible = true
			update_sheet(current_table_name)
		3:
			print("Error 3 - Key cannot be Blank")
			error_display.set_labeltext("Key cannot be Blank")
#			popup_error.visible = true
			update_sheet(current_table_name)
		4:
			print("Error 4 - Table name, key and values cannot be blank")
			error_display.set_labeltext("Table name, key and values cannot be blank")
#			popup_error.visible = true
		5:
			print("Error 5 - A table with the same name already exists")
			error_display.set_labeltext("A table with the same name already exists")


#--------Start of code used for User interface-------------------------------------


############################MIS FUNCTIONS#######################################################33




#############------------------Backup Scripts - Delete when confirmed that they are not needed------------------------------









func _on_Conver_File_Data_button_up():
	convert_keyFile_to_new_format()


func _on_Refresh_Data_button_up() -> void:
	get_main_node()._ready()
	_on_Close_Table_button_up()
	_ready()

