shader_type spatial;
render_mode blend_mix, depth_draw_alpha_prepass, cull_back;

uniform vec4 cloud_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float density : hint_range(0.0, 1.0) = 0.52;
uniform float speed : hint_range(0.0, 0.2) = 0.018;

float hash21(vec2 p) {
    p = fract(p * vec2(123.34, 345.45));
    p += dot(p, p + 34.345);
    return fract(p.x * p.y);
}

float noise2(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    float a = hash21(i);
    float b = hash21(i + vec2(1.0, 0.0));
    float c = hash21(i + vec2(0.0, 1.0));
    float d = hash21(i + vec2(1.0, 1.0));
    return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

void fragment() {
    vec2 p = UV * vec2(8.0, 4.0) + vec2(TIME * speed, 0.0);
    float n = noise2(p) * 0.55 + noise2(p * 2.1 + 4.2) * 0.30 + noise2(p * 4.2 - 1.6) * 0.15;
    float cloud = smoothstep(density, min(density + 0.20, 0.99), n);
    ALBEDO = cloud_color.rgb;
    ROUGHNESS = 0.92;
    ALPHA = cloud * 0.46;
}
