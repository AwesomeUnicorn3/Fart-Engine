extends HBoxContainer

var file_name := ""
var parent_container : Node
# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass


func _on_Load_button_up() -> void:
	FART.load_game(file_name)
#	FART.root.get_node("UI/TitleScreen").visible = false
	#SET PLAYER POSITION
#	FARTset_player_position()
#	parent_container.remove_load_menu()


func _on_Delete_button_up() -> void:
	FART.delete_save_file(file_name)
	parent_container.clear_save_file_list()
	parent_container._ready()
