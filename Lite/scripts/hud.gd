extends CanvasLayer

signal resume_requested
signal return_to_menu_requested

var _time_label: Label = null
var _body_label: Label = null
var _selected_label: Label = null
var _notice_label: Label = null
var _pause_panel: PanelContainer = null
var _crosshair: Label = null

func _ready() -> void:
    _build()

func _build() -> void:
    layer = 20

    var top_bar: PanelContainer = PanelContainer.new()
    top_bar.position = Vector2(22.0, 18.0)
    top_bar.custom_minimum_size = Vector2(510.0, 82.0)
    top_bar.add_theme_stylebox_override("panel", _glass_style(Color(0.008, 0.020, 0.044, 0.90), 13))
    add_child(top_bar)

    var top_margin: MarginContainer = MarginContainer.new()
    top_margin.add_theme_constant_override("margin_left", 18)
    top_margin.add_theme_constant_override("margin_right", 18)
    top_margin.add_theme_constant_override("margin_top", 12)
    top_margin.add_theme_constant_override("margin_bottom", 12)
    top_bar.add_child(top_margin)

    var top_box: VBoxContainer = VBoxContainer.new()
    top_box.add_theme_constant_override("separation", 2)
    top_margin.add_child(top_box)

    var title: Label = Label.new()
    title.text = "RAKEN SANDBOX"
    title.add_theme_font_size_override("font_size", 18)
    title.add_theme_color_override("font_color", Color(0.76, 0.93, 1.0))
    top_box.add_child(title)

    _time_label = Label.new()
    _time_label.add_theme_font_size_override("font_size", 11)
    _time_label.add_theme_color_override("font_color", Color(0.40, 0.68, 0.88))
    top_box.add_child(_time_label)

    _body_label = Label.new()
    _body_label.position = Vector2(24.0, 116.0)
    _body_label.add_theme_font_size_override("font_size", 11)
    _body_label.add_theme_color_override("font_color", Color(0.49, 0.59, 0.70))
    add_child(_body_label)

    var inspector: PanelContainer = PanelContainer.new()
    inspector.set_anchors_preset(Control.PRESET_TOP_RIGHT)
    inspector.position = Vector2(-352.0, 18.0)
    inspector.custom_minimum_size = Vector2(330.0, 248.0)
    inspector.add_theme_stylebox_override("panel", _glass_style(Color(0.008, 0.020, 0.044, 0.90), 13))
    add_child(inspector)

    var inspector_margin: MarginContainer = MarginContainer.new()
    inspector_margin.add_theme_constant_override("margin_left", 18)
    inspector_margin.add_theme_constant_override("margin_right", 18)
    inspector_margin.add_theme_constant_override("margin_top", 16)
    inspector_margin.add_theme_constant_override("margin_bottom", 16)
    inspector.add_child(inspector_margin)

    _selected_label = Label.new()
    _selected_label.text = "OBJECT INSPECTOR\n\nClick a celestial body."
    _selected_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    _selected_label.add_theme_font_size_override("font_size", 12)
    _selected_label.add_theme_color_override("font_color", Color(0.80, 0.87, 0.94))
    inspector_margin.add_child(_selected_label)

    var lower_left: PanelContainer = PanelContainer.new()
    lower_left.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
    lower_left.position = Vector2(22.0, -128.0)
    lower_left.custom_minimum_size = Vector2(520.0, 106.0)
    lower_left.add_theme_stylebox_override("panel", _glass_style(Color(0.006, 0.015, 0.032, 0.78), 12))
    add_child(lower_left)

    var help_margin: MarginContainer = MarginContainer.new()
    help_margin.add_theme_constant_override("margin_left", 16)
    help_margin.add_theme_constant_override("margin_right", 16)
    help_margin.add_theme_constant_override("margin_top", 12)
    help_margin.add_theme_constant_override("margin_bottom", 12)
    lower_left.add_child(help_margin)

    var help: Label = Label.new()
    help.text = "WASD / Q E   FREE CAMERA      SHIFT   BOOST      MOUSE   LOOK\nSPACE   PAUSE      [ ]   TIME SCALE      LEFT CLICK   INSPECT\n1   PLANET      2   STAR      3   BLACK HOLE      F5 / F9   SAVE / LOAD"
    help.add_theme_font_size_override("font_size", 10)
    help.add_theme_color_override("font_color", Color(0.45, 0.54, 0.64))
    help_margin.add_child(help)

    _crosshair = Label.new()
    _crosshair.text = "+"
    _crosshair.set_anchors_preset(Control.PRESET_CENTER)
    _crosshair.position = Vector2(-7.0, -11.0)
    _crosshair.size = Vector2(14.0, 22.0)
    _crosshair.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    _crosshair.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    _crosshair.add_theme_font_size_override("font_size", 16)
    _crosshair.add_theme_color_override("font_color", Color(0.52, 0.78, 0.96, 0.72))
    add_child(_crosshair)

    _notice_label = Label.new()
    _notice_label.set_anchors_preset(Control.PRESET_CENTER)
    _notice_label.position = Vector2(-220.0, -52.0)
    _notice_label.size = Vector2(440.0, 44.0)
    _notice_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    _notice_label.add_theme_font_size_override("font_size", 18)
    _notice_label.add_theme_color_override("font_color", Color(0.76, 0.93, 1.0))
    _notice_label.visible = false
    add_child(_notice_label)

    _build_pause_panel()

func _build_pause_panel() -> void:
    _pause_panel = PanelContainer.new()
    _pause_panel.set_anchors_preset(Control.PRESET_CENTER)
    _pause_panel.position = Vector2(-210.0, -165.0)
    _pause_panel.custom_minimum_size = Vector2(420.0, 330.0)
    _pause_panel.add_theme_stylebox_override("panel", _glass_style(Color(0.004, 0.012, 0.028, 0.985), 18))
    _pause_panel.visible = false
    add_child(_pause_panel)

    var margin: MarginContainer = MarginContainer.new()
    margin.add_theme_constant_override("margin_left", 30)
    margin.add_theme_constant_override("margin_right", 30)
    margin.add_theme_constant_override("margin_top", 28)
    margin.add_theme_constant_override("margin_bottom", 28)
    _pause_panel.add_child(margin)

    var box: VBoxContainer = VBoxContainer.new()
    box.add_theme_constant_override("separation", 14)
    margin.add_child(box)

    var title: Label = Label.new()
    title.text = "SIMULATION PAUSED"
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_theme_font_size_override("font_size", 24)
    title.add_theme_color_override("font_color", Color(0.80, 0.94, 1.0))
    box.add_child(title)

    var subtitle: Label = Label.new()
    subtitle.text = "The simulation clock is stopped."
    subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    subtitle.add_theme_font_size_override("font_size", 11)
    subtitle.add_theme_color_override("font_color", Color(0.43, 0.54, 0.66))
    box.add_child(subtitle)

    var gap: Control = Control.new()
    gap.custom_minimum_size.y = 12.0
    box.add_child(gap)

    var resume_button: Button = _pause_button("RESUME")
    resume_button.pressed.connect(Callable(self, "_on_resume"))
    box.add_child(resume_button)

    var menu_button: Button = _pause_button("RETURN TO MAIN MENU")
    menu_button.pressed.connect(Callable(self, "_on_menu"))
    box.add_child(menu_button)

func _pause_button(text_value: String) -> Button:
    var button: Button = Button.new()
    button.text = text_value
    button.custom_minimum_size.y = 52.0
    button.add_theme_font_size_override("font_size", 14)

    var normal: StyleBoxFlat = StyleBoxFlat.new()
    normal.bg_color = Color(0.020, 0.050, 0.090, 0.95)
    normal.border_color = Color(0.10, 0.38, 0.64, 0.42)
    normal.set_border_width_all(1)
    normal.set_corner_radius_all(9)

    var hover: StyleBoxFlat = normal.duplicate() as StyleBoxFlat
    hover.bg_color = Color(0.028, 0.145, 0.235, 1.0)

    button.add_theme_stylebox_override("normal", normal)
    button.add_theme_stylebox_override("hover", hover)
    return button

func _glass_style(color_value: Color, radius: int) -> StyleBoxFlat:
    var style: StyleBoxFlat = StyleBoxFlat.new()
    style.bg_color = color_value
    style.border_color = Color(0.09, 0.32, 0.54, 0.38)
    style.set_border_width_all(1)
    style.set_corner_radius_all(radius)
    return style

func update_status(time_scale: float, body_count: int, paused: bool) -> void:
    if is_instance_valid(_time_label):
        var paused_suffix: String = "   •   PAUSED" if paused else ""
        _time_label.text = "TIME  ×%s%s" % [_format_scale(time_scale), paused_suffix]

    if is_instance_valid(_body_label):
        _body_label.text = "ACTIVE BODIES  %d" % body_count

func show_selected(body: Dictionary) -> void:
    if not is_instance_valid(_selected_label):
        return

    if body.is_empty():
        _selected_label.text = "OBJECT INSPECTOR\n\nClick a celestial body."
        return

    var velocity: Vector3 = body.get("vel", Vector3.ZERO) as Vector3
    var speed: float = velocity.length()
    var display_name: String = str(body.get("name", "Body"))
    var body_type: String = str(body.get("type", "UNKNOWN"))
    var mass: float = float(body.get("mass", 0.0))
    var radius_km: float = float(body.get("radius", 0.0))
    var temperature: float = float(body.get("temp", 0.0))

    _selected_label.text = (
        "OBJECT INSPECTOR\n\n"
        + "%s\n" % display_name
        + "%s\n\n" % body_type
        + "Mass        %.3e kg\n" % mass
        + "Radius      %.3e km\n" % radius_km
        + "Speed       %.2f km/s\n" % speed
        + "Temperature %.0f K" % temperature
    )

func flash_notice(text_value: String) -> void:
    if not is_instance_valid(_notice_label):
        return

    _notice_label.text = text_value
    _notice_label.visible = true
    _notice_label.modulate.a = 0.0

    var tween: Tween = create_tween()
    tween.tween_property(_notice_label, "modulate:a", 1.0, 0.10)
    tween.tween_interval(0.65)
    tween.tween_property(_notice_label, "modulate:a", 0.0, 0.28)
    tween.finished.connect(Callable(self, "_hide_notice"))

func set_pause_menu_visible(value: bool) -> void:
    if is_instance_valid(_pause_panel):
        _pause_panel.visible = value

    if is_instance_valid(_crosshair):
        _crosshair.visible = not value

func _hide_notice() -> void:
    if is_instance_valid(_notice_label):
        _notice_label.visible = false

func _on_resume() -> void:
    resume_requested.emit()

func _on_menu() -> void:
    return_to_menu_requested.emit()

func _format_scale(value: float) -> String:
    if value >= 86400.0:
        return "%.2f days/s" % (value / 86400.0)
    if value >= 3600.0:
        return "%.2f hours/s" % (value / 3600.0)
    if value >= 60.0:
        return "%.2f min/s" % (value / 60.0)
    return "%.0f s/s" % value
