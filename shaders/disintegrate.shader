shader_type canvas_item;

float random(vec2 _st) {
	return fract(sin(dot(_st.xy, vec2(12.9898,78.233))) * 43758.5453123);
}

void fragment() {
	vec2 new = UV;
	
	new.x = UV.x + sin(TIME) * random(UV);
	//new.y = UV.y + sin(TIME) * random(UV);
	
		if (UV.y > 0.5) {
			new.y = UV.y + sin(TIME) * random(UV);}
		else {
			new.y = UV.y - sin(TIME) * random(UV);}
	
	
	COLOR = texture(TEXTURE,new);
	} 