extends MultiMeshInstance3D

var quality_level: int = 1
var radius: float = 9000.0

func _ready() -> void:
    _build()

func _build() -> void:
    var counts: Array[int] = [520, 980, 1500]
    var star_count: int = counts[clampi(quality_level, 0, 2)]

    var star_mesh: SphereMesh = SphereMesh.new()
    star_mesh.radius = 1.0
    star_mesh.height = 2.0
    star_mesh.radial_segments = 6
    star_mesh.rings = 3

    var material: ShaderMaterial = ShaderMaterial.new()
    material.shader = load("res://shaders/stars.gdshader") as Shader
    star_mesh.material = material

    var multi_mesh: MultiMesh = MultiMesh.new()
    multi_mesh.transform_format = MultiMesh.TRANSFORM_3D
    multi_mesh.use_colors = true
    multi_mesh.mesh = star_mesh
    multi_mesh.instance_count = star_count

    var random: RandomNumberGenerator = RandomNumberGenerator.new()
    random.seed = 778

    for i: int in range(star_count):
        var direction: Vector3 = Vector3(
            random.randf_range(-1.0, 1.0),
            random.randf_range(-1.0, 1.0),
            random.randf_range(-1.0, 1.0)
        )

        if direction.length_squared() < 0.02:
            direction = Vector3.FORWARD
        else:
            direction = direction.normalized()

        var distance_value: float = radius * random.randf_range(0.92, 1.08)
        var size_value: float = random.randf_range(0.10, 0.56)
        var transform_value: Transform3D = Transform3D(
            Basis.IDENTITY.scaled(Vector3.ONE * size_value),
            direction * distance_value
        )
        multi_mesh.set_instance_transform(i, transform_value)

        var temperature_mix: float = random.randf()
        var color_value: Color = Color(0.58, 0.72, 1.0)

        if temperature_mix > 0.76:
            color_value = Color(1.0, 0.76, 0.45)
        elif temperature_mix > 0.44:
            color_value = Color(0.90, 0.94, 1.0)

        multi_mesh.set_instance_color(i, color_value * random.randf_range(0.58, 1.12))

    multimesh = multi_mesh
