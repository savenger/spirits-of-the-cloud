shader_type canvas_item;

uniform float tint_strength : hint_range(0.0, 1.0) = 1.0;
uniform vec4 tint_color : source_color = vec4(0.5, 0.55, 0.65, 1.0);

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);

    // Lighter pixels get tinted more strongly; darker pixels pass through mostly untouched.
    float lightness = min(tex_color.r, min(tex_color.g, tex_color.b));

    // Multiply toward a grey/blue storm color; higher tint_strength = greyer/bluer.
    tex_color.rgb = mix(tex_color.rgb, tex_color.rgb * tint_color.rgb, tint_strength * lightness);

    COLOR = tex_color;
}