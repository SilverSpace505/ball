shader_type spatial;

uniform int shade_bands : hint_range(2, 10) = 3;

uniform int colour_bands : hint_range(2, 10) = 3;

uniform vec4 grass_colour;
uniform vec4 dirt_colour;

varying vec4 colour;
varying vec3 normal;

void vertex() {
	colour = COLOR;
	normal = NORMAL;
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 c = colour;
	float grass = clamp(dot(normal, vec3(0, 1, 0)) * 1.2 - 0.2, 0.0, 1.0);
	c = dirt_colour * (1.0 - grass) + grass_colour * grass;
	
	ALBEDO = vec3(
		round(c.r * float(colour_bands)) / float(colour_bands) - 0.05, 
		round(c.g * float(colour_bands)) / float(colour_bands), 
		round(c.b * float(colour_bands)) / float(colour_bands)
	);
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
