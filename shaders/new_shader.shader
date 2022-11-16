shader_type canvas_item;
uniform vec2 timer = vec2(0.0, 0.0);

float random(vec2 _st) {
    return fract(sin(dot(_st.xy, vec2(12.9898,78.233))) * 43758.5453123);
}

void fragment() {
	if (COLOR.a != 0.0) {
		vec2 new = UV;
		
		new.x = UV.x*sin(UV.x+TIME);
		//new.y = random(UV+TIME);
		
		COLOR = texture(TEXTURE,new);}
	}
//UV.x/TEXTURE_PIXEL_SIZE.x to get the value of UV.x in actual pixels
	//float sintime = sin(TIME);
	//float rand1 = random(UV);
	//float rand2 = random(vec2(sintime,sintime));
