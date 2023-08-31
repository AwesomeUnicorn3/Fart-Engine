extends TextureProgressBar

func _ready():
	FARTENGINE.player_health_updated.connect(_on_player_health_update)
#	await FARTENGINE.DbManager_loaded
#	_on_player_health_update()


func _on_player_health_update():
	print(FARTENGINE.player_node.current_health.y)
	set_min(FARTENGINE.player_node.current_health.x)
	set_max(FARTENGINE.player_node.current_health.z)
	set_value(FARTENGINE.player_node.current_health.y)
