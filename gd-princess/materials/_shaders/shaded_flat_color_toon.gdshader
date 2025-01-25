shader_type spatial;

uniform vec3 color: source_color = vec3(1.0, 1.0, 1.0);
uniform float metalic: hint_range(0.0, 1.0, 0.01) = 0.0;
uniform float roughness: hint_range(0.0, 1.0, 0.01) = 1.0;
uniform float light_factor: hint_range(0.0, 10.0, 0.01) = 1.0;

#include "cell_shading.gdshaderinc"

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	ALBEDO = color;
	ROUGHNESS = roughness;
	METALLIC = metalic;
}

void light() {
	DIFFUSE_LIGHT += diffuse_light(
			ALBEDO,
			LIGHT_COLOR,
			LIGHT,
			NORMAL,
			ATTENUATION
	) * light_factor;
}
