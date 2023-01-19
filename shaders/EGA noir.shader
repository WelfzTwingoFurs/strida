shader_type canvas_item;

float random(vec2 _st) {
	return fract(sin(dot(_st.xy, vec2(12.9898,78.233))) * 43758.5453123);
}

void fragment() {
	COLOR = texture(TEXTURE,UV);
	
	float r32 = 84.0/255.0;
	float r98 = 252.0/255.0;
	float r65 = 168.0/255.0;
	
	vec4 c0 = vec4(0.0, 0.0, 0.0, 0.0);
	vec4 c1 = vec4(r32, r32, r32, 1.0);
	vec4 c2 = vec4(r32, r32, r98, 1.0);
	vec4 c3 = vec4(r32, r98, r32, 1.0);
	vec4 c4 = vec4(r32, r98, r98, 1.0);
	vec4 c5 = vec4(r98, r32, r32, 1.0);
	vec4 c6 = vec4(r98, r32, r98, 1.0);
	vec4 c7 = vec4(r98, r98, r32, 1.0);
	vec4 c8 = vec4(r98, r98, r98, 1.0);
	vec4 c9 = vec4(0.0, 0.0, 0.0, 1.0);
	vec4 c10 = vec4(0.0, 0.0, r65, 1.0);
	vec4 c11 = vec4(0.0, r65, 0.0, 1.0);
	vec4 c12 = vec4(0.0, r65, r65, 1.0);
	vec4 c13 = vec4(r65, 0.0, 0.0, 1.0);
	vec4 c14 = vec4(r65, 0.0, r65, 1.0);
	vec4 c15 = vec4(r65, r32, 0.0, 1.0);
	vec4 c16 = vec4(r65, r65, r65, 1.0);
	
	if (COLOR == c1) {COLOR = c1;}
	
	else if (COLOR == c2) {
		if (int(UV.y/TEXTURE_PIXEL_SIZE.y) % 2 == 0)
			if (int(UV.x/TEXTURE_PIXEL_SIZE.x) % 2 == 0) {COLOR = c1;}
			else {COLOR = c9;}
			
		else
			if (int(UV.x/TEXTURE_PIXEL_SIZE.x) % 2 == 0) {COLOR = c9;}
			else {COLOR = c1;}}
	
	else if (COLOR == c3) {
		if (int(UV.y/TEXTURE_PIXEL_SIZE.y) % 2 == 0)
			if (int(UV.x/TEXTURE_PIXEL_SIZE.x) % 2 == 0) {COLOR = c8;}
			else {COLOR = c9;}
			
		else
			if (int(UV.x/TEXTURE_PIXEL_SIZE.x) % 2 == 0) {COLOR = c9;}
			else {COLOR = c8;}}
	
	else if (COLOR == c4) {
		if (int(UV.y/TEXTURE_PIXEL_SIZE.y) % 2 == 0)
			if (int(UV.x/TEXTURE_PIXEL_SIZE.x) % 2 == 0) {COLOR = c8;}
			else {COLOR = c1;}
			
		else
			if (int(UV.x/TEXTURE_PIXEL_SIZE.x) % 2 == 0) {COLOR = c1;}
			else {COLOR = c8;}}
	
	else if (COLOR == c5) {
		if (int(UV.y/TEXTURE_PIXEL_SIZE.y) % 2 == 0)
			if (int(UV.x/TEXTURE_PIXEL_SIZE.x) % 2 == 0) {COLOR = c16;}
			else {COLOR = c1;}
			
		else
			if (int(UV.x/TEXTURE_PIXEL_SIZE.x) % 2 == 0) {COLOR = c1;}
			else {COLOR = c16;}}
	
	else if (COLOR == c6) {COLOR = c16;}
	
	else if (COLOR == c7) {
		if (int(UV.y/TEXTURE_PIXEL_SIZE.y) % 2 == 0)
			if (int(UV.x/TEXTURE_PIXEL_SIZE.x) % 2 == 0) {COLOR = c8;}
			else {COLOR = c16;}
			
		else
			if (int(UV.x/TEXTURE_PIXEL_SIZE.x) % 2 == 0) {COLOR = c16;}
			else {COLOR = c8;}}
	
	else if (COLOR == c8) {COLOR = c8;}
	else if (COLOR == c9) {COLOR = c9;}
	else if (COLOR == c10) {COLOR = c9;}
	else if (COLOR == c11) {COLOR = c1;}
	
	else if (COLOR == c12) {
		if (int(UV.y/TEXTURE_PIXEL_SIZE.y) % 2 == 0)
			if (int(UV.x/TEXTURE_PIXEL_SIZE.x) % 2 == 0) {COLOR = c16;}
			else {COLOR = c9;}
			
		else
			if (int(UV.x/TEXTURE_PIXEL_SIZE.x) % 2 == 0) {COLOR = c9;}
			else {COLOR = c16;}}
	
	else if (COLOR == c13) {
		if (int(UV.y/TEXTURE_PIXEL_SIZE.y) % 2 == 0)
			if (int(UV.x/TEXTURE_PIXEL_SIZE.x) % 2 == 0) {COLOR = c1;}
			else {COLOR = c9;}
			
		else
			if (int(UV.x/TEXTURE_PIXEL_SIZE.x) % 2 == 0) {COLOR = c9;}
			else {COLOR = c1;}}
	
	else if (COLOR == c14) {
		if (int(UV.y/TEXTURE_PIXEL_SIZE.y) % 2 == 0)
			if (int(UV.x/TEXTURE_PIXEL_SIZE.x) % 2 == 0) {COLOR = c1;}
			else {COLOR = c9;}
			
		else
			if (int(UV.x/TEXTURE_PIXEL_SIZE.x) % 2 == 0) {COLOR = c9;}
			else {COLOR = c1;}}
	
	else if (COLOR == c15) {COLOR = c1;}
	else if (COLOR == c16) {COLOR = c16;}
	else {COLOR = c0;}
	}