extends Control


func _ready() -> void:
	$VBox1/VBox1/GameTitle.set_text(await FART.get_game_title())
