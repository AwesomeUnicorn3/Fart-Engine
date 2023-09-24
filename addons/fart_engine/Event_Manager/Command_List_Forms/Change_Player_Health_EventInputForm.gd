@tool
extends CommandForm


@onready var operation_inputNode = $Control/VBoxContainer/HBoxContainer2/ItemType_Selection
@onready var set_number_inputNode = $Control/VBoxContainer/Checkbox_Template2
@onready var health_change_inputNode = $Control/VBoxContainer/HBoxContainer2/Number_Counter3
@onready var knockback_inputNode = $Control/VBoxContainer/Number_Counter
@onready var custom_cooldown_inputNode = $Control/VBoxContainer/Number_Counter2
@onready var use_default_cooldown_inputNode = $Control/VBoxContainer/Checkbox_Template


var function_name :String = "change_player_health" #must be name of valid function

var health_change :float
var knockback :float
var custom_cooldown :float
var use_default_cooldown :bool
var set_number:bool
var operation:String

var event_name :String = ""

func _ready():
	operation_inputNode.populate_list()
	use_default_cooldown_inputNode.inputNode.toggled.connect(_on_default_cooldown_pressed)
	use_default_cooldown_inputNode.inputNode.emit_signal("toggled", true)

	set_number_inputNode.inputNode.toggled.connect(_on_set_or_change_pressed)
	set_number_inputNode.inputNode.emit_signal("toggled", false)


func set_input_values(old_function_dict :Dictionary):
	health_change_inputNode.set_input_value(old_function_dict[function_name][0])
	knockback_inputNode.set_input_value(old_function_dict[function_name][1])
	custom_cooldown_inputNode.set_input_value(old_function_dict[function_name][2])
	use_default_cooldown_inputNode.set_input_value(old_function_dict[function_name][3])
	set_number_inputNode.set_input_value(old_function_dict[function_name][4])
	operation_inputNode.set_input_value(old_function_dict[function_name][5])
	
	
func get_input_values():
#	print( what_dir_inputNode.get_input_value())
	health_change = health_change_inputNode.get_input_value()
	knockback = knockback_inputNode.get_input_value()
	custom_cooldown = custom_cooldown_inputNode.get_input_value()
	use_default_cooldown = use_default_cooldown_inputNode.get_input_value()
	set_number = set_number_inputNode.get_input_value()
	operation = operation_inputNode.get_input_value()


	event_name = commandListForm.CommandInputForm.source_node.parent_node.event_name
	var return_function_dict = {function_name : [health_change, knockback, custom_cooldown, use_default_cooldown, set_number, operation, event_name]}
	return return_function_dict


func _on_accept_button_up():
	commandListForm.CommandInputForm.function_dict = get_input_values()
	get_parent()._on_close_button_up()


func _on_default_cooldown_pressed(value:bool):
	custom_cooldown_inputNode.visible = !value#use_default_cooldown_inputNode.get_input_value()

func _on_set_or_change_pressed(value:bool):
	operation_inputNode.visible = !value
