extends PanelContainer
tool
var previous_data = ""
var new_data = ""
var row = ""
var column = ""
var cellAddress = ""
var data_format = "String"


func initial_values():
	cellAddress = $".".get_name()
	var array = []
	array = cellAddress.rsplit(" ")
	row = array[0]
	column = array[1]
	previous_data = $input.get_text()

func update_values():
	cellAddress = $".".get_name()
	var array = []
	array = cellAddress.rsplit(" ")
	row = array[0]
	column = array[1]
	previous_data = $input.get_text()
	new_data = ""


func update_rows():
	cellAddress = $".".get_name()
	var array = []
	array = cellAddress.rsplit(" ")
	row = array[0]
	column = array[1]
	previous_data = row


func _on_input_text_entered(new_text):
	update_text()


func _on_input_focus_exited():
	update_text()

func update_text():
#Need to add
	#Check that new data is the correct format
	new_data = $input.text
	if column == "Order":
		column = previous_data
