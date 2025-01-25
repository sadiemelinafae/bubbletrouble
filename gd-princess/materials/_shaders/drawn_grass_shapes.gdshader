shader_type spatial;
render_mode cull_disabled, shadows_disabled;

uniform vec4 A : source_color = vec4(1, 1, 1, 1);
uniform vec4 B : source_color = vec4(1, 1, 1, 1);
uniform vec4 multiply : source_color = vec4(1, 1, 1, 1);

uniform sampler2D Texture : repeat_disable;

//
// WIND
//

// Wind settings.
uniform float speed = 1.0;
uniform float offset = 0;
uniform float detail = 1.0;
uniform float strengthfactor = 2.0;
uniform sampler2D WindNoise;
uniform float WindTilted = 0.5;

void vertex() {
    float time = TIME * speed + offset;
	
	vec2 NoiseLocation = VERTEX.xz * detail + vec2(time, 0);
	float strength = strengthfactor * (texture(WindNoise, NoiseLocation).r - 0.5 + WindTilted/2.0);
	
	float wind = strength * max(0.0, COLOR.g);
    VERTEX.x += wind;
	
	//
	// Make it look good when shown from above
	//
	
	// 1. how much are we looking from above
	vec3 view = (vec4(VERTEX + vec3(0, 0, 1), 1.0) * MODELVIEW_MATRIX).xyz - (vec4(VERTEX, 1.0) * MODELVIEW_MATRIX).xyz;
	float viewFromUp = clamp(dot(view, vec3(0, 1, 0))/4.0, 0.0, 1.0);
	
	// 2. stretch all grass in the camera UP vector direction
	vec3 flattenDirection =  normalize(vec3(1, 0, 1) *(vec4(0, 0, 1, 0) * INV_VIEW_MATRIX).xzy);
	VERTEX += flattenDirection * viewFromUp * COLOR.g * 10.0;
}


//
// COLOR STUFF
//

void fragment() {
	//ALBEDO = mix(vec3(1, 0, 0), vec3(1, 1, 1), viewFromUp);
	ALBEDO = mix(A.rgb, B.rgb, COLOR.r) * multiply.rgb;
	ALPHA = texture(Texture, UV).a;

	// This type of alpha seems to work best
	ALPHA_SCISSOR_THRESHOLD = 0.1;
}

void light() {
//	DIFFUSE_LIGHT += LIGHT * ATTENUATION * LIGHT_COLOR;
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
	DIFFUSE_LIGHT += ATTENUATION * LIGHT_COLOR;
}
