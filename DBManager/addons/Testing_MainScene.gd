extends Control


func _ready():
	var dict = udsmain.Static_Game_Dict['Items']['Chode']['Type']
	$Label.set_text(str(dict))

