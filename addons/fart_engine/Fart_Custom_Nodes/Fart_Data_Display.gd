@tool
extends Control


@export var table: String = "10002"
@export var key:String = "1"
@export var field: String = "Current Map"
@export var field_type: String = "1"

var datatype_dict:Dictionary
var display_node
var field_value
var set_values_running:bool = false


func data_display():
	pass
