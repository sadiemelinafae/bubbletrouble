shader_type spatial;

uniform vec4 A : source_color = vec4(1, 1, 1, 1);
uniform vec4 B : source_color = vec4(1, 1, 1, 1);
uniform vec4 multiply : source_color = vec4(1, 1, 1, 1);
uniform vec3 emit : source_color = vec3(0, 0, 0);

void fragment() {
	ALBEDO = mix(A.rgb, B.rgb, COLOR.r) * multiply.rgb;
	EMISSION = emit;
}
