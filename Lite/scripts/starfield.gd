extends MultiMeshInstance3D

var quality_level: int = 1
var radius: float = 9000.0

func _ready() -> void:
    _build()

func _build() -> void:
    var counts := [500, 950, 1500]
    var star_count: int = counts[clampi(quality_level, 0, 2)]

    var star_mesh := SphereMesh.new()
    star_mesh.radius = 1.0
    star_mesh.height = 2.0
    star_mesh.radial_segments = 6
    star_mesh.rings = 3

    var mat := ShaderMaterial.new()
    mat.shader = load("res://shaders/stars.gdshader")
    star_mesh.material = mat

    var mm := MultiMesh.new()
    mm.transform_format = MultiMesh.TRANSFORM_3D
    mm.use_colors = true
    mm.mesh = star_mesh
    mm.instance_count = star_count

    var rng := RandomNumberGenerator.new()
    rng.seed = 778

    for i in range(star_count):
        var dir := Vector3(
            rng.randf_range(-1.0, 1.0),
            rng.randf_range(-1.0, 1.0),
            rng.randf_range(-1.0, 1.0)
        ).normalized()

        if dir.length_squared() < 0.1:
            dir = Vector3.FORWARD

        var dist := radius * rng.randf_range(0.92, 1.08)
        var size := rng.randf_range(0.12, 0.62)
        var transform := Transform3D(Basis.IDENTITY.scaled(Vector3.ONE * size), dir * dist)
        mm.set_instance_transform(i, transform)

        var temperature_mix := rng.randf()
        var color := Color(0.58, 0.72, 1.0)
        if temperature_mix > 0.72:
            color = Color(1.0, 0.78, 0.50)
        elif temperature_mix > 0.42:
            color = Color(0.92, 0.95, 1.0)

        mm.set_instance_color(i, color * rng.randf_range(0.55, 1.15))

    multimesh = mm
