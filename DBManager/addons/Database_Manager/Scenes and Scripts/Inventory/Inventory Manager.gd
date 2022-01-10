extends Control
tool
onready var table_list = $VBox1/HBox2/Scroll1/Table_Buttons
onready var item_name_label = $VBox1/HBox2/Panel1/Item_Name_Label
var btn_itemselect = preload("res://addons/Database_Manager/Scenes and Scripts/Inventory/Btn_ItemSelect.tscn")
var item_list = {}
var item_data = {}


func _on_Inventory_Manager_visibility_changed():
	if visible:
		item_list = import_data("res://addons/Database_Manager/Data/Items_Row") 
		item_data = import_data("res://addons/Database_Manager/Data/Items.json")
		reload_buttons()
	else:
		clear_data()
		clear_buttons()

func clear_buttons():
	for i in table_list.get_children():
		i.queue_free()

func reload_buttons():
	clear_buttons()
	create_table_buttons()

func clear_data():
	item_name_label.set_text("")

func enable_all_buttons():
	for i in table_list.get_children():
		i.disabled = false

func refresh_data(item_name : String):
	enable_all_buttons()
	clear_data()
	item_name_label.set_text(item_name)
	table_list.get_node(item_name).disabled = true

func create_table_buttons():
	 #Loop through the item_list dictionary and add a button for each item
	for i in item_list["Row"].size():
		var item_number = str(i + 1)
		var newbtn = btn_itemselect.instance()
		table_list.add_child(newbtn)
		var label = item_list["Row"][item_number]
		newbtn.set_name(label)
		newbtn.get_node("Label").set_text(label)


func import_data(table_loc):
	var curr_tbl_data = {}
	var currdata_file = File.new()
	if currdata_file.open(table_loc, File.READ) != OK:
		print(table_loc)
		print("Error Could not open file")
	else:
		currdata_file.open(table_loc, File.READ)
		var currdata_json = JSON.parse(currdata_file.get_as_text())
		curr_tbl_data = currdata_json.result
		currdata_file.close()
		return curr_tbl_data
