shader_type spatial;
render_mode unshaded;

void fragment() {
    vec3 c = COLOR.rgb;
    ALBEDO = c;
    EMISSION = c * 2.4;
}
