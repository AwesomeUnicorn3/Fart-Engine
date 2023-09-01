extends TextureProgressBar

func _ready():
	FART.player_health_updated.connect(_on_player_health_update)
#	await FART.DbManager_loaded
#	_on_player_health_update()


func _on_player_health_update():
	print(FART.player_node.current_health.y)
	set_min(FART.player_node.current_health.x)
	set_max(FART.player_node.current_health.z)
	set_value(FART.player_node.current_health.y)
