shader_type canvas_item;

// How much to desaturate the cloud toward grey (0 = untouched, 1 = fully grey).
uniform float grey_amount : hint_range(0.0, 1.0) = 0.5;
// How much to darken the cloud (0 = untouched, 1 = black).
uniform float darken_amount : hint_range(0.0, 1.0) = 0.3;

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);

	float luminance = dot(tex_color.rgb, vec3(0.299, 0.587, 0.114));
	vec3 grey = mix(tex_color.rgb, vec3(luminance), grey_amount);
	vec3 darkened = grey * (1.0 - darken_amount);

	COLOR = vec4(darkened, tex_color.a);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
