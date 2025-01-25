shader_type spatial;

uniform vec3 A: source_color = vec3(1, 1, 1);
uniform vec3 B: source_color = vec3(1, 1, 1);

uniform sampler2D Tex;
uniform float scale = 20;

uniform sampler2D Noise;
uniform vec3 NoiseColor: source_color = vec3(1, 1, 1);
uniform float NoiseScale = 40;

uniform vec3 multiply: source_color = vec3(1, 1, 1);

#include "cell_shading.gdshaderinc"

varying vec3 world_position;

void vertex() {
    world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec2 uv = world_position.xz + vec2(world_position.y * .5, world_position.y * .5);
	float factor_Tex = 1.0-texture(Tex, uv / scale).r;
	float factor_Noise = texture(Noise, uv / NoiseScale).r;
	ALBEDO = mix(mix(A, B, factor_Tex), NoiseColor, factor_Noise) * multiply;
}

void light() {
	DIFFUSE_LIGHT += diffuse_light(
			ALBEDO,
			LIGHT_COLOR,
			LIGHT,
			NORMAL,
			ATTENUATION
	);
}
