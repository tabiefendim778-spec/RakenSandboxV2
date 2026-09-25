shader_type spatial;
render_mode unshaded, blend_add, cull_front, depth_draw_never;

uniform vec4 atmosphere_color : source_color = vec4(0.10, 0.42, 1.0, 1.0);
uniform float strength : hint_range(0.1, 6.0) = 1.7;
uniform float density : hint_range(0.01, 1.0) = 0.28;

void fragment() {
    float rim = pow(1.0 - max(dot(normalize(NORMAL), normalize(VIEW)), 0.0), 2.2);
    vec3 glow = atmosphere_color.rgb * rim * strength;
    ALBEDO = glow;
    EMISSION = glow;
    ALPHA = clamp(rim * density, 0.0, 0.92);
}
