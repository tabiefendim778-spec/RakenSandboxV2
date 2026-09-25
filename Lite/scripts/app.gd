extends Node

const MENU_SCRIPT: Script = preload("res://scripts/main_menu.gd")
const SIMULATION_SCRIPT: Script = preload("res://scripts/simulation.gd")

var _menu: Node = null
var _simulation: Node = null
var _transition: ColorRect = null
var _quality_level: int = 1

func _ready() -> void:
    DisplayServer.window_set_title("RAKEN SANDBOX")
    _build_transition_layer()
    await _play_intro()
    _show_menu()

func _build_transition_layer() -> void:
    var layer: CanvasLayer = CanvasLayer.new()
    layer.layer = 100
    add_child(layer)

    _transition = ColorRect.new()
    _transition.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    _transition.color = Color(0.001, 0.003, 0.010, 0.0)
    _transition.mouse_filter = Control.MOUSE_FILTER_IGNORE
    layer.add_child(_transition)

func _play_intro() -> void:
    var layer: CanvasLayer = CanvasLayer.new()
    layer.layer = 90
    add_child(layer)

    var root: Control = Control.new()
    root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    root.mouse_filter = Control.MOUSE_FILTER_IGNORE
    layer.add_child(root)

    var background: ColorRect = ColorRect.new()
    background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    var background_material: ShaderMaterial = ShaderMaterial.new()
    background_material.shader = load("res://shaders/menu_space.gdshader") as Shader
    background.material = background_material
    root.add_child(background)

    var center: VBoxContainer = VBoxContainer.new()
    center.set_anchors_preset(Control.PRESET_CENTER)
    center.position = Vector2(-360.0, -110.0)
    center.size = Vector2(720.0, 220.0)
    center.alignment = BoxContainer.ALIGNMENT_CENTER
    center.add_theme_constant_override("separation", 4)
    root.add_child(center)

    var title: Label = Label.new()
    title.text = "RAKEN"
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_theme_font_size_override("font_size", 78)
    title.add_theme_color_override("font_color", Color(0.82, 0.95, 1.0))
    title.add_theme_constant_override("outline_size", 8)
    title.add_theme_color_override("font_outline_color", Color(0.03, 0.16, 0.28, 0.45))
    center.add_child(title)

    var subtitle: Label = Label.new()
    subtitle.text = "SANDBOX"
    subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    subtitle.add_theme_font_size_override("font_size", 23)
    subtitle.add_theme_color_override("font_color", Color(0.26, 0.73, 1.0))
    center.add_child(subtitle)

    var divider: ColorRect = ColorRect.new()
    divider.custom_minimum_size = Vector2(260.0, 1.0)
    divider.color = Color(0.15, 0.62, 1.0, 0.42)
    center.add_child(divider)

    var status: Label = Label.new()
    status.text = "CELESTIAL SIMULATION SYSTEM"
    status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    status.add_theme_font_size_override("font_size", 11)
    status.add_theme_color_override("font_color", Color(0.48, 0.60, 0.72))
    center.add_child(status)

    await get_tree().create_timer(0.75).timeout

    var tween: Tween = create_tween()
    tween.set_trans(Tween.TRANS_QUAD)
    tween.set_ease(Tween.EASE_IN_OUT)
    tween.tween_property(root, "modulate:a", 0.0, 0.35)
    await tween.finished

    layer.queue_free()

func _show_menu() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

    if is_instance_valid(_simulation):
        _simulation.queue_free()
        _simulation = null

    if is_instance_valid(_menu):
        _menu.queue_free()
        _menu = null

    var menu_node: Node = MENU_SCRIPT.new()
    menu_node.connect("start_requested", Callable(self, "_start_simulation"))
    menu_node.connect("quality_changed", Callable(self, "_set_quality"))
    menu_node.connect("quit_requested", Callable(self, "_quit_game"))
    _menu = menu_node
    add_child(_menu)

    _fade_from_black()

func _start_simulation() -> void:
    await _fade_to_black()

    if is_instance_valid(_menu):
        _menu.queue_free()
        _menu = null

    var simulation_node: Node = SIMULATION_SCRIPT.new()
    simulation_node.set("quality_level", _quality_level)
    simulation_node.connect("exit_requested", Callable(self, "_return_to_menu"))
    _simulation = simulation_node
    add_child(_simulation)

    await get_tree().process_frame
    _fade_from_black()

func _return_to_menu() -> void:
    await _fade_to_black()
    _show_menu()

func _set_quality(level: int) -> void:
    _quality_level = clampi(level, 0, 2)

func _quit_game() -> void:
    await _fade_to_black()
    get_tree().quit()

func _fade_to_black() -> void:
    if not is_instance_valid(_transition):
        return

    _transition.mouse_filter = Control.MOUSE_FILTER_STOP
    var color_value: Color = _transition.color
    color_value.a = 0.0
    _transition.color = color_value

    var tween: Tween = create_tween()
    tween.set_trans(Tween.TRANS_QUAD)
    tween.set_ease(Tween.EASE_IN_OUT)
    tween.tween_property(_transition, "color:a", 1.0, 0.24)
    await tween.finished

func _fade_from_black() -> void:
    if not is_instance_valid(_transition):
        return

    var color_value: Color = _transition.color
    color_value.a = 1.0
    _transition.color = color_value

    var tween: Tween = create_tween()
    tween.set_trans(Tween.TRANS_QUAD)
    tween.set_ease(Tween.EASE_IN_OUT)
    tween.tween_property(_transition, "color:a", 0.0, 0.38)
    tween.finished.connect(Callable(self, "_on_fade_from_black_finished"))

func _on_fade_from_black_finished() -> void:
    if is_instance_valid(_transition):
        _transition.mouse_filter = Control.MOUSE_FILTER_IGNORE
