shader_type canvas_item;

uniform sampler2D dark_texture;
uniform float transition : hint_range(0.0, 1.0) = 0.0;

void fragment()
{
    vec4 bright = texture(TEXTURE, UV);
    vec4 dark = texture(dark_texture, UV);

    vec3 color = mix(bright.rgb, dark.rgb, clamp(transition, 0.0, 1.0));

    COLOR = vec4(color, bright.a);
}