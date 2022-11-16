shader_type canvas_item;

void fragment() {
	if (COLOR.a != 0.0) {
		vec2 new = UV;
		
		new.x = UV.x+sin(TIME+UV.y+UV.x)/2.0;
		
		
		COLOR = texture(TEXTURE,new);}
	}