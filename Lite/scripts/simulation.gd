extends Node3D

signal exit_requested

const G_KM: float = 6.67430e-20
const POSITION_SCALE: float = 0.000004
const MAX_BODIES: int = 96
const STARFIELD_SCRIPT: Script = preload("res://scripts/starfield.gd")
const HUD_SCRIPT: Script = preload("res://scripts/hud.gd")

var quality_level: int = 1
var bodies: Array[Dictionary] = []
var camera: Camera3D = null
var hud: CanvasLayer = null
var sim_paused: bool = false
var pause_menu_open: bool = false
var time_scale: float = 7200.0
var mouse_sensitivity: float = 0.0021
var camera_speed: float = 250.0
var selected_index: int = -1

func _ready() -> void:
    _build_world()
    _build_camera()
    _build_starfield()
    _build_hud()
    _seed_solar_system()
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _exit_tree() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _build_world() -> void:
    var world_environment: WorldEnvironment = WorldEnvironment.new()
    var environment: Environment = Environment.new()
    environment.background_mode = Environment.BG_COLOR
    environment.background_color = Color(0.0008, 0.0016, 0.0060, 1.0)
    environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    environment.ambient_light_color = Color(0.045, 0.065, 0.11)
    environment.ambient_light_energy = 0.18
    environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
    world_environment.environment = environment
    add_child(world_environment)

func _build_camera() -> void:
    camera = Camera3D.new()
    camera.fov = 70.0
    camera.near = 0.08
    camera.far = 24000.0
    camera.position = Vector3(410.0, 210.0, 910.0)
    add_child(camera)
    camera.look_at(Vector3.ZERO, Vector3.UP)

func _build_starfield() -> void:
    var stars: Node = STARFIELD_SCRIPT.new()
    stars.set("quality_level", quality_level)
    add_child(stars)

func _build_hud() -> void:
    var hud_node: Node = HUD_SCRIPT.new()
    hud_node.connect("resume_requested", Callable(self, "_resume_from_menu"))
    hud_node.connect("return_to_menu_requested", Callable(self, "_return_to_menu"))
    hud = hud_node as CanvasLayer
    add_child(hud_node)

func _seed_solar_system() -> void:
    bodies.clear()

    _add_body(_make_body(
        "Sun", "STAR", 1.98847e30, 695700.0,
        Vector3.ZERO, Vector3.ZERO, 5772.0,
        Color(1.0, 0.55, 0.12), true
    ))

    _add_body(_make_body(
        "Earth", "PLANET", 5.9722e24, 6371.0,
        Vector3(149597870.7, 0.0, 0.0),
        Vector3(0.0, 0.0, 29.78), 288.0,
        Color(0.035, 0.28, 0.92), false
    ))

    _add_body(_make_body(
        "Moon", "MOON", 7.342e22, 1737.4,
        Vector3(149982270.7, 0.0, 0.0),
        Vector3(0.0, 0.0, 30.802), 250.0,
        Color(0.50, 0.52, 0.56), false
    ))

    _add_body(_make_body(
        "Mars", "ROCKY", 6.4171e23, 3389.5,
        Vector3(0.0, 0.0, -227939200.0),
        Vector3(24.077, 0.0, 0.0), 210.0,
        Color(0.72, 0.17, 0.055), false
    ))

    _add_body(_make_body(
        "Jupiter", "GAS_GIANT", 1.89813e27, 69911.0,
        Vector3(-778570000.0, 0.0, 0.0),
        Vector3(0.0, 0.0, -13.07), 165.0,
        Color(0.68, 0.45, 0.25), false
    ))

    _add_body(_make_body(
        "Saturn", "RINGED_PLANET", 5.6834e26, 58232.0,
        Vector3(0.0, 0.0, 1433530000.0),
        Vector3(-9.68, 0.0, 0.0), 134.0,
        Color(0.80, 0.66, 0.39), false
    ))

func _make_body(
    display_name: String,
    body_type: String,
    mass_kg: float,
    radius_km: float,
    position_km: Vector3,
    velocity_km_s: Vector3,
    temperature_k: float,
    color_value: Color,
    fixed_value: bool
) -> Dictionary:
    return {
        "name": display_name,
        "type": body_type,
        "mass": mass_kg,
        "radius": radius_km,
        "pos": position_km,
        "vel": velocity_km_s,
        "temp": temperature_k,
        "color": color_value,
        "fixed": fixed_value,
        "node": null
    }

func _process(delta: float) -> void:
    _update_camera(delta)

    if not sim_paused and not pause_menu_open:
        _simulate(delta)

    _sync_visuals()
    _update_hud()

func _simulate(delta: float) -> void:
    var body_count: int = bodies.size()
    if body_count < 2:
        return

    var total_dt: float = minf(delta * time_scale, 172800.0)
    var desired_steps: int = int(ceil(total_dt / 1200.0))
    var substeps: int = clampi(desired_steps, 1, 10)
    var dt: float = total_dt / float(substeps)

    for _step: int in range(substeps):
        var accelerations: Array[Vector3] = []
        accelerations.resize(body_count)

        for i: int in range(body_count):
            accelerations[i] = Vector3.ZERO
            var body_i: Dictionary = bodies[i]

            if bool(body_i.get("fixed", false)):
                continue

            var pos_i: Vector3 = body_i.get("pos", Vector3.ZERO) as Vector3
            var acceleration: Vector3 = Vector3.ZERO

            for j: int in range(body_count):
                if i == j:
                    continue

                var body_j: Dictionary = bodies[j]
                var pos_j: Vector3 = body_j.get("pos", Vector3.ZERO) as Vector3
                var delta_pos: Vector3 = pos_j - pos_i
                var dist_sq: float = maxf(delta_pos.length_squared(), 10000.0)
                var inv_dist: float = 1.0 / sqrt(dist_sq)
                var direction: Vector3 = delta_pos * inv_dist
                var source_mass: float = float(body_j.get("mass", 0.0))
                acceleration += direction * (G_KM * source_mass / dist_sq)

            accelerations[i] = acceleration

        for i: int in range(body_count):
            var body: Dictionary = bodies[i]
            if bool(body.get("fixed", false)):
                continue

            var velocity: Vector3 = body.get("vel", Vector3.ZERO) as Vector3
            var position: Vector3 = body.get("pos", Vector3.ZERO) as Vector3

            velocity += accelerations[i] * dt
            position += velocity * dt

            body["vel"] = velocity
            body["pos"] = position
            bodies[i] = body

        _resolve_collisions()
        body_count = bodies.size()

func _resolve_collisions() -> void:
    var i: int = 0

    while i < bodies.size():
        var j: int = i + 1

        while j < bodies.size():
            var a: Dictionary = bodies[i]
            var b: Dictionary = bodies[j]
            var pos_a: Vector3 = a.get("pos", Vector3.ZERO) as Vector3
            var pos_b: Vector3 = b.get("pos", Vector3.ZERO) as Vector3
            var distance_km: float = pos_a.distance_to(pos_b)
            var collision_radius: float = (float(a.get("radius", 0.0)) + float(b.get("radius", 0.0))) * 0.80

            if distance_km <= collision_radius:
                _merge_bodies(i, j)

                if selected_index == j:
                    selected_index = i
                elif selected_index > j:
                    selected_index -= 1

                continue

            j += 1

        i += 1

func _merge_bodies(a_index: int, b_index: int) -> void:
    if a_index < 0 or b_index < 0:
        return
    if a_index >= bodies.size() or b_index >= bodies.size():
        return

    var a: Dictionary = bodies[a_index]
    var b: Dictionary = bodies[b_index]
    var mass_a: float = float(a.get("mass", 0.0))
    var mass_b: float = float(b.get("mass", 0.0))
    var total_mass: float = maxf(mass_a + mass_b, 1.0)

    var velocity_a: Vector3 = a.get("vel", Vector3.ZERO) as Vector3
    var velocity_b: Vector3 = b.get("vel", Vector3.ZERO) as Vector3
    var position_a: Vector3 = a.get("pos", Vector3.ZERO) as Vector3
    var position_b: Vector3 = b.get("pos", Vector3.ZERO) as Vector3

    var merged_velocity: Vector3 = (velocity_a * mass_a + velocity_b * mass_b) / total_mass
    var merged_position: Vector3 = (position_a * mass_a + position_b * mass_b) / total_mass

    var radius_a: float = float(a.get("radius", 1.0))
    var radius_b: float = float(b.get("radius", 1.0))
    var merged_radius: float = pow(pow(radius_a, 3.0) + pow(radius_b, 3.0), 1.0 / 3.0)

    var dominant: Dictionary = a if mass_a >= mass_b else b
    var color_a: Color = a.get("color", Color.WHITE) as Color
    var color_b: Color = b.get("color", Color.WHITE) as Color
    var blend_factor: float = clampf(mass_b / total_mass, 0.0, 1.0)

    a["name"] = "%s + %s" % [str(a.get("name", "A")), str(b.get("name", "B"))]
    a["type"] = str(dominant.get("type", "PLANET"))
    a["mass"] = total_mass
    a["radius"] = merged_radius
    a["vel"] = merged_velocity
    a["pos"] = merged_position
    a["temp"] = (
        float(a.get("temp", 250.0)) * mass_a
        + float(b.get("temp", 250.0)) * mass_b
    ) / total_mass
    a["color"] = color_a.lerp(color_b, blend_factor)
    a["fixed"] = bool(a.get("fixed", false)) or bool(b.get("fixed", false))

    var old_b_node: Node3D = b.get("node") as Node3D
    if is_instance_valid(old_b_node):
        old_b_node.queue_free()

    bodies[a_index] = a
    bodies.remove_at(b_index)

    _reindex_areas()
    _rebuild_body_visual(a_index)

    if is_instance_valid(hud):
        hud.call("flash_notice", "COLLISION  /  MERGE")

func _add_body(data: Dictionary) -> void:
    if bodies.size() >= MAX_BODIES:
        if is_instance_valid(hud):
            hud.call("flash_notice", "BODY LIMIT REACHED")
        return

    var body: Dictionary = data.duplicate(true)
    var index: int = bodies.size()
    var visual: Node3D = _create_visual(body, index)
    body["node"] = visual
    bodies.append(body)

func _create_visual(body: Dictionary, body_index: int) -> Node3D:
    var holder: Node3D = Node3D.new()
    holder.name = str(body.get("name", "CelestialBody"))
    add_child(holder)

    var body_type: String = str(body.get("type", "PLANET"))
    var radius_km: float = float(body.get("radius", 1.0))
    var visual_radius: float = _visual_radius(radius_km, body_type)

    var sphere: MeshInstance3D = MeshInstance3D.new()
    sphere.name = "Surface"
    sphere.mesh = _make_sphere_mesh()
    sphere.scale = Vector3.ONE * visual_radius
    holder.add_child(sphere)

    var body_color: Color = body.get("color", Color.WHITE) as Color

    if body_type == "STAR":
        _style_star(holder, sphere, body_color, visual_radius)
    elif body_type == "BLACK_HOLE":
        _style_black_hole(holder, sphere, visual_radius)
    elif body_type == "GAS_GIANT" or body_type == "RINGED_PLANET":
        _style_gas_giant(holder, sphere, body_color, body_index, visual_radius, body_type == "RINGED_PLANET")
    else:
        _style_rocky_world(holder, sphere, body_color, body_type, body_index, visual_radius)

    var area: Area3D = Area3D.new()
    area.set_meta("body_index", body_index)
    holder.add_child(area)

    var collision: CollisionShape3D = CollisionShape3D.new()
    var shape: SphereShape3D = SphereShape3D.new()
    shape.radius = maxf(visual_radius * 1.12, 3.0)
    collision.shape = shape
    area.add_child(collision)

    var position_km: Vector3 = body.get("pos", Vector3.ZERO) as Vector3
    holder.position = position_km * POSITION_SCALE

    return holder

func _make_sphere_mesh() -> SphereMesh:
    var mesh: SphereMesh = SphereMesh.new()
    mesh.radius = 1.0
    mesh.height = 2.0

    if quality_level <= 0:
        mesh.radial_segments = 24
        mesh.rings = 12
    elif quality_level == 1:
        mesh.radial_segments = 40
        mesh.rings = 20
    else:
        mesh.radial_segments = 56
        mesh.rings = 28

    return mesh

func _style_star(holder: Node3D, sphere: MeshInstance3D, body_color: Color, visual_radius: float) -> void:
    var material: ShaderMaterial = ShaderMaterial.new()
    material.shader = load("res://shaders/star.gdshader") as Shader
    material.set_shader_parameter("star_color", body_color)
    material.set_shader_parameter("intensity", 4.0)
    sphere.material_override = material

    var corona: MeshInstance3D = MeshInstance3D.new()
    corona.name = "Corona"
    corona.mesh = _make_sphere_mesh()
    corona.scale = Vector3.ONE * visual_radius * 1.11

    var corona_material: ShaderMaterial = ShaderMaterial.new()
    corona_material.shader = load("res://shaders/atmosphere.gdshader") as Shader
    corona_material.set_shader_parameter("atmosphere_color", body_color)
    corona_material.set_shader_parameter("strength", 2.4)
    corona_material.set_shader_parameter("density", 0.30)
    corona.material_override = corona_material
    holder.add_child(corona)

    var light: OmniLight3D = OmniLight3D.new()
    light.light_color = body_color
    light.light_energy = 4.6
    light.omni_range = 8500.0
    light.shadow_enabled = quality_level >= 2
    holder.add_child(light)

func _style_black_hole(holder: Node3D, sphere: MeshInstance3D, visual_radius: float) -> void:
    var black_material: ShaderMaterial = ShaderMaterial.new()
    black_material.shader = load("res://shaders/black_hole.gdshader") as Shader
    sphere.material_override = black_material

    var photon_shell: MeshInstance3D = MeshInstance3D.new()
    photon_shell.name = "PhotonRing"
    photon_shell.mesh = _make_sphere_mesh()
    photon_shell.scale = Vector3.ONE * visual_radius * 1.18

    var photon_material: ShaderMaterial = ShaderMaterial.new()
    photon_material.shader = load("res://shaders/atmosphere.gdshader") as Shader
    photon_material.set_shader_parameter("atmosphere_color", Color(0.48, 0.18, 1.0))
    photon_material.set_shader_parameter("strength", 1.8)
    photon_material.set_shader_parameter("density", 0.22)
    photon_shell.material_override = photon_material
    holder.add_child(photon_shell)

    _add_accretion_disk(holder, visual_radius)

func _style_rocky_world(
    holder: Node3D,
    sphere: MeshInstance3D,
    body_color: Color,
    body_type: String,
    body_index: int,
    visual_radius: float
) -> void:
    var material: ShaderMaterial = ShaderMaterial.new()
    material.shader = load("res://shaders/planet.gdshader") as Shader
    material.set_shader_parameter("base_color", body_color)
    material.set_shader_parameter("land_color", _land_color(body_color, body_type))
    material.set_shader_parameter("ocean_amount", 0.47 if str(holder.name) == "Earth" else 0.57)
    material.set_shader_parameter("seed", float(body_index) * 3.17 + 1.2)
    sphere.material_override = material

    if body_type == "PLANET":
        _add_atmosphere(holder, visual_radius, body_color)

        if quality_level > 0:
            _add_clouds(holder, visual_radius)

func _style_gas_giant(
    holder: Node3D,
    sphere: MeshInstance3D,
    body_color: Color,
    body_index: int,
    visual_radius: float,
    has_rings: bool
) -> void:
    var material: ShaderMaterial = ShaderMaterial.new()
    material.shader = load("res://shaders/gas_giant.gdshader") as Shader
    material.set_shader_parameter("base_color", body_color)
    material.set_shader_parameter("band_color", body_color.lightened(0.28))
    material.set_shader_parameter("seed", float(body_index) * 2.4 + 1.0)
    sphere.material_override = material

    if has_rings:
        _add_ring(holder, visual_radius)

func _add_atmosphere(holder: Node3D, visual_radius: float, body_color: Color) -> void:
    var atmosphere: MeshInstance3D = MeshInstance3D.new()
    atmosphere.name = "Atmosphere"
    atmosphere.mesh = _make_sphere_mesh()
    atmosphere.scale = Vector3.ONE * visual_radius * 1.055

    var material: ShaderMaterial = ShaderMaterial.new()
    material.shader = load("res://shaders/atmosphere.gdshader") as Shader
    material.set_shader_parameter(
        "atmosphere_color",
        body_color.lerp(Color(0.14, 0.52, 1.0), 0.78)
    )
    material.set_shader_parameter("strength", 1.75)
    material.set_shader_parameter("density", 0.25)
    atmosphere.material_override = material
    holder.add_child(atmosphere)

func _add_clouds(holder: Node3D, visual_radius: float) -> void:
    var clouds: MeshInstance3D = MeshInstance3D.new()
    clouds.name = "Clouds"
    clouds.mesh = _make_sphere_mesh()
    clouds.scale = Vector3.ONE * visual_radius * 1.025

    var material: ShaderMaterial = ShaderMaterial.new()
    material.shader = load("res://shaders/clouds.gdshader") as Shader
    material.set_shader_parameter("density", 0.50)
    material.set_shader_parameter("speed", 0.018)
    clouds.material_override = material
    holder.add_child(clouds)

func _add_accretion_disk(holder: Node3D, visual_radius: float) -> void:
    var disk: MeshInstance3D = MeshInstance3D.new()
    disk.name = "AccretionDisk"

    var mesh: CylinderMesh = CylinderMesh.new()
    mesh.top_radius = 1.0
    mesh.bottom_radius = 1.0
    mesh.height = 0.03
    mesh.radial_segments = 64 if quality_level > 0 else 40
    disk.mesh = mesh
    disk.scale = Vector3(visual_radius * 5.2, visual_radius * 0.08, visual_radius * 5.2)

    var material: ShaderMaterial = ShaderMaterial.new()
    material.shader = load("res://shaders/accretion.gdshader") as Shader
    disk.material_override = material
    holder.add_child(disk)

func _add_ring(holder: Node3D, visual_radius: float) -> void:
    var ring: MeshInstance3D = MeshInstance3D.new()
    ring.name = "PlanetRing"

    var mesh: CylinderMesh = CylinderMesh.new()
    mesh.top_radius = 1.0
    mesh.bottom_radius = 1.0
    mesh.height = 0.012
    mesh.radial_segments = 80 if quality_level > 0 else 48
    ring.mesh = mesh
    ring.scale = Vector3(visual_radius * 2.55, visual_radius * 0.035, visual_radius * 2.55)

    var material: ShaderMaterial = ShaderMaterial.new()
    material.shader = load("res://shaders/rings.gdshader") as Shader
    ring.material_override = material
    holder.add_child(ring)

func _sync_visuals() -> void:
    for i: int in range(bodies.size()):
        var body: Dictionary = bodies[i]
        var node: Node3D = body.get("node") as Node3D

        if not is_instance_valid(node):
            continue

        var position_km: Vector3 = body.get("pos", Vector3.ZERO) as Vector3
        node.position = position_km * POSITION_SCALE

        var disk: Node3D = node.get_node_or_null("AccretionDisk") as Node3D
        if is_instance_valid(disk):
            disk.rotate_y(get_process_delta_time() * 0.34)

        var clouds: Node3D = node.get_node_or_null("Clouds") as Node3D
        if is_instance_valid(clouds):
            clouds.rotate_y(get_process_delta_time() * 0.012)

func _update_camera(delta: float) -> void:
    if pause_menu_open or not is_instance_valid(camera):
        return

    var movement: Vector3 = Vector3.ZERO

    if Input.is_key_pressed(KEY_W):
        movement -= camera.global_transform.basis.z
    if Input.is_key_pressed(KEY_S):
        movement += camera.global_transform.basis.z
    if Input.is_key_pressed(KEY_A):
        movement -= camera.global_transform.basis.x
    if Input.is_key_pressed(KEY_D):
        movement += camera.global_transform.basis.x
    if Input.is_key_pressed(KEY_E):
        movement += Vector3.UP
    if Input.is_key_pressed(KEY_Q):
        movement -= Vector3.UP

    if movement.length_squared() > 0.0:
        var speed_multiplier: float = 5.0 if Input.is_key_pressed(KEY_SHIFT) else 1.0
        camera.position += movement.normalized() * camera_speed * speed_multiplier * delta

func _update_hud() -> void:
    if not is_instance_valid(hud):
        return

    hud.call("update_status", time_scale, bodies.size(), sim_paused or pause_menu_open)

    if selected_index >= 0 and selected_index < bodies.size():
        hud.call("show_selected", bodies[selected_index])
    else:
        hud.call("show_selected", {})

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseMotion:
        var motion: InputEventMouseMotion = event as InputEventMouseMotion
        if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and not pause_menu_open:
            camera.rotate_y(-motion.relative.x * mouse_sensitivity)
            camera.rotation.x = clampf(
                camera.rotation.x - motion.relative.y * mouse_sensitivity,
                deg_to_rad(-88.0),
                deg_to_rad(88.0)
            )
            return

    if event is InputEventMouseButton:
        var mouse_button: InputEventMouseButton = event as InputEventMouseButton
        if mouse_button.pressed and mouse_button.button_index == MOUSE_BUTTON_LEFT and not pause_menu_open:
            _select_at_screen(mouse_button.position)
            return

    if event is InputEventKey:
        var key_event: InputEventKey = event as InputEventKey
        if not key_event.pressed or key_event.echo:
            return

        match key_event.keycode:
            KEY_ESCAPE:
                _toggle_pause_menu()
            KEY_SPACE:
                if not pause_menu_open:
                    sim_paused = not sim_paused
                    hud.call("flash_notice", "PAUSED" if sim_paused else "RUNNING")
            KEY_BRACKETLEFT:
                if not pause_menu_open:
                    time_scale = maxf(1.0, time_scale * 0.5)
                    hud.call("flash_notice", "TIME  ×%s" % _short_scale())
            KEY_BRACKETRIGHT:
                if not pause_menu_open:
                    time_scale = minf(2592000.0, time_scale * 2.0)
                    hud.call("flash_notice", "TIME  ×%s" % _short_scale())
            KEY_1:
                _spawn_in_front("PLANET")
            KEY_2:
                _spawn_in_front("STAR")
            KEY_3:
                _spawn_in_front("BLACK_HOLE")
            KEY_F5:
                _quick_save()
            KEY_F9:
                _quick_load()

func _select_at_screen(screen_position: Vector2) -> void:
    if not is_instance_valid(camera):
        return

    var ray_origin: Vector3 = camera.project_ray_origin(screen_position)
    var ray_end: Vector3 = ray_origin + camera.project_ray_normal(screen_position) * 24000.0
    var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
    query.collide_with_areas = true
    query.collide_with_bodies = false

    var result: Dictionary = get_world_3d().direct_space_state.intersect_ray(query)

    if result.is_empty():
        selected_index = -1
        return

    var collider_variant: Variant = result.get("collider")
    if collider_variant is Area3D:
        var collider: Area3D = collider_variant as Area3D
        if collider.has_meta("body_index"):
            selected_index = int(collider.get_meta("body_index"))

func _spawn_in_front(body_type: String) -> void:
    if pause_menu_open or not is_instance_valid(camera):
        return

    var world_position: Vector3 = camera.global_position - camera.global_transform.basis.z * 170.0
    var position_km: Vector3 = world_position / POSITION_SCALE
    var body: Dictionary

    if body_type == "STAR":
        body = _make_body(
            "New Star", "STAR", 1.98847e30, 695700.0,
            position_km, Vector3.ZERO, 5772.0,
            Color(1.0, 0.55, 0.12), false
        )
    elif body_type == "BLACK_HOLE":
        body = _make_body(
            "Black Hole", "BLACK_HOLE", 1.98847e31, 29.53,
            position_km, Vector3.ZERO, 0.000001,
            Color.BLACK, false
        )
    else:
        body = _make_body(
            "New Planet", "PLANET", 5.9722e24, 6371.0,
            position_km, Vector3.ZERO, 288.0,
            Color(0.04, 0.32, 0.92), false
        )

    _add_body(body)

    if is_instance_valid(hud):
        hud.call("flash_notice", body_type.replace("_", " ") + " CREATED")

func _toggle_pause_menu() -> void:
    pause_menu_open = not pause_menu_open

    if is_instance_valid(hud):
        hud.call("set_pause_menu_visible", pause_menu_open)

    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if pause_menu_open else Input.MOUSE_MODE_CAPTURED

func _resume_from_menu() -> void:
    pause_menu_open = false

    if is_instance_valid(hud):
        hud.call("set_pause_menu_visible", false)

    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _return_to_menu() -> void:
    exit_requested.emit()

func _visual_radius(radius_km: float, body_type: String) -> float:
    var safe_radius: float = maxf(radius_km, 1.0)
    var log_radius: float = log(safe_radius) / log(10.0)
    var result: float = clampf(pow(log_radius, 2.0) * 0.55, 2.3, 45.0)

    if body_type == "STAR":
        result *= 1.65
    elif body_type == "BLACK_HOLE":
        result = clampf(result * 2.4, 9.0, 55.0)

    return result

func _land_color(base_color: Color, body_type: String) -> Color:
    if body_type == "MOON":
        return Color(0.36, 0.37, 0.39)
    if body_type == "ROCKY":
        return base_color.lightened(0.18)
    if base_color.b > base_color.r:
        return Color(0.055, 0.29, 0.12)
    return base_color.lightened(0.12)

func _reindex_areas() -> void:
    for i: int in range(bodies.size()):
        var body: Dictionary = bodies[i]
        var node: Node3D = body.get("node") as Node3D

        if not is_instance_valid(node):
            continue

        var children: Array[Node] = node.get_children()
        for child: Node in children:
            if child is Area3D:
                var area: Area3D = child as Area3D
                area.set_meta("body_index", i)

func _rebuild_body_visual(index: int) -> void:
    if index < 0 or index >= bodies.size():
        return

    var body: Dictionary = bodies[index]
    var old_node: Node3D = body.get("node") as Node3D

    if is_instance_valid(old_node):
        old_node.queue_free()

    body["node"] = _create_visual(body, index)
    bodies[index] = body

func _quick_save() -> void:
    var save_bodies: Array = []

    for i: int in range(bodies.size()):
        var body: Dictionary = bodies[i]
        var position: Vector3 = body.get("pos", Vector3.ZERO) as Vector3
        var velocity: Vector3 = body.get("vel", Vector3.ZERO) as Vector3
        var color_value: Color = body.get("color", Color.WHITE) as Color

        save_bodies.append({
            "name": str(body.get("name", "Body")),
            "type": str(body.get("type", "PLANET")),
            "mass": float(body.get("mass", 1.0)),
            "radius": float(body.get("radius", 1.0)),
            "pos": [position.x, position.y, position.z],
            "vel": [velocity.x, velocity.y, velocity.z],
            "temp": float(body.get("temp", 250.0)),
            "color": [color_value.r, color_value.g, color_value.b, color_value.a],
            "fixed": bool(body.get("fixed", false))
        })

    var payload: Dictionary = {
        "version": 2,
        "time_scale": time_scale,
        "bodies": save_bodies
    }

    var file: FileAccess = FileAccess.open("user://raken_quicksave.json", FileAccess.WRITE)

    if file != null:
        file.store_string(JSON.stringify(payload))
        if is_instance_valid(hud):
            hud.call("flash_notice", "QUICK SAVE COMPLETE")

func _quick_load() -> void:
    if not FileAccess.file_exists("user://raken_quicksave.json"):
        if is_instance_valid(hud):
            hud.call("flash_notice", "NO QUICK SAVE")
        return

    var file: FileAccess = FileAccess.open("user://raken_quicksave.json", FileAccess.READ)
    if file == null:
        return

    var parsed: Variant = JSON.parse_string(file.get_as_text())
    if not (parsed is Dictionary):
        if is_instance_valid(hud):
            hud.call("flash_notice", "SAVE FILE ERROR")
        return

    var payload: Dictionary = parsed as Dictionary
    var raw_bodies: Array = payload.get("bodies", []) as Array

    for i: int in range(bodies.size()):
        var current: Dictionary = bodies[i]
        var current_node: Node3D = current.get("node") as Node3D
        if is_instance_valid(current_node):
            current_node.queue_free()

    bodies.clear()
    selected_index = -1
    time_scale = float(payload.get("time_scale", 7200.0))

    for i: int in range(raw_bodies.size()):
        var raw_variant: Variant = raw_bodies[i]
        if not (raw_variant is Dictionary):
            continue

        var raw: Dictionary = raw_variant as Dictionary
        var pos_array: Array = raw.get("pos", [0.0, 0.0, 0.0]) as Array
        var vel_array: Array = raw.get("vel", [0.0, 0.0, 0.0]) as Array
        var color_array: Array = raw.get("color", [0.5, 0.5, 0.5, 1.0]) as Array

        var position: Vector3 = _array_to_vector3(pos_array)
        var velocity: Vector3 = _array_to_vector3(vel_array)
        var color_value: Color = _array_to_color(color_array)

        _add_body(_make_body(
            str(raw.get("name", "Body")),
            str(raw.get("type", "PLANET")),
            float(raw.get("mass", 1.0e20)),
            float(raw.get("radius", 1000.0)),
            position,
            velocity,
            float(raw.get("temp", 250.0)),
            color_value,
            bool(raw.get("fixed", false))
        ))

    if is_instance_valid(hud):
        hud.call("flash_notice", "QUICK SAVE LOADED")

func _array_to_vector3(values: Array) -> Vector3:
    if values.size() < 3:
        return Vector3.ZERO

    return Vector3(
        float(values[0]),
        float(values[1]),
        float(values[2])
    )

func _array_to_color(values: Array) -> Color:
    if values.size() < 4:
        return Color(0.5, 0.5, 0.5, 1.0)

    return Color(
        float(values[0]),
        float(values[1]),
        float(values[2]),
        float(values[3])
    )

func _short_scale() -> String:
    if time_scale >= 86400.0:
        return "%.1f d/s" % (time_scale / 86400.0)
    if time_scale >= 3600.0:
        return "%.1f h/s" % (time_scale / 3600.0)
    return "%.0f s/s" % time_scale
