shader_type spatial;
uniform sampler2D color_ramp;

void vertex() {
	// Called for every vertex the material is visible on.
}

vec2 random(vec2 uv) {
	return vec2(fract(sin(dot(uv.xy,
		vec2(12.9898,78.233))) * 43758.5453123));
}

float worley(vec2 uv, float columns, float rows) {
	
	vec2 index_uv = floor(vec2(uv.x * columns, uv.y * rows));
	vec2 fract_uv = fract(vec2(uv.x * columns, uv.y * rows));
	
	float minimum_dist = 1.0;  
	
	for (int y= -1; y <= 1; y++) {
		for (int x= -1; x <= 1; x++) {
			vec2 neighbor = vec2(float(x),float(y));
			vec2 point = random(index_uv + neighbor);
			
			float speed = 4.5;
			point = vec2( cos(TIME * point.x * speed), sin(TIME * point.y * speed) ) * 0.5 + 0.5;


			vec2 diff = neighbor + point - fract_uv;
			float dist = length(diff);
			minimum_dist = min(minimum_dist, dist);
		}
	}
	
	return minimum_dist;
}

void fragment() {
	float worley = worley(UV + TIME*0.00001f, 400.0f, 400.0f);
	float color = texture(color_ramp, vec2(worley)).r;
	color = min(0.999,color);
	color = log(0.999) / log(color);
	color *= 20.0f;
	EMISSION = vec3(color);
	ALPHA = color;
}


//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
