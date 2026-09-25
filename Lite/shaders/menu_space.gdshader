shader_type canvas_item;

float hash21(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

float noise2(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    float a = hash21(i);
    float b = hash21(i + vec2(1.0, 0.0));
    float c = hash21(i + vec2(0.0, 1.0));
    float d = hash21(i + vec2(1.0, 1.0));
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

float fbm(vec2 p) {
    float v = 0.0;
    float a = 0.5;
    for (int i = 0; i < 4; i++) {
        v += noise2(p) * a;
        p = p * 2.03 + vec2(13.2, 7.7);
        a *= 0.5;
    }
    return v;
}

void fragment() {
    vec2 uv = UV;
    vec2 p = (uv - 0.5) * vec2(1.78, 1.0);
    float t = TIME * 0.025;

    float n1 = fbm(p * 2.2 + vec2(t, -t * 0.6));
    float n2 = fbm(p * 4.5 - vec2(t * 0.8, t * 0.3));
    float nebula = smoothstep(0.42, 0.86, n1 * 0.72 + n2 * 0.38);

    vec3 base = vec3(0.006, 0.010, 0.028);
    vec3 blue = vec3(0.025, 0.15, 0.34);
    vec3 violet = vec3(0.16, 0.045, 0.26);
    vec3 col = base + blue * nebula * 0.85 + violet * pow(nebula, 2.2) * 0.55;

    vec2 star_grid = floor(uv * vec2(260.0, 145.0));
    float h = hash21(star_grid);
    float star = step(0.994, h);
    float twinkle = 0.45 + 0.55 * sin(TIME * (1.4 + h * 3.0) + h * 40.0);
    col += vec3(0.72, 0.84, 1.0) * star * (0.35 + twinkle * 1.5);

    float vignette = 1.0 - smoothstep(0.38, 0.92, length(p));
    col *= 0.65 + vignette * 0.55;

    COLOR = vec4(col, 1.0);
}
