shader_type canvas_item;
uniform vec2 timer = vec2(0.0, 0.0);

void fragment() {
	if (COLOR.a != 0.0) {
		vec2 new = UV;
		
		if (int(UV.y/TEXTURE_PIXEL_SIZE.y) % 2 == 0) {
			new.x = UV.x+timer.x;}//SIN(TIME) will make a smooth loop
		else {
			new.x = UV.x-timer.x;
		}
		
		
		if (int(UV.x/TEXTURE_PIXEL_SIZE.x) % 2 == 0) {
			new.y = UV.y+timer.y;}
		else {
			new.y = UV.y-timer.y;
		}
		
		
		COLOR = texture(TEXTURE,new);}
	}

//UV.x/TEXTURE_PIXEL_SIZE.x to get the value of UV.x in actual pixels
//float random(vec2 _st) {
//	return fract(sin(dot(_st.xy, vec2(12.9898,78.233))) * 43758.5453123);
//}
	//float sintime = sin(TIME);
	//float rand1 = random(UV);
	//float rand2 = random(vec2(sintime,sintime));
