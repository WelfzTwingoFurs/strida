shader_type canvas_item;

float random(vec2 _st) {
	return fract(sin(dot(_st.xy, vec2(12.9898,78.233))) * 43758.5453123);
}

void fragment() {
	vec2 new = UV;
	float sintime = sin(TIME);
	
	if (int(UV.y/TEXTURE_PIXEL_SIZE.y) % 2 == 0) {
		new.x += sintime/random(UV);
	} else {
		new.x -= sintime/random(UV);
	}
	
	
	if (int(UV.x/TEXTURE_PIXEL_SIZE.x) % 2 == 0) {
		new.y += sintime/random(UV);
	} else {
		new.y -= sintime/random(UV);
	}
	
	COLOR = texture(TEXTURE,new);
	} 