shader_type spatial;
render_mode unshaded, cull_disabled, blend_add;

uniform vec4 hot_color : source_color = vec4(1.0, 0.82, 0.24, 1.0);
uniform vec4 cool_color : source_color = vec4(1.0, 0.08, 0.01, 1.0);
uniform float intensity : hint_range(0.5, 12.0) = 4.0;

void fragment() {
    vec2 p = UV - vec2(0.5);
    float r = length(p) * 2.0;
    float a = atan(p.y, p.x);
    float spiral = 0.5 + 0.5 * sin(a * 8.0 - TIME * 3.2 + r * 22.0);
    float ring = smoothstep(1.0, 0.12, abs(r - 0.62));
    float fade = smoothstep(1.0, 0.18, r) * smoothstep(0.08, 0.28, r);
    vec3 c = mix(cool_color.rgb, hot_color.rgb, pow(1.0 - r, 2.0) + spiral * 0.22);
    float alpha = ring * fade;
    ALBEDO = c;
    EMISSION = c * intensity * alpha;
    ALPHA = alpha;
}
