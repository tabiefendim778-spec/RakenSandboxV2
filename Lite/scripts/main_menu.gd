extends Control

signal start_requested
signal quality_changed(level: int)
signal quit_requested

var _settings_panel: PanelContainer = null
var _quality_option: OptionButton = null

func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    _build_background()
    _build_interface()

func _build_background() -> void:
    var background: ColorRect = ColorRect.new()
    background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    var material: ShaderMaterial = ShaderMaterial.new()
    material.shader = load("res://shaders/menu_space.gdshader") as Shader
    background.material = material
    add_child(background)

    var shade: ColorRect = ColorRect.new()
    shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    shade.color = Color(0.0, 0.0, 0.02, 0.10)
    shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(shade)

func _build_interface() -> void:
    var safe: MarginContainer = MarginContainer.new()
    safe.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    safe.add_theme_constant_override("margin_left", 76)
    safe.add_theme_constant_override("margin_right", 76)
    safe.add_theme_constant_override("margin_top", 54)
    safe.add_theme_constant_override("margin_bottom", 42)
    add_child(safe)

    var layout: VBoxContainer = VBoxContainer.new()
    layout.add_theme_constant_override("separation", 10)
    safe.add_child(layout)

    var top_row: HBoxContainer = HBoxContainer.new()
    layout.add_child(top_row)

    var brand_box: VBoxContainer = VBoxContainer.new()
    brand_box.add_theme_constant_override("separation", -3)
    top_row.add_child(brand_box)

    var brand: Label = Label.new()
    brand.text = "RAKEN"
    brand.add_theme_font_size_override("font_size", 68)
    brand.add_theme_color_override("font_color", Color(0.82, 0.95, 1.0))
    brand.add_theme_constant_override("outline_size", 6)
    brand.add_theme_color_override("font_outline_color", Color(0.02, 0.16, 0.27, 0.42))
    brand_box.add_child(brand)

    var subtitle: Label = Label.new()
    subtitle.text = "SANDBOX  /  CELESTIAL SIMULATION"
    subtitle.add_theme_font_size_override("font_size", 13)
    subtitle.add_theme_color_override("font_color", Color(0.26, 0.71, 1.0))
    brand_box.add_child(subtitle)

    var top_spacer: Control = Control.new()
    top_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    top_row.add_child(top_spacer)

    var build_chip: PanelContainer = PanelContainer.new()
    build_chip.custom_minimum_size = Vector2(210.0, 44.0)
    build_chip.add_theme_stylebox_override("panel", _panel_style(Color(0.010, 0.025, 0.050, 0.76), 10))
    top_row.add_child(build_chip)

    var chip_label: Label = Label.new()
    chip_label.text = "RAKEN  /  LITE CORE"
    chip_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    chip_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    chip_label.add_theme_font_size_override("font_size", 11)
    chip_label.add_theme_color_override("font_color", Color(0.54, 0.70, 0.84))
    build_chip.add_child(chip_label)

    var vertical_spacer: Control = Control.new()
    vertical_spacer.custom_minimum_size.y = 40.0
    layout.add_child(vertical_spacer)

    var content_row: HBoxContainer = HBoxContainer.new()
    content_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
    layout.add_child(content_row)

    var menu_panel: PanelContainer = PanelContainer.new()
    menu_panel.custom_minimum_size = Vector2(420.0, 400.0)
    menu_panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    menu_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.008, 0.020, 0.043, 0.91), 16))
    content_row.add_child(menu_panel)

    var menu_margin: MarginContainer = MarginContainer.new()
    menu_margin.add_theme_constant_override("margin_left", 28)
    menu_margin.add_theme_constant_override("margin_right", 28)
    menu_margin.add_theme_constant_override("margin_top", 28)
    menu_margin.add_theme_constant_override("margin_bottom", 28)
    menu_panel.add_child(menu_margin)

    var menu_box: VBoxContainer = VBoxContainer.new()
    menu_box.add_theme_constant_override("separation", 13)
    menu_margin.add_child(menu_box)

    var section: Label = Label.new()
    section.text = "SIMULATION"
    section.add_theme_font_size_override("font_size", 11)
    section.add_theme_color_override("font_color", Color(0.46, 0.62, 0.79))
    menu_box.add_child(section)

    var description: Label = Label.new()
    description.text = "Build systems. Bend orbits. Create worlds."
    description.add_theme_font_size_override("font_size", 16)
    description.add_theme_color_override("font_color", Color(0.77, 0.84, 0.91))
    menu_box.add_child(description)

    var small_gap: Control = Control.new()
    small_gap.custom_minimum_size.y = 8.0
    menu_box.add_child(small_gap)

    menu_box.add_child(_menu_button("NEW SANDBOX", Callable(self, "_on_start"), true))
    menu_box.add_child(_menu_button("SETTINGS", Callable(self, "_open_settings"), false))
    menu_box.add_child(_menu_button("QUIT", Callable(self, "_on_quit"), false))

    var info_spacer: Control = Control.new()
    info_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
    menu_box.add_child(info_spacer)

    var hint: Label = Label.new()
    hint.text = "Optimized for integrated graphics\nwithout removing the simulation core."
    hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    hint.add_theme_font_size_override("font_size", 11)
    hint.add_theme_color_override("font_color", Color(0.39, 0.47, 0.57))
    menu_box.add_child(hint)

    var content_spacer: Control = Control.new()
    content_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    content_row.add_child(content_spacer)

    var footer: HBoxContainer = HBoxContainer.new()
    layout.add_child(footer)

    var footer_left: Label = Label.new()
    footer_left.text = "N-BODY GRAVITY  •  PROCEDURAL WORLDS  •  BLACK HOLES"
    footer_left.add_theme_font_size_override("font_size", 10)
    footer_left.add_theme_color_override("font_color", Color(0.34, 0.43, 0.54))
    footer.add_child(footer_left)

    var footer_spacer: Control = Control.new()
    footer_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    footer.add_child(footer_spacer)

    var footer_right: Label = Label.new()
    footer_right.text = "GODOT 4.7  /  COMPATIBILITY"
    footer_right.add_theme_font_size_override("font_size", 10)
    footer_right.add_theme_color_override("font_color", Color(0.34, 0.43, 0.54))
    footer.add_child(footer_right)

    _build_settings_panel()

func _menu_button(text_value: String, callback: Callable, primary: bool) -> Button:
    var button: Button = Button.new()
    button.text = text_value
    button.alignment = HORIZONTAL_ALIGNMENT_LEFT
    button.custom_minimum_size = Vector2(360.0, 62.0)
    button.add_theme_font_size_override("font_size", 16)
    button.add_theme_color_override("font_color", Color(0.80, 0.88, 0.96))
    button.add_theme_color_override("font_hover_color", Color.WHITE)

    var normal_color: Color = Color(0.020, 0.065, 0.115, 0.88) if primary else Color(0.018, 0.038, 0.070, 0.80)
    var hover_color: Color = Color(0.030, 0.190, 0.320, 0.97) if primary else Color(0.025, 0.115, 0.190, 0.94)

    button.add_theme_stylebox_override("normal", _button_style(normal_color))
    button.add_theme_stylebox_override("hover", _button_style(hover_color))
    button.add_theme_stylebox_override("pressed", _button_style(Color(0.020, 0.110, 0.185, 1.0)))
    button.pressed.connect(callback)
    return button

func _build_settings_panel() -> void:
    _settings_panel = PanelContainer.new()
    _settings_panel.set_anchors_preset(Control.PRESET_CENTER)
    _settings_panel.position = Vector2(-235.0, -215.0)
    _settings_panel.custom_minimum_size = Vector2(470.0, 430.0)
    _settings_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.006, 0.017, 0.038, 0.985), 18))
    _settings_panel.visible = false
    add_child(_settings_panel)

    var margin: MarginContainer = MarginContainer.new()
    margin.add_theme_constant_override("margin_left", 30)
    margin.add_theme_constant_override("margin_right", 30)
    margin.add_theme_constant_override("margin_top", 28)
    margin.add_theme_constant_override("margin_bottom", 28)
    _settings_panel.add_child(margin)

    var box: VBoxContainer = VBoxContainer.new()
    box.add_theme_constant_override("separation", 15)
    margin.add_child(box)

    var title: Label = Label.new()
    title.text = "SETTINGS"
    title.add_theme_font_size_override("font_size", 28)
    title.add_theme_color_override("font_color", Color(0.80, 0.94, 1.0))
    box.add_child(title)

    var separator: HSeparator = HSeparator.new()
    box.add_child(separator)

    var quality_label: Label = Label.new()
    quality_label.text = "GRAPHICS QUALITY"
    quality_label.add_theme_font_size_override("font_size", 11)
    quality_label.add_theme_color_override("font_color", Color(0.45, 0.61, 0.78))
    box.add_child(quality_label)

    _quality_option = OptionButton.new()
    _quality_option.add_item("COMPATIBILITY  /  Intel HD")
    _quality_option.add_item("BALANCED")
    _quality_option.add_item("HIGH")
    _quality_option.selected = 1
    _quality_option.item_selected.connect(Callable(self, "_on_quality_selected"))
    box.add_child(_quality_option)

    var fullscreen: CheckButton = CheckButton.new()
    fullscreen.text = "FULLSCREEN"
    fullscreen.toggled.connect(Callable(self, "_on_fullscreen_toggled"))
    box.add_child(fullscreen)

    var vsync: CheckButton = CheckButton.new()
    vsync.text = "V-SYNC"
    vsync.button_pressed = true
    vsync.toggled.connect(Callable(self, "_on_vsync_toggled"))
    box.add_child(vsync)

    var info: Label = Label.new()
    info.text = "Compatibility keeps atmosphere, procedural planets and black holes while reducing geometry and shadow cost."
    info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    info.add_theme_font_size_override("font_size", 11)
    info.add_theme_color_override("font_color", Color(0.43, 0.51, 0.61))
    box.add_child(info)

    var stretch: Control = Control.new()
    stretch.size_flags_vertical = Control.SIZE_EXPAND_FILL
    box.add_child(stretch)

    box.add_child(_menu_button("BACK", Callable(self, "_close_settings"), false))

func _panel_style(color_value: Color, radius: int) -> StyleBoxFlat:
    var style: StyleBoxFlat = StyleBoxFlat.new()
    style.bg_color = color_value
    style.border_color = Color(0.10, 0.34, 0.57, 0.42)
    style.set_border_width_all(1)
    style.set_corner_radius_all(radius)
    return style

func _button_style(color_value: Color) -> StyleBoxFlat:
    var style: StyleBoxFlat = StyleBoxFlat.new()
    style.bg_color = color_value
    style.border_color = Color(0.10, 0.42, 0.70, 0.42)
    style.set_border_width_all(1)
    style.set_corner_radius_all(10)
    style.content_margin_left = 20.0
    return style

func _on_start() -> void:
    start_requested.emit()

func _on_quit() -> void:
    quit_requested.emit()

func _open_settings() -> void:
    if not is_instance_valid(_settings_panel):
        return
    _settings_panel.visible = true
    _settings_panel.modulate.a = 0.0
    var tween: Tween = create_tween()
    tween.tween_property(_settings_panel, "modulate:a", 1.0, 0.16)

func _close_settings() -> void:
    if not is_instance_valid(_settings_panel):
        return
    var tween: Tween = create_tween()
    tween.tween_property(_settings_panel, "modulate:a", 0.0, 0.14)
    await tween.finished
    _settings_panel.visible = false

func _on_quality_selected(index: int) -> void:
    quality_changed.emit(index)

func _on_fullscreen_toggled(enabled: bool) -> void:
    if enabled:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
    else:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_vsync_toggled(enabled: bool) -> void:
    if enabled:
        DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
    else:
        DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
