shader_type spatial;
render_mode shadows_disabled;

//
// Color
//
uniform vec4 A : source_color = vec4(1, 1, 1, 1);
uniform vec4 B : source_color = vec4(1, 1, 1, 1);
uniform vec4 multiply : source_color = vec4(1, 1, 1, 1);
uniform vec3 emit: source_color = vec3(0.0, 0.0, 0.0);
uniform float metalic: hint_range(0.0, 1.0, 0.01) = 0.0;
uniform float roughness: hint_range(0.0, 1.0, 0.01) = 1.0;

uniform sampler2D Texture;

//
// Billboard
//

uniform float leaf_expansion : hint_range(0.0, 5.0, 0.01) = 1.5;

//
// WIND
//

// Wind settings.
uniform float wind_speed = 20.0;
uniform float wind_scale = 200.0;
uniform float wind_strength = 1.0;
uniform sampler2D WindNoise;


void vertex() {
	//
	// Wind
	//
    float time = TIME / wind_speed;
	vec2 NoiseLocation = VERTEX.xz / wind_scale + vec2(time, 0);
	float wind = wind_strength * texture(WindNoise, NoiseLocation).r;
    VERTEX.x += wind;
	
	//
	// Billboarding
	//
	float MeshScale = -1.0 * leaf_expansion / length(MODEL_MATRIX * vec4(1.0, 0.0, 0.0, 0.0));
	
	// Source: https://godotshaders.com/shader/simple-cheap-stylized-tree-shader/
	//Camera-Orientation based on https://www.youtube.com/watch?v=iASMFba7GeI
	vec3 orient_2d = vec3(1.0, 1.0, 0.0) - vec3(UV.x, UV.y, 0.0);
	orient_2d *= 2.0;
	orient_2d -= vec3(1.0, 1.0, 0.0);
	orient_2d *= -1.0;
	orient_2d *= MeshScale;
	
	vec3 oriented_offset = reflect((INV_VIEW_MATRIX * vec4(orient_2d, 0.0)).xyz,INV_VIEW_MATRIX[0].xyz);
	vec3 obj_oriented_offset = (vec4(oriented_offset, 0.0) * MODEL_MATRIX).xyz;
	
	VERTEX += obj_oriented_offset;
}


//
// COLOR STUFF
//

void fragment() {
	float angle = abs(dot(NORMAL, vec3(0, 0, 1)));
	
	ROUGHNESS = roughness;
	METALLIC = metalic;
	
	ALBEDO = (mix(A, B, angle)*multiply).xyz;
	float transparency = texture(Texture, UV).a;

	// This type of alpha seems to work best
	ALPHA_SCISSOR_THRESHOLD = 0.5;
	
	ALPHA = transparency;
	
	EMISSION = emit;
}
