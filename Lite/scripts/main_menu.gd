extends Control

signal start_requested
signal quality_changed(level: int)
signal quit_requested

var _settings_panel: PanelContainer
var _quality_option: OptionButton

func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    _build_background()
    _build_layout()

func _build_background() -> void:
    var bg := ColorRect.new()
    bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

    var shader_material := ShaderMaterial.new()
    shader_material.shader = load("res://shaders/menu_space.gdshader")
    bg.material = shader_material
    add_child(bg)

    var shade := ColorRect.new()
    shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    shade.color = Color(0.0, 0.0, 0.02, 0.18)
    shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(shade)

func _build_layout() -> void:
    var root := MarginContainer.new()
    root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    root.add_theme_constant_override("margin_left", 82)
    root.add_theme_constant_override("margin_right", 82)
    root.add_theme_constant_override("margin_top", 58)
    root.add_theme_constant_override("margin_bottom", 48)
    add_child(root)

    var column := VBoxContainer.new()
    column.add_theme_constant_override("separation", 16)
    root.add_child(column)

    var brand := Label.new()
    brand.text = "RAKEN"
    brand.add_theme_font_size_override("font_size", 70)
    brand.add_theme_color_override("font_color", Color(0.80, 0.94, 1.0))
    column.add_child(brand)

    var sub := Label.new()
    sub.text = "SANDBOX  •  SPACE SIMULATION"
    sub.add_theme_font_size_override("font_size", 15)
    sub.add_theme_color_override("font_color", Color(0.30, 0.72, 1.0))
    column.add_child(sub)

    var spacer := Control.new()
    spacer.custom_minimum_size.y = 42
    column.add_child(spacer)

    var menu_panel := PanelContainer.new()
    menu_panel.custom_minimum_size = Vector2(410, 350)
    menu_panel.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
    menu_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.016, 0.027, 0.055, 0.91)))
    column.add_child(menu_panel)

    var margin := MarginContainer.new()
    margin.add_theme_constant_override("margin_left", 26)
    margin.add_theme_constant_override("margin_right", 26)
    margin.add_theme_constant_override("margin_top", 26)
    margin.add_theme_constant_override("margin_bottom", 26)
    menu_panel.add_child(margin)

    var buttons := VBoxContainer.new()
    buttons.add_theme_constant_override("separation", 12)
    margin.add_child(buttons)

    var intro := Label.new()
    intro.text = "SIMULATION"
    intro.add_theme_font_size_override("font_size", 12)
    intro.add_theme_color_override("font_color", Color(0.46, 0.61, 0.78))
    buttons.add_child(intro)

    buttons.add_child(_menu_button("NEW SANDBOX", _on_start))
    buttons.add_child(_menu_button("SETTINGS", _open_settings))
    buttons.add_child(_menu_button("QUIT", _on_quit))

    var filler := Control.new()
    filler.size_flags_vertical = Control.SIZE_EXPAND_FILL
    column.add_child(filler)

    var footer := Label.new()
    footer.text = "RAKEN LITE CORE  •  GODOT 4.7.2  •  COMPATIBILITY RENDERER"
    footer.add_theme_font_size_override("font_size", 11)
    footer.add_theme_color_override("font_color", Color(0.38, 0.43, 0.52))
    column.add_child(footer)

    _build_settings()

func _menu_button(text_value: String, callback: Callable) -> Button:
    var button := Button.new()
    button.text = text_value
    button.custom_minimum_size = Vector2(350, 58)
    button.alignment = HORIZONTAL_ALIGNMENT_LEFT
    button.add_theme_font_size_override("font_size", 17)
    button.add_theme_color_override("font_color", Color(0.82, 0.90, 0.98))
    button.add_theme_color_override("font_hover_color", Color.WHITE)
    button.add_theme_constant_override("outline_size", 0)
    button.add_theme_stylebox_override("normal", _button_style(Color(0.025, 0.055, 0.105, 0.78)))
    button.add_theme_stylebox_override("hover", _button_style(Color(0.035, 0.18, 0.30, 0.94)))
    button.add_theme_stylebox_override("pressed", _button_style(Color(0.02, 0.12, 0.22, 1.0)))
    button.pressed.connect(callback)
    return button

func _build_settings() -> void:
    _settings_panel = PanelContainer.new()
    _settings_panel.custom_minimum_size = Vector2(430, 390)
    _settings_panel.set_anchors_preset(Control.PRESET_CENTER)
    _settings_panel.position = Vector2(-215, -195)
    _settings_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.012, 0.024, 0.052, 0.97)))
    _settings_panel.visible = false
    add_child(_settings_panel)

    var margin := MarginContainer.new()
    margin.add_theme_constant_override("margin_left", 30)
    margin.add_theme_constant_override("margin_right", 30)
    margin.add_theme_constant_override("margin_top", 28)
    margin.add_theme_constant_override("margin_bottom", 28)
    _settings_panel.add_child(margin)

    var box := VBoxContainer.new()
    box.add_theme_constant_override("separation", 16)
    margin.add_child(box)

    var title := Label.new()
    title.text = "SETTINGS"
    title.add_theme_font_size_override("font_size", 27)
    title.add_theme_color_override("font_color", Color(0.78, 0.93, 1.0))
    box.add_child(title)

    var quality_label := Label.new()
    quality_label.text = "GRAPHICS QUALITY"
    quality_label.add_theme_font_size_override("font_size", 12)
    quality_label.add_theme_color_override("font_color", Color(0.50, 0.64, 0.80))
    box.add_child(quality_label)

    _quality_option = OptionButton.new()
    _quality_option.add_item("COMPATIBILITY")
    _quality_option.add_item("BALANCED")
    _quality_option.add_item("HIGH")
    _quality_option.selected = 1
    _quality_option.item_selected.connect(_on_quality_selected)
    box.add_child(_quality_option)

    var fullscreen := CheckButton.new()
    fullscreen.text = "FULLSCREEN"
    fullscreen.toggled.connect(_on_fullscreen_toggled)
    box.add_child(fullscreen)

    var vsync := CheckButton.new()
    vsync.text = "V-SYNC"
    vsync.button_pressed = true
    vsync.toggled.connect(_on_vsync_toggled)
    box.add_child(vsync)

    var info := Label.new()
    info.text = "Compatibility mode is recommended for Intel HD graphics."
    info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    info.add_theme_font_size_override("font_size", 12)
    info.add_theme_color_override("font_color", Color(0.48, 0.55, 0.65))
    box.add_child(info)

    var close := _menu_button("BACK", _close_settings)
    close.custom_minimum_size.y = 48
    box.add_child(close)

func _panel_style(color_value: Color) -> StyleBoxFlat:
    var style := StyleBoxFlat.new()
    style.bg_color = color_value
    style.border_color = Color(0.12, 0.35, 0.58, 0.38)
    style.set_border_width_all(1)
    style.set_corner_radius_all(14)
    return style

func _button_style(color_value: Color) -> StyleBoxFlat:
    var style := StyleBoxFlat.new()
    style.bg_color = color_value
    style.border_color = Color(0.10, 0.42, 0.70, 0.45)
    style.set_border_width_all(1)
    style.set_corner_radius_all(9)
    style.content_margin_left = 18
    return style

func _on_start() -> void:
    start_requested.emit()

func _on_quit() -> void:
    quit_requested.emit()

func _open_settings() -> void:
    _settings_panel.visible = true
    _settings_panel.modulate.a = 0.0
    var tween := create_tween()
    tween.tween_property(_settings_panel, "modulate:a", 1.0, 0.18)

func _close_settings() -> void:
    var tween := create_tween()
    tween.tween_property(_settings_panel, "modulate:a", 0.0, 0.14)
    await tween.finished
    _settings_panel.visible = false

func _on_quality_selected(index: int) -> void:
    quality_changed.emit(index)

func _on_fullscreen_toggled(enabled: bool) -> void:
    DisplayServer.window_set_mode(
        DisplayServer.WINDOW_MODE_FULLSCREEN if enabled else DisplayServer.WINDOW_MODE_WINDOWED
    )

func _on_vsync_toggled(enabled: bool) -> void:
    DisplayServer.window_set_vsync_mode(
        DisplayServer.VSYNC_ENABLED if enabled else DisplayServer.VSYNC_DISABLED
    )
