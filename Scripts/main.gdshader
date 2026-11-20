shader_type canvas_item;

uniform vec3 chroma_key_color : source_color = vec3(0.0, 1.0, 0.0);
uniform float pickup_range : hint_range(0.0, 1.0) = 0.1;
uniform float fade_amount : hint_range(0.0, 1.0) = 0.1;

void fragment() {
    vec4 color = texture(TEXTURE, UV);
    float distance = length(color.rgb - chroma_key_color);

    if (distance <= pickup_range) {
        discard;
    }

    float fade_factor = smoothstep(pickup_range, pickup_range + fade_amount, distance);
    COLOR = vec4(color.rgb, fade_factor);
}   