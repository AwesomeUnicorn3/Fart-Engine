extends ColorRect


func update_label(new_value:int):
	var text_value:String = str(new_value)
	$TextureRect/Label.set_text(text_value)

func update_texture(new_texture:Texture2D):
	$TextureRect.set_texture(new_texture)
