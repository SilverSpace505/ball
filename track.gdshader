shader_type spatial;

uniform int shade_bands : hint_range(2, 10) = 3;

uniform sampler2D trackTypes : source_color, filter_nearest;

varying vec3 world_position;

varying flat vec2 uv2;

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	uv2 = UV2;
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 tex_color = texture(trackTypes, vec2(mod(UV.x, 0.5), mod(UV.y, 0.5)) + uv2);
	ALBEDO = tex_color.rgb;
	// Called for every pixel the material is visible on.
}

void light() {
	DIFFUSE_LIGHT = vec3(0.0);
	SPECULAR_LIGHT = vec3(0.0);
	
    float NdotL = dot(NORMAL, LIGHT);
	float band = NdotL * float(shade_bands);
	float stepped_diffuse = floor(band) / float(shade_bands);

	// Add slight smoothing at the edges
	float smooth_amount = 0.3; // 0.0 = hard steps, 1.0 = fully smooth
	float fract_part = fract(band);
	stepped_diffuse += (smoothstep(0.0, smooth_amount, fract_part) * smooth_amount) / float(shade_bands);

	stepped_diffuse = max(0.0, stepped_diffuse);
    DIFFUSE_LIGHT = ALBEDO * LIGHT_COLOR * ATTENUATION * stepped_diffuse / 15.0;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
