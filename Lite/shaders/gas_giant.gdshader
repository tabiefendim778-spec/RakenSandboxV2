shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx;

uniform vec4 base_color : source_color = vec4(0.72, 0.50, 0.30, 1.0);
uniform vec4 band_color : source_color = vec4(0.92, 0.76, 0.56, 1.0);
uniform float seed = 1.0;

float hash11(float p) {
    return fract(sin(p * 127.1) * 43758.5453);
}

void fragment() {
    vec3 n = normalize(VERTEX);
    float latitude = n.y;
    float longitude = atan(n.z, n.x);

    float bands = 0.5 + 0.5 * sin(latitude * 58.0 + sin(longitude * 3.0 + seed) * 1.6);
    float fine = 0.5 + 0.5 * sin(latitude * 150.0 + longitude * 2.0 + seed * 4.0);
    float mix_value = clamp(bands * 0.72 + fine * 0.18, 0.0, 1.0);

    vec3 color = mix(base_color.rgb * 0.70, band_color.rgb, mix_value);

    float spot_lon = longitude + 0.55;
    float spot_lat = latitude + 0.17;
    float spot = exp(-(spot_lon * spot_lon * 9.0 + spot_lat * spot_lat * 180.0));
    color = mix(color, vec3(0.62, 0.16, 0.07), spot * 0.72);

    ALBEDO = color;
    ROUGHNESS = 0.74;
    SPECULAR = 0.22;
}
