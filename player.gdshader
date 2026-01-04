shader_type spatial;

varying vec3 pos;
uniform int shade_bands : hint_range(2, 10) = 3;

uniform vec4 rim_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float rim_threshold : hint_range(0.0, 1.0) = 0.5;
uniform float rim_smoothness : hint_range(0.0, 0.1) = 0.01;

void vertex() {
	pos = (VERTEX + 1.0) / 2.0;
}

void fragment() {
	ALBEDO = vec3(0.0, clamp(pos.x / 2.0 + 0.5, 0.5, 1.0), clamp((pos.z + pos.x) / 4.0 + 0.75, 0.75, 1.0)) / 3.0;
	float NdotV = dot(NORMAL, VIEW);
	float rim = 1.0 - NdotV;
	rim = smoothstep(
		rim_threshold - rim_smoothness,
		rim_threshold + rim_smoothness,
		rim
	);
	ALBEDO = (1.0 - rim) * ALBEDO + (vec3(0.5) + ALBEDO / 2.0) * 1.0;
}

void light() {
	float NdotL = dot(NORMAL, LIGHT);
	
	float stepped_diffuse = floor(NdotL * float(shade_bands)) / float(shade_bands);
	stepped_diffuse = max(0.0, stepped_diffuse);
    DIFFUSE_LIGHT += ALBEDO * LIGHT_COLOR * ATTENUATION * NdotL / 50.0;
	
	float NdotV = dot(NORMAL, VIEW);
	float rim = 1.0 - NdotV;
	rim = smoothstep(
		rim_threshold - rim_smoothness,
		rim_threshold + rim_smoothness,
		rim
	);
	DIFFUSE_LIGHT += rim_color.rgb * rim * ATTENUATION;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
