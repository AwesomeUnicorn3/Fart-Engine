extends Control
tool
onready var column = preload("res://addons/Database_Manager/Scenes and Scripts/Column.tscn")
onready var row = preload("res://addons/Database_Manager/Scenes and Scripts/Row.tscn")
onready var datainput = preload("res://addons/Database_Manager/Scenes and Scripts/DataInput.tscn")
onready var table = $ScrollContainer/GridConainer
onready var main_page = get_node("../../../..")
var popup_error 
var table_data = {}
var row_header_values = []
var column_header_values = []
var row_header_order = {}
var column_header_order = {}
var column_header_orderA = []
var table_name = ""
var adj_table_name = ""
var cName
var columnCount = 1
var index = 0
var file_format = ".json"
var adj_file_format = ""
var RCT = "T"
var data_type = ""
var main_tbl = {}
var error = 0
var old_order_array = []
var new_order_array = []
var row_count = 0
var new_key_array = []
var blankX = 0
var blankY = 0
var h = 0
var v = 0


func _ready():
	popup_error = main_page.get_node("Popups/popup_error")

func _process(delta):
	h = $ScrollContainer.get_h_scroll()
	v = $ScrollContainer.get_v_scroll()


func update_sheet(name, rct):
	blankX = 0
	#Clear and reset arrays, dictionaries, and variables
	RCT = rct
	columnCount = 1
	row_header_order = {}
	column_header_order = {}
	row_header_values = []
	column_header_values = []
	table_name = name
	table_data = {}
	#remove any previous data
	clear_cells()


	match RCT:
		
		"T":
			data_type = "Table"
			var tabledata_file = File.new()
			tabledata_file.open(main_page.save_path + table_name + file_format, File.READ)
			var tabledata_json = JSON.parse(tabledata_file.get_as_text())
			tabledata_file.close()
			table_data = tabledata_json.result
			
			var rowdata_file = File.new()
			rowdata_file.open(main_page.save_path + table_name + "_Row", File.READ)
			var rowdata_json = JSON.parse(rowdata_file.get_as_text())
			rowdata_file.close()
			row_header_order = rowdata_json.result
			
			var columndata_file = File.new()
			columndata_file.open(main_page.save_path + table_name + "_Column", File.READ)
			var columndata_json = JSON.parse(columndata_file.get_as_text())
			columndata_file.close()
			column_header_order = columndata_json.result
			
			var temp = row_header_order["Row"].size()
			for i in row_header_order["Row"].size():
				var t = str(i + 1)
				row_header_values += [row_header_order["Row"][t]]
			#create column header array
			column_header_orderA = []
			for n in column_header_order["Column"].size():
				var t = str(n + 1)
				var p = int(t)
				column_header_orderA +=  [t]
				
			for n in column_header_orderA:
				column_header_values += [column_header_order["Column"][n]]
			
			#create column header cells
			for i in column_header_values:
				columnCount += 1
				var newcell = column.instance()
				table.add_child(newcell)
				newcell.set_text(str(i))
			#set the number of columns in the grid Container
			table.columns = columnCount

			#create row header cells
			for i in row_header_values:
				var index = 0
				var newcell = row.instance()
				table.add_child(newcell)
				newcell.set_text(str(i))

				# for each row header cell, create data cells
				for n in column_header_values.size():
					var Columnname = column_header_values[index]
					var newinput = datainput.instance()
					table.add_child(newinput)

					var y = table_data[i][column_header_values[n]]
					var keyname = remove_special_char(i)
					var columnname = remove_special_char(Columnname)
					newinput.set_name(keyname + " " + columnname)
					newinput.get_node("input").set_text(str(y))
					newinput.initial_values()
					index += 1
				
		"R":
			data_type = "Row"
			update_sheet_RC()
		"C":
			data_type = "Column"
			update_sheet_RC()



func error_check():
	error = 0
	old_order_array = []
	new_order_array = []
	row_count = 0
	new_key_array = []
	#Get Row Count
	for i in table_data[data_type]:
		old_order_array += [i]
	row_count = old_order_array.max()

	# Get new data and order of keys
	for i in table.get_children():
		var id
		var array
		var temp
		var nm = i.get_name()
		if nm != "Blank" and nm != "Row" and nm != "Column":
			array = nm.rsplit(" ")
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


func error_display():
	match error:
		1:
			print("Error 1 - Duplicate Key name")
			popup_error.set_text("Cannot have duplicate Key names. Values will be reset")
			popup_error.visible = true
			update_sheet(table_name, RCT)
		2:
			print("Error 2 - duplicate order number")
			popup_error.set_text("Cannot have duplicate order numbers. Values will be reset")
			popup_error.visible = true
			update_sheet(table_name, RCT)
		3:
			print("Error 3 - Key cannot be Blank")
			popup_error.set_text("Key cannot be Blank")
			popup_error.visible = true
			update_sheet(table_name, RCT)
		4:
			print("Error 4 - Table name, key and values cannot be blank")
			popup_error.set_text("Table name, key and values cannot be blank")
			popup_error.visible = true
		5:
			print("Error 5 - A table with the same name already exists")
			popup_error.set_text("A table with the same name already exists")

func update_dict():
	error = 0
#when save button pressed
	match RCT:
		"T":
			var row_dict = {}
			var column_dict = {}
			for i in table_data:
				row_dict[remove_special_char(i)] = i
			for i in row_dict:
				var key = row_dict[i]
				for u in table_data[key]:
					column_dict[remove_special_char(u)] = u
			for e in table.get_children():
				if e.get_class() == "PanelContainer":
					var Row = e.row
					var rowname = remove_special_char(Row)
					var Rowname = row_dict[rowname]
					var Column = e.column
					var Columnname = column_dict[Column]
					var temp = e.new_data
					if e.new_data != "" and e.new_data != null:
						table_data[Rowname][Columnname] = e.new_data
			adj_file_format = file_format
			adj_table_name = table_name
			save_data()
			update_sheet(table_name, RCT)
		"R":
			error_check()
			if error == 0:
				index = 1
				for e in table.get_children():
					if e.get_class() == "PanelContainer":
						var Row = e.row
						var new = e.new_data
						var prev = e.previous_data
						var Prevnodename = remove_special_char(prev)
						var Newnodename =  remove_special_char(new)
						var array = e.get_name().rsplit(" ")
						var type = array[1]
						var nm = array[0]
						if type == "key":
							if new == "" or new == null:
								table_data["Row"][str(index)] = prev
							else:
								table_data["Row"][str(index)] = new
								e.set_name(Newnodename + " key")
								e.update_values()
								e.new_data = ""

								
								#in order to find the correct node, all special characters must be removed from the name
								var d = table.get_node(".").get_node(Prevnodename + " Order")
								d.set_name(Newnodename + " Order")
								d.update_rows()
								#update and save main table with new key
								main_tbl = {}
								var main_tbl_data_file = File.new()
								main_tbl_data_file.open(main_page.save_path + table_name + file_format, File.READ)
								var data_json = JSON.parse(main_tbl_data_file.get_as_text())
								main_tbl_data_file.close()
								main_tbl = data_json.result
								var test = {}
								var test2 = {}
								test = main_tbl[prev]
								main_tbl.erase(prev)
								main_tbl[new] = test
								adj_table_name = table_name
								adj_file_format = file_format
								var tbldta = table_data
								table_data = main_tbl
								save_data()
								table_data = tbldta

							index += 1
				var tmpTable_data = table_data.duplicate(true)
				for e in table.get_children():
					if e.get_class() == "PanelContainer":
						var array = e.get_name().rsplit(" ")
						var type = array[1]
						var nm = array[0]
						if type != "key":
							var Row = e.row
							var new = e.new_data
							var prev = e.previous_data
							if new != "":
								var u = tmpTable_data["Row"][prev]
								table_data["Row"][new] = u
				adj_file_format = ""
				adj_table_name = table_name + "_Row"
				save_data()
				update_sheet(table_name, RCT)
			else:
				error_display()

		"C":
			error_check()
			if error == 0:
				index = 1
				for e in table.get_children():
					if e.get_class() == "PanelContainer":
						var Row = e.row
						var new = e.new_data
						var prev = e.previous_data
						var Prevnodename = remove_special_char(prev)
						var Newnodename =  remove_special_char(new)
						var array = e.get_name().rsplit(" ")
						var type = array[1]
						var nm = array[0]
						if type == "key":
							if new == "" or new == null:
								table_data["Column"][str(index)] = prev
							else:
								table_data["Column"][str(index)] = new
								e.set_name(Newnodename + " key")
								e.update_values()
								e.new_data = ""
								var d = table.get_node(".").get_node(Prevnodename + " Order")
								d.set_name(Newnodename + " Order")
								d.update_rows()
								#update and save main table with new key
								main_tbl = {}
								var main_tbl_data_file = File.new()
								main_tbl_data_file.open(main_page.save_path + table_name + file_format, File.READ)
								var data_json = JSON.parse(main_tbl_data_file.get_as_text())
								main_tbl_data_file.close()
								main_tbl = data_json.result
								
								var tbldta = table_data
								for k in main_tbl.keys():
									var test = {}
									var test2
									test = main_tbl[k]
									test2 = main_tbl[k][prev]
									test.erase(prev)
									test[new] = test2
									main_tbl.erase(k)
									main_tbl[k] = test
									adj_table_name = table_name
									adj_file_format = file_format
								table_data = main_tbl
								save_data()
								table_data = tbldta
							index += 1
				var tmpTable_data = table_data.duplicate(true)
				for e in table.get_children():
					if e.get_class() == "PanelContainer":
						var array = e.get_name().rsplit(" ")
						var type = array[1]
						var nm = array[0]
						if type != "key":
							var Row = e.row
							var new = e.new_data
							var prev = e.previous_data
							if new != "":
								var u = tmpTable_data["Column"][prev]
								table_data["Column"][new] = u
				adj_file_format = ""
				adj_table_name = table_name + "_Column"
				save_data()
				update_sheet(table_name, RCT)
			
			else:
				error_display()


func save_data():
#Save dictionary to .json upon user confirmation
	var save_file = File.new()
	var sv_path = main_page.save_path + adj_table_name + adj_file_format
	if save_file.open(sv_path, File.WRITE) != OK:
		print("Error Could not update file")
	else:
		var save_d = table_data
		save_file.open(sv_path, File.WRITE)
		save_d = to_json(save_d)
		save_file.store_line(save_d)
		save_file.close()


func clear_cells():
	for n in table.get_children():
		if n.get_name() != "Blank":
			table.remove_child(n)
			n.queue_free()

func update_sheet_RC():
	var RC = ""
	match RCT:
		"R":
			RC = "Row"
		"C":
			RC = "Column"
	var tabledata_file = File.new()
	tabledata_file.open(main_page.save_path + table_name + "_" + RC, File.READ)
	var tabledata_json = JSON.parse(tabledata_file.get_as_text())
	tabledata_file.close()
	table_data = tabledata_json.result
	column_header_orderA = []
	for n in table_data[RC].size():
		var t = str(n + 1)
		column_header_orderA +=  [t]
	column_header_values = column_header_orderA
	for n in column_header_orderA:
		row_header_values += [table_data[RC][n]]

	#create column header cells
	columnCount += 1
	var newcolumn = column.instance()
	table.add_child(newcolumn)
	newcolumn.set_text("Order")
	#set the number of columns in the grid Container
	table.columns = columnCount
	index = 0
	#create row header cells
	for i in row_header_values:
		var newcell = datainput.instance()
		table.add_child(newcell)
		newcell.get_node("input").set_text(str(i))
		var t = remove_special_char(i)
		newcell.set_name(t + " key")
		newcell.initial_values()

		# for each row header cell, create data cells
		var columnname = "Order"
		var newinput = datainput.instance()
		table.add_child(newinput)
		var y = column_header_values[index]
		var q = remove_special_char(i)
		newinput.set_name(q + " " + columnname)
		newinput.get_node("input").set_text(str(y))
		newinput.initial_values()
		index += 1

func deleteKeys(key, key_name):
	var tmparray = {}
	table_data[data_type].erase(key)
	var id = 1
	var tmp
	for i in table_data[data_type].size():
		var r = i + 1
		if table_data[data_type].has(str(r)):
			tmparray[str(id)] =  table_data[data_type][str(r)]
		else:
			tmparray[str(id)] = table_data[data_type][str(r + 1)]
			table_data[data_type].erase(str(r + 1))
		id += 1

	table_data[data_type].clear()
	table_data[data_type] = tmparray
	adj_file_format = ""
	adj_table_name = table_name + "_" + data_type
	save_data()

	main_tbl = {}
	var main_tbl_data_file = File.new()
	main_tbl_data_file.open(main_page.save_path + table_name + file_format, File.READ)
	var data_json = JSON.parse(main_tbl_data_file.get_as_text())
	main_tbl_data_file.close()
	main_tbl = data_json.result
	match data_type:
		"Row":
			main_tbl.erase(key_name)
			adj_table_name = table_name
			adj_file_format = file_format
			var tbldta = table_data
			table_data = main_tbl
			save_data()
			table_data = tbldta

		"Column":
			for n in main_tbl:
				main_tbl[n].erase(key_name)
			adj_table_name = table_name
			adj_file_format = file_format
			var tbldta = table_data
			table_data = main_tbl
			save_data()
			table_data = tbldta

	update_sheet(table_name, RCT)


func add_key(new_key):
	error_check()
	if new_key == "":
		error = 3
	var q = new_key_array.count(new_key)
	if q >= 1:
		error = 1
	if error == 0:
		var id = 1
		var keyarr = []
		var empty = false
		for n in table_data[data_type]:
			keyarr += [n]
		for n in keyarr:
			if empty == true:
				pass
			elif str(id) in keyarr:
				id += 1
			else:
				empty = true
		table_data[data_type][str(id)] = new_key
		adj_file_format = ""
		adj_table_name = table_name + "_" + data_type
		save_data()
		#add new key to main table
		match RCT:
			"R":
				main_tbl = {}
				var main_tbl_data_file = File.new()
				main_tbl_data_file.open(main_page.save_path + table_name + file_format, File.READ)
				var data_json = JSON.parse(main_tbl_data_file.get_as_text())
				main_tbl_data_file.close()
				main_tbl = data_json.result
				var key_array = []
				var key_ex = ""
				var new_key_dict = {}
				key_array = main_tbl.keys()
				key_ex = key_array[0]
				new_key_dict = main_tbl[key_ex]
				new_key_dict = new_key_dict.duplicate(true)
				for i in new_key_dict.keys():
					new_key_dict[i] = "empty"
				main_tbl[new_key] = new_key_dict
				adj_table_name = table_name
				adj_file_format = file_format
				var tbldta = table_data
				table_data = main_tbl
				save_data()
				table_data = tbldta
				update_sheet(table_name, RCT)
	
			"C":
				main_tbl = {}
				var main_tbl_data_file = File.new()
				main_tbl_data_file.open(main_page.save_path + table_name + file_format, File.READ)
				var data_json = JSON.parse(main_tbl_data_file.get_as_text())
				main_tbl_data_file.close()
				main_tbl = data_json.result
				var key_array = []
				var new_key_dict = {}
				for n in main_tbl:
					main_tbl[n][new_key] = "empty"
				adj_table_name = table_name
				adj_file_format = file_format
				var tbldta = table_data
				table_data = main_tbl
				save_data()
				table_data = tbldta
				update_sheet(table_name, RCT)
	else:
		error_display()


func remove_special_char(text : String):
	var array = [":", "/", "." , " ", "_"]
	var result = text
	for i in array:
		result = result.replace(i, "")
	return result

func get_x():
	blankX = $ScrollContainer/GridConainer/Blank.rect_size
	return blankX.x

func get_y():
	blankY = $ScrollContainer/GridConainer/Blank.rect_size
	return blankY.y
