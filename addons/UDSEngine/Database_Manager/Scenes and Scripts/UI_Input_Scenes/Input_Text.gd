@tool
extends InputEngine

func _init() -> void:
	type = "1"

#func startup():
#	inputNode = $Input
#	labelNode = $Label/HBox1/Label_Button
	

#TEMPLATE FOR IF I DECIDE TO MOVE THE SET/GET FUNCTIONS FROM DATABASEENGINE TO INDIVIDUAL INPUT SCENES
func set_input_data(value):
	inputNode.set_text(value)
	input_data = value

func get_input_data():
	return input_data

