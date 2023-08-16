extends Label


func _physics_process(delta): #NEED TO ADD THIS TO IN-GAME COMMANDS
	var fps: String = str(Engine.get_frames_per_second())
	set_text(fps)
