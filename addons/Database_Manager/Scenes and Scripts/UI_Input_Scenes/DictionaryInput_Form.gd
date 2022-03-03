extends DatabaseEngine
tool
#onready var engine = preload("res://addons/Database_Manager/DatabaseEngine.gd")
onready var input_dictionary_template = preload("res://addons/Database_Manager/Scenes and Scripts/UI_Input_Scenes/Dictionary_input.tscn")
onready var inputContainer = $VBox1/Scroll1/VBox1
var mainDictionary : Dictionary = {}
var parent_node
var source_node


func _on_Close_button_up() -> void:
	if parent_node.get_child_count() <= 1:
		parent_node.get_node("..").visible = false
	clear_input_fields()
	self.call_deferred("close_form")

func close_form():
	updateMainDict()
	source_node.inputNode.set_text(var2str(mainDictionary))
	source_node.main_dictionary = mainDictionary
	call_deferred("delete_me")

func delete_me():
	self.queue_free()

func _on_SaveChanges_button_up() -> void:
#	var dict = {}
	updateMainDict()


func updateMainDict():
	var key = ""
	for i in inputContainer.get_children():
		for j in i.get_children():
			if j.name != "DeleteButton":
				if str(j.name) != str(update_match(j)):
					mainDictionary[key][j.name] = update_match(j)
				else:
					key = update_match(j)
	
	source_node.inputNode.set_text(var2str(mainDictionary))

	source_node.main_dictionary = mainDictionary


func clear_input_fields():
	for i in inputContainer.get_children():
		i.queue_free()

func _delete_selected_list_item(itemKey := ""):
#	print(itemKey)
	#WHEN BUTTON IS PRESSED IT WILL GET THE KEY VALUE FROM IT'S PARENT NODE
	#THEN IT WILL RUN THIS SCRIPT WITH THE STRING OF THE KEY VALUE
	
	#THIS SCRIPT WILL THEN DELETE THE SELECTED KEY FROM THE MAINDICTIONARY
	mainDictionary.erase(itemKey)
	refresh_form()
	print(mainDictionary)
			#I HESITATE TO REORDER THE INPUT FIELDS BECAUSE THE VALUE IS A KEY
			#HOWEVER I WILL NEED TO CHANGE THE mainDictSizePlusOne VALUE IN THE
			# q ADD_LINE FUNCTION TO GET THE MAX KEY NUMBER RATHER THAN THE SIZE OF THE DICTIONARY

	
	
func create_input_fields():
	for i in mainDictionary:
		var input_dict : Node =  input_dictionary_template.instance()
		inputContainer.add_child(input_dict)
		input_dict.Input_field.name = str(i)
		input_dict.Input_field.inputNode.set_text(str(i))

		for j in mainDictionary[i].size() / 3:
			j += 1

			var dataType_Field = add_input_field(input_dict, input_dropDownMenu)
			dataType_Field.set_name("Datatype " + str(j))
			var tableName = "DataTypes"
			dataType_Field.selection_table_name = tableName
			dataType_Field.relatedTableName = mainDictionary[i]["TableName " + str(j)]
			dataType_Field.populate_list()
			dataType_Field.inputNode.connect("item_selected", input_dict, "item_selected")
#			dataType_Field.selectedItemName = dataType_Field.get_dataType_name(mainDictionary[i]["Datatype " + str(j)], true)

			var get_select_item = dataType_Field.get_dataType_name(mainDictionary[i]["Datatype " + str(j)], true)

			if dataType_Field.has_method("_on_Input_item_selected"):
				var itemSelected = dataType_Field._on_Input_item_selected(get_select_item)
				dataType_Field.inputNode.select(get_select_item)

			dataType_Field.labelNode.set_text("Datatype " + str(j))

			var dataType_Input = add_input_node(1, 1, "Value " + str(j), mainDictionary, input_dict, null, mainDictionary[i]["Value " + str(j)], mainDictionary[i]["Datatype " + str(j)], mainDictionary[i]["TableName " + str(j)])

			dataType_Field.relatedInputNode = dataType_Input


func _on_AddItem_button_up() -> void:
	_add_input_field()


func _add_input_field():
	var nextKeyValue :int
	
	if mainDictionary.size() == 0:
		print(mainDictionary)
		nextKeyValue = 1
	else:
		nextKeyValue = int(mainDictionary.keys().max()) + 1
	print(nextKeyValue)
	

	var defaultValue :Dictionary = { #I NEED TO FIGURE OUT A WAY TO LINK THIS WITH THE INPUT_DICTIONARY SCENE DEFAULT VALUE, 
		#POSSIBLY I CAN PUT ALL DEFAULTS IN THE DBENGINE by looping through the input scenes and setting the default in 
		#a dictionary in the engine script
"Datatype 1": "TYPE_STRING",
"Datatype 2": "TYPE_INT",
"TableName 1" : "DataTypes",
"TableName 2" : "DataTypes",
"Value 1": "Default Value1",
"Value 2": "1"
}
	mainDictionary[str(nextKeyValue)] = defaultValue
	refresh_form()


func refresh_form():
	clear_input_fields()
	create_input_fields()
