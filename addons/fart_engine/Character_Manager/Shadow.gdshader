shader_type canvas_item;
uniform float light_source = 50.0;
uniform vec2 sprite_size = vec2(130,120);
varying vec2 new_uv;
varying vec2 vert;

void vertex(){
	
//	COLOR.a += -abs(sin(VERTEX.x * TIME));
//	VERTEX.x += light_source;
	new_uv = vec2(VERTEX.x/sprite_size.y, VERTEX.y/sprite_size.x);
	VERTEX.x += -( new_uv.y - .5) * light_source;
	VERTEX.y += 1.0- (new_uv.y - .5) * light_source ;

}

void fragment() {
	
	vec4 shadow = texture(TEXTURE, UV);
	vec4 return_color = vec4(0.0,0.0,0.0,shadow.a * 0.5);
	COLOR = return_color;
}


