shader_type canvas_item;

uniform float tint_strength : hint_range(0.0, 1.0) = 1.0;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    
    // Check if the pixel is primarily green (Green > Red and Green > Blue)
    if (tex_color.g > tex_color.r && tex_color.g > tex_color.b) {
        // Add red and pull green down to turn green into orange
        tex_color.r = mix(tex_color.r, tex_color.g, tint_strength);
        tex_color.g = mix(tex_color.g, tex_color.g * 0.5, tint_strength);
    }
    
    COLOR = tex_color;
}