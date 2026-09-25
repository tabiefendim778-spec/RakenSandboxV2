extends CanvasLayer

signal return_to_menu_requested

var title_label: Label
var time_label: Label
var body_label: Label
var selected_label: Label
var help_label: Label
var center_notice: Label
var pause_panel: PanelContainer

func _ready() -> void:
    _build()

func _build() -> void:
    var top := PanelContainer.new()
    top.position = Vector2(22, 18)
    top.custom_minimum_size = Vector2(430, 74)
    top.add_theme_stylebox_override("panel", _glass_style())
    add_child(top)

    var margin := MarginContainer.new()
    margin.add_theme_constant_override("margin_left", 18)
    margin.add_theme_constant_override("margin_right", 18)
    margin.add_theme_constant_override("margin_top", 12)
    margin.add_theme_constant_override("margin_bottom", 12)
    top.add_child(margin)

    var top_box := VBoxContainer.new()
    margin.add_child(top_box)

    title_label = Label.new()
    title_label.text = "RAKEN SANDBOX"
    title_label.add_theme_font_size_override("font_size", 19)
    title_label.add_theme_color_override("font_color", Color(0.72, 0.91, 1.0))
    top_box.add_child(title_label)

    time_label = Label.new()
    time_label.add_theme_font_size_override("font_size", 12)
    time_label.add_theme_color_override("font_color", Color(0.48, 0.66, 0.82))
    top_box.add_child(time_label)

    body_label = Label.new()
    body_label.position = Vector2(24, 112)
    body_label.add_theme_font_size_override("font_size", 12)
    body_label.add_theme_color_override("font_color", Color(0.56, 0.64, 0.75))
    add_child(body_label)

    var inspector := PanelContainer.new()
    inspector.set_anchors_preset(Control.PRESET_TOP_RIGHT)
    inspector.position = Vector2(-330, 18)
    inspector.custom_minimum_size = Vector2(308, 212)
    inspector.add_theme_stylebox_override("panel", _glass_style())
    add_child(inspector)

    var inspect_margin := MarginContainer.new()
    inspect_margin.add_theme_constant_override("margin_left", 18)
    inspect_margin.add_theme_constant_override("margin_right", 18)
    inspect_margin.add_theme_constant_override("margin_top", 16)
    inspect_margin.add_theme_constant_override("margin_bottom", 16)
    inspector.add_child(inspect_margin)

    selected_label = Label.new()
    selected_label.text = "OBJECT INSPECTOR\n\nClick a celestial body to inspect it."
    selected_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    selected_label.add_theme_font_size_override("font_size", 13)
    selected_label.add_theme_color_override("font_color", Color(0.82, 0.88, 0.95))
    inspect_margin.add_child(selected_label)

    help_label = Label.new()
    help_label.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
    help_label.position = Vector2(24, -106)
    help_label.text = "WASD / Q E  Fly     Mouse  Look     Shift  Boost\nSpace  Pause     [ ]  Time     1 Planet  2 Star  3 Black Hole\nLeft Click  Inspect     Esc  Menu"
    help_label.add_theme_font_size_override("font_size", 11)
    help_label.add_theme_color_override("font_color", Color(0.48, 0.57, 0.68))
    add_child(help_label)

    center_notice = Label.new()
    center_notice.set_anchors_preset(Control.PRESET_CENTER)
    center_notice.position = Vector2(-180, -24)
    center_notice.size = Vector2(360, 48)
    center_notice.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    center_notice.add_theme_font_size_override("font_size", 22)
    center_notice.add_theme_color_override("font_color", Color(0.76, 0.93, 1.0))
    center_notice.visible = false
    add_child(center_notice)

    _build_pause_panel()

func _build_pause_panel() -> void:
    pause_panel = PanelContainer.new()
    pause_panel.set_anchors_preset(Control.PRESET_CENTER)
    pause_panel.position = Vector2(-190, -140)
    pause_panel.custom_minimum_size = Vector2(380, 280)
    pause_panel.add_theme_stylebox_override("panel", _glass_style(Color(0.008, 0.016, 0.036, 0.97)))
    pause_panel.visible = false
    add_child(pause_panel)

    var margin := MarginContainer.new()
    margin.add_theme_constant_override("margin_left", 28)
    margin.add_theme_constant_override("margin_right", 28)
    margin.add_theme_constant_override("margin_top", 24)
    margin.add_theme_constant_override("margin_bottom", 24)
    pause_panel.add_child(margin)

    var box := VBoxContainer.new()
    box.add_theme_constant_override("separation", 14)
    margin.add_child(box)

    var title := Label.new()
    title.text = "SIMULATION PAUSED"
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_theme_font_size_override("font_size", 24)
    title.add_theme_color_override("font_color", Color(0.76, 0.92, 1.0))
    box.add_child(title)

    var resume := _small_button("RESUME")
    resume.pressed.connect(func() -> void:
        pause_panel.visible = false
    )
    box.add_child(resume)

    var menu := _small_button("RETURN TO MAIN MENU")
    menu.pressed.connect(func() -> void:
        return_to_menu_requested.emit()
    )
    box.add_child(menu)

func _small_button(text_value: String) -> Button:
    var button := Button.new()
    button.text = text_value
    button.custom_minimum_size.y = 48
    button.add_theme_font_size_override("font_size", 14)
    var normal := StyleBoxFlat.new()
    normal.bg_color = Color(0.025, 0.07, 0.12, 0.92)
    normal.border_color = Color(0.10, 0.42, 0.70, 0.4)
    normal.set_border_width_all(1)
    normal.set_corner_radius_all(8)
    var hover := normal.duplicate()
    hover.bg_color = Color(0.04, 0.18, 0.28, 0.98)
    button.add_theme_stylebox_override("normal", normal)
    button.add_theme_stylebox_override("hover", hover)
    return button

func _glass_style(color_value: Color = Color(0.012, 0.026, 0.052, 0.88)) -> StyleBoxFlat:
    var style := StyleBoxFlat.new()
    style.bg_color = color_value
    style.border_color = Color(0.10, 0.34, 0.58, 0.36)
    style.set_border_width_all(1)
    style.set_corner_radius_all(12)
    return style

func update_status(time_scale: float, body_count: int, paused: bool) -> void:
    time_label.text = "TIME SCALE  ×%s%s" % [_format_scale(time_scale), "   •   PAUSED" if paused else ""]
    body_label.text = "ACTIVE BODIES  %d" % body_count

func show_selected(body: Dictionary) -> void:
    if body.is_empty():
        selected_label.text = "OBJECT INSPECTOR\n\nClick a celestial body to inspect it."
        return

    var speed: float = (body["vel"] as Vector3).length()
    selected_label.text = (
        "OBJECT INSPECTOR\n\n"
        + "%s\n" % body["name"]
        + "%s\n\n" % body["type"]
        + "Mass     %.3e kg\n" % body["mass"]
        + "Radius   %.3e km\n" % body["radius"]
        + "Speed    %.2f km/s\n" % speed
        + "Temp     %.0f K" % body["temp"]
    )

func flash_notice(text_value: String) -> void:
    center_notice.text = text_value
    center_notice.modulate.a = 0.0
    center_notice.visible = true
    var tween := create_tween()
    tween.tween_property(center_notice, "modulate:a", 1.0, 0.12)
    tween.tween_interval(0.75)
    tween.tween_property(center_notice, "modulate:a", 0.0, 0.35)
    tween.finished.connect(func() -> void:
        center_notice.visible = false
    )

func set_pause_menu_visible(value: bool) -> void:
    pause_panel.visible = value

func _format_scale(value: float) -> String:
    if value >= 86400.0:
        return "%.2f days/s" % (value / 86400.0)
    if value >= 3600.0:
        return "%.2f hours/s" % (value / 3600.0)
    return "%.0f s/s" % value
