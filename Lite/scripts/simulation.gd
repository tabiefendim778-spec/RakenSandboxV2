extends Node3D

signal exit_requested

const G_KM := 6.67430e-20
const POSITION_SCALE := 0.000004
const MAX_BODIES := 96

const StarfieldScript = preload("res://scripts/starfield.gd")
const HUDScript = preload("res://scripts/hud.gd")

var quality_level: int = 1
var bodies: Array[Dictionary] = []
var camera: Camera3D
var hud: CanvasLayer
var sim_paused := false
var pause_menu_open := false
var time_scale := 7200.0
var mouse_sensitivity := 0.0022
var camera_speed := 260.0
var selected_index := -1

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
    var world_env := WorldEnvironment.new()
    var env := Environment.new()
    env.background_mode = Environment.BG_COLOR
    env.background_color = Color(0.0015, 0.0025, 0.009, 1.0)
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color(0.08, 0.11, 0.18)
    env.ambient_light_energy = 0.16
    env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
    world_env.environment = env
    add_child(world_env)

func _build_camera() -> void:
    camera = Camera3D.new()
    camera.fov = 72.0
    camera.near = 0.08
    camera.far = 25000.0
    camera.position = Vector3(210.0, 175.0, 820.0)
    add_child(camera)
    camera.look_at(Vector3.ZERO, Vector3.UP)

func _build_starfield() -> void:
    var stars = StarfieldScript.new()
    stars.quality_level = quality_level
    add_child(stars)

func _build_hud() -> void:
    hud = HUDScript.new()
    hud.return_to_menu_requested.connect(_return_to_menu)
    add_child(hud)

func _seed_solar_system() -> void:
    bodies.clear()

    _add_body({
        "name": "Sun",
        "type": "STAR",
        "mass": 1.98847e30,
        "radius": 695700.0,
        "pos": Vector3.ZERO,
        "vel": Vector3.ZERO,
        "temp": 5772.0,
        "color": Color(1.0, 0.56, 0.14),
        "fixed": true
    })

    _add_body({
        "name": "Earth",
        "type": "PLANET",
        "mass": 5.9722e24,
        "radius": 6371.0,
        "pos": Vector3(149597870.7, 0.0, 0.0),
        "vel": Vector3(0.0, 0.0, 29.78),
        "temp": 288.0,
        "color": Color(0.05, 0.30, 0.95),
        "fixed": false
    })

    _add_body({
        "name": "Moon",
        "type": "MOON",
        "mass": 7.342e22,
        "radius": 1737.4,
        "pos": Vector3(149982270.7, 0.0, 0.0),
        "vel": Vector3(0.0, 0.0, 30.802),
        "temp": 250.0,
        "color": Color(0.58, 0.60, 0.64),
        "fixed": false
    })

    _add_body({
        "name": "Mars",
        "type": "PLANET",
        "mass": 6.4171e23,
        "radius": 3389.5,
        "pos": Vector3(0.0, 0.0, -227939200.0),
        "vel": Vector3(24.077, 0.0, 0.0),
        "temp": 210.0,
        "color": Color(0.76, 0.22, 0.08),
        "fixed": false
    })

    _add_body({
        "name": "Jupiter",
        "type": "PLANET",
        "mass": 1.89813e27,
        "radius": 69911.0,
        "pos": Vector3(-778570000.0, 0.0, 0.0),
        "vel": Vector3(0.0, 0.0, -13.07),
        "temp": 165.0,
        "color": Color(0.72, 0.50, 0.30),
        "fixed": false
    })

    _add_body({
        "name": "Saturn",
        "type": "RINGED_PLANET",
        "mass": 5.6834e26,
        "radius": 58232.0,
        "pos": Vector3(0.0, 0.0, 1433530000.0),
        "vel": Vector3(-9.68, 0.0, 0.0),
        "temp": 134.0,
        "color": Color(0.80, 0.70, 0.45),
        "fixed": false
    })

func _process(delta: float) -> void:
    _update_camera(delta)

    if not sim_paused and not pause_menu_open:
        _simulate(delta)

    _sync_visuals()

    if is_instance_valid(hud):
        hud.update_status(time_scale, bodies.size(), sim_paused or pause_menu_open)
        if selected_index >= 0 and selected_index < bodies.size():
            hud.show_selected(bodies[selected_index])
        else:
            hud.show_selected({})

func _simulate(delta: float) -> void:
    if bodies.size() < 2:
        return

    var total_dt := min(delta * time_scale, 86400.0 * 2.0)
    var substeps := clampi(int(ceil(total_dt / 1200.0)), 1, 10)
    var dt := total_dt / float(substeps)

    for _step in substeps:
        var accelerations: Array[Vector3] = []
        accelerations.resize(bodies.size())

        for i in bodies.size():
            accelerations[i] = Vector3.ZERO
            if bool(bodies[i].get("fixed", false)):
                continue

            var pos_i: Vector3 = bodies[i]["pos"]
            var acceleration := Vector3.ZERO

            for j in bodies.size():
                if i == j:
                    continue

                var delta_pos: Vector3 = bodies[j]["pos"] - pos_i
                var dist_sq := max(delta_pos.length_squared(), 10000.0)
                var inv_dist := 1.0 / sqrt(dist_sq)
                var direction := delta_pos * inv_dist
                acceleration += direction * (G_KM * float(bodies[j]["mass"]) / dist_sq)

            accelerations[i] = acceleration

        for i in bodies.size():
            if bool(bodies[i].get("fixed", false)):
                continue

            var vel: Vector3 = bodies[i]["vel"]
            vel += accelerations[i] * dt
            bodies[i]["vel"] = vel
            bodies[i]["pos"] = (bodies[i]["pos"] as Vector3) + vel * dt

        _resolve_collisions()

func _resolve_collisions() -> void:
    var i := 0
    while i < bodies.size():
        var j := i + 1
        while j < bodies.size():
            var a := bodies[i]
            var b := bodies[j]
            var distance_km := (a["pos"] as Vector3).distance_to(b["pos"])
            var collision_radius := (float(a["radius"]) + float(b["radius"])) * 0.82

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
    if a_index < 0 or b_index < 0 or a_index >= bodies.size() or b_index >= bodies.size():
        return

    var a := bodies[a_index]
    var b := bodies[b_index]
    var mass_a := float(a["mass"])
    var mass_b := float(b["mass"])
    var total_mass := mass_a + mass_b

    var merged_velocity: Vector3 = (
        (a["vel"] as Vector3) * mass_a + (b["vel"] as Vector3) * mass_b
    ) / total_mass

    var merged_position: Vector3 = (
        (a["pos"] as Vector3) * mass_a + (b["pos"] as Vector3) * mass_b
    ) / total_mass

    var radius := pow(pow(float(a["radius"]), 3.0) + pow(float(b["radius"]), 3.0), 1.0 / 3.0)
    var dominant := a if mass_a >= mass_b else b

    a["name"] = "%s + %s" % [a["name"], b["name"]]
    a["type"] = dominant["type"]
    a["mass"] = total_mass
    a["radius"] = radius
    a["vel"] = merged_velocity
    a["pos"] = merged_position
    a["temp"] = (float(a["temp"]) * mass_a + float(b["temp"]) * mass_b) / total_mass
    a["color"] = (a["color"] as Color).lerp(b["color"], mass_b / total_mass)
    a["fixed"] = bool(a.get("fixed", false)) or bool(b.get("fixed", false))

    if is_instance_valid(b.get("node")):
        b["node"].queue_free()

    bodies[a_index] = a
    bodies.remove_at(b_index)
    _reindex_areas()
    _rebuild_body_visual(a_index)

    if is_instance_valid(hud):
        hud.flash_notice("COLLISION MERGE")

func _add_body(data: Dictionary) -> void:
    if bodies.size() >= MAX_BODIES:
        if is_instance_valid(hud):
            hud.flash_notice("BODY LIMIT REACHED")
        return

    var body := data.duplicate(true)
    var node := _create_visual(body, bodies.size())
    body["node"] = node
    bodies.append(body)

func _create_visual(body: Dictionary, body_index: int) -> Node3D:
    var holder := Node3D.new()
    holder.name = str(body["name"])
    add_child(holder)

    var sphere := MeshInstance3D.new()
    var sphere_mesh := SphereMesh.new()
    sphere_mesh.radius = 1.0
    sphere_mesh.height = 2.0
    sphere_mesh.radial_segments = 32 if quality_level > 0 else 20
    sphere_mesh.rings = 16 if quality_level > 0 else 10
    sphere.mesh = sphere_mesh
    holder.add_child(sphere)

    var visual_radius := _visual_radius(float(body["radius"]), str(body["type"]))
    sphere.scale = Vector3.ONE * visual_radius

    var body_type := str(body["type"])
    if body_type == "STAR":
        var mat := ShaderMaterial.new()
        mat.shader = load("res://shaders/star.gdshader")
        mat.set_shader_parameter("star_color", body["color"])
        mat.set_shader_parameter("intensity", 3.6)
        sphere.material_override = mat

        var light := OmniLight3D.new()
        light.light_color = body["color"]
        light.light_energy = 5.0
        light.omni_range = 2400.0
        light.shadow_enabled = quality_level >= 2
        holder.add_child(light)
    elif body_type == "BLACK_HOLE":
        var black_mat := ShaderMaterial.new()
        black_mat.shader = load("res://shaders/black_hole.gdshader")
        sphere.material_override = black_mat
        _add_accretion_disk(holder, visual_radius)
    else:
        var mat := ShaderMaterial.new()
        mat.shader = load("res://shaders/planet.gdshader")
        mat.set_shader_parameter("base_color", body["color"])
        mat.set_shader_parameter("land_color", _land_color(body["color"], body_type))
        mat.set_shader_parameter("ocean_amount", 0.48 if str(body["name"]) == "Earth" else 0.58)
        mat.set_shader_parameter("seed", float(body_index) * 3.17 + 1.2)
        sphere.material_override = mat

        if body_type == "PLANET" and quality_level > 0:
            _add_atmosphere(holder, visual_radius, body["color"])

        if body_type == "RINGED_PLANET":
            _add_ring(holder, visual_radius)

    var area := Area3D.new()
    area.set_meta("body_index", body_index)
    holder.add_child(area)

    var collision := CollisionShape3D.new()
    var shape := SphereShape3D.new()
    shape.radius = max(visual_radius * 1.15, 3.0)
    collision.shape = shape
    area.add_child(collision)

    holder.position = (body["pos"] as Vector3) * POSITION_SCALE
    return holder

func _add_atmosphere(holder: Node3D, radius_value: float, color_value: Color) -> void:
    var atmosphere := MeshInstance3D.new()
    var mesh := SphereMesh.new()
    mesh.radius = 1.0
    mesh.height = 2.0
    mesh.radial_segments = 28
    mesh.rings = 14
    atmosphere.mesh = mesh
    atmosphere.scale = Vector3.ONE * radius_value * 1.055

    var material := ShaderMaterial.new()
    material.shader = load("res://shaders/atmosphere.gdshader")
    material.set_shader_parameter("atmosphere_color", color_value.lerp(Color(0.25, 0.62, 1.0), 0.72))
    material.set_shader_parameter("strength", 1.7)
    material.set_shader_parameter("density", 0.25)
    atmosphere.material_override = material
    holder.add_child(atmosphere)

func _add_accretion_disk(holder: Node3D, radius_value: float) -> void:
    var disk := MeshInstance3D.new()
    disk.name = "AccretionDisk"
    var mesh := CylinderMesh.new()
    mesh.top_radius = 1.0
    mesh.bottom_radius = 1.0
    mesh.height = 0.018
    mesh.radial_segments = 96 if quality_level >= 2 else 48
    disk.mesh = mesh
    disk.scale = Vector3(radius_value * 5.4, radius_value * 0.15, radius_value * 5.4)

    var mat := ShaderMaterial.new()
    mat.shader = load("res://shaders/accretion.gdshader")
    disk.material_override = mat
    holder.add_child(disk)

func _add_ring(holder: Node3D, radius_value: float) -> void:
    var ring := MeshInstance3D.new()
    var mesh := CylinderMesh.new()
    mesh.top_radius = 1.0
    mesh.bottom_radius = 1.0
    mesh.height = 0.012
    mesh.radial_segments = 72
    ring.mesh = mesh
    ring.scale = Vector3(radius_value * 2.6, radius_value * 0.05, radius_value * 2.6)

    var mat := StandardMaterial3D.new()
    mat.albedo_color = Color(0.78, 0.66, 0.43, 0.42)
    mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    mat.cull_mode = BaseMaterial3D.CULL_DISABLED
    ring.material_override = mat
    holder.add_child(ring)

func _sync_visuals() -> void:
    for body in bodies:
        var node: Node3D = body.get("node")
        if is_instance_valid(node):
            node.position = (body["pos"] as Vector3) * POSITION_SCALE

            var disk := node.get_node_or_null("AccretionDisk")
            if is_instance_valid(disk):
                disk.rotate_y(get_process_delta_time() * 0.35)

func _update_camera(delta: float) -> void:
    if pause_menu_open:
        return

    var move := Vector3.ZERO
    if Input.is_key_pressed(KEY_W):
        move -= camera.global_transform.basis.z
    if Input.is_key_pressed(KEY_S):
        move += camera.global_transform.basis.z
    if Input.is_key_pressed(KEY_A):
        move -= camera.global_transform.basis.x
    if Input.is_key_pressed(KEY_D):
        move += camera.global_transform.basis.x
    if Input.is_key_pressed(KEY_E):
        move += Vector3.UP
    if Input.is_key_pressed(KEY_Q):
        move -= Vector3.UP

    if move.length_squared() > 0.0:
        var multiplier := 5.0 if Input.is_key_pressed(KEY_SHIFT) else 1.0
        camera.position += move.normalized() * camera_speed * multiplier * delta

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
        camera.rotate_y(-event.relative.x * mouse_sensitivity)
        camera.rotation.x = clamp(
            camera.rotation.x - event.relative.y * mouse_sensitivity,
            deg_to_rad(-88.0),
            deg_to_rad(88.0)
        )

    if event is InputEventMouseButton and event.pressed:
        if event.button_index == MOUSE_BUTTON_LEFT and not pause_menu_open:
            _select_at_screen(event.position)

    if event is InputEventKey and event.pressed and not event.echo:
        match event.keycode:
            KEY_ESCAPE:
                _toggle_pause_menu()
            KEY_SPACE:
                if not pause_menu_open:
                    sim_paused = not sim_paused
                    hud.flash_notice("PAUSED" if sim_paused else "RUNNING")
            KEY_BRACKETLEFT:
                time_scale = max(1.0, time_scale * 0.5)
                hud.flash_notice("TIME ×%s" % _short_scale())
            KEY_BRACKETRIGHT:
                time_scale = min(2592000.0, time_scale * 2.0)
                hud.flash_notice("TIME ×%s" % _short_scale())
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
    var from := camera.project_ray_origin(screen_position)
    var to := from + camera.project_ray_normal(screen_position) * 20000.0
    var query := PhysicsRayQueryParameters3D.create(from, to)
    query.collide_with_areas = true
    query.collide_with_bodies = false

    var result := get_world_3d().direct_space_state.intersect_ray(query)
    if result.is_empty():
        selected_index = -1
        return

    var collider = result.get("collider")
    if collider != null and collider.has_meta("body_index"):
        selected_index = int(collider.get_meta("body_index"))

func _spawn_in_front(body_type: String) -> void:
    if pause_menu_open:
        return

    var world_pos := camera.global_position - camera.global_transform.basis.z * 170.0
    var pos_km := world_pos / POSITION_SCALE
    var data: Dictionary

    if body_type == "STAR":
        data = {
            "name": "New Star",
            "type": "STAR",
            "mass": 1.98847e30,
            "radius": 695700.0,
            "pos": pos_km,
            "vel": Vector3.ZERO,
            "temp": 5772.0,
            "color": Color(1.0, 0.55, 0.14),
            "fixed": false
        }
    elif body_type == "BLACK_HOLE":
        data = {
            "name": "Black Hole",
            "type": "BLACK_HOLE",
            "mass": 1.98847e31,
            "radius": 29.53,
            "pos": pos_km,
            "vel": Vector3.ZERO,
            "temp": 0.000001,
            "color": Color.BLACK,
            "fixed": false
        }
    else:
        data = {
            "name": "New Planet",
            "type": "PLANET",
            "mass": 5.9722e24,
            "radius": 6371.0,
            "pos": pos_km,
            "vel": Vector3.ZERO,
            "temp": 288.0,
            "color": Color(0.08, 0.35, 0.92),
            "fixed": false
        }

    _add_body(data)
    hud.flash_notice(body_type.replace("_", " ") + " CREATED")

func _toggle_pause_menu() -> void:
    pause_menu_open = not pause_menu_open
    hud.set_pause_menu_visible(pause_menu_open)
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if pause_menu_open else Input.MOUSE_MODE_CAPTURED

func _return_to_menu() -> void:
    exit_requested.emit()

func _visual_radius(radius_km: float, body_type: String) -> float:
    var result := clamp(pow(log(max(radius_km, 1.0)) / log(10.0), 2.0) * 0.43, 2.2, 42.0)
    if body_type == "STAR":
        result *= 1.55
    elif body_type == "BLACK_HOLE":
        result = clamp(result * 2.2, 8.0, 52.0)
    return result

func _land_color(base: Color, body_type: String) -> Color:
    if body_type == "MOON":
        return Color(0.38, 0.38, 0.39)
    if base.r > base.b:
        return base.lightened(0.16)
    return Color(0.07, 0.30, 0.13)

func _reindex_areas() -> void:
    for i in bodies.size():
        var node: Node3D = bodies[i].get("node")
        if not is_instance_valid(node):
            continue
        for child in node.get_children():
            if child is Area3D:
                child.set_meta("body_index", i)

func _rebuild_body_visual(index: int) -> void:
    if index < 0 or index >= bodies.size():
        return

    var old_node: Node3D = bodies[index].get("node")
    if is_instance_valid(old_node):
        old_node.queue_free()

    bodies[index]["node"] = _create_visual(bodies[index], index)

func _quick_save() -> void:
    var save_bodies: Array = []
    for body in bodies:
        save_bodies.append({
            "name": body["name"],
            "type": body["type"],
            "mass": body["mass"],
            "radius": body["radius"],
            "pos": _vec_to_array(body["pos"]),
            "vel": _vec_to_array(body["vel"]),
            "temp": body["temp"],
            "color": _color_to_array(body["color"]),
            "fixed": body.get("fixed", false)
        })

    var payload := {
        "version": 1,
        "time_scale": time_scale,
        "bodies": save_bodies
    }

    var file := FileAccess.open("user://raken_quicksave.json", FileAccess.WRITE)
    if file:
        file.store_string(JSON.stringify(payload))
        hud.flash_notice("QUICK SAVE COMPLETE")

func _quick_load() -> void:
    if not FileAccess.file_exists("user://raken_quicksave.json"):
        hud.flash_notice("NO QUICK SAVE")
        return

    var file := FileAccess.open("user://raken_quicksave.json", FileAccess.READ)
    if file == null:
        return

    var parsed = JSON.parse_string(file.get_as_text())
    if not parsed is Dictionary:
        hud.flash_notice("SAVE FILE ERROR")
        return

    for body in bodies:
        var node: Node3D = body.get("node")
        if is_instance_valid(node):
            node.queue_free()

    bodies.clear()
    selected_index = -1
    time_scale = float(parsed.get("time_scale", 7200.0))

    for raw in parsed.get("bodies", []):
        var c: Array = raw.get("color", [0.5, 0.5, 0.5, 1.0])
        _add_body({
            "name": raw.get("name", "Body"),
            "type": raw.get("type", "PLANET"),
            "mass": float(raw.get("mass", 1.0e20)),
            "radius": float(raw.get("radius", 1000.0)),
            "pos": _array_to_vec(raw.get("pos", [0,0,0])),
            "vel": _array_to_vec(raw.get("vel", [0,0,0])),
            "temp": float(raw.get("temp", 250.0)),
            "color": Color(float(c[0]), float(c[1]), float(c[2]), float(c[3])),
            "fixed": bool(raw.get("fixed", false))
        })

    hud.flash_notice("QUICK SAVE LOADED")

func _vec_to_array(value: Vector3) -> Array:
    return [value.x, value.y, value.z]

func _array_to_vec(value: Array) -> Vector3:
    if value.size() < 3:
        return Vector3.ZERO
    return Vector3(float(value[0]), float(value[1]), float(value[2]))

func _color_to_array(value: Color) -> Array:
    return [value.r, value.g, value.b, value.a]

func _short_scale() -> String:
    if time_scale >= 86400.0:
        return "%.1f d/s" % (time_scale / 86400.0)
    if time_scale >= 3600.0:
        return "%.1f h/s" % (time_scale / 3600.0)
    return "%.0f s/s" % time_scale
