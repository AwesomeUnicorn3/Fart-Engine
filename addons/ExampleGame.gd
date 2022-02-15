extends Control


func _ready():
	var key1 = OS.get_scancode_string(udsmain.Static_Game_Dict['Controls']['jump']['Key1'])
	var action1 = "Push " + key1 + " To Jump"
	$HUD/VBox1/Label.set_text(str(action1))
	
	var key2 = OS.get_scancode_string(udsmain.Static_Game_Dict['Controls']['move_left']['Key1'])
	var action2 = "Push " + key2 + " Move Left"
	$HUD/VBox1/Label2.set_text(str(action2))

	var key3 = OS.get_scancode_string(udsmain.Static_Game_Dict['Controls']['move_right']['Key1'])
	var action3 = "Push " + key3 + " Move Right"
	$HUD/VBox1/Label3.set_text(str(action3))
