shader_type canvas_item;

void fragment() {
	vec4 shadow = texture(TEXTURE, UV);
	vec4 return_color = vec4(0.0,0.0,0.0,shadow.a * 0.5);

	COLOR = return_color;
}