@tool
extends Control

signal button_clicked
signal delete_key

var index :String



func clicked_signal(is_new_key :bool = false):
	emit_signal("button_clicked", index, is_new_key)


func delete_selected_key():
	emit_signal("delete_key", index)
