extends Node2D

#onready var HUD = $UI/HUD
#onready var Save_Label = $UI/HUD/Label


#func _init() -> void:
#	print(get_parent().get_node_or_null(get_parent().get_path()))

func _ready():
	print("ExampleGameLoaded")
#	udsmain.new_game()
#	var key = OS.get_scancode_string(udsmain.Static_Game_Dict['Controls']['move_up']['Key1'])
#	var action = "Push " + key + " To Move Up"
#	$HUD/VBox1/Label.set_text(str(action))
#
#	key = OS.get_scancode_string(udsmain.Static_Game_Dict['Controls']['move_down']['Key1'])
#	action = "Push " + key + " To Move Down"
#	$HUD/VBox1/Label2.set_text(str(action))
#
#	key = OS.get_scancode_string(udsmain.Static_Game_Dict['Controls']['move_left']['Key1'])
#	action = "Push " + key + " Move Left"
#	$HUD/VBox1/Label3.set_text(str(action))
#
#	key = OS.get_scancode_string(udsmain.Static_Game_Dict['Controls']['move_right']['Key1'])
#	action = "Push " + key + " Move Right"
#	$HUD/VBox1/Label4.set_text(str(action))



