@tool
extends DatabaseEngine

signal save_complete

@onready var conditionLineItem = preload("res://addons/fart_engine/Event_Manager/Condition_line_item.tscn")
@onready var inputContainer = $VBox1/Scroll1/VBox1
var mainDictionary : Dictionary = {}
var local_variable_dictionary : Dictionary 
var par_node
var source_node
var tab_node = null


func _on_Close_button_up() -> void:
	emit_signal("save_complete")
	_on_SaveChanges_button_up()
	self.call_deferred("close_form")


func close_form():
	call_deferred("delete_me")


func delete_me():
	self.queue_free()


func _on_SaveChanges_button_up() -> void:
	mainDictionary = get_input_values()


func clear_input_fields():
	for i in inputContainer.get_children():
		i.queue_free()



func _delete_selected_list_item(itemKey := ""):
	mainDictionary.erase(itemKey)
	refresh_form()


func _on_AddItem_button_up() -> void:
	_add_input_field()


func _add_input_field():
	_on_SaveChanges_button_up()
	var nextKeyValue :int
	if mainDictionary.size() == 0:
		nextKeyValue = 1
	else:
		nextKeyValue = (mainDictionary.keys().max()).to_int() + 1
	mainDictionary[str(nextKeyValue)] = {}
	refresh_form()
	_on_SaveChanges_button_up()


func refresh_form():
	clear_input_fields()
	set_input_values(mainDictionary)


func get_input_values():
	var return_val :Dictionary = {}
	for node in inputContainer.get_children():
		return_val[node.get_key_ID()] = node.get_input_value()
	return return_val


func set_input_values(input_value:Dictionary):
	for condition_line in input_value:
		var condition_line_node = conditionLineItem.instantiate()
		inputContainer.add_child(condition_line_node)
		condition_line_node.key_display.inputNode.set_text(condition_line)
		#SET VALUES IN CONDITION LINE NODE
		await get_tree().create_timer(0.5).timeout
		condition_line_node.set_input_values(input_value[condition_line])

	mainDictionary = input_value
