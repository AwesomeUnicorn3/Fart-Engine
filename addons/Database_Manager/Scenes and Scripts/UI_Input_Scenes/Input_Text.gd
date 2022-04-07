extends InputEngine
tool

func _init() -> void:
	type = "TYPE_STRING"

#func _ready():
#
#	default = "Default Text"

#TEMPLATE FOR IF I DECIDE TO MOVE THE SET/GET FUNCTIONS FROM DATABASEENGINE TO INDIVIDUAL INPUT SCENES
func set_input_data(value):
	inputNode.set_text(value)
	input_data = value

func get_input_data():
	return input_data

