extends CanvasLayer
## Spielmenue (Doku 2.5): Mit Esc (Aktion "pause") waehrend eines Levels.
## - Continue (oder Esc): Menue zu, weiter spielen.
## - Settings: Lautstaerke (Gesamt, Effekte, Umgebung, Musik), gespeichert in
##   user://settings.cfg (Autoload Sfx).
## - Quit: Nachfrage, weil der Fortschritt seit der letzten Klonstation
##   verloren geht; Ja = zurueck zum Titelbildschirm.
## Oeffnet nur in Leveln (nicht im Titel, Intro, Ende), nicht waehrend eines
## Levelwechsels und nicht, wenn schon etwas anderes pausiert (Bedienfeld,
## Entwicklermenue). Baut sich selbst im Code; Look aus MenuStyle, Texte aus
## dialogues/menu.json.

const TEXT_FILE := "res://dialogues/menu.json"
## Einstellbare Busse in dieser Reihenfolge und ihre Text-IDs.
const VOLUME_ROWS := [["Master", "settings_master"], ["SFX", "settings_sfx"], ["Ambient", "settings_ambient"], ["Music", "settings_music"]]

## Ist das Menue offen?
var is_open := false

var _texts := {}
var _root: Control
var _main: VBoxContainer
var _settings: VBoxContainer
var _confirm: VBoxContainer
var _continue: Button
var _settings_button: Button
var _quit: Button
var _back: Button
var _yes: Button
var _no: Button
var _sliders := {}
var _value_labels := {}


func _ready() -> void:
	layer = 90
	process_mode = Node.PROCESS_MODE_ALWAYS
	_texts = _load_texts()
	_build()
	visible = false


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("pause"):
		return
	if is_open:
		close()
		get_viewport().set_input_as_handled()
	elif can_open():
		open()
		get_viewport().set_input_as_handled()


## Darf das Menue jetzt aufgehen?
func can_open() -> bool:
	var tree := get_tree()
	if tree.current_scene == null or not tree.current_scene.is_in_group("level") or tree.paused:
		return false
	var flow := get_node_or_null("/root/LevelFlow")
	return flow == null or not flow.is_changing()


func open() -> void:
	is_open = true
	visible = true
	get_tree().paused = true
	Sound.play("panel_open")
	_show_page(_main)
	_continue.grab_focus()


func close() -> void:
	if not is_open:
		return
	is_open = false
	visible = false
	get_tree().paused = false
	Sound.play("panel_close")


## Seite anzeigen (fuer Tests auch von aussen).
func show_settings() -> void:
	_show_page(_settings)
	_sliders["Master"].grab_focus()


func ask_quit() -> void:
	_show_page(_confirm)
	_no.grab_focus()


func confirm_quit() -> void:
	close()
	var flow := get_node_or_null("/root/LevelFlow")
	if flow:
		flow.go_to(flow.TITLE_SCENE)
	else:
		get_tree().change_scene_to_file("res://scenes/ui/title_screen.tscn")


func back_to_main() -> void:
	_show_page(_main)
	_continue.grab_focus()


## Aktuell sichtbare Seite: "main", "settings" oder "confirm" (fuer Tests).
func get_page() -> String:
	if _settings.visible:
		return "settings"
	if _confirm.visible:
		return "confirm"
	return "main"


func _show_page(page: Control) -> void:
	for p in [_main, _settings, _confirm]:
		p.visible = p == page
	if page == _settings:
		for bus in _sliders:
			_sliders[bus].set_value_no_signal(roundf(_sfx().get_volume(bus) * 100.0))
			_update_value_label(bus)


func _build() -> void:
	_root = Control.new()
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.theme = MenuStyle.make_theme()
	add_child(_root)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.add_child(center)
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", MenuStyle.box(MenuStyle.COLOR_PANEL, MenuStyle.COLOR_PANEL_BORDER, 2, 24))
	center.add_child(panel)
	var pages := VBoxContainer.new()
	panel.add_child(pages)

	# Hauptseite
	_main = _page(pages, _text("pause_title"))
	_continue = _button(_main, _text("pause_continue"), close)
	_settings_button = _button(_main, _text("pause_settings"), show_settings)
	_quit = _button(_main, _text("pause_quit"), ask_quit)

	# Einstellungen
	_settings = _page(pages, _text("settings_title"))
	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 16)
	grid.add_theme_constant_override("v_separation", 12)
	_settings.add_child(grid)
	for row in VOLUME_ROWS:
		var bus: String = row[0]
		var label := Label.new()
		label.text = _text(row[1])
		grid.add_child(label)
		var slider := HSlider.new()
		slider.min_value = 0
		slider.max_value = 100
		slider.step = 5
		slider.custom_minimum_size = Vector2(220, 20)
		slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		slider.focus_mode = Control.FOCUS_ALL
		slider.value_changed.connect(_on_volume_changed.bind(bus))
		grid.add_child(slider)
		_sliders[bus] = slider
		var value := Label.new()
		value.custom_minimum_size = Vector2(56, 0)
		value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		grid.add_child(value)
		_value_labels[bus] = value
	_back = _button(_settings, _text("settings_back"), back_to_main)

	# Nachfrage beim Beenden
	_confirm = _page(pages, "")
	var question := Label.new()
	question.text = _text("pause_confirm_quit")
	question.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_confirm.add_child(question)
	var answers := HBoxContainer.new()
	answers.alignment = BoxContainer.ALIGNMENT_CENTER
	answers.add_theme_constant_override("separation", 16)
	_confirm.add_child(answers)
	_yes = _button(answers, _text("menu_yes"), confirm_quit)
	_no = _button(answers, _text("menu_no"), back_to_main)
	_show_page(_main)


func _page(parent: Control, title: String) -> VBoxContainer:
	var page := VBoxContainer.new()
	page.add_theme_constant_override("separation", 12)
	parent.add_child(page)
	if title != "":
		var label := Label.new()
		label.text = title
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.add_theme_color_override("font_color", MenuStyle.COLOR_TITLE)
		label.add_theme_font_size_override("font_size", 32)
		page.add_child(label)
	return page


func _button(parent: Control, text: String, action: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(200, 0)
	button.focus_mode = Control.FOCUS_ALL
	button.mouse_entered.connect(func() -> void: Sound.play("ui_hover"))
	button.focus_entered.connect(func() -> void: Sound.play("ui_hover"))
	button.pressed.connect(func() -> void: Sound.play("ui_click"))
	button.pressed.connect(action)
	parent.add_child(button)
	return button


func _on_volume_changed(value: float, bus: String) -> void:
	_sfx().set_volume(bus, value / 100.0)
	_update_value_label(bus)
	# Hoerprobe (Effekte und Gesamt): kurzer Klick in der neuen Lautstaerke
	if bus == "SFX" or bus == "Master":
		Sound.play("knob_tick")


func _update_value_label(bus: String) -> void:
	_value_labels[bus].text = "%d %%" % roundi(_sliders[bus].value)


func _sfx() -> Node:
	return get_node("/root/Sfx")


func _text(id: String) -> String:
	return str(_texts.get(id, id))


func _load_texts() -> Dictionary:
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(TEXT_FILE))
	return data if data is Dictionary else {}
