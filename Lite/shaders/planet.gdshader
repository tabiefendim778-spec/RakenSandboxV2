shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx;

uniform vec4 base_color : source_color = vec4(0.03, 0.22, 0.72, 1.0);
uniform vec4 land_color : source_color = vec4(0.08, 0.32, 0.12, 1.0);
uniform float roughness_value : hint_range(0.05, 1.0) = 0.58;
uniform float ocean_amount : hint_range(0.0, 1.0) = 0.46;
uniform float seed = 2.0;

float hash31(vec3 p) {
    p = fract(p * 0.1031);
    p += dot(p, p.yzx + 33.33);
    return fract((p.x + p.y) * p.z);
}

float noise3(vec3 p) {
    vec3 i = floor(p);
    vec3 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    float n000 = hash31(i);
    float n100 = hash31(i + vec3(1,0,0));
    float n010 = hash31(i + vec3(0,1,0));
    float n110 = hash31(i + vec3(1,1,0));
    float n001 = hash31(i + vec3(0,0,1));
    float n101 = hash31(i + vec3(1,0,1));
    float n011 = hash31(i + vec3(0,1,1));
    float n111 = hash31(i + vec3(1,1,1));
    float x00 = mix(n000, n100, f.x);
    float x10 = mix(n010, n110, f.x);
    float x01 = mix(n001, n101, f.x);
    float x11 = mix(n011, n111, f.x);
    return mix(mix(x00, x10, f.y), mix(x01, x11, f.y), f.z);
}

void fragment() {
    vec3 p = normalize(VERTEX) * 4.2 + vec3(seed);
    float n = noise3(p) * 0.62 + noise3(p * 2.4) * 0.28 + noise3(p * 5.0) * 0.10;
    float land = smoothstep(ocean_amount - 0.08, ocean_amount + 0.08, n);
    vec3 color = mix(base_color.rgb * (0.72 + n * 0.28), land_color.rgb * (0.65 + n * 0.5), land);
    float polar = pow(abs(normalize(VERTEX).y), 8.0);
    color = mix(color, vec3(0.86, 0.91, 0.96), polar * 0.72);
    ALBEDO = color;
    ROUGHNESS = mix(0.22, roughness_value, land);
    SPECULAR = mix(0.85, 0.35, land);
}
