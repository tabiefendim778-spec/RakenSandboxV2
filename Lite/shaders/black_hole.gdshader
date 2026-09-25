shader_type spatial;
render_mode unshaded;

void fragment() {
    float rim = pow(1.0 - max(dot(normalize(NORMAL), normalize(VIEW)), 0.0), 5.0);
    vec3 edge = vec3(0.08, 0.025, 0.18) * rim;
    ALBEDO = edge;
    EMISSION = edge * 2.0;
}
