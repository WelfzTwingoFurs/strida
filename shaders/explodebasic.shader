shader_type canvas_item;

void fragment() {
	if (COLOR.a != 0.0) {
		vec2 new = UV;
		
		if (UV.x > 0.5) {
			new.x += sin(TIME);}
		else {
			new.x -= sin(TIME);}
		
		if (UV.y > 0.5) {
			new.y += sin(TIME);}
		else {
			new.y -= sin(TIME);}
		
		
		
		COLOR = texture(TEXTURE,new);}
	}