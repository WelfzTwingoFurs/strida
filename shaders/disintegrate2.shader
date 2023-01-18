shader_type canvas_item;

uniform float timer = 0.0;

float random(vec2 _st) {
	return fract(sin(dot(_st.xy, vec2(12.9898,78.233))) * 43758.5453123);
}

void fragment() {
	vec2 new = UV;
	//float sintime = sin(TIME);
	
	if (int(UV.y/TEXTURE_PIXEL_SIZE.y) % 2 == 0) {
		new.x += timer/random(UV);
	} else {
		new.x -= timer/random(UV);
	}
	
	
	if (int(UV.x/TEXTURE_PIXEL_SIZE.x) % 2 == 0) {
		new.y += timer/random(UV);
	} else {
		new.y -= timer/random(UV);
	}
	
	COLOR = texture(TEXTURE,new);
	} 