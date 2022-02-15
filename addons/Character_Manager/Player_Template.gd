extends Character



func _ready() -> void:
	var characterBody = $Body/FullBody
	var frameVector : Vector2 = udsmain.convert_string_to_Vector(characterSprite[1])
	characterBody.set_texture(load(characterSprite[0]))
	characterBody.set_vframes(frameVector.x)
	characterBody.set_hframes(frameVector.y)
	
	#SET COLLISION SHAPE = TO SPRITE SIZE

func _physics_process(delta: float) -> void:
	velocity = move_and_slide(velocity, Vector2.UP)
