extends Node

const MenuScene = preload("res://scripts/main_menu.gd")
const SimulationScene = preload("res://scripts/simulation.gd")

var _menu: Control
var _simulation: Node
var _transition: ColorRect
var _quality: int = 1

func _ready() -> void:
    DisplayServer.window_set_title("RAKEN SANDBOX")
    _build_transition()
    _show_splash_then_menu()

func _build_transition() -> void:
    var layer := CanvasLayer.new()
    layer.layer = 100
    add_child(layer)

    _transition = ColorRect.new()
    _transition.color = Color(0.002, 0.004, 0.012, 1.0)
    _transition.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _transition.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    layer.add_child(_transition)

func _show_splash_then_menu() -> void:
    var layer := CanvasLayer.new()
    layer.layer = 90
    add_child(layer)

    var background := ColorRect.new()
    background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    var material := ShaderMaterial.new()
    material.shader = load("res://shaders/menu_space.gdshader")
    background.material = material
    layer.add_child(background)

    var center := VBoxContainer.new()
    center.alignment = BoxContainer.ALIGNMENT_CENTER
    center.set_anchors_preset(Control.PRESET_CENTER)
    center.position = Vector2(-350.0, -95.0)
    center.size = Vector2(700.0, 190.0)
    layer.add_child(center)

    var title := Label.new()
    title.text = "RAKEN"
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_theme_font_size_override("font_size", 72)
    title.add_theme_color_override("font_color", Color(0.78, 0.93, 1.0))
    center.add_child(title)

    var subtitle := Label.new()
    subtitle.text = "SANDBOX"
    subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    subtitle.add_theme_font_size_override("font_size", 24)
    subtitle.add_theme_color_override("font_color", Color(0.30, 0.70, 1.0))
    center.add_child(subtitle)

    var status := Label.new()
    status.text = "SIMULATION CORE INITIALIZING"
    status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    status.add_theme_font_size_override("font_size", 12)
    status.add_theme_color_override("font_color", Color(0.56, 0.62, 0.72))
    center.add_child(status)

    _transition.color.a = 0.0
    await get_tree().create_timer(0.9).timeout

    var tween := create_tween()
    tween.tween_property(layer, "modulate:a", 0.0, 0.55)
    await tween.finished
    layer.queue_free()
    _show_menu()

func _show_menu() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

    if is_instance_valid(_simulation):
        _simulation.queue_free()
        _simulation = null

    if is_instance_valid(_menu):
        _menu.queue_free()

    _menu = MenuScene.new()
    _menu.start_requested.connect(_start_simulation)
    _menu.quality_changed.connect(_set_quality)
    _menu.quit_requested.connect(_quit_game)
    add_child(_menu)

    _fade_from_black()

func _start_simulation() -> void:
    await _fade_to_black()

    if is_instance_valid(_menu):
        _menu.queue_free()
        _menu = null

    _simulation = SimulationScene.new()
    _simulation.quality_level = _quality
    _simulation.exit_requested.connect(_return_to_menu)
    add_child(_simulation)

    await get_tree().process_frame
    _fade_from_black()

func _return_to_menu() -> void:
    await _fade_to_black()
    _show_menu()

func _set_quality(level: int) -> void:
    _quality = clampi(level, 0, 2)

func _quit_game() -> void:
    await _fade_to_black()
    get_tree().quit()

func _fade_to_black() -> void:
    _transition.mouse_filter = Control.MOUSE_FILTER_STOP
    var tween := create_tween()
    tween.tween_property(_transition, "color:a", 1.0, 0.28)
    await tween.finished

func _fade_from_black() -> void:
    var tween := create_tween()
    tween.tween_property(_transition, "color:a", 0.0, 0.42)
    tween.finished.connect(func() -> void:
        _transition.mouse_filter = Control.MOUSE_FILTER_IGNORE
    )
