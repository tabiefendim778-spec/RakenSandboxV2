shader_type spatial;
render_mode unshaded, blend_mix, cull_disabled, depth_draw_alpha_prepass;

uniform vec4 inner_color : source_color = vec4(0.86, 0.76, 0.55, 1.0);
uniform vec4 outer_color : source_color = vec4(0.48, 0.40, 0.31, 1.0);

void fragment() {
    vec2 p = UV - vec2(0.5);
    float r = length(p) * 2.0;
    float inner = smoothstep(0.35, 0.40, r);
    float outer = 1.0 - smoothstep(0.96, 1.0, r);
    float rings = 0.72 + 0.28 * sin(r * 180.0) * sin(r * 57.0);
    float alpha = inner * outer * (0.38 + 0.42 * rings);
    vec3 color = mix(inner_color.rgb, outer_color.rgb, smoothstep(0.42, 0.95, r));
    ALBEDO = color;
    EMISSION = color * 0.11;
    ALPHA = alpha;
}
