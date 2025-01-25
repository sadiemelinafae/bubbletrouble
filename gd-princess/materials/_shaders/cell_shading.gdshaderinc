uniform sampler2D cell_shading_diffuse_curve: repeat_disable;

 float diffuse_sample(vec3 light, vec3 normal) {
	return texture(cell_shading_diffuse_curve, vec2(dot(light, normal), 0)
	).r;
 }

float is_lit(vec3 light, vec3 normal, float attenuation) {
	return attenuation * diffuse_sample(light, normal);
}

vec3 diffuse_light(
		vec3 albedo,
		vec3 light_color,
		vec3 light,
		vec3 normal,
		float attenuation
) {
	return albedo * light_color * is_lit(light, normal, attenuation);
}