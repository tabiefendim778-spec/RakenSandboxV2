shader_type spatial;
render_mode unshaded;

uniform vec4 star_color : source_color = vec4(1.0, 0.58, 0.16, 1.0);
uniform float intensity : hint_range(0.5, 12.0) = 3.4;

void fragment() {
    vec3 n = normalize(NORMAL);
    float bands = sin((n.y * 18.0 + n.x * 9.0) + TIME * 1.7) * 0.08;
    float cells = sin(n.x * 34.0 + TIME * 0.8) * sin(n.z * 31.0 - TIME) * 0.06;
    vec3 c = star_color.rgb * (1.0 + bands + cells);
    ALBEDO = c;
    EMISSION = c * intensity;
}
