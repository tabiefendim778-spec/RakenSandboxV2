shader_type canvas_item;

float hash21(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 34.345);
    return fract(p.x * p.y);
}

float value_noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    float a = hash21(i);
    float b = hash21(i + vec2(1.0, 0.0));
    float c = hash21(i + vec2(0.0, 1.0));
    float d = hash21(i + vec2(1.0, 1.0));
    return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

float fbm(vec2 p) {
    float total = 0.0;
    float amplitude = 0.52;
    for (int i = 0; i < 5; i++) {
        total += value_noise(p) * amplitude;
        p = p * 2.03 + vec2(17.2, -11.7);
        amplitude *= 0.49;
    }
    return total;
}

void fragment() {
    vec2 uv = UV;
    vec2 p = (uv - 0.5) * vec2(1.7777778, 1.0);
    float t = TIME * 0.018;

    vec3 color = vec3(0.0015, 0.004, 0.013);

    float cloud_a = fbm(p * 3.1 + vec2(t, -t * 0.55));
    float cloud_b = fbm(p * 6.3 - vec2(t * 0.65, t * 0.22));
    float nebula = smoothstep(0.47, 0.86, cloud_a * 0.72 + cloud_b * 0.32);
    float ribbon = smoothstep(0.18, 0.78, 1.0 - abs(p.y + 0.10 + sin(p.x * 1.5) * 0.10));

    color += vec3(0.018, 0.085, 0.20) * nebula * 0.95;
    color += vec3(0.10, 0.025, 0.17) * pow(nebula, 2.0) * ribbon * 0.54;

    vec2 star_grid = floor(uv * vec2(520.0, 292.0));
    vec2 cell_uv = fract(uv * vec2(520.0, 292.0)) - 0.5;
    float star_hash = hash21(star_grid);
    float star_mask = step(0.9895, star_hash);
    float star_core = smoothstep(0.20, 0.0, length(cell_uv));
    float twinkle = 0.72 + 0.28 * sin(TIME * (1.1 + star_hash * 2.6) + star_hash * 50.0);
    vec3 star_tint = mix(vec3(0.62, 0.77, 1.0), vec3(1.0, 0.87, 0.65), step(0.72, star_hash));
    color += star_tint * star_mask * star_core * twinkle * 2.2;

    vec2 planet_center = vec2(0.57, 0.08);
    float planet_radius = 0.39;
    vec2 planet_p = p - planet_center;
    float planet_dist = length(planet_p);
    float planet_mask = smoothstep(planet_radius + 0.003, planet_radius - 0.003, planet_dist);
    float rim = smoothstep(planet_radius + 0.052, planet_radius - 0.004, planet_dist)
              - smoothstep(planet_radius + 0.005, planet_radius - 0.02, planet_dist);

    vec2 normal_2d = planet_p / max(planet_radius, 0.001);
    float light_term = clamp(dot(normalize(vec3(normal_2d, sqrt(max(0.0, 1.0 - dot(normal_2d, normal_2d))))), normalize(vec3(-0.8, -0.18, 0.6))), 0.0, 1.0);
    float surface_noise = fbm(planet_p * 10.0 + vec2(3.2, 8.8));
    vec3 planet_dark = vec3(0.005, 0.010, 0.023);
    vec3 planet_lit = mix(vec3(0.025, 0.12, 0.26), vec3(0.045, 0.24, 0.34), surface_noise);
    vec3 planet_color = mix(planet_dark, planet_lit, pow(light_term, 0.72));

    color = mix(color, planet_color, planet_mask);
    color += vec3(0.08, 0.42, 0.92) * rim * (0.75 + light_term) * 1.35;

    vec2 sun_center = vec2(-0.88, -0.22);
    float sun_d = length(p - sun_center);
    float sun_glow = exp(-sun_d * 5.2);
    color += vec3(0.12, 0.24, 0.55) * sun_glow * 0.75;

    float vignette = smoothstep(1.08, 0.35, length(p * vec2(0.83, 1.0)));
    color *= 0.70 + 0.34 * vignette;

    COLOR = vec4(color, 1.0);
}
